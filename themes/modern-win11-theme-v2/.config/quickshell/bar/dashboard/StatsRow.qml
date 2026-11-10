import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

RowLayout {
    id: root

    required property var barState
    signal navigateToPage(int pageIndex)

    spacing: 10
    implicitHeight: 120

    // ── Stat Card Component ──
    component StatCard: Rectangle {
        property string title: ""
        property string value: ""
        property string subvalue: ""
        property var history: []
        property int targetPage: 2
        property color sparkColor: root.barState.themeAccent

        Layout.fillWidth: true
        Layout.fillHeight: true
        color: root.barState.themeSurfaceContainer
        radius: root.barState.themeCardRadius
        border.color: cardHov.hovered ? root.barState.themeBorderSpecular : root.barState.themeBorder
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
            anchors.margins: 12
            spacing: 2

            Text {
                text: title
                font.family: root.barState.themeFontInterface
                font.pixelSize: 9
                font.weight: Font.DemiBold
                color: root.barState.themeOnSurfaceLow
            }

            Text {
                text: value
                font.family: root.barState.themeFontDisplay
                font.pixelSize: 20
                font.weight: Font.DemiBold
                color: root.barState.themeOnSurface
            }

            Text {
                visible: subvalue !== ""
                text: subvalue
                font.family: root.barState.themeFontInterface
                font.pixelSize: 9
                color: root.barState.themeOnSurfaceDim
            }
        }

        // Real-time Canvas Sparkline
        Canvas {
            id: sparkCanvas
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 38
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
                    var y = height - (pts[j] / maxVal) * (height - 6) - 3;
                    if (j === 0) ctx.moveTo(x, y);
                    else ctx.lineTo(x, y);
                }
                ctx.stroke();

                // Faint fill gradient
                ctx.lineTo(width, height);
                ctx.lineTo(0, height);
                ctx.closePath();
                ctx.fillStyle = Qt.rgba(sparkColor.r, sparkColor.g, sparkColor.b, 0.12);
                ctx.fill();
            }
        }
    }

    // ── 1. CPU Card ──
    StatCard {
        title: "CPU"
        value: root.barState.cpuPercent + "%"
        subvalue: "Gobernanza"
        history: root.barState.cpuHistory
        targetPage: 2
        sparkColor: root.barState.themeAccent
    }

    // ── 2. RAM Card ──
    StatCard {
        title: "MEMORIA"
        value: root.barState.ramPercent + "%"
        subvalue: root.barState.ramUsed || "En uso"
        history: root.barState.ramHistory
        targetPage: 2
        sparkColor: root.barState.themeAccentHover
    }

    // ── 3. Download Card ──
    StatCard {
        title: "DESCARGA"
        value: root.barState.netDownRate || "0 KB/s"
        subvalue: "Ancho de banda"
        history: root.barState.netHistory
        targetPage: 3
        sparkColor: root.barState.themeAccentActive
    }
}
