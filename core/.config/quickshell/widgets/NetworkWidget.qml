import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property var widgetsState

    Rectangle {
        anchors.fill: parent
        radius: root.widgetsState ? root.widgetsState.cardRadius : 22
        color: root.widgetsState ? root.widgetsState.cardBg : Qt.rgba(0.12, 0.14, 0.18, 0.75)
        border.color: root.widgetsState ? root.widgetsState.cardBorder : Qt.rgba(1, 1, 1, 0.14)
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
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
                            text: root.widgetsState.netDownVal
                            font.family: "SF Pro Display"
                            font.pixelSize: 18
                            font.weight: Font.ExtraBold
                            color: root.widgetsState.textColor
                        }

                        Text {
                            text: root.widgetsState.netDownUnit
                            font.family: "SF Pro Display"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            color: root.widgetsState.textDim
                        }

                    }

                    Text {
                        text: "󰇚 Bajada"
                        font.family: "SF Pro Display"
                        font.pixelSize: 9
                        font.weight: Font.Medium
                        color: "#64D2FF"
                    }

                }

                // Upload
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    RowLayout {
                        spacing: 3

                        Text {
                            text: root.widgetsState.netUpVal
                            font.family: "SF Pro Display"
                            font.pixelSize: 18
                            font.weight: Font.ExtraBold
                            color: root.widgetsState.textColor
                        }

                        Text {
                            text: root.widgetsState.netUpUnit
                            font.family: "SF Pro Display"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            color: root.widgetsState.textDim
                        }

                    }

                    Text {
                        text: "󰕒 Subida"
                        font.family: "SF Pro Display"
                        font.pixelSize: 9
                        font.weight: Font.Medium
                        color: "#30D158"
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
                        // 1. Trazar Curva Suavizada de Línea Tenue
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
                        // Guardar ruta de la línea para trazar el contorno tenue
                        ctx.lineWidth = 1.5;
                        ctx.strokeStyle = root.widgetsState.isDarkTheme ? "rgba(48, 209, 88, 0.75)" : "rgba(36, 170, 70, 0.85)";
                        ctx.stroke();
                        // 2. Relleno Degradado Sutil Translúcido
                        ctx.lineTo(w, h);
                        ctx.lineTo(0, h);
                        ctx.closePath();
                        var grad = ctx.createLinearGradient(0, 0, 0, h);
                        grad.addColorStop(0, root.widgetsState.isDarkTheme ? "rgba(48, 209, 88, 0.22)" : "rgba(48, 209, 88, 0.16)");
                        grad.addColorStop(1, "rgba(48, 209, 88, 0.0)");
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
                    font.family: "SF Pro Display"
                    font.pixelSize: 8
                    font.weight: Font.Bold
                    color: root.widgetsState.textDim
                    opacity: 0.6
                }

            }

            // ── Divider Line ──
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.08)" : "rgba(0,0,0,0.06)"
            }

            // ── Bottom Info Rows: Status, Interface & IP ──
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Estado"
                        font.family: "SF Pro Display"
                        font.pixelSize: 9
                        font.weight: Font.Medium
                        color: root.widgetsState.textDim
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: root.widgetsState.netStatus
                        font.family: "SF Pro Display"
                        font.pixelSize: 9
                        font.weight: Font.ExtraBold
                        color: root.widgetsState.accentGreen
                    }

                }

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Interfaz"
                        font.family: "SF Pro Display"
                        font.pixelSize: 9
                        font.weight: Font.Medium
                        color: root.widgetsState.textDim
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: root.widgetsState.netInterface
                        font.family: "SF Pro Display"
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        color: root.widgetsState.textColor
                    }

                }

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "IP"
                        font.family: "SF Pro Display"
                        font.pixelSize: 9
                        font.weight: Font.Medium
                        color: root.widgetsState.textDim
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: root.widgetsState.netIp
                        font.family: "CaskaydiaCove Nerd Font"
                        font.pixelSize: 9
                        font.weight: Font.Normal
                        color: root.widgetsState.textColor
                    }

                }

            }

        }

    }

}
