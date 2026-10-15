import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root
    property var widgetsState

    readonly property bool isSmall: root.width <= 220
    readonly property bool isMedium: root.width > 220 && root.height <= 240
    readonly property bool isLarge: root.width > 220 && root.height > 240

    // Dispositivos reales conectados con batería obtenidos de WidgetsState
    readonly property var rawDevices: root.widgetsState ? (root.widgetsState.batteryDevices || []) : []
    // Filtrar únicamente aquellos que tienen porcentaje de batería válido
    readonly property var activeDevices: {
        var list = [];
        for (var i = 0; i < rawDevices.length; i++) {
            var dev = rawDevices[i];
            if (dev && dev.percent !== undefined && dev.percent !== null) {
                list.push(dev);
            }
        }
        return list;
    }

    Rectangle {
        id: cardBg
        anchors.fill: parent
        radius: 22
        clip: true
        color: root.widgetsState && root.widgetsState.isDarkTheme ? "#231B3D" : (root.widgetsState ? root.widgetsState.cardBg : "#231B3D")
        border.color: root.widgetsState ? root.widgetsState.cardBorder : Qt.rgba(1, 1, 1, 0.12)
        border.width: 1

        // ═══════════════════════════════════════════════════════════════════
        // ── COMPONENTE REUTILIZABLE: ANILLO DE BATERÍA ESTILO macOS ──
        // ═══════════════════════════════════════════════════════════════════
        component BatteryRingSlot: Item {
            id: slot
            property var deviceData: null
            property bool isEmpty: deviceData === null
            property real ringDiameter: 58
            property real strokeWidth: 5.5

            implicitWidth: ringDiameter + 16
            implicitHeight: ringDiameter + 30

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 7

                // Anillo circular Canvas
                Item {
                    Layout.alignment: Qt.AlignHCenter
                    width: slot.ringDiameter
                    height: slot.ringDiameter

                    Canvas {
                        id: canvas
                        anchors.fill: parent
                        renderTarget: Canvas.FramebufferObject
                        antialiasing: true

                        property int pct: slot.deviceData ? Math.max(0, Math.min(100, slot.deviceData.percent)) : 0
                        property bool empty: slot.isEmpty
                        property string dType: slot.deviceData ? (slot.deviceData.type || "headset") : ""
                        property bool charging: slot.deviceData ? !!slot.deviceData.charging : false

                        onPctChanged: requestPaint()
                        onEmptyChanged: requestPaint()
                        onDTypeChanged: requestPaint()
                        onChargingChanged: requestPaint()

                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);

                            var cx = width / 2;
                            var cy = height / 2;
                            var r = (slot.ringDiameter - slot.strokeWidth) / 2;

                            // 1. Pista circular de fondo (Track)
                            ctx.beginPath();
                            ctx.arc(cx, cy, r, 0, 2 * Math.PI, false);
                            ctx.strokeStyle = empty ? "rgba(255, 255, 255, 0.14)" : "rgba(255, 255, 255, 0.18)";
                            ctx.lineWidth = slot.strokeWidth;
                            ctx.stroke();

                            if (empty) return;

                            // 2. Arco de progreso activo
                            var startAngle = -Math.PI / 2;
                            var sweepAngle = (pct / 100.0) * 2 * Math.PI;
                            var endAngle = startAngle + sweepAngle;

                            // Color macOS: Verde vibrante (#30D158), Amarillo (<25%), Rojo (<12%)
                            var strokeColor = "#30D158";
                            if (pct <= 12) strokeColor = "#FF453A";
                            else if (pct <= 25) strokeColor = "#FF9F0A";

                            ctx.beginPath();
                            ctx.arc(cx, cy, r, startAngle, endAngle, false);
                            ctx.strokeStyle = strokeColor;
                            ctx.lineWidth = slot.strokeWidth;
                            ctx.lineCap = "round";
                            ctx.stroke();

                            // 3. Icono vectorial del dispositivo en el centro
                            ctx.strokeStyle = "rgba(255, 255, 255, 0.90)";
                            ctx.fillStyle = "rgba(255, 255, 255, 0.90)";
                            var s = slot.ringDiameter / 58.0;

                            if (dType === "headset") {
                                // Diadema de auriculares
                                ctx.lineWidth = 1.8 * s;
                                ctx.beginPath();
                                ctx.arc(cx, cy - 2 * s, 9 * s, Math.PI, 0, false);
                                ctx.stroke();

                                // Almohadilla izquierda
                                ctx.beginPath();
                                ctx.rect(cx - 10.5 * s, cy - 4 * s, 3.2 * s, 8.5 * s);
                                ctx.fill();

                                // Almohadilla derecha
                                ctx.beginPath();
                                ctx.rect(cx + 7.3 * s, cy - 4 * s, 3.2 * s, 8.5 * s);
                                ctx.fill();
                            } else if (dType === "laptop") {
                                // Pantalla de laptop
                                ctx.lineWidth = 1.6 * s;
                                ctx.strokeRect(cx - 9.5 * s, cy - 7 * s, 19 * s, 11 * s);
                                // Base con muesca
                                ctx.beginPath();
                                ctx.moveTo(cx - 12.5 * s, cy + 5.5 * s);
                                ctx.lineTo(cx + 12.5 * s, cy + 5.5 * s);
                                ctx.lineWidth = 1.8 * s;
                                ctx.stroke();
                            } else if (dType === "phone") {
                                // Teléfono móvil
                                ctx.lineWidth = 1.6 * s;
                                ctx.strokeRect(cx - 5.5 * s, cy - 9.5 * s, 11 * s, 19 * s);
                                // Botón / barra inferior
                                ctx.beginPath();
                                ctx.moveTo(cx - 2.5 * s, cy + 6.5 * s);
                                ctx.lineTo(cx + 2.5 * s, cy + 6.5 * s);
                                ctx.lineWidth = 1.2 * s;
                                ctx.stroke();
                            } else if (dType === "mouse") {
                                // Ratón
                                ctx.lineWidth = 1.6 * s;
                                ctx.beginPath();
                                ctx.rect(cx - 5.5 * s, cy - 9 * s, 11 * s, 18 * s);
                                ctx.stroke();
                                ctx.beginPath();
                                ctx.moveTo(cx, cy - 6 * s);
                                ctx.lineTo(cx, cy - 1 * s);
                                ctx.lineWidth = 1.4 * s;
                                ctx.stroke();
                            } else {
                                // Icono genérico de dispositivo / batería
                                ctx.lineWidth = 1.6 * s;
                                ctx.strokeRect(cx - 6 * s, cy - 9 * s, 12 * s, 18 * s);
                            }
                        }
                    }
                }

                // Porcentaje debajo del anillo
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    visible: !slot.isEmpty
                    text: slot.deviceData ? (slot.deviceData.percent + " %") : ""
                    font.family: "SF Pro Display, Inter, system-ui, sans-serif"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    font.italic: false
                    color: "#FFFFFF"
                }

                // Espacio reservado transparente para los slots vacíos
                Item {
                    visible: slot.isEmpty
                    width: 10
                    height: 15
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 1. VISTA MEDIUM (354 x 170): 4 ANILLOS HORIZONTALES (REFERENCIA) ──
        // ═══════════════════════════════════════════════════════════════════
        Item {
            anchors.fill: parent
            visible: root.isMedium || (!root.isSmall && !root.isLarge)

            RowLayout {
                anchors.centerIn: parent
                spacing: 16

                Repeater {
                    model: 4

                    BatteryRingSlot {
                        ringDiameter: 58
                        strokeWidth: 5.5
                        deviceData: index < root.activeDevices.length ? root.activeDevices[index] : null
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 2. VISTA COMPACTA (170 x 170): DISPOSITIVO PRINCIPAL O 2x2 ──
        // ═══════════════════════════════════════════════════════════════════
        Item {
            anchors.fill: parent
            visible: root.isSmall

            // Si hay 1 dispositivo conectado: Anillo grande centrado con nombre
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 6
                visible: root.activeDevices.length <= 1

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.activeDevices.length > 0 ? root.activeDevices[0].name : "Sin dispositivos BT"
                    font.family: "SF Pro Display, Inter, system-ui, sans-serif"
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    color: Qt.rgba(1.000, 1.000, 1.000, 0.7)
                    elide: Text.ElideRight
                    Layout.maximumWidth: 140
                }

                BatteryRingSlot {
                    Layout.alignment: Qt.AlignHCenter
                    ringDiameter: 68
                    strokeWidth: 6.0
                    deviceData: root.activeDevices.length > 0 ? root.activeDevices[0] : null
                }
            }

            // Si hay de 2 a 4 dispositivos: cuadrícula 2x2
            GridLayout {
                anchors.centerIn: parent
                columns: 2
                rowSpacing: 4
                columnSpacing: 6
                visible: root.activeDevices.length > 1

                Repeater {
                    model: 4
                    BatteryRingSlot {
                        ringDiameter: 42
                        strokeWidth: 4.0
                        deviceData: index < root.activeDevices.length ? root.activeDevices[index] : null
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 3. VISTA EXPANDIDA (354 x 354): ANILLOS + LISTA DETALLADA ──
        // ═══════════════════════════════════════════════════════════════════
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12
            visible: root.isLarge

            // Fila superior: Los 4 anillos horizontales
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 16

                Repeater {
                    model: 4
                    BatteryRingSlot {
                        ringDiameter: 54
                        strokeWidth: 5.0
                        deviceData: index < root.activeDevices.length ? root.activeDevices[index] : null
                    }
                }
            }

            // Separador sutil
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(1.000, 1.000, 1.000, 0.12)
            }

            // Título de sección
            Text {
                text: "DISPOSITIVOS CONECTADOS"
                font.family: "SF Pro Display"
                font.pixelSize: 10
                font.weight: Font.Bold
                font.letterSpacing: 0.6
                color: Qt.rgba(1.000, 1.000, 1.000, 0.55)
            }

            // Lista detallada de dispositivos conectados
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                visible: root.activeDevices.length > 0
                model: root.activeDevices
                spacing: 8

                delegate: Rectangle {
                    width: parent ? parent.width : 320
                    height: 42
                    radius: 10
                    color: Qt.rgba(1.000, 1.000, 1.000, 0.07)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 10

                        Text {
                            text: modelData.icon || "󰋋"
                            font.family: "CaskaydiaCove Nerd Font"
                            font.pixelSize: 16
                            color: "#FFFFFF"
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: modelData.name || "Dispositivo"
                                font.family: "SF Pro Display"
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                color: "#FFFFFF"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: "Conectado"
                                font.family: "SF Pro Display"
                                font.pixelSize: 10
                                color: "#30D158"
                            }
                        }

                        // Barra horizontal de nivel
                        Rectangle {
                            width: 70
                            height: 6
                            radius: 3
                            color: Qt.rgba(1.000, 1.000, 1.000, 0.15)

                            Rectangle {
                                width: parent.width * (Math.max(0, Math.min(100, modelData.percent)) / 100.0)
                                height: parent.height
                                radius: 3
                                color: modelData.percent > 20 ? "#30D158" : (modelData.percent > 10 ? "#FF9F0A" : "#FF453A")
                            }
                        }

                        Text {
                            text: modelData.percent + "%"
                            font.family: "SF Pro Display"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: "#FFFFFF"
                        }
                    }
                }
            }

            // Empty State
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: root.activeDevices.length === 0

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "󰂎"
                        font.family: "CaskaydiaCove Nerd Font"
                        font.pixelSize: 32
                        color: Qt.rgba(1, 1, 1, 0.25)
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Sin dispositivos vinculados"
                        font.family: "SF Pro Display"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        color: Qt.rgba(1, 1, 1, 0.6)
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Los dispositivos Bluetooth o KDE Connect\nse mostrarán aquí automáticamente"
                        font.family: "SF Pro Display"
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignHCenter
                        color: Qt.rgba(1, 1, 1, 0.35)
                    }
                }
            }
        }
    }
}
