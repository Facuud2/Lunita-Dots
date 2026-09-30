import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root
    property var widgetsState

    readonly property bool isSmall: root.width <= 220
    readonly property bool isMedium: root.width > 220 && root.height <= 240
    readonly property bool isLarge: root.width > 220 && root.height > 240

    // Health metrics from WidgetsState
    readonly property int calories: root.widgetsState ? root.widgetsState.healthCalories : 540
    readonly property int caloriesGoal: root.widgetsState ? root.widgetsState.healthCaloriesGoal : 600
    readonly property int exercise: root.widgetsState ? root.widgetsState.healthExercise : 35
    readonly property int exerciseGoal: root.widgetsState ? root.widgetsState.healthExerciseGoal : 30
    readonly property int steps: root.widgetsState ? root.widgetsState.healthSteps : 8450
    readonly property int stepsGoal: root.widgetsState ? root.widgetsState.healthStepsGoal : 10000
    readonly property real water: root.widgetsState ? root.widgetsState.healthWater : 2.1
    readonly property real waterGoal: root.widgetsState ? root.widgetsState.healthWaterGoal : 2.5
    readonly property var history: root.widgetsState ? root.widgetsState.healthHistory : []

    // Progress percentages
    readonly property real calPct: Math.min(1.5, calories / Math.max(1, caloriesGoal))
    readonly property real exPct: Math.min(1.5, exercise / Math.max(1, exerciseGoal))
    readonly property real stepPct: Math.min(1.5, steps / Math.max(1, stepsGoal))
    readonly property int avgPct: Math.round(((calPct + exPct + stepPct) / 3.0) * 100)

    // Modal state for direct editing
    property bool editModalOpen: false

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 22
        color: root.widgetsState && root.widgetsState.isDarkTheme ? "#1C1428" : (root.widgetsState ? root.widgetsState.cardBg : "#1C1428")
        border.color: root.widgetsState ? root.widgetsState.cardBorder : Qt.rgba(1, 1, 1, 0.12)
        border.width: 1
        clip: true

        // ═══════════════════════════════════════════════════════════════════
        // ── COMPONENTE REUTILIZABLE: ANILLOS DE ACTIVIDAD CONCÉNTRICOS ──
        // ═══════════════════════════════════════════════════════════════════
        component ActivityRingsCanvas: Item {
            id: ringsItem
            property real outerRadius: 52
            property real ringWidth: 7.5
            property real ringGap: 3.5

            implicitWidth: (outerRadius + ringWidth) * 2
            implicitHeight: (outerRadius + ringWidth) * 2

            Canvas {
                id: ringCanvas
                anchors.fill: parent
                renderTarget: Canvas.FramebufferObject
                antialiasing: true

                property real pCal: root.calPct
                property real pEx: root.exPct
                property real pStep: root.stepPct

                onPCalChanged: requestPaint()
                onPExChanged: requestPaint()
                onPStepChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);

                    var cx = width / 2;
                    var cy = height / 2;

                    var r1 = ringsItem.outerRadius;
                    var r2 = r1 - ringsItem.ringWidth - ringsItem.ringGap;
                    var r3 = r2 - ringsItem.ringWidth - ringsItem.ringGap;

                    function drawRing(r, pct, strokeColor, trackColor) {
                        // 1. Track
                        ctx.beginPath();
                        ctx.arc(cx, cy, r, 0, 2 * Math.PI, false);
                        ctx.strokeStyle = trackColor;
                        ctx.lineWidth = ringsItem.ringWidth;
                        ctx.lineCap = "round";
                        ctx.stroke();

                        // 2. Active arc
                        if (pct > 0.01) {
                            var start = -Math.PI / 2;
                            var sweep = pct * 2 * Math.PI;
                            var end = start + sweep;

                            ctx.beginPath();
                            ctx.arc(cx, cy, r, start, end, false);
                            ctx.strokeStyle = strokeColor;
                            ctx.lineWidth = ringsItem.ringWidth;
                            ctx.lineCap = "round";
                            ctx.stroke();
                        }
                    }

                    // Anillo 1: Calorías / Moverse (Rojo vibrante #FA114F)
                    drawRing(r1, ringCanvas.pCal, "#FA114F", "rgba(250, 17, 79, 0.22)");

                    // Anillo 2: Ejercicio (Verde Lima #A1F435)
                    drawRing(r2, ringCanvas.pEx, "#A1F435", "rgba(161, 244, 53, 0.22)");

                    // Anillo 3: Pasos / De pie (Cian #00F5D4)
                    drawRing(r3, ringCanvas.pStep, "#00F5D4", "rgba(0, 245, 212, 0.22)");
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 1. MODO COMPACTO (170 x 170): ANILLOS CENTRADOS + STATS ──
        // ═══════════════════════════════════════════════════════════════════
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 4
            visible: root.isSmall && !root.editModalOpen

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 5

                Text {
                    text: "󰈸"
                    font.family: "CaskaydiaCove Nerd Font"
                    font.pixelSize: 13
                    color: "#FA114F"
                }

                Text {
                    text: "ACTIVIDAD"
                    font.family: "SF Pro Display"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.6)
                    font.letterSpacing: 0.6
                }

                Item { Layout.fillWidth: true }

                // Badge de promedio
                Rectangle {
                    height: 16
                    radius: 8
                    implicitWidth: pctRow.implicitWidth + 8
                    color: Qt.rgba(0.98, 0.07, 0.31, 0.18)
                    border.color: Qt.rgba(0.98, 0.07, 0.31, 0.40)
                    border.width: 1

                    RowLayout {
                        id: pctRow
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            text: root.avgPct + "%"
                            font.family: "SF Pro Display"
                            font.pixelSize: 8
                            font.weight: Font.Bold
                            color: "#FA114F"
                        }
                    }
                }
            }

            // Anillos de actividad
            Item {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 88
                Layout.preferredHeight: 88

                ActivityRingsCanvas {
                    anchors.centerIn: parent
                    outerRadius: 36
                    ringWidth: 6.0
                    ringGap: 2.5
                }

                // Clic para abrir modal de ajuste
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                    onClicked: root.editModalOpen = true
                }
            }

            // Bottom metric indicators
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 6

                // Calorías
                RowLayout {
                    spacing: 3
                    Rectangle { width: 5; height: 5; radius: 2.5; color: "#FA114F" }
                    Text {
                        text: root.calories.toString()
                        font.family: "SF Pro Display"
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                    }
                }

                // Ejercicio
                RowLayout {
                    spacing: 3
                    Rectangle { width: 5; height: 5; radius: 2.5; color: "#A1F435" }
                    Text {
                        text: root.exercise + "m"
                        font.family: "SF Pro Display"
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                    }
                }

                // Pasos
                RowLayout {
                    spacing: 3
                    Rectangle { width: 5; height: 5; radius: 2.5; color: "#00F5D4" }
                    Text {
                        text: (root.steps >= 1000 ? (root.steps / 1000).toFixed(1) + "k" : root.steps)
                        font.family: "SF Pro Display"
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 2. MODO MEDIO (354 x 170): ANILLOS + METRICS CARD & CONTROLS ──
        // ═══════════════════════════════════════════════════════════════════
        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 14
            visible: root.isMedium && !root.editModalOpen

            // Left: Concentric Rings + Icon/Percentage
            Item {
                Layout.preferredWidth: 126
                Layout.preferredHeight: 126
                Layout.alignment: Qt.AlignVCenter

                ActivityRingsCanvas {
                    anchors.centerIn: parent
                    outerRadius: 50
                    ringWidth: 7.5
                    ringGap: 3.5
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 1

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "󰈸"
                        font.family: "CaskaydiaCove Nerd Font"
                        font.pixelSize: 15
                        color: "#FA114F"
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: root.avgPct + "%"
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                    onClicked: root.editModalOpen = true
                }
            }

            // Right: 4 Metrics Rows with quick +/- adjustment buttons
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 4

                // Header with Edit button
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: "SALUD & ACTIVIDAD"
                        font.family: "SF Pro Display"
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.6)
                        font.letterSpacing: 0.6
                    }

                    Item { Layout.fillWidth: true }

                    // Botón Editar manual
                    Rectangle {
                        height: 16
                        radius: 8
                        implicitWidth: editRow.implicitWidth + 8
                        color: editMa.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.08)
                        border.color: Qt.rgba(1, 1, 1, 0.18)
                        border.width: 1

                        RowLayout {
                            id: editRow
                            anchors.centerIn: parent
                            spacing: 3
                            Text {
                                text: "󰏫"
                                font.family: "CaskaydiaCove Nerd Font"
                                font.pixelSize: 9
                                color: "#007AFF"
                            }
                            Text {
                                text: "Editar"
                                font.family: "SF Pro Display"
                                font.pixelSize: 8
                                font.weight: Font.Bold
                                color: "#FFFFFF"
                            }
                        }

                        MouseArea {
                            id: editMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                            onClicked: root.editModalOpen = true
                        }
                    }
                }

                // 1. Calorías (Moverse)
                Rectangle {
                    Layout.fillWidth: true
                    height: 25
                    radius: 7
                    color: Qt.rgba(1, 1, 1, 0.05)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
                        spacing: 6

                        Text { text: "󰈸"; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 11; color: "#FA114F" }
                        Text {
                            text: root.calories + " / " + root.caloriesGoal + " kcal"
                            font.family: "SF Pro Display"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            color: "#FFFFFF"
                            Layout.fillWidth: true
                        }

                        // [-50]
                        Text {
                            text: "－"
                            font.family: "SF Pro Display"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: Qt.rgba(1, 1, 1, 0.7)
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                                onClicked: if (root.widgetsState) root.widgetsState.adjustHealthMetric("calories", -50)
                            }
                        }

                        // [+50]
                        Text {
                            text: "＋"
                            font.family: "SF Pro Display"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: "#FA114F"
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                                onClicked: if (root.widgetsState) root.widgetsState.adjustHealthMetric("calories", 50)
                            }
                        }
                    }
                }

                // 2. Ejercicio
                Rectangle {
                    Layout.fillWidth: true
                    height: 25
                    radius: 7
                    color: Qt.rgba(1, 1, 1, 0.05)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
                        spacing: 6

                        Text { text: "󰋫"; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 11; color: "#A1F435" }
                        Text {
                            text: root.exercise + " / " + root.exerciseGoal + " min"
                            font.family: "SF Pro Display"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            color: "#FFFFFF"
                            Layout.fillWidth: true
                        }

                        // [-10]
                        Text {
                            text: "－"
                            font.family: "SF Pro Display"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: Qt.rgba(1, 1, 1, 0.7)
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                                onClicked: if (root.widgetsState) root.widgetsState.adjustHealthMetric("exercise", -10)
                            }
                        }

                        // [+10]
                        Text {
                            text: "＋"
                            font.family: "SF Pro Display"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: "#A1F435"
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                                onClicked: if (root.widgetsState) root.widgetsState.adjustHealthMetric("exercise", 10)
                            }
                        }
                    }
                }

                // 3. Pasos
                Rectangle {
                    Layout.fillWidth: true
                    height: 25
                    radius: 7
                    color: Qt.rgba(1, 1, 1, 0.05)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
                        spacing: 6

                        Text { text: "󰁞"; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 11; color: "#00F5D4" }
                        Text {
                            text: root.steps.toLocaleString(Qt.locale(), 'f', 0) + " / " + (root.stepsGoal / 1000) + "k pasos"
                            font.family: "SF Pro Display"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            color: "#FFFFFF"
                            Layout.fillWidth: true
                        }

                        // [-500]
                        Text {
                            text: "－"
                            font.family: "SF Pro Display"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: Qt.rgba(1, 1, 1, 0.7)
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                                onClicked: if (root.widgetsState) root.widgetsState.adjustHealthMetric("steps", -500)
                            }
                        }

                        // [+500]
                        Text {
                            text: "＋"
                            font.family: "SF Pro Display"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: "#00F5D4"
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                                onClicked: if (root.widgetsState) root.widgetsState.adjustHealthMetric("steps", 500)
                            }
                        }
                    }
                }

                // 4. Agua / Hidratación
                Rectangle {
                    Layout.fillWidth: true
                    height: 25
                    radius: 7
                    color: Qt.rgba(1, 1, 1, 0.05)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
                        spacing: 6

                        Text { text: "󰅟"; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 11; color: "#0A84FF" }
                        Text {
                            text: root.water.toFixed(1) + " / " + root.waterGoal.toFixed(1) + " L"
                            font.family: "SF Pro Display"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            color: "#FFFFFF"
                            Layout.fillWidth: true
                        }

                        // [-0.25]
                        Text {
                            text: "－"
                            font.family: "SF Pro Display"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: Qt.rgba(1, 1, 1, 0.7)
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                                onClicked: if (root.widgetsState) root.widgetsState.adjustHealthMetric("water", -0.25)
                            }
                        }

                        // [+0.25]
                        Text {
                            text: "＋"
                            font.family: "SF Pro Display"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: "#0A84FF"
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                                onClicked: if (root.widgetsState) root.widgetsState.adjustHealthMetric("water", 0.25)
                            }
                        }
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 3. MODO EXPANDIDO (354 x 354): RESUMEN SEMANAL + HISTORIAL ──
        // ═══════════════════════════════════════════════════════════════════
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10
            visible: root.isLarge && !root.editModalOpen

            // Top: Header & Edit button
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Text { text: "󰈸"; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 14; color: "#FA114F" }
                Text {
                    text: "ACTIVIDAD SEMANAL"
                    font.family: "SF Pro Display"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    height: 18
                    radius: 9
                    implicitWidth: editRowL.implicitWidth + 10
                    color: Qt.rgba(1, 1, 1, 0.10)
                    border.color: Qt.rgba(1, 1, 1, 0.18)
                    border.width: 1

                    RowLayout {
                        id: editRowL
                        anchors.centerIn: parent
                        spacing: 4
                        Text { text: "󰏫"; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 10; color: "#007AFF" }
                        Text { text: "Editar Métricas"; font.family: "SF Pro Display"; font.pixelSize: 9; font.weight: Font.Bold; color: "#FFFFFF" }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                        onClicked: root.editModalOpen = true
                    }
                }
            }

            // Middle: Activity Rings + Daily stats row
            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Item {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 120

                    ActivityRingsCanvas {
                        anchors.centerIn: parent
                        outerRadius: 48
                        ringWidth: 7.0
                        ringGap: 3.5
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 1
                        Text { Layout.alignment: Qt.AlignHCenter; text: "󰈸"; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 14; color: "#FA114F" }
                        Text { Layout.alignment: Qt.AlignHCenter; text: root.avgPct + "%"; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold; color: "#FFFFFF" }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    // Stats chips
                    Repeater {
                        model: [
                            { label: "Moverse", val: root.calories + " kcal", goal: root.caloriesGoal + " kcal", color: "#FA114F", icon: "󰈸" },
                            { label: "Ejercicio", val: root.exercise + " min", goal: root.exerciseGoal + " min", color: "#A1F435", icon: "󰋫" },
                            { label: "Pasos", val: root.steps.toLocaleString(Qt.locale(), 'f', 0), goal: (root.stepsGoal / 1000) + "k", color: "#00F5D4", icon: "󰁞" },
                            { label: "Agua", val: root.water.toFixed(1) + " L", goal: root.waterGoal.toFixed(1) + " L", color: "#0A84FF", icon: "󰅟" }
                        ]

                        Rectangle {
                            Layout.fillWidth: true
                            height: 24
                            radius: 6
                            color: Qt.rgba(1, 1, 1, 0.05)

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 6

                                Text { text: modelData.icon; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 10; color: modelData.color }
                                Text { text: modelData.label; font.family: "SF Pro Display"; font.pixelSize: 9; color: Qt.rgba(1, 1, 1, 0.65) }
                                Item { Layout.fillWidth: true }
                                Text { text: modelData.val; font.family: "SF Pro Display"; font.pixelSize: 9; font.weight: Font.Bold; color: "#FFFFFF" }
                            }
                        }
                    }
                }
            }

            // Separator
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(1, 1, 1, 0.10)
            }

            // History title
            Text {
                text: "HISTORIAL DE LOS ÚLTIMOS 7 DÍAS"
                font.family: "SF Pro Display"
                font.pixelSize: 9
                font.weight: Font.Bold
                font.letterSpacing: 0.5
                color: Qt.rgba(1, 1, 1, 0.55)
            }

            // Weekly mini bars
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 8

                Repeater {
                    model: root.history.length > 0 ? root.history : [
                        { day: "L", cal_pct: 95 }, { day: "M", cal_pct: 90 }, { day: "M", cal_pct: 80 },
                        { day: "J", cal_pct: 105 }, { day: "V", cal_pct: 88 }, { day: "S", cal_pct: 110 }, { day: "D", cal_pct: 90 }
                    ]

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 4

                        // Bar background
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 4
                            color: Qt.rgba(1, 1, 1, 0.08)

                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: Math.min(parent.height, parent.height * ((modelData.cal_pct || 50) / 120.0))
                                radius: 4
                                color: (modelData.cal_pct >= 100) ? "#30D158" : "#FA114F"
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.day
                            font.family: "SF Pro Display"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            color: Qt.rgba(1, 1, 1, 0.7)
                        }
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 4. MODAL / DIÁLOGO DE EDICIÓN MANUAL DE MÉTRICAS ──
        // ═══════════════════════════════════════════════════════════════════
        Rectangle {
            anchors.fill: parent
            radius: 22
            color: root.widgetsState && root.widgetsState.isDarkTheme ? "#161022" : "#FFFFFF"
            visible: root.editModalOpen
            border.color: "#FA114F"
            border.width: 1.5

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text { text: "󰏫"; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 12; color: "#FA114F" }
                    Text {
                        text: "REGISTRAR ACTIVIDAD"
                        font.family: "SF Pro Display"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"
                    }

                    Item { Layout.fillWidth: true }

                    // Botón Cerrar ✕
                    Rectangle {
                        width: 20
                        height: 20
                        radius: 10
                        color: closeMa.containsMouse ? "#FF453A" : Qt.rgba(1, 1, 1, 0.12)

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            font.family: "SF Pro Display"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            color: "#FFFFFF"
                        }

                        MouseArea {
                            id: closeMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.editModalOpen = false
                        }
                    }
                }

                // Grid de campos para editar
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: 6
                    columnSpacing: 8

                    // 1. Calorías
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text { text: "Calorías (kcal)"; font.family: "SF Pro Display"; font.pixelSize: 9; color: "#FA114F"; font.weight: Font.Bold }
                        Rectangle {
                            Layout.fillWidth: true
                            height: 26
                            radius: 6
                            color: Qt.rgba(1, 1, 1, 0.08)
                            border.color: calInput.activeFocus ? "#FA114F" : Qt.rgba(1, 1, 1, 0.15)
                            border.width: 1

                            TextInput {
                                id: calInput
                                anchors.fill: parent
                                anchors.margins: 4
                                text: root.calories.toString()
                                font.family: "SF Pro Display"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: "#FFFFFF"
                                verticalAlignment: TextInput.AlignVCenter
                                validator: IntValidator { bottom: 0; top: 10000 }
                            }
                        }
                    }

                    // 2. Ejercicio
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text { text: "Ejercicio (min)"; font.family: "SF Pro Display"; font.pixelSize: 9; color: "#A1F435"; font.weight: Font.Bold }
                        Rectangle {
                            Layout.fillWidth: true
                            height: 26
                            radius: 6
                            color: Qt.rgba(1, 1, 1, 0.08)
                            border.color: exInput.activeFocus ? "#A1F435" : Qt.rgba(1, 1, 1, 0.15)
                            border.width: 1

                            TextInput {
                                id: exInput
                                anchors.fill: parent
                                anchors.margins: 4
                                text: root.exercise.toString()
                                font.family: "SF Pro Display"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: "#FFFFFF"
                                verticalAlignment: TextInput.AlignVCenter
                                validator: IntValidator { bottom: 0; top: 1440 }
                            }
                        }
                    }

                    // 3. Pasos
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text { text: "Pasos"; font.family: "SF Pro Display"; font.pixelSize: 9; color: "#00F5D4"; font.weight: Font.Bold }
                        Rectangle {
                            Layout.fillWidth: true
                            height: 26
                            radius: 6
                            color: Qt.rgba(1, 1, 1, 0.08)
                            border.color: stepsInput.activeFocus ? "#00F5D4" : Qt.rgba(1, 1, 1, 0.15)
                            border.width: 1

                            TextInput {
                                id: stepsInput
                                anchors.fill: parent
                                anchors.margins: 4
                                text: root.steps.toString()
                                font.family: "SF Pro Display"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: "#FFFFFF"
                                verticalAlignment: TextInput.AlignVCenter
                                validator: IntValidator { bottom: 0; top: 100000 }
                            }
                        }
                    }

                    // 4. Agua
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text { text: "Agua (Litros)"; font.family: "SF Pro Display"; font.pixelSize: 9; color: "#0A84FF"; font.weight: Font.Bold }
                        Rectangle {
                            Layout.fillWidth: true
                            height: 26
                            radius: 6
                            color: Qt.rgba(1, 1, 1, 0.08)
                            border.color: waterInput.activeFocus ? "#0A84FF" : Qt.rgba(1, 1, 1, 0.15)
                            border.width: 1

                            TextInput {
                                id: waterInput
                                anchors.fill: parent
                                anchors.margins: 4
                                text: root.water.toFixed(1)
                                font.family: "SF Pro Display"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: "#FFFFFF"
                                verticalAlignment: TextInput.AlignVCenter
                                validator: DoubleValidator { bottom: 0.0; top: 10.0; decimals: 2 }
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                // Botón Guardar
                Rectangle {
                    Layout.fillWidth: true
                    height: 28
                    radius: 8
                    color: saveMa.containsMouse ? "#FA114F" : Qt.rgba(0.98, 0.07, 0.31, 0.85)

                    Text {
                        anchors.centerIn: parent
                        text: "Guardar Cambios"
                        font.family: "SF Pro Display"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        id: saveMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.widgetsState) {
                                var c = parseInt(calInput.text) || 0;
                                var e = parseInt(exInput.text) || 0;
                                var s = parseInt(stepsInput.text) || 0;
                                var w = parseFloat(waterInput.text) || 0.0;

                                root.widgetsState.setHealthMetric("calories", c);
                                root.widgetsState.setHealthMetric("exercise", e);
                                root.widgetsState.setHealthMetric("steps", s);
                                root.widgetsState.setHealthMetric("water", w);
                            }
                            root.editModalOpen = false;
                        }
                    }
                }
            }
        }
    }
}
