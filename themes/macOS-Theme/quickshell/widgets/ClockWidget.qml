import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root
    property var widgetsState
    property bool contextMenuOpen: false

    readonly property bool isSmall: root.width <= 220
    readonly property bool isMedium: root.width > 220 && root.height <= 240
    readonly property bool isLarge: root.width > 220 && root.height > 240

    Rectangle {
        id: cardBg
        anchors.fill: parent
        radius: 22
        clip: true
        color: root.widgetsState && root.widgetsState.isDarkTheme ? "#211A39" : (root.widgetsState ? root.widgetsState.cardBg : "#211A39")
        border.color: root.widgetsState ? root.widgetsState.cardBorder : Qt.rgba(1, 1, 1, 0.12)
        border.width: 1

        // ── Menú contextual al hacer clic derecho para cambiar ubicación / clima ──
        MouseArea {
            anchors.fill: parent
            enabled: root.widgetsState ? !root.widgetsState.isEditing : true
            acceptedButtons: Qt.RightButton
            cursorShape: Qt.ArrowCursor
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                    root.contextMenuOpen = !root.contextMenuOpen;
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── COMPONENTE REUTILIZABLE: ESFERA ANALÓGICA macOS ──
        // ═══════════════════════════════════════════════════════════════════
        component AnalogClockFace: Item {
            id: clockFace
            property real dialSize: 142

            width: dialSize
            height: dialSize

            Timer {
                interval: 200
                running: true
                repeat: true
                onTriggered: dialCanvas.requestPaint()
            }

            Canvas {
                id: dialCanvas
                anchors.fill: parent
                renderTarget: Canvas.FramebufferObject
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);

                    var cx = width / 2;
                    var cy = height / 2;
                    var r = width / 2 - 2;

                    // 1. Fondo blanco puro del reloj
                    ctx.beginPath();
                    ctx.arc(cx, cy, r, 0, 2 * Math.PI, false);
                    ctx.fillStyle = "#FFFFFF";
                    ctx.fill();

                    // Borde sutil del dial
                    ctx.strokeStyle = "rgba(0, 0, 0, 0.08)";
                    ctx.lineWidth = 1.0;
                    ctx.stroke();

                    // 2. Marcas de minutos y horas (60 ticks)
                    for (var i = 0; i < 60; i++) {
                        var angle = (i / 60.0) * 2 * Math.PI - Math.PI / 2;
                        var isHour = (i % 5 === 0);
                        var tickLen = isHour ? (r * 0.085) : (r * 0.045);
                        var tickWidth = isHour ? 1.6 : 0.85;

                        var rOut = r * 0.96;
                        var rIn = rOut - tickLen;

                        ctx.beginPath();
                        ctx.moveTo(cx + rIn * Math.cos(angle), cy + rIn * Math.sin(angle));
                        ctx.lineTo(cx + rOut * Math.cos(angle), cy + rOut * Math.sin(angle));
                        ctx.strokeStyle = isHour ? "#1C1C1E" : "#8E8E93";
                        ctx.lineWidth = tickWidth;
                        ctx.lineCap = "round";
                        ctx.stroke();
                    }

                    // 3. Números del 1 al 12
                    var fontSize = Math.round(r * 0.21);
                    ctx.font = "bold " + fontSize + "px 'SF Pro Display', Inter, -apple-system, sans-serif";
                    ctx.fillStyle = "#1C1C1E";
                    ctx.textAlign = "center";
                    ctx.textBaseline = "middle";

                    var numRadius = r * 0.67;
                    for (var n = 1; n <= 12; n++) {
                        var nAngle = (n / 12.0) * 2 * Math.PI - Math.PI / 2;
                        var nx = cx + numRadius * Math.cos(nAngle);
                        var ny = cy + numRadius * Math.sin(nAngle);
                        // Ajuste visual fino de baseline vertical
                        ctx.fillText(n.toString(), nx, ny + 0.5);
                    }

                    // 4. Obtener hora actual con fracciones para movimiento suave
                    var now = new Date();
                    var sec = now.getSeconds() + now.getMilliseconds() / 1000.0;
                    var min = now.getMinutes() + sec / 60.0;
                    var hr = (now.getHours() % 12) + min / 60.0;

                    var hrAngle = (hr / 12.0) * 2 * Math.PI - Math.PI / 2;
                    var minAngle = (min / 60.0) * 2 * Math.PI - Math.PI / 2;
                    var secAngle = (sec / 60.0) * 2 * Math.PI - Math.PI / 2;

                    // 5. Aguja de las horas (Negra, redondeada)
                    var hrLen = r * 0.50;
                    ctx.beginPath();
                    ctx.moveTo(cx - (r * 0.08) * Math.cos(hrAngle), cy - (r * 0.08) * Math.sin(hrAngle));
                    ctx.lineTo(cx + hrLen * Math.cos(hrAngle), cy + hrLen * Math.sin(hrAngle));
                    ctx.strokeStyle = "#1C1C1E";
                    ctx.lineWidth = Math.max(2.5, r * 0.055);
                    ctx.lineCap = "round";
                    ctx.stroke();

                    // 6. Aguja de los minutos (Negra, más larga, redondeada)
                    var minLen = r * 0.74;
                    ctx.beginPath();
                    ctx.moveTo(cx - (r * 0.10) * Math.cos(minAngle), cy - (r * 0.10) * Math.sin(minAngle));
                    ctx.lineTo(cx + minLen * Math.cos(minAngle), cy + minLen * Math.sin(minAngle));
                    ctx.strokeStyle = "#1C1C1E";
                    ctx.lineWidth = Math.max(2.0, r * 0.040);
                    ctx.lineCap = "round";
                    ctx.stroke();

                    // 7. Aguja de los segundos (Naranja vibrante macOS con cola contrapeso)
                    var secLen = r * 0.86;
                    var secTail = r * 0.22;
                    ctx.beginPath();
                    ctx.moveTo(cx - secTail * Math.cos(secAngle), cy - secTail * Math.sin(secAngle));
                    ctx.lineTo(cx + secLen * Math.cos(secAngle), cy + secLen * Math.sin(secAngle));
                    ctx.strokeStyle = "#FF9500";
                    ctx.lineWidth = Math.max(1.2, r * 0.018);
                    ctx.lineCap = "round";
                    ctx.stroke();

                    // 8. Tapa central naranja con orificio oscuro
                    var capRadius = Math.max(3.2, r * 0.052);
                    ctx.beginPath();
                    ctx.arc(cx, cy, capRadius, 0, 2 * Math.PI, false);
                    ctx.fillStyle = "#FF9500";
                    ctx.fill();

                    // Punto central interno
                    ctx.beginPath();
                    ctx.arc(cx, cy, capRadius * 0.40, 0, 2 * Math.PI, false);
                    ctx.fillStyle = "#1C1C1E";
                    ctx.fill();
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 1. MODO PEQUEÑO (170 x 170): ESFERA EXACTA DE LA IMAGEN ──
        // ═══════════════════════════════════════════════════════════════════
        Item {
            anchors.fill: parent
            visible: root.isSmall

            AnalogClockFace {
                anchors.centerIn: parent
                dialSize: Math.min(parent.width, parent.height) - 24
            }

            // Botón interactivo para expandir a pronóstico de días posteriores
            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 9
                width: 22
                height: 22
                radius: 11
                color: expMa.containsMouse ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(1, 1, 1, 0.12)
                border.color: Qt.rgba(1, 1, 1, 0.20)
                border.width: 1
                z: 10

                Text {
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: 0.5
                    text: "›"
                    font.family: "SF Pro Display, Inter, sans-serif"
                    font.pixelSize: 15
                    font.weight: Font.Bold
                    color: "#FFFFFF"
                }

                MouseArea {
                    id: expMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.widgetsState) root.widgetsState.toggleClockExpanded();
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 2. MODO MEDIANO (354 x 170): ESFERA + PRONÓSTICO DÍAS POSTERIORES ──
        // ═══════════════════════════════════════════════════════════════════
        Item {
            anchors.fill: parent
            visible: root.isMedium || (!root.isSmall && !root.isLarge)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 14
                spacing: 12

                // Lado Izquierdo: Reloj Analógico
                AnalogClockFace {
                    Layout.alignment: Qt.AlignVCenter
                    dialSize: 138
                }

                // Lado Derecho: Pronóstico de Días Posteriores
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.topMargin: 10
                    Layout.bottomMargin: 10
                    spacing: 4

                    // Cabecera: Ciudad / Temperatura y Botón Contraer
                    RowLayout {
                        Layout.fillWidth: true

                        ColumnLayout {
                            spacing: 1
                            RowLayout {
                                spacing: 4
                                Text {
                                    text: ""
                                    font.family: "CaskaydiaCove Nerd Font"
                                    font.pixelSize: 10
                                    color: "#FF9F0A"
                                }
                                Text {
                                    text: root.widgetsState ? root.widgetsState.clockCity : "BUENOS AIRES"
                                    font.family: "SF Pro Display, Inter, sans-serif"
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                    color: "#FF9F0A"
                                    elide: Text.ElideRight
                                }
                            }
                            Text {
                                text: (root.widgetsState ? root.widgetsState.weatherTemp : "--°C") + " · " + (root.widgetsState ? root.widgetsState.weatherDesc : "Despejado")
                                font.family: "SF Pro Display, Inter, sans-serif"
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                color: "#FFFFFF"
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Botón Contraer (‹)
                        Rectangle {
                            width: 20
                            height: 20
                            radius: 10
                            color: colMa.containsMouse ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(1, 1, 1, 0.12)
                            border.color: Qt.rgba(1, 1, 1, 0.20)
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                anchors.horizontalCenterOffset: -0.5
                                text: "‹"
                                font.family: "SF Pro Display, Inter, sans-serif"
                                font.pixelSize: 15
                                font.weight: Font.Bold
                                color: "#FFFFFF"
                            }

                            MouseArea {
                                id: colMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.widgetsState) root.widgetsState.toggleClockExpanded();
                                }
                            }
                        }
                    }

                    // Separador sutil
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Qt.rgba(1, 1, 1, 0.10)
                    }

                    // Pronóstico de Días Posteriores
                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 4
                        model: root.widgetsState && root.widgetsState.weatherDaily && root.widgetsState.weatherDaily.length > 0
                            ? root.widgetsState.weatherDaily
                            : (root.widgetsState ? root.widgetsState.weatherHourly : [])

                        delegate: Rectangle {
                            width: parent ? parent.width : 180
                            height: 26
                            radius: 6
                            color: Qt.rgba(1, 1, 1, 0.06)

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 6

                                // Día (Hoy, Mañana, etc.)
                                Text {
                                    text: modelData.day || modelData.time || ""
                                    font.family: "SF Pro Display"
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                    color: "#FFFFFF"
                                    Layout.preferredWidth: 44
                                }

                                // Icono
                                Text {
                                    text: modelData.icon || "󰖙"
                                    font.family: "CaskaydiaCove Nerd Font"
                                    font.pixelSize: 12
                                    color: "#FF9F0A"
                                }

                                // Descripción breve
                                Text {
                                    text: modelData.desc || ""
                                    font.family: "SF Pro Display"
                                    font.pixelSize: 9
                                    color: Qt.rgba(1, 1, 1, 0.65)
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                // Min / Max
                                Text {
                                    text: modelData.max ? (modelData.min + " / " + modelData.max) : (modelData.temp || "")
                                    font.family: "SF Pro Display"
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                    color: "#FFFFFF"
                                }
                            }
                        }
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 3. MODO EXPANDIDO (354 x 354): RELOJ GRANDE + RELOJES MUNDIALES ──
        // ═══════════════════════════════════════════════════════════════════
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            visible: root.isLarge

            // Esfera analógica superior grande
            AnalogClockFace {
                Layout.alignment: Qt.AlignHCenter
                dialSize: 170
            }

            // Hora digital central
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: root.widgetsState ? root.widgetsState.clockTime : "12:00"
                font.family: "SF Pro Display, Inter, sans-serif"
                font.pixelSize: 26
                font.weight: Font.Bold
                color: "#FFFFFF"
            }

            // Separador
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(1.000, 1.000, 1.000, 0.12)
            }

            // Relojes Mundiales estilo macOS
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Repeater {
                    model: [
                        { city: "Cupertino", diff: "-4 HRS", time: "17:45" },
                        { city: "Londres",   diff: "+4 HRS", time: "01:45" },
                        { city: "Tokio",     diff: "+12 HRS", time: "09:45" }
                    ]

                    Rectangle {
                        Layout.fillWidth: true
                        height: 48
                        radius: 10
                        color: Qt.rgba(1.000, 1.000, 1.000, 0.08)

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 2

                            Text {
                                text: modelData.city
                                font.family: "SF Pro Display"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: "#FFFFFF"
                            }
                            RowLayout {
                                Text {
                                    text: modelData.diff
                                    font.family: "SF Pro Display"
                                    font.pixelSize: 9
                                    color: Qt.rgba(1.000, 1.000, 1.000, 0.55)
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: modelData.time
                                    font.family: "SF Pro Display"
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                    color: "#FF9F0A"
                                }
                            }
                        }
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── MENÚ CONTEXTUAL FLOTANTE (CLIC DERECHO) ──
        // ═══════════════════════════════════════════════════════════════════
        Rectangle {
            id: contextMenu
            visible: root.contextMenuOpen
            width: 190
            height: menuCol.implicitHeight + 16
            anchors.centerIn: parent
            radius: 12
            color: root.widgetsState && root.widgetsState.isDarkTheme ? "#1E1E24" : "#FFFFFF"
            border.color: root.widgetsState ? root.widgetsState.cardBorder : "rgba(255,255,255,0.2)"
            border.width: 1
            z: 200

            ColumnLayout {
                id: menuCol
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4

                Text {
                    text: "UBICACIÓN Y CLIMA"
                    font.family: "SF Pro Display"
                    font.pixelSize: 9
                    font.weight: Font.Bold
                    font.letterSpacing: 0.5
                    color: root.widgetsState ? root.widgetsState.textDim : "#8E8E93"
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 22
                    radius: 6
                    color: bsaMa.containsMouse ? "rgba(10, 132, 255, 0.25)" : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "Buenos Aires"
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"
                    }
                    MouseArea {
                        id: bsaMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.widgetsState) root.widgetsState.setWeatherLocation("Buenos Aires");
                            root.contextMenuOpen = false;
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 22
                    radius: 6
                    color: autMa.containsMouse ? "rgba(48, 209, 88, 0.25)" : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "Auto por IP"
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        color: "#30D158"
                    }
                    MouseArea {
                        id: autMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.widgetsState) root.widgetsState.setWeatherLocation("");
                            root.contextMenuOpen = false;
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(1.000, 1.000, 1.000, 0.12)
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 22
                    radius: 6
                    color: refMa.containsMouse ? "rgba(255, 255, 255, 0.15)" : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "Actualizar clima"
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"
                    }
                    MouseArea {
                        id: refMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.widgetsState) root.widgetsState.refreshWeather();
                            root.contextMenuOpen = false;
                        }
                    }
                }
            }
        }
    }
}
