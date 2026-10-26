import QtQuick
import QtQuick.Controls

Item {
    id: root

    property var widgetsState: null
    property var canvas: null

    readonly property var skin: root.widgetsState ? root.widgetsState.skin : null
    readonly property bool nothing: root.skin ? root.skin.isNothing : false

    // Forzar dimensiones pequeñas estándar (170 x 170)
    width: 170
    height: 170

    Rectangle {
        id: cardBg

        anchors.fill: parent
        radius: root.nothing ? root.skin.radius : (root.widgetsState ? root.widgetsState.cardRadius : 22)
        clip: true
        color: root.nothing ? root.skin.card : (root.widgetsState ? root.widgetsState.cardBg : "#211A39")
        border.color: root.nothing ? "transparent" : (root.widgetsState ? root.widgetsState.cardBorder : Qt.rgba(1, 1, 1, 0.12))
        border.width: root.nothing ? 0 : 1
        scale: cardMa.pressed ? 0.985 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }

        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        MouseArea {
            id: cardMa
            anchors.fill: parent
            enabled: !root.widgetsState || !root.widgetsState.isEditing
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                Quickshell.execDetached(["lunita-widgets-manager", "clock"]);
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── ESFERA ANALÓGICA EXCLUSIVA (Reloj Suave macOS, Centrado) ───────
        // ═══════════════════════════════════════════════════════════════════
        AnalogClockFace {
            id: mainClockFace
            visible: !root.nothing
            anchors.centerIn: parent
            dialSize: 142
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── SKIN NOTHING: HORA DOT-MATRIX APILADA ──────────────────────────
        // ═══════════════════════════════════════════════════════════════════
        Item {
            id: nothingFace

            property date now: new Date()

            anchors.fill: parent
            anchors.margins: root.nothing ? root.skin.pad : 16
            visible: root.nothing

            Timer {
                interval: 1000
                running: nothingFace.visible
                repeat: true
                triggeredOnStart: true
                onTriggered: nothingFace.now = new Date()
            }

            // Punto rojo de "en vivo": late con los segundos
            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: 4
                width: 8
                height: 8
                radius: 4
                color: root.nothing ? root.skin.signal : "red"
                opacity: nothingFace.now.getSeconds() % 2 === 0 ? 1 : 0.25

                Behavior on opacity {
                    NumberAnimation { duration: 250; easing.type: Easing.InOutSine }
                }
            }

            Column {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.topMargin: -4
                spacing: -14

                Text {
                    text: Qt.formatTime(nothingFace.now, "HH")
                    font.family: root.nothing ? root.skin.fontFigure : "Doto"
                    font.pixelSize: 54
                    color: root.nothing ? root.skin.ink : "white"
                }

                Text {
                    text: Qt.formatTime(nothingFace.now, "mm")
                    font.family: root.nothing ? root.skin.fontFigure : "Doto"
                    font.pixelSize: 54
                    color: root.nothing ? root.skin.inkDim : "grey"
                }
            }

            Text {
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                text: {
                    var s = nothingFace.now.toLocaleDateString(Qt.locale("es_AR"), "ddd d MMM");
                    return s.charAt(0).toUpperCase() + s.slice(1).replace(/\./g, "");
                }
                font.family: root.nothing ? root.skin.fontText : "sans-serif"
                font.pixelSize: root.nothing ? root.skin.sizeBody : 14
                font.weight: Font.Medium
                color: root.nothing ? root.skin.ink : "white"
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── COMPONENTE REUTILIZABLE: ESFERA ANALÓGICA macOS ────────────────
        // ═══════════════════════════════════════════════════════════════════
        component AnalogClockFace: Item {
            id: clockFace

            property real dialSize: 142

            width: dialSize
            height: dialSize

            Timer {
                interval: 200
                running: clockFace.visible
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
                    ctx.lineWidth = 1;
                    ctx.stroke();

                    // 2. Marcas de minutos y horas (60 ticks)
                    for (var i = 0; i < 60; i++) {
                        var angle = (i / 60) * 2 * Math.PI - Math.PI / 2;
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
                        var nAngle = (n / 12) * 2 * Math.PI - Math.PI / 2;
                        var nx = cx + numRadius * Math.cos(nAngle);
                        var ny = cy + numRadius * Math.sin(nAngle);
                        ctx.fillText(n.toString(), nx, ny + 0.5);
                    }

                    // 4. Obtener hora actual con fracciones para movimiento suave
                    var now = new Date();
                    var sec = now.getSeconds() + now.getMilliseconds() / 1000;
                    var min = now.getMinutes() + sec / 60;
                    var hr = (now.getHours() % 12) + min / 60;
                    var hrAngle = (hr / 12) * 2 * Math.PI - Math.PI / 2;
                    var minAngle = (min / 60) * 2 * Math.PI - Math.PI / 2;
                    var secAngle = (sec / 60) * 2 * Math.PI - Math.PI / 2;

                    // 5. Aguja de las horas (Negra, redondeada)
                    var hrLen = r * 0.5;
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
                    ctx.moveTo(cx - (r * 0.1) * Math.cos(minAngle), cy - (r * 0.1) * Math.sin(minAngle));
                    ctx.lineTo(cx + minLen * Math.cos(minAngle), cy + minLen * Math.sin(minAngle));
                    ctx.strokeStyle = "#1C1C1E";
                    ctx.lineWidth = Math.max(2, r * 0.04);
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

                    ctx.beginPath();
                    ctx.arc(cx, cy, capRadius * 0.4, 0, 2 * Math.PI, false);
                    ctx.fillStyle = "#1C1C1E";
                    ctx.fill();
                }
            }
        }
    }
}
