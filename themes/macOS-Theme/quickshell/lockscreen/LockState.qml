import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Services.UPower

QtObject {
    id: lockState

    property string home: Quickshell.env("HOME") || "/home/facuud2"
    property string wallpaperPath: "file://" + home + "/.config/hypr/current_wallpaper.png"

    // ── Authentication State ──
    property bool authenticating: false
    property bool authFailed: false
    property string statusText: ""

    // ── System / Network / Bluetooth State ──
    property string netIcon: "󰖩"
    property string btIcon: "󰂲"
    property string kbLayout: "ES"

    // ── Battery State ──
    readonly property bool isLaptopBattery: UPower.displayDevice.ready ? UPower.displayDevice.isLaptopBattery : false
    readonly property int batPercent: UPower.displayDevice.ready ? Math.round(UPower.displayDevice.percentage * 100) : 100
    readonly property bool isCharging: UPower.displayDevice.ready && (UPower.displayDevice.state === UPowerDeviceState.Charging || UPower.displayDevice.state === UPowerDeviceState.FullyCharged)
    readonly property string batIcon: isCharging ? "󰂄" : (batPercent > 80 ? "" : (batPercent > 50 ? "" : (batPercent > 20 ? "" : "")))

    // ── Media / Player State ──
    property bool mediaActive: false
    property bool isPlaying: false
    property string trackTitle: "Apple Music"
    property string trackArtist: "No playback active"
    property string artUrl: ""
    property string timeProgress: "--:-- / --:--"
    property real artTimestamp: Date.now()

    // ── Signal to close lockscreen on success ──
    signal unlockSuccess()

    // ── PAM Context ──
    property PamContext pam: PamContext {
        id: pamContext

        onCompleted: (result) => {
            lockState.authenticating = false;
            if (result === PamResult.Success) {
                lockState.authFailed = false;
                lockState.unlockSuccess();
            } else {
                lockState.authFailed = true;
                lockState.statusText = "Contraseña Incorrecta";
                pamRestartTimer.restart();
            }
        }
    }

    Timer {
        id: pamRestartTimer
        interval: 400
        repeat: false
        onTriggered: {
            pamContext.start();
        }
    }

    function initPam() {
        authenticating = false;
        authFailed = false;
        statusText = "";
        pamContext.start();
    }

    function submitPassword(pwd) {
        if (authenticating) return;
        authenticating = true;
        authFailed = false;
        pamContext.respond(pwd);
    }

    // ── Status Poller (Network & Bluetooth) ──
    Process {
        id: statusPoller
        command: [
            "bash",
            "-c",
            "net='󰖩'; if command -v nmcli >/dev/null 2>&1; then act=$(nmcli -t -f TYPE,STATE dev 2>/dev/null | grep -E 'wifi:connected|ethernet:connected' | head -n1); if [[ \"$act\" == *'ethernet'* ]]; then net='󰈀'; elif [[ \"$act\" == *'wifi'* ]]; then net='󰖩'; else net='󰖪'; fi; fi; bt='󰂲'; if command -v bluetoothctl >/dev/null 2>&1; then if bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then if bluetoothctl info 2>/dev/null | grep -q 'Device'; then bt='󰂯'; else bt='󰂰'; fi; fi; fi; echo \"$net|$bt\""
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                let parts = this.text.trim().split("|");
                if (parts.length === 2) {
                    lockState.netIcon = parts[0];
                    lockState.btIcon = parts[1];
                }
            }
        }
    }

    // ── Media Poller (Metadata & Exact Time via lock_media.sh) ──
    Process {
        id: mediaPoller
        command: [
            "bash",
            "-c",
            home + "/.config/hypr/scripts/lock_media.sh json"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                let raw = this.text.trim();
                if (raw.startsWith("{")) {
                    try {
                        let data = JSON.parse(raw);
                        let prevTitle = lockState.trackTitle;
                        lockState.mediaActive = data.active;
                        lockState.isPlaying = data.isPlaying;
                        lockState.trackTitle = data.title;
                        lockState.trackArtist = data.artist;
                        lockState.timeProgress = data.timeProgress;

                        if (prevTitle !== data.title || lockState.artUrl === "") {
                            artPoller.running = false;
                            artPoller.running = true;
                        }
                    } catch(e) {}
                }
            }
        }
    }

    Process {
        id: artPoller
        command: [
            "bash",
            "-c",
            home + "/.config/hypr/scripts/lock_media.sh art"
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                let p = this.text.trim();
                if (p !== "") {
                    lockState.artTimestamp = Date.now();
                    lockState.artUrl = "file://" + p + "?t=" + lockState.artTimestamp;
                }
            }
        }
    }

    Timer {
        interval: 600
        running: true
        repeat: true
        onTriggered: {
            if (!mediaPoller.running) mediaPoller.running = true;
        }
    }

    Timer {
        interval: 3500
        running: true
        repeat: true
        onTriggered: {
            if (!statusPoller.running) statusPoller.running = true;
        }
    }

    // ── Media Playback Actions ──
    function togglePlay() {
        Quickshell.execDetached(["playerctl", "play-pause"]);
        mediaPoller.running = false;
        mediaPoller.running = true;
    }

    function previousTrack() {
        Quickshell.execDetached(["playerctl", "previous"]);
        mediaPoller.running = false;
        mediaPoller.running = true;
    }

    function nextTrack() {
        Quickshell.execDetached(["playerctl", "next"]);
        mediaPoller.running = false;
        mediaPoller.running = true;
    }

    // ── Power Actions ──
    function suspend() {
        Quickshell.execDetached(["systemctl", "suspend"]);
    }

    function reboot() {
        Quickshell.execDetached(["systemctl", "reboot"]);
    }

    function poweroff() {
        Quickshell.execDetached(["systemctl", "poweroff"]);
    }

    Component.onCompleted: {
        initPam();
        statusPoller.running = true;
        mediaPoller.running = true;
        artPoller.running = true;
    }
}
