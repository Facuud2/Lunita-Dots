import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    property var widgetsState

    readonly property bool isSmall: root.width <= 220
    readonly property bool isMedium: root.width > 220 && root.height <= 240
    readonly property bool isLarge: root.width > 220 && root.height > 240

    readonly property real cardRadius: root.widgetsState ? root.widgetsState.cardRadius : 22
    readonly property string fontFamily: "-apple-system, BlinkMacSystemFont, 'SF Pro Display', 'SF Pro Text', Cantarell, Roboto, sans-serif"

    // ── Métricas de Salud y Anillos de Actividad (Apple Fitness) ──────────
    readonly property int calories: root.widgetsState ? root.widgetsState.healthCalories : 450
    readonly property int caloriesGoal: root.widgetsState ? root.widgetsState.healthCaloriesGoal : 600

    readonly property int exercise: root.widgetsState ? root.widgetsState.healthExercise : 24
    readonly property int exerciseGoal: root.widgetsState ? root.widgetsState.healthExerciseGoal : 30

    readonly property int steps: root.widgetsState ? root.widgetsState.healthSteps : 8420
    readonly property int stepsGoal: root.widgetsState ? root.widgetsState.healthStepsGoal : 10000

    readonly property var history: (root.widgetsState && root.widgetsState.healthHistory && root.widgetsState.healthHistory.length === 7) ? root.widgetsState.healthHistory : [
        { "day": "L", "cal_pct": 90, "ex_pct": 100, "step_pct": 85 },
        { "day": "M", "cal_pct": 110, "ex_pct": 80, "step_pct": 95 },
        { "day": "M", "cal_pct": 75, "ex_pct": 60, "step_pct": 70 },
        { "day": "J", "cal_pct": 100, "ex_pct": 100, "step_pct": 110 },
        { "day": "V", "cal_pct": 85, "ex_pct": 90, "step_pct": 90 },
        { "day": "S", "cal_pct": 120, "ex_pct": 110, "step_pct": 105 },
        { "day": "D", "cal_pct": 75, "ex_pct": 80, "step_pct": 84 }
    ]

    // Porcentajes de progreso
    readonly property real rawCalPct: calories / Math.max(1, caloriesGoal)
    readonly property real rawExPct: exercise / Math.max(1, exerciseGoal)
    readonly property real rawStepPct: steps / Math.max(1, stepsGoal)

    // Animación fluida de llenado radial (Behavior con Easing.OutCubic)
    property real animCalPct: rawCalPct
    property real animExPct: rawExPct
    property real animStepPct: rawStepPct

    Behavior on animCalPct {
        NumberAnimation {
            duration: 800
            easing.type: Easing.OutCubic
        }
    }

    Behavior on animExPct {
        NumberAnimation {
            duration: 800
            easing.type: Easing.OutCubic
        }
    }

    Behavior on animStepPct {
        NumberAnimation {
            duration: 800
            easing.type: Easing.OutCubic
        }
    }

    // ── Paleta Oficial de Anillos de Actividad Apple Fitness ──────────────
    readonly property color colMove: "#FA114F"
    readonly property color colMoveTrack: Qt.rgba(0.98, 0.07, 0.31, 0.20)

    readonly property color colExercise: "#A2FF00"
    readonly property color colExerciseTrack: Qt.rgba(0.63, 1.0, 0.0, 0.20)

    readonly property color colStand: "#00F0FF"
    readonly property color colStandTrack: Qt.rgba(0.0, 0.94, 1.0, 0.20)

    // Formateador de millares para pasos (ej: 8.420)
    function formatNumber(num) {
        return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".");
    }

    // Ajustar métricas en tiempo real
    function addCalories(delta) {
        if (root.widgetsState)
            root.widgetsState.adjustHealthMetric("calories", delta);
    }

    function addExercise(delta) {
        if (root.widgetsState)
            root.widgetsState.adjustHealthMetric("exercise", delta);
    }

    function addSteps(delta) {
        if (root.widgetsState)
            root.widgetsState.adjustHealthMetric("steps", delta);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // ── Componente de Anillos Concéntricos Apple Fitness (ActivityRings) ──
    // ═══════════════════════════════════════════════════════════════════════
    component ActivityRings : Item {
        id: ringsContainer

        property real outerRadius: 52
        property real ringWidth: 10
        property real ringGap: 2.5

        implicitWidth: (outerRadius + ringWidth) * 2
        implicitHeight: (outerRadius + ringWidth) * 2

        Canvas {
            id: ringsCanvas

            anchors.fill: parent
            antialiasing: true
            renderTarget: Canvas.FramebufferObject

            property real cPct: root.animCalPct
            property real ePct: root.animExPct
            property real sPct: root.animStepPct

            onCPctChanged: requestPaint()
            onEPctChanged: requestPaint()
            onSPctChanged: requestPaint()

            function drawRing(ctx, cx, cy, r, pct, strokeCol, trackCol) {
                var width = ringsContainer.ringWidth;

                // 1. Pista de fondo (círculo 360° translúcido)
                ctx.beginPath();
                ctx.arc(cx, cy, r, 0, 2 * Math.PI, false);
                ctx.strokeStyle = trackCol;
                ctx.lineWidth = width;
                ctx.lineCap = "round";
                ctx.stroke();

                // 2. Arco de progreso activo
                if (pct > 0.005) {
                    var startAngle = -Math.PI / 2;
                    var sweep = Math.min(pct, 2.0) * 2 * Math.PI;
                    var endAngle = startAngle + sweep;

                    ctx.beginPath();
                    ctx.arc(cx, cy, r, startAngle, endAngle, false);
                    ctx.strokeStyle = strokeCol;
                    ctx.lineWidth = width;
                    ctx.lineCap = "round";
                    ctx.stroke();

                    // 3. Efecto 3D de solapamiento Apple: cuando pct > 1.0, sombra en la punta
                    if (pct > 1.0) {
                        var capX = cx + r * Math.cos(endAngle);
                        var capY = cy + r * Math.sin(endAngle);

                        ctx.save();
                        ctx.shadowColor = "rgba(0, 0, 0, 0.45)";
                        ctx.shadowBlur = 6;
                        ctx.beginPath();
                        ctx.arc(capX, capY, width / 2, 0, 2 * Math.PI, false);
                        ctx.fillStyle = strokeCol;
                        ctx.fill();
                        ctx.restore();
                    }
                }
            }

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);

                var cx = width / 2;
                var cy = height / 2;

                var r1 = ringsContainer.outerRadius;
                var r2 = r1 - ringsContainer.ringWidth - ringsContainer.ringGap;
                var r3 = r2 - ringsContainer.ringWidth - ringsContainer.ringGap;

                // Anillo 1: Movimiento / Calorías (Rojo-Coral)
                drawRing(ctx, cx, cy, r1, ringsCanvas.cPct, root.colMove, root.colMoveTrack);

                // Anillo 2: Ejercicio (Lima Eléctrico)
                drawRing(ctx, cx, cy, r2, ringsCanvas.ePct, root.colExercise, root.colExerciseTrack);

                // Anillo 3: De pie / Pasos (Cian Eléctrico)
                drawRing(ctx, cx, cy, r3, ringsCanvas.sPct, root.colStand, root.colStandTrack);
            }
        }
    }

    // ── Tarjeta Contenedora Principal Estilo Apple OLED Black ─────────────
    Rectangle {
        id: cardBg

        anchors.fill: parent
        radius: root.cardRadius
        color: "#000000"
        clip: true
        border.color: Qt.rgba(255, 255, 255, 0.12) // taste-skill-ignore
        border.width: 1 // taste-skill-ignore

        // ═══════════════════════════════════════════════════════════════════
        // ── 1. MODO SMALL (170 x 170): ANILLOS FULL-IMMERSIVE + STATS ─────
        // ═══════════════════════════════════════════════════════════════════
        Item {
            id: smallView

            anchors.fill: parent
            visible: root.isSmall

            // Anillos Concéntricos Centrados de Gran Escala
            ActivityRings {
                anchors.centerIn: parent
                outerRadius: 52
                ringWidth: 10
                ringGap: 2.8
            }

            // Indicadores sutiles en las esquinas inferiores
            Row {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 10
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10

                // Move
                Row {
                    spacing: 3
                    Rectangle {
                        width: 5
                        height: 5
                        radius: 2.5
                        color: root.colMove
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: root.calories.toString()
                        color: "#FFFFFF"
                        font.family: root.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                    }
                }

                // Exercise
                Row {
                    spacing: 3
                    Rectangle {
                        width: 5
                        height: 5
                        radius: 2.5
                        color: root.colExercise
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: root.exercise + "m"
                        color: "#FFFFFF"
                        font.family: root.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                    }
                }

                // Steps
                Row {
                    spacing: 3
                    Rectangle {
                        width: 5
                        height: 5
                        radius: 2.5
                        color: root.colStand
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: (root.steps >= 1000 ? (root.steps / 1000).toFixed(1) + "k" : root.steps)
                        color: "#FFFFFF"
                        font.family: root.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                    }
                }
            }

            // Clic interactivo para abrir gestor
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Quickshell.execDetached(["lunita-widgets-manager"])
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 2. MODO MEDIUM (354 x 176): ANILLOS IZQ + MÉTRICAS DETALLADAS ─
        // ═══════════════════════════════════════════════════════════════════
        Item {
            id: mediumView

            anchors.fill: parent
            visible: root.isMedium || (!root.isSmall && !root.isLarge)

            // Lado Izquierdo: Anillos de Actividad
            Item {
                id: ringsLeftArea

                anchors.left: parent.left
                anchors.leftMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                width: 136
                height: 136

                ActivityRings {
                    anchors.centerIn: parent
                    outerRadius: 52
                    ringWidth: 10
                    ringGap: 2.8
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Quickshell.execDetached(["lunita-widgets-manager"])
                }
            }

            // Lado Derecho: Columnas de Métricas con Botones de Registro Rápido
            Column {
                anchors.left: ringsLeftArea.right
                anchors.leftMargin: 18
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                // Fila 1: Movimiento
                RowLayout {
                    width: parent.width
                    spacing: 8

                    Column {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: "MOVIMIENTO"
                            color: root.colMove
                            font.family: root.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            font.letterSpacing: 0.6
                        }

                        Row {
                            spacing: 3
                            Text {
                                text: root.calories.toString()
                                color: "#FFFFFF"
                                font.family: root.fontFamily
                                font.pixelSize: 18
                                font.weight: Font.DemiBold
                            }
                            Text {
                                anchors.baseline: parent.children[0].baseline
                                text: " / " + root.caloriesGoal + " KCAL"
                                color: Qt.rgba(1, 1, 1, 0.55)
                                font.family: root.fontFamily
                                font.pixelSize: 11
                                font.weight: Font.Normal
                            }
                        }
                    }

                    // Botón +50 kcal
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        color: addCalMa.containsMouse ? Qt.rgba(250, 17, 79, 0.35) : Qt.rgba(250, 17, 79, 0.18)
                        border.color: Qt.rgba(250, 17, 79, 0.45)
                        border.width: 1 // taste-skill-ignore

                        Text {
                            anchors.centerIn: parent
                            text: "+"
                            color: root.colMove
                            font.family: root.fontFamily
                            font.pixelSize: 15
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            id: addCalMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.addCalories(50)
                        }
                    }
                }

                // Fila 2: Ejercicio
                RowLayout {
                    width: parent.width
                    spacing: 8

                    Column {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: "EJERCICIO"
                            color: root.colExercise
                            font.family: root.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            font.letterSpacing: 0.6
                        }

                        Row {
                            spacing: 3
                            Text {
                                text: root.exercise.toString()
                                color: "#FFFFFF"
                                font.family: root.fontFamily
                                font.pixelSize: 18
                                font.weight: Font.DemiBold
                            }
                            Text {
                                anchors.baseline: parent.children[0].baseline
                                text: " / " + root.exerciseGoal + " MIN"
                                color: Qt.rgba(1, 1, 1, 0.55)
                                font.family: root.fontFamily
                                font.pixelSize: 11
                                font.weight: Font.Normal
                            }
                        }
                    }

                    // Botón +5 min
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        color: addExMa.containsMouse ? Qt.rgba(162, 255, 0, 0.35) : Qt.rgba(162, 255, 0, 0.18)
                        border.color: Qt.rgba(162, 255, 0, 0.45)
                        border.width: 1 // taste-skill-ignore

                        Text {
                            anchors.centerIn: parent
                            text: "+"
                            color: root.colExercise
                            font.family: root.fontFamily
                            font.pixelSize: 15
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            id: addExMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.addExercise(5)
                        }
                    }
                }

                // Fila 3: De pie / Pasos
                RowLayout {
                    width: parent.width
                    spacing: 8

                    Column {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: "DE PIE / PASOS"
                            color: root.colStand
                            font.family: root.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            font.letterSpacing: 0.6
                        }

                        Row {
                            spacing: 3
                            Text {
                                text: root.formatNumber(root.steps)
                                color: "#FFFFFF"
                                font.family: root.fontFamily
                                font.pixelSize: 18
                                font.weight: Font.DemiBold
                            }
                            Text {
                                anchors.baseline: parent.children[0].baseline
                                text: " / " + root.formatNumber(root.stepsGoal)
                                color: Qt.rgba(1, 1, 1, 0.55)
                                font.family: root.fontFamily
                                font.pixelSize: 11
                                font.weight: Font.Normal
                            }
                        }
                    }

                    // Botón +500 pasos
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        color: addStepMa.containsMouse ? Qt.rgba(0, 240, 255, 0.35) : Qt.rgba(0, 240, 255, 0.18)
                        border.color: Qt.rgba(0, 240, 255, 0.45)
                        border.width: 1 // taste-skill-ignore

                        Text {
                            anchors.centerIn: parent
                            text: "+"
                            color: root.colStand
                            font.family: root.fontFamily
                            font.pixelSize: 15
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            id: addStepMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.addSteps(500)
                        }
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 3. MODO LARGE (354 x 354): ANILLOS + GRÁFICO SEMANAL + QUICK ──
        // ═══════════════════════════════════════════════════════════════════
        Item {
            id: largeView

            anchors.fill: parent
            visible: root.isLarge

            Column {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 16

                // Sección 1: Anillos + Resumen de Métricas
                RowLayout {
                    width: parent.width
                    spacing: 18

                    Item {
                        Layout.preferredWidth: 126
                        Layout.preferredHeight: 126

                        ActivityRings {
                            anchors.centerIn: parent
                            outerRadius: 48
                            ringWidth: 9
                            ringGap: 2.6
                        }
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 10

                        // Movimiento
                        Column {
                            spacing: 1
                            Text {
                                text: "MOVIMIENTO"
                                color: root.colMove
                                font.family: root.fontFamily
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                font.letterSpacing: 0.6
                            }
                            Row {
                                spacing: 3
                                Text {
                                    text: root.calories.toString()
                                    color: "#FFFFFF"
                                    font.family: root.fontFamily
                                    font.pixelSize: 17
                                    font.weight: Font.DemiBold
                                }
                                Text {
                                    anchors.baseline: parent.children[0].baseline
                                    text: " / " + root.caloriesGoal + " KCAL"
                                    color: Qt.rgba(1, 1, 1, 0.55)
                                    font.family: root.fontFamily
                                    font.pixelSize: 11
                                }
                            }
                        }

                        // Ejercicio
                        Column {
                            spacing: 1
                            Text {
                                text: "EJERCICIO"
                                color: root.colExercise
                                font.family: root.fontFamily
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                font.letterSpacing: 0.6
                            }
                            Row {
                                spacing: 3
                                Text {
                                    text: root.exercise.toString()
                                    color: "#FFFFFF"
                                    font.family: root.fontFamily
                                    font.pixelSize: 17
                                    font.weight: Font.DemiBold
                                }
                                Text {
                                    anchors.baseline: parent.children[0].baseline
                                    text: " / " + root.exerciseGoal + " MIN"
                                    color: Qt.rgba(1, 1, 1, 0.55)
                                    font.family: root.fontFamily
                                    font.pixelSize: 11
                                }
                            }
                        }

                        // De pie
                        Column {
                            spacing: 1
                            Text {
                                text: "DE PIE / PASOS"
                                color: root.colStand
                                font.family: root.fontFamily
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                font.letterSpacing: 0.6
                            }
                            Row {
                                spacing: 3
                                Text {
                                    text: root.formatNumber(root.steps)
                                    color: "#FFFFFF"
                                    font.family: root.fontFamily
                                    font.pixelSize: 17
                                    font.weight: Font.DemiBold
                                }
                                Text {
                                    anchors.baseline: parent.children[0].baseline
                                    text: " / " + root.formatNumber(root.stepsGoal)
                                    color: Qt.rgba(1, 1, 1, 0.55)
                                    font.family: root.fontFamily
                                    font.pixelSize: 11
                                }
                            }
                        }
                    }
                }

                // Sección 2: Historial Semanal Estilo Apple Activity
                Rectangle {
                    width: parent.width
                    height: 86
                    radius: 14
                    color: Qt.rgba(255, 255, 255, 0.05)
                    border.color: Qt.rgba(255, 255, 255, 0.08)
                    border.width: 1 // taste-skill-ignore

                    Row {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 0

                        Repeater {
                            model: 7

                            Item {
                                width: (parent.width) / 7
                                height: parent.height

                                readonly property var dayData: root.history[index] || ({ "day": "D", "cal_pct": 50, "ex_pct": 50, "step_pct": 50 })

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 6

                                    // Barras triples concéntricas verticales
                                    Row {
                                        spacing: 3
                                        anchors.horizontalCenter: parent.horizontalCenter

                                        // Barra Move
                                        Rectangle {
                                            width: 4
                                            height: 38
                                            radius: 2
                                            color: Qt.rgba(250, 17, 79, 0.20)

                                            Rectangle {
                                                anchors.bottom: parent.bottom
                                                width: parent.width
                                                height: Math.min(parent.height, Math.round(parent.height * (dayData.cal_pct / 100)))
                                                radius: 2
                                                color: root.colMove
                                            }
                                        }

                                        // Barra Exercise
                                        Rectangle {
                                            width: 4
                                            height: 38
                                            radius: 2
                                            color: Qt.rgba(162, 255, 0, 0.20)

                                            Rectangle {
                                                anchors.bottom: parent.bottom
                                                width: parent.width
                                                height: Math.min(parent.height, Math.round(parent.height * (dayData.ex_pct / 100)))
                                                radius: 2
                                                color: root.colExercise
                                            }
                                        }

                                        // Barra Stand
                                        Rectangle {
                                            width: 4
                                            height: 38
                                            radius: 2
                                            color: Qt.rgba(0, 240, 255, 0.20)

                                            Rectangle {
                                                anchors.bottom: parent.bottom
                                                width: parent.width
                                                height: Math.min(parent.height, Math.round(parent.height * (dayData.step_pct / 100)))
                                                radius: 2
                                                color: root.colStand
                                            }
                                        }
                                    }

                                    // Letra del Día
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: dayData.day || ""
                                        color: Qt.rgba(1, 1, 1, 0.65)
                                        font.family: root.fontFamily
                                        font.pixelSize: 11
                                        font.weight: Font.DemiBold
                                    }
                                }
                            }
                        }
                    }
                }

                // Sección 3: Botones de Registro Rápido
                RowLayout {
                    width: parent.width
                    spacing: 8

                    Rectangle {
                        Layout.fillWidth: true
                        height: 36
                        radius: 12
                        color: btnCalMa.containsMouse ? Qt.rgba(250, 17, 79, 0.32) : Qt.rgba(250, 17, 79, 0.16)
                        border.color: Qt.rgba(250, 17, 79, 0.40)
                        border.width: 1 // taste-skill-ignore

                        Text {
                            anchors.centerIn: parent
                            text: "+100 kcal"
                            color: root.colMove
                            font.family: root.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            id: btnCalMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.addCalories(100)
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 36
                        radius: 12
                        color: btnExMa.containsMouse ? Qt.rgba(162, 255, 0, 0.32) : Qt.rgba(162, 255, 0, 0.16)
                        border.color: Qt.rgba(162, 255, 0, 0.40)
                        border.width: 1 // taste-skill-ignore

                        Text {
                            anchors.centerIn: parent
                            text: "+15 min"
                            color: root.colExercise
                            font.family: root.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            id: btnExMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.addExercise(15)
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 36
                        radius: 12
                        color: btnStepMa.containsMouse ? Qt.rgba(0, 240, 255, 0.32) : Qt.rgba(0, 240, 255, 0.16)
                        border.color: Qt.rgba(0, 240, 255, 0.40)
                        border.width: 1 // taste-skill-ignore

                        Text {
                            anchors.centerIn: parent
                            text: "+1.000 pasos"
                            color: root.colStand
                            font.family: root.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            id: btnStepMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.addSteps(1000)
                        }
                    }
                }
            }
        }
    }
}
