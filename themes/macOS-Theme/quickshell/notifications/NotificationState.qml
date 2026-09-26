import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Item {
    id: root

    // ── Theme Mode (macOS Light & Dark) ──
    property bool isDarkTheme: true

    // Frosted Glass & Liquid Acrylic Palette (macOS 27 / Sequoia Style)
    readonly property color cardBg: isDarkTheme 
        ? Qt.rgba(0.12, 0.13, 0.17, 0.88) 
        : Qt.rgba(0.96, 0.97, 0.99, 0.90)

    readonly property color cardBorder: isDarkTheme 
        ? Qt.rgba(1.0, 1.0, 1.0, 0.16) 
        : Qt.rgba(0.0, 0.0, 0.0, 0.12)

    readonly property color cardShadow: isDarkTheme 
        ? Qt.rgba(0.0, 0.0, 0.0, 0.50) 
        : Qt.rgba(0.0, 0.0, 0.0, 0.18)

    readonly property color textColor: isDarkTheme ? "#FFFFFF" : "#1D1D1F"
    readonly property color textDimColor: isDarkTheme ? Qt.rgba(1.0, 1.0, 1.0, 0.65) : Qt.rgba(0.11, 0.11, 0.12, 0.65)
    readonly property color textSubtleColor: isDarkTheme ? Qt.rgba(1.0, 1.0, 1.0, 0.45) : Qt.rgba(0.11, 0.11, 0.12, 0.45)

    readonly property color timeSensitiveColor: isDarkTheme ? "#FF453A" : "#D70015"
    readonly property color accentColor: "#007AFF"

    // Action button & Dropdown menu styling
    readonly property color buttonBg: isDarkTheme ? Qt.rgba(1.0, 1.0, 1.0, 0.12) : Qt.rgba(0.0, 0.0, 0.0, 0.08)
    readonly property color buttonHoverBg: isDarkTheme ? Qt.rgba(1.0, 1.0, 1.0, 0.22) : Qt.rgba(0.0, 0.0, 0.0, 0.15)
    readonly property color buttonBorder: isDarkTheme ? Qt.rgba(1.0, 1.0, 1.0, 0.10) : Qt.rgba(0.0, 0.0, 0.0, 0.08)

    readonly property color menuBg: isDarkTheme ? Qt.rgba(0.14, 0.15, 0.19, 0.96) : Qt.rgba(0.98, 0.98, 1.0, 0.96)
    readonly property color menuBorder: isDarkTheme ? Qt.rgba(1.0, 1.0, 1.0, 0.20) : Qt.rgba(0.0, 0.0, 0.0, 0.14)
    readonly property color menuItemHover: "#007AFF"
    readonly property color menuSeparator: isDarkTheme ? Qt.rgba(1.0, 1.0, 1.0, 0.10) : Qt.rgba(0.0, 0.0, 0.0, 0.08)

    // Close button (x) styling
    readonly property color closeBtnBg: isDarkTheme ? Qt.rgba(0.20, 0.20, 0.25, 0.90) : Qt.rgba(0.88, 0.88, 0.90, 0.90)
    readonly property color closeBtnHoverBg: isDarkTheme ? Qt.rgba(0.35, 0.35, 0.40, 0.95) : Qt.rgba(0.75, 0.75, 0.80, 0.95)
    readonly property color closeBtnIcon: isDarkTheme ? "#FFFFFF" : "#1D1D1F"

    // Active notifications model list
    property var activeList: []
    property int nextId: 1

    // Sound effect on arrival
    property bool soundEnabled: true

    // DND mode sync
    property bool dndEnabled: false

    // Initialize theme detection
    Process {
        id: themeProc
        running: true
        command: ["bash", "-c", "if [ -f $HOME/.config/lunita/color_scheme ]; then cat $HOME/.config/lunita/color_scheme; else gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || echo 'prefer-dark'; fi"]
        stdout: SplitParser {
            onRead: data => {
                var str = data.trim().toLowerCase();
                root.isDarkTheme = (str.indexOf("light") === -1);
            }
        }
    }

    Timer {
        id: themePollTimer
        interval: 3000
        running: true
        repeat: true
        onTriggered: themeProc.running = true
    }

    // ── Smart Icon Resolver ──
    function resolveIcon(appName, appIcon, image) {
        var baseDir = Quickshell.env("HOME") + "/.config/quickshell/notifications/assets/";
        
        // 1. Direct image or custom icon path
        if (image && image.length > 0) {
            if (image.indexOf("://") !== -1 || image.startsWith("/")) {
                return image;
            }
        }
        if (appIcon && appIcon.length > 0) {
            if (appIcon.indexOf("://") !== -1 || appIcon.startsWith("/")) {
                return appIcon;
            }
        }

        var app = (appName || "").toLowerCase();
        var icon = (appIcon || "").toLowerCase();

        // 2. Specific macOS built-in App icons
        if (app.indexOf("reminder") !== -1 || icon.indexOf("reminder") !== -1) return baseDir + "reminders.svg";
        if (app.indexOf("message") !== -1 || app.indexOf("telegram") !== -1 || app.indexOf("discord") !== -1 || app.indexOf("vesktop") !== -1 || icon.indexOf("message") !== -1) return baseDir + "messages.svg";
        if (app.indexOf("facetime") !== -1 || icon.indexOf("facetime") !== -1 || icon.indexOf("camera") !== -1) return baseDir + "facetime.svg";
        if (app.indexOf("calendar") !== -1 || icon.indexOf("calendar") !== -1 || app.indexOf("event") !== -1) return baseDir + "calendar.svg";
        if (app.indexOf("mail") !== -1 || icon.indexOf("mail") !== -1 || icon.indexOf("email") !== -1) return baseDir + "mail.svg";
        if (app.indexOf("safari") !== -1 || app.indexOf("browser") !== -1 || app.indexOf("zen") !== -1 || app.indexOf("firefox") !== -1 || app.indexOf("chrome") !== -1) return baseDir + "safari.svg";
        if (app.indexOf("music") !== -1 || app.indexOf("spotify") !== -1 || icon.indexOf("music") !== -1) return baseDir + "music.svg";
        if (app.indexOf("photo") !== -1 || icon.indexOf("photo") !== -1 || icon.indexOf("image") !== -1) return baseDir + "photos.svg";
        if (app.indexOf("note") !== -1 || icon.indexOf("note") !== -1) return baseDir + "notes.svg";
        if (app.indexOf("setting") !== -1 || icon.indexOf("setting") !== -1 || icon.indexOf("config") !== -1) return baseDir + "settings.svg";
        if (app.indexOf("term") !== -1 || app.indexOf("kitty") !== -1 || app.indexOf("ghostty") !== -1 || icon.indexOf("terminal") !== -1) return baseDir + "terminal.svg";
        if (app.indexOf("finder") !== -1 || app.indexOf("dolphin") !== -1 || icon.indexOf("folder") !== -1) return baseDir + "finder.svg";
        if (app.indexOf("code") !== -1 || app.indexOf("nvim") !== -1 || icon.indexOf("code") !== -1) return baseDir + "code.svg";
        if (app.indexOf("map") !== -1 || icon.indexOf("map") !== -1) return baseDir + "maps.svg";
        if (app.indexOf("phone") !== -1 || icon.indexOf("phone") !== -1) return baseDir + "phone.svg";
        if (app.indexOf("contact") !== -1 || icon.indexOf("contact") !== -1) return baseDir + "contacts.svg";
        if (app.indexOf("shortcut") !== -1 || icon.indexOf("shortcut") !== -1) return baseDir + "shortcuts.svg";
        if (app.indexOf("apple") !== -1) return baseDir + "apple.svg";

        // 3. System theme icon fallback via Qt icon provider
        if (appIcon && appIcon.length > 0) {
            return "image://icon/" + appIcon;
        }

        return baseDir + "reminders.svg";
    }

    // ── Register New Notification ──
    function handleIncomingNotification(notif) {
        if (!notif) return;
        notif.tracked = true;

        if (root.dndEnabled && notif.urgency < 2) {
            // Save to cache without showing popup during DND
            saveCache();
            return;
        }

        var app = notif.appName || "Notification";
        var summary = notif.summary || "";
        var body = notif.body || "";
        var urgency = typeof notif.urgency === "number" ? notif.urgency : 1;
        var iconResolved = resolveIcon(app, notif.appIcon, notif.image);

        var isTimeSensitive = (urgency === 2 || app.toLowerCase() === "reminders" || app.toLowerCase() === "calendar" || (notif.category && notif.category.indexOf("time") !== -1));
        var headerTag = isTimeSensitive ? "TIME SENSITIVE" : app.toUpperCase();

        // Extract actions safely
        var actionsList = [];
        if (notif.actions && notif.actions.length > 0) {
            for (var i = 0; i < notif.actions.length; i++) {
                var act = notif.actions[i];
                actionsList.push({
                    identifier: act.identifier || act.id || ("action_" + i),
                    text: act.text || "Option",
                    rawAction: act
                });
            }
        }

        // Standard auto-timeout: 6.5s for normal, 0 (persistent) for critical
        var timeoutMs = 6500;
        if (typeof notif.expireTimeout === "number" && notif.expireTimeout > 0) {
            timeoutMs = notif.expireTimeout;
        } else if (urgency === 2) {
            timeoutMs = 0;
        }

        var item = {
            id: root.nextId++,
            notifObj: notif,
            appName: app,
            summary: summary,
            body: body,
            iconPath: iconResolved,
            image: notif.image || "",
            actions: actionsList,
            urgency: urgency,
            isTimeSensitive: isTimeSensitive,
            headerTag: headerTag,
            createdAt: Date.now(),
            expireMs: timeoutMs,
            isExiting: false,
            optionsOpen: false
        };

        // Add to active notifications array (maximum 5 on screen simultaneously)
        var current = root.activeList.slice();
        if (current.length >= 5) {
            var old = current.pop();
            if (old.notifObj && typeof old.notifObj.dismiss === "function") {
                old.notifObj.dismiss();
            }
        }
        current.unshift(item);
        root.activeList = current;

        // Play chime sound
        if (root.soundEnabled) {
            playNotificationSound();
        }

        saveCache();
    }

    function playNotificationSound() {
        Quickshell.execDetached(["bash", "-c", "paplay /usr/share/sounds/freedesktop/stereo/message.oga 2>/dev/null || paplay /usr/share/sounds/ocean/stereo/dialog-information.oga 2>/dev/null || true"]);
    }

    // ── Dismiss Single Notification ──
    function dismiss(id) {
        var current = root.activeList.slice();
        var index = -1;
        for (var i = 0; i < current.length; i++) {
            if (current[i].id === id) {
                index = i;
                break;
            }
        }
        if (index !== -1) {
            var target = current[index];
            if (target.notifObj && typeof target.notifObj.dismiss === "function") {
                target.notifObj.dismiss();
            }
            current.splice(index, 1);
            root.activeList = current;
            saveCache();
        }
    }

    // ── Invoke Notification Action ──
    function invokeAction(id, actionIndex) {
        var current = root.activeList.slice();
        for (var i = 0; i < current.length; i++) {
            if (current[i].id === id) {
                var item = current[i];
                if (item.actions && item.actions[actionIndex] && item.actions[actionIndex].rawAction) {
                    try {
                        item.actions[actionIndex].rawAction.invoke();
                    } catch(e) {
                        console.log("Error invoking action:", e);
                    }
                }
                dismiss(id);
                return;
            }
        }
    }

    // ── Clear All Notifications ──
    function clearAll() {
        var current = root.activeList.slice();
        for (var i = 0; i < current.length; i++) {
            if (current[i].notifObj && typeof current[i].notifObj.dismiss === "function") {
                current[i].notifObj.dismiss();
            }
        }
        root.activeList = [];
        saveCache();
    }

    // ── Signal to close all open card dropdowns without mutating activeList ──
    signal requestCloseDropdowns()

    function closeAllOptions() {
        requestCloseDropdowns();
    }

    // ── Sync with /tmp/notifications_cache.json ──
    function saveCache() {
        var list = [];
        for (var i = 0; i < root.activeList.length; i++) {
            var n = root.activeList[i];
            list.push({
                id: n.id,
                appName: n.appName,
                summary: n.summary,
                body: n.body,
                timeStr: new Date(n.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
                urgency: n.urgency
            });
        }
        var jsonStr = JSON.stringify(list, null, 2);
        Quickshell.execDetached(["bash", "-c", "echo '" + jsonStr.replace(/'/g, "'\\''") + "' > /tmp/notifications_cache.json"]);
    }
}
