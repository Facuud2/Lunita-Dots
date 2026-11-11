import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

RowLayout {
    id: root

    required property var barState
    signal navigateToPage(int pageIndex)

    spacing: 12
    implicitHeight: 120

    // ── Stat Card Component ──
    component StatCard: Rectangle {
        property string title: ""
        property string value: ""
        property var history: []
        property int targetPage: 2
        property color sparkColor: root.barState.themeAccent

        Layout.fillWidth: true
        Layout.fillHeight: true
        color: Qt.rgba(1, 1, 1, 0.08)
        radius: 16
        border.color: cardHov.hovered ? root.barState.themeBorderSpecular : Qt.rgba(1, 1, 1, 0.12)
        border.width: 1
        clip: true

        HoverHandler { id: cardHov }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.navigateToPage(targetPage)
        }

        ColumnLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 14
            spacing: 2

            Text {
                text: title
                font.family: root.barState.themeFontInterface
                font.pixelSize: 10
                font.weight: Font.DemiBold
                font.letterSpacing: 1.2
                color: Qt.rgba(1, 1, 1, 0.60)
            }

            Text {
                text: value
                font.family: root.barState.themeFontDisplay
                font.pixelSize: 22
                font.weight: Font.Light
                color: "#FFFFFF"
            }
        }

        // Real-time Canvas Sparkline (Bottom 42px)
        Canvas {
            id: sparkCanvas
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 42
            antialiasing: true

            Connections {
                target: root.barState
                function onCpuHistoryChanged() { sparkCanvas.requestPaint(); }
                function onRamHistoryChanged() { sparkCanvas.requestPaint(); }
                function onNetHistoryChanged() { sparkCanvas.requestPaint(); }
            }

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);

                var pts = history || [];
                if (pts.length < 2) return;

                var maxVal = 1;
                for (var i = 0; i < pts.length; i++) {
                    if (pts[i] > maxVal) maxVal = pts[i];
                }

                ctx.strokeStyle = sparkColor;
                ctx.lineWidth = 1.8;
                ctx.beginPath();

                var step = width / (pts.length - 1);
                for (var j = 0; j < pts.length; j++) {
                    var x = j * step;
                    var y = height - (pts[j] / maxVal) * (height - 8) - 4;
                    if (j === 0) ctx.moveTo(x, y);
                    else ctx.lineTo(x, y);
                }
                ctx.stroke();

                // Faint fill gradient
                ctx.lineTo(width, height);
                ctx.lineTo(0, height);
                ctx.closePath();
                var grad = ctx.createLinearGradient(0, 0, 0, height);
                grad.addColorStop(0, Qt.rgba(sparkColor.r, sparkColor.g, sparkColor.b, 0.16));
                grad.addColorStop(1, Qt.rgba(sparkColor.r, sparkColor.g, sparkColor.b, 0.00));
                ctx.fillStyle = grad;
                ctx.fill();
            }
        }
    }

    // ── 1. CPU Card ──
    StatCard {
        title: "CPU"
        value: root.barState.cpuPercent + "%"
        history: root.barState.cpuHistory
        targetPage: 2
        sparkColor: root.barState.themeAccent
    }

    // ── 2. RAM Card ──
    StatCard {
        title: "MEMORY"
        value: root.barState.ramPercent + "%"
        history: root.barState.ramHistory
        targetPage: 2
        sparkColor: root.barState.themeAccent
    }

    // ── 3. Download Card ──
    StatCard {
        title: "DOWNLOAD"
        value: root.barState.netDownRate || "0 KB/s"
        history: root.barState.netHistory
        targetPage: 3
        sparkColor: root.barState.themeAccent
    }
}
