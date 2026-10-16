#include "linuxdragshakedetector.h"

#include "loghelpers.h"

#include <cerrno>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <dirent.h>
#include <fcntl.h>
#include <poll.h>
#include <unistd.h>
#include <linux/input.h>

#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>

#include <sys/socket.h>
#include <sys/un.h>
#include <string>

namespace {
constexpr int kPollTimeoutMs = 100;
constexpr int kMaxAbsDelta = 50;

bool has_bit(unsigned long *bits, int nr)
{
    return bits[nr / (8 * sizeof(unsigned long))] &
           (1UL << (nr % (8 * sizeof(unsigned long))));
}

bool isHyprlandFullscreen()
{
    const char *his = std::getenv("HYPRLAND_INSTANCE_SIGNATURE");
    if (!his || his[0] == '\0') {
        return false;
    }

    const char *xrd = std::getenv("XDG_RUNTIME_DIR");
    std::string sockPath;
    if (xrd && xrd[0] != '\0') {
        sockPath = std::string(xrd) + "/hypr/" + his + "/.socket.sock";
    } else {
        sockPath = "/run/user/" + std::to_string(getuid()) + "/hypr/" + his + "/.socket.sock";
    }

    auto querySocket = [&](const char *cmd) -> QByteArray {
        int s = ::socket(AF_UNIX, SOCK_STREAM, 0);
        if (s < 0)
            return {};

        struct timeval tv;
        tv.tv_sec = 0;
        tv.tv_usec = 40000; // 40ms timeout
        setsockopt(s, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));
        setsockopt(s, SOL_SOCKET, SO_SNDTIMEO, &tv, sizeof(tv));

        struct sockaddr_un addr;
        std::memset(&addr, 0, sizeof(addr));
        addr.sun_family = AF_UNIX;
        std::strncpy(addr.sun_path, sockPath.c_str(), sizeof(addr.sun_path) - 1);

        if (::connect(s, (struct sockaddr *)&addr, sizeof(addr)) != 0) {
            ::close(s);
            return {};
        }

        if (::write(s, cmd, std::strlen(cmd)) <= 0) {
            ::close(s);
            return {};
        }

        QByteArray response;
        char buf[2048];
        while (true) {
            ssize_t n = ::read(s, buf, sizeof(buf));
            if (n <= 0)
                break;
            response.append(buf, n);
            if (response.size() > 16384)
                break;
        }
        ::close(s);
        return response;
    };

    // 1. Check active window fullscreen state
    QByteArray winData = querySocket("j/activewindow");
    if (!winData.isEmpty()) {
        QJsonDocument doc = QJsonDocument::fromJson(winData);
        if (doc.isObject()) {
            QJsonObject obj = doc.object();
            int fullscreen = obj.value("fullscreen").toInt(0);
            int fullscreenClient = obj.value("fullscreenClient").toInt(0);
            if (fullscreen > 0 || fullscreenClient > 0) {
                return true;
            }
        }
    }

    // 2. Check active workspace fullscreen state (covers games capturing focus or mouse grab)
    QByteArray wsData = querySocket("j/activeworkspace");
    if (!wsData.isEmpty()) {
        QJsonDocument doc = QJsonDocument::fromJson(wsData);
        if (doc.isObject()) {
            QJsonObject obj = doc.object();
            if (obj.value("hasfullscreen").toBool(false)) {
                return true;
            }
        }
    }

    return false;
}
}

LinuxDragShakeDetector::LinuxDragShakeDetector(QObject *parent)
    : QObject(parent)
{
    scanDevices();
    running = true;
    worker = std::thread(&LinuxDragShakeDetector::workerLoop, this);
}

LinuxDragShakeDetector::~LinuxDragShakeDetector()
{
    running = false;
    if (worker.joinable())
        worker.join();
    for (int fd : fds) {
        if (fd >= 0)
            ::close(fd);
    }
}

