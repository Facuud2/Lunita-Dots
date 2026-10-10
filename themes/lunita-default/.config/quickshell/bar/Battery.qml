import QtQuick
import Quickshell
import Quickshell.Io
import "."

Row {
    id: root
    spacing: 4

    property bool present: false
    property int percent: 100
    property bool charging: false

    property var batProc: Process {
        command: ["bash", "-c", "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1; cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1"]
        stdout: SplitParser {
            onRead: text => {
                if (!text) return;
                var lines = text.trim().split("\n");
                if (lines.length >= 1 && lines[0] !== "") {
                    root.present = true;
                    root.percent = parseInt(lines[0]) || 0;
                    if (lines.length >= 2) {
                        root.charging = lines[1].toLowerCase().indexOf("charging") !== -1;
                    }
                } else {
                    root.present = false;
                }
            }
        }
    }

    readonly property Timer tick: Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (root.batProc) root.batProc.running = true;
        }
    }

    visible: present

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: {
            if (root.charging)
                return Icons.batCharging;
            const p = root.percent;
            if (p > 85)
                return Icons.batFull;
            if (p > 60)
                return Icons.bat3q;
            if (p > 35)
                return Icons.batHalf;
            if (p > 15)
                return Icons.batQuarter;
            return Icons.batEmpty;
        }
        color: root.charging ? Theme.primary : root.percent <= 15 ? Theme.error : Theme.fg
        font.family: Theme.fontIcon
        font.pixelSize: 18
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.percent
        color: Theme.fgVariant
        font.family: Theme.fontUi
        font.pixelSize: 12
    }
}
