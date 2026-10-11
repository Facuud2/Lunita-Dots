import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root
    property var widgetsState
    property var canvas: null
    property bool contextMenuOpen: false
    property int forecastTab: 0 // 0 = 4 Horas, 1 = Días
    readonly property real expandProgress: Math.max(0.0, Math.min(1.0, (root.width - 170.0) / (354.0 - 170.0)))

    function toggleExpanded() {
        if (root.canvas) {
            root.canvas.toggleClockExpanded();
        } else if (root.widgetsState) {
            root.widgetsState.toggleClockExpanded();
        }
    }

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
        // ── ESFERA ANALÓGICA UNIFICADA (Estable, sin parpadeos) ─────────────
        // ═══════════════════════════════════════════════════════════════════
        AnalogClockFace {
            id: mainClockFace
            visible: !root.isLarge
            dialSize: 138
            x: 16
            y: (parent.height - dialSize) / 2
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── MODO PEQUEÑO: PÍLDORA DE CLIMA Y BOTÓN DE EXPANSIÓN ─────────────
        // ═══════════════════════════════════════════════════════════════════
        Rectangle {
            id: smallWeatherPill
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 8
            x: 16 + (138 - width) / 2
            height: 20
            implicitWidth: weatherSmallRow.implicitWidth + 14
            radius: 10
            color: wSmMa.containsMouse ? Qt.rgba(0.12, 0.12, 0.18, 0.90) : Qt.rgba(0.08, 0.08, 0.12, 0.75)
            border.color: wSmMa.containsMouse ? Qt.rgba(1, 1, 1, 0.35) : Qt.rgba(1, 1, 1, 0.18)
            border.width: 1
            z: 10

            opacity: Math.max(0.0, 1.0 - root.expandProgress * 3.0)
            visible: opacity > 0.01 && !root.isLarge

            RowLayout {
                id: weatherSmallRow
                anchors.centerIn: parent
                spacing: 4

                Text {
                    text: root.widgetsState ? (root.widgetsState.weatherIcon || "󰖙") : "󰖙"
                    font.family: "CaskaydiaCove Nerd Font"
                    font.pixelSize: 11
                    color: "#FF9F0A"
                }
                Text {
                    text: root.widgetsState ? (root.widgetsState.weatherTemp || "--°C") : "--°C"
                    font.family: "SF Pro Display, Inter, sans-serif"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    color: "#FFFFFF"
                }
            }

            MouseArea {
                id: wSmMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.toggleExpanded();
                }
            }
        }

        // Botón interactivo para expandir a pronóstico de días posteriores (›)
        Rectangle {
            id: smallExpandBtn
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

            opacity: Math.max(0.0, 1.0 - root.expandProgress * 3.0)
            visible: opacity > 0.01 && !root.isLarge

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
                    root.toggleExpanded();
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 2. PANEL DE TEMPERATURAS Y CLIMA (DESPLIEGUE FLUIDO macOS) ────
        // ═══════════════════════════════════════════════════════════════════
        Item {
            id: weatherExpandedPanel
            x: 166
            y: 8
            width: 174
            height: parent.height - 16
            visible: opacity > 0.005 && !root.isLarge
            z: 10

            // Animación fluida moderna estilo macOS (Fade-in + Slide-in armónico)
            opacity: Math.max(0.0, Math.min(1.0, (root.expandProgress - 0.08) / 0.92))
            transform: Translate {
                x: (1.0 - root.expandProgress) * 26
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 2

                // ── Cabecera: Ubicación, Temperatura y Botón Contraer ──
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        RowLayout {
                            spacing: 4
                            Text {
                                text: ""
                                font.family: "CaskaydiaCove Nerd Font"
                                font.pixelSize: 10
                                color: "#FF9F0A"
                            }
                            Text {
                                Layout.fillWidth: true
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
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                            color: "#FFFFFF"
                            elide: Text.ElideRight
                        }
                    }

                    // Botón Contraer (‹) con estilo macOS
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
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            color: "#FFFFFF"
                        }

                        MouseArea {
                            id: colMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.toggleExpanded();
                            }
                        }
                    }
                }

                // ── Métricas Secundarias: Humedad y Viento ──
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Text {
                        text: "󰖌 " + (root.widgetsState ? root.widgetsState.weatherHumidity : "--%")
                        font.family: "CaskaydiaCove Nerd Font, SF Pro Display"
                        font.pixelSize: 8
                        color: Qt.rgba(1, 1, 1, 0.60)
                    }
                    Text {
                        text: "󰖝 " + (root.widgetsState ? root.widgetsState.weatherWind : "-- km/h")
                        font.family: "CaskaydiaCove Nerd Font, SF Pro Display"
                        font.pixelSize: 8
                        color: Qt.rgba(1, 1, 1, 0.60)
                    }
                }

                // ── Selector Segmentado macOS [ 4 Horas | 3 Días ] ──
                Rectangle {
                    Layout.fillWidth: true
                    height: 18
                    radius: 9
                    color: Qt.rgba(0, 0, 0, 0.25)
                    border.color: Qt.rgba(1, 1, 1, 0.10)
                    border.width: 1

                    // Pastilla deslizante indicadora activa
                    Rectangle {
                        x: root.forecastTab === 0 ? 1 : (parent.width / 2)
                        y: 1
                        width: (parent.width / 2) - 1
                        height: parent.height - 2
                        radius: 8
                        color: Qt.rgba(1, 1, 1, 0.20)

                        Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                    }

                    RowLayout {
                        anchors.fill: parent
                        spacing: 0

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Text {
                                anchors.centerIn: parent
                                text: "4 Horas"
                                font.family: "SF Pro Display"
                                font.pixelSize: 8
                                font.weight: root.forecastTab === 0 ? Font.Bold : Font.Normal
                                color: root.forecastTab === 0 ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.60)
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.forecastTab = 0
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Text {
                                anchors.centerIn: parent
                                text: "3 Días"
                                font.family: "SF Pro Display"
                                font.pixelSize: 8
                                font.weight: root.forecastTab === 1 ? Font.Bold : Font.Normal
                                color: root.forecastTab === 1 ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.60)
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.forecastTab = 1
                            }
                        }
                    }
                }

                // ── Lista de Pronósticos con Entrada Escalonada macOS ──
                ListView {
                    id: forecastListView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 2
                    model: root.forecastTab === 0
                        ? ((root.widgetsState && root.widgetsState.weatherHourly) ? root.widgetsState.weatherHourly : [])
                        : ((root.widgetsState && root.widgetsState.weatherDaily) ? root.widgetsState.weatherDaily : [])

                    delegate: Rectangle {
                        id: forecastRow
                        width: forecastListView.width
                        height: 18
                        radius: 5
                        color: fRowMa.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.05)

                        // Animación escalonada según índice al desplegarse
                        transform: Translate {
                            x: (1.0 - root.expandProgress) * (14 + index * 4)
                        }
                        opacity: Math.max(0.0, Math.min(1.0, (root.expandProgress - (0.20 + index * 0.07)) / 0.70))

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            spacing: 4

                            // Hora o Día
                            Text {
                                text: modelData.time || modelData.day || ""
                                font.family: "SF Pro Display"
                                font.pixelSize: 9
                                font.weight: Font.Bold
                                color: "#FFFFFF"
                                Layout.preferredWidth: 42
                            }

                            // Icono
                            Text {
                                text: modelData.icon || "󰖙"
                                font.family: "CaskaydiaCove Nerd Font"
                                font.pixelSize: 11
                                color: "#FF9F0A"
                            }

                            Item { Layout.fillWidth: true }

                            // Temperatura o Rango mín/máx
                            Text {
                                text: modelData.temp || (modelData.max ? (modelData.min + " / " + modelData.max) : "")
                                font.family: "SF Pro Display"
                                font.pixelSize: 9
                                font.weight: Font.Bold
                                color: "#FFFFFF"
                            }
                        }

                        MouseArea {
                            id: fRowMa
                            anchors.fill: parent
                            hoverEnabled: true
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
        MouseArea {
            id: contextMenuBackdrop
            anchors.fill: parent
            visible: root.contextMenuOpen
            z: 199
            onClicked: root.contextMenuOpen = false
        }

        Rectangle {
            id: contextMenu
            width: 204
            height: menuCol.implicitHeight + 16
            anchors.centerIn: parent
            radius: 14
            color: root.widgetsState && root.widgetsState.isDarkTheme ? "#1C1C24" : "#FFFFFF"
            border.color: root.widgetsState ? root.widgetsState.cardBorder : Qt.rgba(1, 1, 1, 0.20)
            border.width: 1
            z: 200

            // Animación emergente fluida estilo macOS (Spring/Pop & Fade)
            scale: root.contextMenuOpen ? 1.0 : 0.88
            opacity: root.contextMenuOpen ? 1.0 : 0.0
            visible: opacity > 0.005
            transformOrigin: Item.Center

            Behavior on scale {
                NumberAnimation { duration: 220; easing.type: Easing.OutBack }
            }
            Behavior on opacity {
                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
            }

            ColumnLayout {
                id: menuCol
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "UBICACIÓN Y CLIMA"
                        font.family: "SF Pro Display"
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        font.letterSpacing: 0.5
                        color: root.widgetsState ? root.widgetsState.textDim : "#8E8E93"
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "✕"
                        font.pixelSize: 10
                        color: Qt.rgba(1, 1, 1, 0.5)
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.contextMenuOpen = false
                        }
                    }
                }

                // Input para buscar cualquier ciudad
                Rectangle {
                    Layout.fillWidth: true
                    height: 24
                    radius: 6
                    color: Qt.rgba(1, 1, 1, 0.08)
                    border.color: cityInput.activeFocus ? "#007AFF" : Qt.rgba(1, 1, 1, 0.15)
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
                        spacing: 4

                        Text { text: ""; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 9; color: "#8E8E93" }

                        TextInput {
                            id: cityInput
                            Layout.fillWidth: true
                            font.family: "SF Pro Display"
                            font.pixelSize: 10
                            color: "#FFFFFF"
                            verticalAlignment: TextInput.AlignVCenter
                            clip: true
                            onAccepted: {
                                if (text.trim() !== "" && root.widgetsState) {
                                    root.widgetsState.setWeatherLocation(text.trim());
                                    root.contextMenuOpen = false;
                                }
                            }

                            Text {
                                text: "Buscar ciudad..."
                                font.family: "SF Pro Display"
                                font.pixelSize: 10
                                color: Qt.rgba(1, 1, 1, 0.35)
                                visible: !cityInput.text && !cityInput.activeFocus
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
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
                        text: "Auto por IP (GeoIP)"
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