void LinuxDragShakeDetector::scanDevices()
{
    Logger &log = Logger::instance();
    log.push("scanDevices");

    DIR *dir = opendir("/dev/input");
    if (!dir) {
        qWarning() << "Failed to open /dev/input (shake detection disabled)";
        log.pop();
        return;
    }

    log.log() << "REL devices advertising REL_X:";
    struct dirent *ent;
    while ((ent = readdir(dir)) != nullptr) {
        if (strncmp(ent->d_name, "event", 5) != 0)
            continue;

        char path[64];
        snprintf(path, sizeof(path), "/dev/input/%s", ent->d_name);

        int probe = ::open(path, O_RDONLY);
        if (probe < 0)
            continue;

        unsigned long evbits[EV_MAX / (8 * sizeof(unsigned long)) + 1] = {};
        if (ioctl(probe, EVIOCGBIT(0, sizeof(evbits)), evbits) < 0) {
            ::close(probe);
            continue;
        }

        bool relX = false;
        if (has_bit(evbits, EV_REL)) {
            unsigned long relbits[REL_MAX / (8 * sizeof(unsigned long)) + 1] = {};
            if (ioctl(probe, EVIOCGBIT(EV_REL, sizeof(relbits)), relbits) >= 0)
                relX = has_bit(relbits, REL_X);
        }

        bool absX = false;
        bool absMtX = false;
        if (has_bit(evbits, EV_ABS)) {
            unsigned long absbits[ABS_MAX / (8 * sizeof(unsigned long)) + 1] = {};
            if (ioctl(probe, EVIOCGBIT(EV_ABS, sizeof(absbits)), absbits) >= 0) {
                absX = has_bit(absbits, ABS_X);
                absMtX = has_bit(absbits, ABS_MT_POSITION_X);
            }
        }

        if (relX || absX || absMtX) {
            log.log() << path << (relX ? "rel" : "")
                      << (absMtX ? "mt" : (absX ? "abs" : ""));
            fds.push_back(probe);
        } else {
            ::close(probe);
        }
    }

    closedir(dir);

    if (fds.empty()) {
        qWarning() << "No accessible input device with REL_X or ABS_X found in /dev/input; shake detection disabled";
        log.pop();
        return;
    }

    log.pop();
}

void LinuxDragShakeDetector::workerLoop()
{
    if (fds.empty())
        return;

    Logger &log = Logger::instance();
    log.push("workerLoop");

    std::vector<struct pollfd> pfds(fds.size());
    for (size_t i = 0; i < fds.size(); ++i) {
        pfds[i].fd = fds[i];
        pfds[i].events = POLLIN;
    }

    struct input_event buffer[64];

    while (running) {
        int n = poll(pfds.data(), pfds.size(), kPollTimeoutMs);
        if (n < 0) {
            if (errno == EINTR)
                continue;
            log.log() << "poll failed:" << strerror(errno);
            break;
        }
        if (n == 0)
            continue;

        for (size_t i = 0; i < pfds.size(); ++i) {
            if (!(pfds[i].revents & POLLIN))
                continue;

            ssize_t bytes = ::read(pfds[i].fd, buffer, sizeof(buffer));
            if (bytes <= 0) {
                log.log() << "failed to read input events from fd" << pfds[i].fd;
                continue;
            }

            size_t count = (size_t)bytes / sizeof(struct input_event);
            for (size_t j = 0; j < count; ++j) {
                const struct input_event &ev = buffer[j];

                if (ev.type == EV_KEY && ev.code == BTN_LEFT) {
                    if (ev.value == 1) {
                        leftPressed = true;
                        hasAbs = false;
                    } else if (ev.value == 0) {
                        leftPressed = false;
                        hasAbs = false;
                        detector.reset();
                    }
                    continue;
                }

                AxisMode evMode = AxisMode::None;
                if (ev.type == EV_REL && ev.code == REL_X)
                    evMode = AxisMode::Rel;
                else if (ev.type == EV_ABS && ev.code == ABS_MT_POSITION_X)
                    evMode = AxisMode::AbsMt;
                else if (ev.type == EV_ABS && ev.code == ABS_X &&
                         mode != AxisMode::AbsMt)
                    evMode = AxisMode::AbsX;

                if (evMode == AxisMode::None)
                    continue;

                if (evMode != mode) {
                    mode = evMode;
                    hasAbs = false;
                    detector.reset();
                }

                int dx = ev.value;
                if (mode == AxisMode::AbsX || mode == AxisMode::AbsMt) {
                    if (!hasAbs) {
                        lastAbs = ev.value;
                        hasAbs = true;
                        continue;
                    }
                    dx = ev.value - lastAbs;
                    lastAbs = ev.value;
                }

                if (std::abs(dx) > kMaxAbsDelta) {
                    detector.reset();
                    continue;
                }

                if (leftPressed && detector.feed(dx)) {
                    if (isHyprlandFullscreen()) {
                        log.log() << "Shake ignored: fullscreen active";
                        detector.reset();
                        continue;
                    }
                    emit shakeDetected();
                }
            }
        }
    }

    log.pop();
}
