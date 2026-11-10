import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Item {
    id: root

    // Pristine White Liquid Glass Palette (Fluent / Windows 11 style)
    readonly property color cardBorder: Qt.rgba(1.0, 1.0, 1.0, 0.50)
    readonly property color textColor: "#FFFFFF"
    readonly property color textDimColor: Qt.rgba(1.0, 1.0, 1.0, 0.88)
    readonly property color textSubtleColor: Qt.rgba(1.0, 1.0, 1.0, 0.65)
    readonly property color accentColor: "#00E5FF"

    // Active toast popups visible on bottom-right of screen
    property var activePopups: []

    // Complete notification history list for the Calendar & Notification Center flyout
    property var historyList: []

    property int nextId: 1
    property bool soundEnabled: true
    property bool dndEnabled: false

    Process {
        id: loadCacheProc
        command: ["bash", "-c", "jq -c . /tmp/notifications_cache.json 2>/dev/null || tr -d '\\n' < /tmp/notifications_cache.json 2>/dev/null || echo '[]'"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                var str = data.trim();
                if (!str || str === "[]") return;
                try {
                    var parsed = JSON.parse(str);
                    if (Array.isArray(parsed) && parsed.length > 0) {
                        root.historyList = parsed;
                        var maxId = 0;
                        for (var i = 0; i < parsed.length; i++) {
                            if (parsed[i].id > maxId) maxId = parsed[i].id;
                        }
                        root.nextId = maxId + 1;
                    }
                } catch(e) {}
            }
        }
    }

    // ── Windows 11 Smart Icon Resolver ──
    function resolveIcon(appName, appIcon, image) {
        var baseDir = Quickshell.env("HOME") + "/.config/quickshell/notifications/assets/";
        var iconsDir = baseDir + "icons/";

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

        // 2. Specific Windows 11 & modern app icons
        if (app.indexOf("whatsapp") !== -1 || icon.indexOf("whatsapp") !== -1) return iconsDir + "whatsapp.svg";
        if (app.indexOf("spotify") !== -1 || icon.indexOf("spotify") !== -1) return iconsDir + "win11-spotify.svg";
        if (app.indexOf("firefox") !== -1 || icon.indexOf("firefox") !== -1) return iconsDir + "win11-firefox.svg";
        if (app.indexOf("edge") !== -1 || app.indexOf("msedge") !== -1 || icon.indexOf("edge") !== -1) return iconsDir + "win11-edge.svg";
        if (app.indexOf("term") !== -1 || app.indexOf("kitty") !== -1 || app.indexOf("alacritty") !== -1 || icon.indexOf("terminal") !== -1) return iconsDir + "win11-terminal.svg";
        if (app.indexOf("explorer") !== -1 || app.indexOf("dolphin") !== -1 || app.indexOf("nautilus") !== -1 || app.indexOf("thunar") !== -1) return iconsDir + "win11-explorer.svg";
        if (app.indexOf("code") !== -1 || app.indexOf("vscodium") !== -1 || app.indexOf("antigravity") !== -1) return iconsDir + "code.svg";
        if (app.indexOf("obs") !== -1) return iconsDir + "win11-obs.svg";
        if (app.indexOf("falcon") !== -1 || app.indexOf("steam") !== -1) return iconsDir + "win11-falcon.svg";
        if (app.indexOf("store") !== -1 || app.indexOf("discover") !== -1) return iconsDir + "win11-store.svg";
        if (app.indexOf("message") !== -1 || app.indexOf("telegram") !== -1 || app.indexOf("discord") !== -1 || app.indexOf("vesktop") !== -1) return iconsDir + "messages.svg";
        if (app.indexOf("mail") !== -1 || icon.indexOf("mail") !== -1) return iconsDir + "mail.svg";
        if (app.indexOf("setting") !== -1 || icon.indexOf("setting") !== -1) return iconsDir + "settings.svg";

        // 3. System desktop icon lookup
        if (appIcon && appIcon.length > 0) {
            return "image://icon/" + appIcon;
        }

        return iconsDir + "win11-start.svg";
    }

    // ── Handle Incoming Notification ──
    function handleIncomingNotification(notif) {
        if (!notif) return;
        notif.tracked = true;

        var app = notif.appName || "Notificación";
        var summary = notif.summary || "";
        var body = notif.body || "";
        var urgency = typeof notif.urgency === "number" ? notif.urgency : 1;
        var iconResolved = resolveIcon(app, notif.appIcon, notif.image);

        // Action options list
        var actionsList = [];
        if (notif.actions && notif.actions.length > 0) {
            for (var i = 0; i < notif.actions.length; i++) {
                var act = notif.actions[i];
                actionsList.push({
                    identifier: act.identifier || act.id || ("action_" + i),
                    text: act.text || "Abrir",
                    rawAction: act
                });
            }
        }

        var timeoutMs = 5500;
        if (typeof notif.expireTimeout === "number" && notif.expireTimeout > 0) {
            timeoutMs = notif.expireTimeout;
        } else if (urgency === 2) {
            timeoutMs = 0; // Persistent for critical
        }

        var now = new Date();
        var timeStr = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

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
            createdAt: Date.now(),
            timeStr: timeStr,
            expireMs: timeoutMs
        };

        // 1. Add to active toast popups (unless DND active on normal urgency)
        if (!root.dndEnabled || urgency === 2) {
            var popups = root.activePopups.slice();
            if (popups.length >= 3) {
                popups.shift();
            }
            popups.push(item);
            root.activePopups = popups;

            // Play notification sound chime
            if (root.soundEnabled) {
                playNotificationSound();
            }
        }

        // 2. Add to persistent history list for CalendarNotificationFlyout
        var hist = root.historyList.slice();
        hist.unshift(item);
        if (hist.length > 50) {
            hist.pop();
        }
        root.historyList = hist;

        // 3. Save to /tmp/notifications_cache.json
        saveCache();
    }

    function playNotificationSound() {
        Quickshell.execDetached(["bash", "-c", "paplay /usr/share/sounds/freedesktop/stereo/message.oga 2>/dev/null || paplay /usr/share/sounds/ocean/stereo/dialog-information.oga 2>/dev/null || true"]);
    }

    // ── Dismiss Toast Popup Only (Keeps in history for Notification Center) ──
    function dismissPopup(id) {
        var popups = root.activePopups.slice();
        for (var i = 0; i < popups.length; i++) {
            if (popups[i].id === id) {
                popups.splice(i, 1);
                break;
            }
        }
        root.activePopups = popups;
    }

    // ── Dismiss Single Notification (Removes from both Toast & History) ──
    function dismiss(id) {
        dismissPopup(id);

        var hist = root.historyList.slice();
        for (var i = 0; i < hist.length; i++) {
            if (hist[i].id === id) {
                var target = hist[i];
                if (target.notifObj && typeof target.notifObj.dismiss === "function") {
                    try { target.notifObj.dismiss(); } catch(e) {}
                }
                hist.splice(i, 1);
                break;
            }
        }
        root.historyList = hist;
        saveCache();
    }

    // ── Invoke Action on Notification ──
    function invokeAction(id, actionIndex) {
        for (var i = 0; i < root.historyList.length; i++) {
            if (root.historyList[i].id === id) {
                var item = root.historyList[i];
                if (item.actions && item.actions[actionIndex] && item.actions[actionIndex].rawAction) {
                    try {
                        item.actions[actionIndex].rawAction.invoke();
                    } catch(e) {}
                }
                break;
            }
        }
        dismiss(id);
    }

    // ── Clear All History & Popups ("Borrar todo") ──
    function clearAll() {
        for (var i = 0; i < root.historyList.length; i++) {
            var it = root.historyList[i];
            if (it.notifObj && typeof it.notifObj.dismiss === "function") {
                try { it.notifObj.dismiss(); } catch(e) {}
            }
        }
        root.activePopups = [];
        root.historyList = [];
        saveCache();
    }

    // ── Sync with /tmp/notifications_cache.json ──
    function saveCache() {
        var list = [];
        for (var i = 0; i < root.historyList.length; i++) {
            var n = root.historyList[i];
            list.push({
                id: n.id,
                appName: n.appName,
                summary: n.summary,
                body: n.body,
                iconPath: n.iconPath,
                image: n.image,
                timeStr: n.timeStr,
                urgency: n.urgency
            });
        }
        var jsonStr = JSON.stringify(list);
        var escaped = jsonStr.replace(/'/g, "'\\''");
        Quickshell.execDetached(["bash", "-c", "printf '%s\\n' '" + escaped + "' > /tmp/notifications_cache.json.tmp && mv -f /tmp/notifications_cache.json.tmp /tmp/notifications_cache.json"]);
    }
}
