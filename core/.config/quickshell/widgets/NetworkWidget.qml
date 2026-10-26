import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property var widgetsState

    readonly property var skin: root.widgetsState ? root.widgetsState.skin : null
    readonly property bool nothing: root.skin ? root.skin.isNothing : false
    readonly property string fontText: root.nothing ? root.skin.fontText : "SF Pro Display, Inter, sans-serif"
    readonly property string fontFigure: root.nothing ? root.skin.fontFigure : "SF Pro Display, Inter, sans-serif"

    readonly property string netDownVal: root.widgetsState ? (root.widgetsState.netDownVal || "0") : "0"
    readonly property string netDownUnit: root.widgetsState ? (root.widgetsState.netDownUnit || "KB/s") : "KB/s"
    readonly property string netUpVal: root.widgetsState ? (root.widgetsState.netUpVal || "0") : "0"
    readonly property string netUpUnit: root.widgetsState ? (root.widgetsState.netUpUnit || "KB/s") : "KB/s"
    readonly property string netStatus: root.widgetsState ? (root.widgetsState.netStatus || "UP") : "UP"
    readonly property string netInterface: root.widgetsState ? (root.widgetsState.netInterface || "Ethernet") : "Ethernet"
    readonly property string netIp: root.widgetsState ? (root.widgetsState.netIp || "127.0.0.1") : "127.0.0.1"
    readonly property color textColor: root.nothing ? root.skin.ink : (root.widgetsState ? root.widgetsState.textColor : "#FFFFFF")
    readonly property color textDim: root.nothing ? root.skin.inkDim : (root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.6))
    readonly property color accentGreen: root.nothing ? root.skin.ink : (root.widgetsState ? root.widgetsState.accentGreen : "#30D158")
    readonly property bool isDarkTheme: root.widgetsState ? root.widgetsState.isDarkTheme : true

    Rectangle {
        id: cardBg
        anchors.fill: parent
        radius: root.nothing ? root.skin.radius : (root.widgetsState ? root.widgetsState.cardRadius : 22)
        color: root.nothing ? root.skin.card : (root.widgetsState ? root.widgetsState.cardBg : Qt.rgba(0.12, 0.14, 0.18, 0.75))
        border.color: root.nothing ? "transparent" : (root.widgetsState ? root.widgetsState.cardBorder : Qt.rgba(1, 1, 1, 0.14))
        border.width: root.nothing ? 0 : 1
        scale: cardMa.pressed ? 0.985 : 1.0
        Behavior on scale {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        MouseArea {
            id: cardMa
            anchors.fill: parent
            hoverEnabled: true
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: root.nothing ? root.skin.pad : 12
            spacing: 4

            // ── Top Row: Speed (Download & Upload) ──
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                // Download
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    RowLayout {
                        spacing: 3

                        Text {
                            text: root.netDownVal
                            font.family: root.fontFigure
                            font.pixelSize: 18
                            font.weight: Font.DemiBold
                            color: root.nothing ? root.skin.cyan : root.textColor
                        }

                        Text {
                            text: root.netDownUnit
                            font.family: root.fontText
                            font.pixelSize: 9
                            font.weight: Font.Medium
                            color: root.textDim
                        }

                    }

                    Text {
                        text: "↓ Bajada"
                        font.family: root.fontText
                        font.pixelSize: 9
                        font.weight: Font.Medium
                        color: root.nothing ? root.skin.cyan : "#64D2FF"
                    }

                }

                // Upload
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    RowLayout {
                        spacing: 3

                        Text {
                            text: root.netUpVal
                            font.family: root.fontFigure
                            font.pixelSize: 18
                            font.weight: Font.DemiBold
                            color: root.nothing ? root.skin.green : root.textColor
                        }

                        Text {
                            text: root.netUpUnit
                            font.family: root.fontText
                            font.pixelSize: 9
                            font.weight: Font.Medium
                            color: root.textDim
                        }

                    }

                    Text {
                        text: "↑ Subida"
                        font.family: root.fontText
                        font.pixelSize: 9
                        font.weight: Font.Medium
                        color: root.nothing ? root.skin.green : "#30D158"
                    }

                }

            }

            // ── Center: Sparkline Mini-graph (History 60s) ──
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                clip: true

                Canvas {
                    id: sparklineCanvas

                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();
                        var history = root.widgetsState ? root.widgetsState.netHistory : [];
                        if (!history || history.length < 2)
                            return ;

                        var w = width;
                        var h = height;
                        var maxVal = 50; // Mínimo 50 KB/s de techo para escala suave
                        for (var i = 0; i < history.length; i++) {
                            if (history[i] > maxVal)
                                maxVal = history[i];
                        }
                        var stepX = w / (history.length - 1);
                        // 1. Trazar Curva Suavizada de Línea
                        ctx.beginPath();
                        var pts = [];
                        for (var j = 0; j < history.length; j++) {
                            var val = history[j];
                            var px = j * stepX;
                            var py = h - ((val / maxVal) * (h - 8)) - 4;
                            pts.push({
                                "x": px,
                                "y": py
                            });
                        }
                        ctx.moveTo(pts[0].x, pts[0].y);
                        for (var k = 1; k < pts.length; k++) {
                            var midX = (pts[k - 1].x + pts[k].x) / 2;
                            var midY = (pts[k - 1].y + pts[k].y) / 2;
                            ctx.quadraticCurveTo(pts[k - 1].x, pts[k - 1].y, midX, midY);
                        }
                        ctx.lineTo(pts[pts.length - 1].x, pts[pts.length - 1].y);
                        ctx.lineWidth = 1.5;
                        if (root.nothing) {
                            ctx.strokeStyle = root.skin.cyan;
                        } else {
                            ctx.strokeStyle = root.isDarkTheme ? "rgba(48, 209, 88, 0.75)" : "rgba(36, 170, 70, 0.85)";
                        }
                        ctx.stroke();

                        // 2. Relleno Degradado Sutil Translúcido
                        ctx.lineTo(w, h);
                        ctx.lineTo(0, h);
                        ctx.closePath();
                        var grad = ctx.createLinearGradient(0, 0, 0, h);
                        if (root.nothing) {
                            grad.addColorStop(0, "rgba(0, 210, 255, 0.22)");
                            grad.addColorStop(1, "rgba(0, 210, 255, 0.0)");
                        } else {
                            grad.addColorStop(0, root.isDarkTheme ? "rgba(48, 209, 88, 0.22)" : "rgba(48, 209, 88, 0.16)");
                            grad.addColorStop(1, "rgba(48, 209, 88, 0.0)");
                        }
                        ctx.fillStyle = grad;
                        ctx.fill();
                    }

                    Connections {
                        function onNetHistoryChanged() {
                            sparklineCanvas.requestPaint();
                        }

                        target: root.widgetsState
                    }

                }

                // Indicador '60s' en esquina tenue
                Text {
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.bottomMargin: 1
                    anchors.rightMargin: 2
                    text: "60s"
                    font.family: root.fontText
                    font.pixelSize: 8
                    font.weight: Font.Bold
                    color: root.textDim
                    opacity: 0.6
                }

            }

            // ── Divider Line ──
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: root.nothing ? root.skin.dotOff : (root.isDarkTheme ? "rgba(255,255,255,0.08)" : "rgba(0,0,0,0.06)")
            }

            // ── Bottom Info Rows: Status, Interface & IP ──
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Estado"
                        font.family: root.fontText
                        font.pixelSize: 9
                        font.weight: Font.Medium
                        color: root.textDim
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: root.netStatus
                        font.family: root.fontText
                        font.pixelSize: 9
                        font.weight: Font.ExtraBold
                        color: root.nothing ? (root.netStatus === "UP" ? root.skin.green : root.skin.signal) : root.accentGreen
                    }

                }

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Interfaz"
                        font.family: root.fontText
                        font.pixelSize: 9
                        font.weight: Font.Medium
                        color: root.textDim
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: root.netInterface
                        font.family: root.fontText
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        color: root.textColor
                    }

                }

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "IP"
                        font.family: root.fontText
                        font.pixelSize: 9
                        font.weight: Font.Medium
                        color: root.textDim
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: root.netIp
                        font.family: root.nothing ? root.fontFigure : "CaskaydiaCove Nerd Font"
                        font.pixelSize: 9
                        font.weight: Font.Normal
                        color: root.textColor
                    }

                }

            }

        }

    }

}
