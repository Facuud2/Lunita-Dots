pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "."

QtObject {
    id: root

    property bool muted: false
    property var list: []
    readonly property int count: list.length
    property var current: null

    function addNotification(summary, body, appName, icon) {
        if (root.muted) return;
        var notif = {
            id: Date.now(),
            summary: summary || "",
            body: body || "",
            appName: appName || "Sistema",
            icon: icon || ""
        };
        var updated = root.list.slice();
        updated.unshift(notif);
        if (updated.length > 20) updated.pop();
        root.list = updated;
        root.current = notif;
        root.popupTimer.restart();
    }

    readonly property Timer popupTimer: Timer {
        interval: 5000
        onTriggered: root.current = null
    }

    function dismissAt(row) {
        if (row >= 0 && row < root.list.length) {
            var updated = root.list.slice();
            updated.splice(row, 1);
            root.list = updated;
        }
    }

    function clearAll() {
        root.list = [];
        root.current = null;
    }

    function toggleMute() {
        root.muted = !root.muted;
        if (root.muted)
            root.current = null;
    }
}
