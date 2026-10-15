import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root
    property var widgetsState

    readonly property bool isSmall: root.width <= 220
    readonly property bool isMedium: root.width > 220 && root.height <= 240
    readonly property bool isLarge: root.width > 220 && root.height > 240

    readonly property bool isActive: root.widgetsState ? !!root.widgetsState.ttIsActive : false
    readonly property bool isFinishingSoon: root.widgetsState ? !!root.widgetsState.ttIsFinishingSoon : false

    // Tab state for Small mode: 0 = Clases, 1 = Tareas, 2 = Notas
    property int smallTab: 0

    // Modal state for adding a new task or editing notes
    property bool addTaskModalOpen: false
    property bool notesModalOpen: false

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 22
        color: isFinishingSoon
            ? (root.widgetsState && root.widgetsState.isDarkTheme ? Qt.rgba(0.20, 0.14, 0.10, 0.85) : Qt.rgba(1.0, 0.96, 0.90, 0.90))
            : (root.widgetsState ? root.widgetsState.cardBg : Qt.rgba(0.12, 0.14, 0.18, 0.75))
        border.color: isFinishingSoon ? "#FF9F0A" : (root.widgetsState ? root.widgetsState.cardBorder : Qt.rgba(1, 1, 1, 0.14))
        border.width: isFinishingSoon ? 1.5 : 1
        clip: true

        Behavior on color { ColorAnimation { duration: 350 } }
        Behavior on border.color { ColorAnimation { duration: 350 } }

        // ═══════════════════════════════════════════════════════════════════
        // ── 1. MODO COMPACTO (170 x 170): TABS CLASES / TAREAS ──
        // ═══════════════════════════════════════════════════════════════════
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 11
            spacing: 5
            visible: root.isSmall && !root.addTaskModalOpen && !root.notesModalOpen

            // Header with segmented tabs
            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                // Segmented control
                Rectangle {
                    height: 20
                    radius: 10
                    implicitWidth: 84
                    color: Qt.rgba(1, 1, 1, 0.08)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 2
                        spacing: 2

                        // Tab 0: Agenda
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 8
                            color: root.smallTab === 0 ? (root.isActive ? "#30D158" : "#007AFF") : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "Agenda"
                                font.family: "SF Pro Display"
                                font.pixelSize: 8
                                font.weight: Font.Bold
                                color: root.smallTab === 0 ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.55)
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.smallTab = 0
                            }
                        }

                        // Tab 1: Tareas
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 8
                            color: root.smallTab === 1 ? "#AF52DE" : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "Tareas"
                                font.family: "SF Pro Display"
                                font.pixelSize: 8
                                font.weight: Font.Bold
                                color: root.smallTab === 1 ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.55)
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.smallTab = 1
                            }
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Quick add task button (+)
                Rectangle {
                    width: 20
                    height: 20
                    radius: 10
                    color: plusMaS.containsMouse ? "#007AFF" : Qt.rgba(1, 1, 1, 0.10)

                    Text {
                        anchors.centerIn: parent
                        text: "＋"
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        id: plusMaS
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                        onClicked: root.addTaskModalOpen = true
                    }
                }
            }

            // --- Vista Tab 0: Clases UNaB ---
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 3
                visible: root.smallTab === 0

                // Subject Title
                Text {
                    Layout.fillWidth: true
                    text: root.widgetsState && root.widgetsState.ttSubject ? root.widgetsState.ttSubject : "Laboratorio"
                    font.family: "SF Pro Display"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"
                    elide: Text.ElideRight
                    maximumLineCount: 2
                    wrapMode: Text.WordWrap
                }

                // Aula & Horario
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: "󰔛 " + (root.widgetsState && root.widgetsState.ttStart ? root.widgetsState.ttStart + " - " + root.widgetsState.ttEnd : "18:00 - 22:00")
                        font.family: "CaskaydiaCove Nerd Font, SF Pro Display"
                        font.pixelSize: 9
                        color: isFinishingSoon ? "#FF9F0A" : (isActive ? "#30D158" : Qt.rgba(1, 1, 1, 0.6))
                    }
                }

                Text {
                    text: "󰮤 " + (root.widgetsState && root.widgetsState.ttRoom ? root.widgetsState.ttRoom : "Aula 104")
                    font.family: "CaskaydiaCove Nerd Font, SF Pro Display"
                    font.pixelSize: 9
                    color: Qt.rgba(1, 1, 1, 0.55)
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Item { Layout.fillHeight: true }

                // Status chip / countdown
                Rectangle {
                    Layout.fillWidth: true
                    height: 22
                    radius: 7
                    color: isFinishingSoon ? Qt.rgba(1.0, 0.62, 0.04, 0.20) : (isActive ? Qt.rgba(0.19, 0.82, 0.35, 0.20) : Qt.rgba(0.0, 0.48, 1.0, 0.16))
                    border.color: isFinishingSoon ? "#FF9F0A" : (isActive ? "#30D158" : "#007AFF")
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
                        spacing: 4

                        Text {
                            text: isActive ? "󱎫" : "󱑂"
                            font.family: "CaskaydiaCove Nerd Font"
                            font.pixelSize: 10
                            color: isFinishingSoon ? "#FF9F0A" : (isActive ? "#30D158" : "#007AFF")
                        }

                        Text {
                            text: root.widgetsState && root.widgetsState.ttTimeLeftStr ? root.widgetsState.ttTimeLeftStr : "Próxima semana"
                            font.family: "SF Pro Display"
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                            color: "#FFFFFF"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            // --- Vista Tab 1: Tareas de Estudio & Trabajo ---
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4
                visible: root.smallTab === 1
                model: root.widgetsState && root.widgetsState.ttTasks ? root.widgetsState.ttTasks : []

                delegate: Rectangle {
                    width: parent ? parent.width : 148
                    height: 28
                    radius: 6
                    color: Qt.rgba(1, 1, 1, 0.06)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
                        spacing: 6

                        // Checkbox
                        Rectangle {
                            width: 14
                            height: 14
                            radius: 7
                            color: modelData.done ? (modelData.tag_color || "#30D158") : "transparent"
                            border.color: modelData.done ? (modelData.tag_color || "#30D158") : Qt.rgba(1, 1, 1, 0.4)
                            border.width: 1.5

                            Text {
                                anchors.centerIn: parent
                                text: "✓"
                                font.pixelSize: 8
                                font.weight: Font.Black
                                color: "#FFFFFF"
                                visible: modelData.done
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.widgetsState) root.widgetsState.toggleTimetableTask(modelData.id);
                                }
                            }
                        }

                        // Title
                        Text {
                            text: modelData.title
                            font.family: "SF Pro Display"
                            font.pixelSize: 9
                            font.weight: Font.Medium
                            font.strikeout: !!modelData.done
                            color: modelData.done ? Qt.rgba(1, 1, 1, 0.4) : "#FFFFFF"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 2. MODO MEDIO (354 x 170): DUAL VIEW (CLASE IZQ + TAREAS DER) ──
        // ═══════════════════════════════════════════════════════════════════
        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12
            visible: root.isMedium && !root.addTaskModalOpen && !root.notesModalOpen

            // Left Side: Current/Upcoming Class Card
            Rectangle {
                Layout.preferredWidth: 154
                Layout.fillHeight: true
                radius: 14
                color: Qt.rgba(1, 1, 1, 0.05)
                border.color: Qt.rgba(1, 1, 1, 0.10)
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 9
                    spacing: 4

                    // Header Tag
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text { text: "󰸗"; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 11; color: isActive ? "#30D158" : "#007AFF" }
                        Text {
                            text: "AGENDA"
                            font.family: "SF Pro Display"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.6)
                            font.letterSpacing: 0.6
                        }

                        Item { Layout.fillWidth: true }

                        Rectangle {
                            height: 14
                            radius: 7
                            implicitWidth: Math.max(44, statusText.implicitWidth + 8)
                            color: isActive ? Qt.rgba(0.19, 0.82, 0.35, 0.20) : Qt.rgba(0.0, 0.48, 1.0, 0.16)

                            Text {
                                id: statusText
                                anchors.centerIn: parent
                                text: root.widgetsState && root.widgetsState.ttStatusLabel ? root.widgetsState.ttStatusLabel.toUpperCase() : (isActive ? "EN CURSO" : "AGENDA")
                                font.family: "SF Pro Display"
                                font.pixelSize: 7
                                font.weight: Font.Bold
                                color: isActive ? "#30D158" : "#007AFF"
                            }
                        }
                    }

                    // Subject
                    Text {
                        Layout.fillWidth: true
                        text: root.widgetsState && root.widgetsState.ttSubject ? root.widgetsState.ttSubject : "Laboratorio I"
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"
                        elide: Text.ElideRight
                        maximumLineCount: 2
                        wrapMode: Text.WordWrap
                    }

                    // Room & Prof
                    Text {
                        text: "󰮤 " + (root.widgetsState && root.widgetsState.ttRoom ? root.widgetsState.ttRoom : "Lab 2")
                        font.family: "CaskaydiaCove Nerd Font, SF Pro Display"
                        font.pixelSize: 9
                        color: Qt.rgba(1, 1, 1, 0.6)
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "󰔛 " + (root.widgetsState && root.widgetsState.ttStart ? root.widgetsState.ttStart + " - " + root.widgetsState.ttEnd : "18:30 - 21:30")
                        font.family: "CaskaydiaCove Nerd Font, SF Pro Display"
                        font.pixelSize: 9
                        color: isFinishingSoon ? "#FF9F0A" : (isActive ? "#30D158" : Qt.rgba(1, 1, 1, 0.7))
                    }

                    Item { Layout.fillHeight: true }

                    // Countdown / Status badge
                    Text {
                        Layout.fillWidth: true
                        text: root.widgetsState && root.widgetsState.ttTimeLeftStr ? root.widgetsState.ttTimeLeftStr : "Mañana a las 18:30"
                        font.family: "SF Pro Display"
                        font.pixelSize: 9
                        font.weight: Font.DemiBold
                        color: isFinishingSoon ? "#FF9F0A" : (isActive ? "#30D158" : "#007AFF")
                        elide: Text.ElideRight
                    }
                }
            }

            // Right Side: Work & Study Tasks / Notes
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 4

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: "TAREAS & NOTAS"
                        font.family: "SF Pro Display"
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.6)
                        font.letterSpacing: 0.6
                    }

                    Item { Layout.fillWidth: true }

                    // Botón Notas
                    Rectangle {
                        height: 16
                        radius: 8
                        implicitWidth: noteRow.implicitWidth + 8
                        color: noteMa.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.08)

                        RowLayout {
                            id: noteRow
                            anchors.centerIn: parent
                            spacing: 3
                            Text { text: "󰠮"; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 9; color: "#FF9F0A" }
                            Text { text: "Apuntes"; font.family: "SF Pro Display"; font.pixelSize: 8; font.weight: Font.Bold; color: "#FFFFFF" }
                        }

                        MouseArea {
                            id: noteMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                            onClicked: root.notesModalOpen = true
                        }
                    }

                    // Botón + Agregar Tarea
                    Rectangle {
                        height: 16
                        radius: 8
                        implicitWidth: addRow.implicitWidth + 8
                        color: addMa.containsMouse ? "#007AFF" : Qt.rgba(0.0, 0.48, 1.0, 0.25)
                        border.color: "#007AFF"
                        border.width: 1

                        RowLayout {
                            id: addRow
                            anchors.centerIn: parent
                            spacing: 3
                            Text { text: "＋"; font.family: "SF Pro Display"; font.pixelSize: 9; font.weight: Font.Bold; color: "#FFFFFF" }
                            Text { text: "Nueva"; font.family: "SF Pro Display"; font.pixelSize: 8; font.weight: Font.Bold; color: "#FFFFFF" }
                        }

                        MouseArea {
                            id: addMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                            onClicked: root.addTaskModalOpen = true
                        }
                    }
                }

                // Task List (scrollable)
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 4
                    model: root.widgetsState && root.widgetsState.ttTasks ? root.widgetsState.ttTasks : []

                    delegate: Rectangle {
                        width: parent ? parent.width : 160
                        height: 27
                        radius: 6
                        color: delMa.containsMouse ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(1, 1, 1, 0.05)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            spacing: 5

                            // Checkbox
                            Rectangle {
                                width: 13
                                height: 13
                                radius: 6.5
                                color: modelData.done ? (modelData.tag_color || "#30D158") : "transparent"
                                border.color: modelData.done ? (modelData.tag_color || "#30D158") : Qt.rgba(1, 1, 1, 0.4)
                                border.width: 1.5

                                Text {
                                    anchors.centerIn: parent
                                    text: "✓"
                                    font.pixelSize: 8
                                    font.weight: Font.Black
                                    color: "#FFFFFF"
                                    visible: modelData.done
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.widgetsState) root.widgetsState.toggleTimetableTask(modelData.id);
                                    }
                                }
                            }

                            // Title
                            Text {
                                text: modelData.title
                                font.family: "SF Pro Display"
                                font.pixelSize: 9
                                font.weight: Font.Medium
                                font.strikeout: !!modelData.done
                                color: modelData.done ? Qt.rgba(1, 1, 1, 0.35) : "#FFFFFF"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            // Tag badge
                            Rectangle {
                                height: 13
                                radius: 4
                                implicitWidth: tagTxt.implicitWidth + 6
                                color: Qt.rgba(1, 1, 1, 0.08)

                                Text {
                                    id: tagTxt
                                    anchors.centerIn: parent
                                    text: modelData.tag || "UNaB"
                                    font.family: "SF Pro Display"
                                    font.pixelSize: 7
                                    font.weight: Font.Bold
                                    color: modelData.tag_color || "#007AFF"
                                }
                            }

                            // Delete button (on hover)
                            Text {
                                text: "✕"
                                font.pixelSize: 8
                                color: Qt.rgba(1, 1, 1, 0.4)
                                visible: delMa.containsMouse

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.widgetsState) root.widgetsState.deleteTimetableTask(modelData.id);
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: delMa
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.NoButton
                        }
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 3. MODO EXPANDIDO (354 x 354): WORKSTATION COMPLETO ──
        // ═══════════════════════════════════════════════════════════════════
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8
            visible: root.isLarge && !root.addTaskModalOpen && !root.notesModalOpen

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Text { text: "󰠮"; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 14; color: "#007AFF" }
                Text {
                    text: "NOTAS & AGENDA"
                    font.family: "SF Pro Display"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    height: 18
                    radius: 9
                    implicitWidth: addLargeRow.implicitWidth + 8
                    color: "#007AFF"

                    RowLayout {
                        id: addLargeRow
                        anchors.centerIn: parent
                        spacing: 3
                        Text { text: "＋"; font.pixelSize: 10; font.weight: Font.Bold; color: "#FFFFFF" }
                        Text { text: "Agregar"; font.family: "SF Pro Display"; font.pixelSize: 9; font.weight: Font.Bold; color: "#FFFFFF" }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                        onClicked: root.addTaskModalOpen = true
                    }
                }
            }

            // Current Class / Agenda Banner
            Rectangle {
                Layout.fillWidth: true
                height: 52
                radius: 10
                color: Qt.rgba(1, 1, 1, 0.06)

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: root.widgetsState && root.widgetsState.ttSubject ? root.widgetsState.ttSubject : "Sin eventos programados"
                            font.family: "SF Pro Display"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: "#FFFFFF"
                            elide: Text.ElideRight
                        }
                        Text {
                            text: (root.widgetsState && root.widgetsState.ttRoom ? root.widgetsState.ttRoom : "General") + " • " + (root.widgetsState && root.widgetsState.ttStart ? root.widgetsState.ttStart : "Todo el día")
                            font.family: "SF Pro Display"
                            font.pixelSize: 9
                            color: Qt.rgba(1, 1, 1, 0.6)
                            elide: Text.ElideRight
                        }
                    }

                    Rectangle {
                        height: 20
                        radius: 10
                        implicitWidth: Math.max(50, largeTimeText.implicitWidth + 12)
                        color: isActive ? Qt.rgba(0.19, 0.82, 0.35, 0.20) : Qt.rgba(0.0, 0.48, 1.0, 0.20)
                        Text {
                            id: largeTimeText
                            anchors.centerIn: parent
                            text: root.widgetsState && root.widgetsState.ttTimeLeftStr ? root.widgetsState.ttTimeLeftStr : (root.widgetsState && root.widgetsState.ttStart ? root.widgetsState.ttStart : "Hoy")
                            font.family: "SF Pro Display"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            color: isActive ? "#30D158" : "#007AFF"
                        }
                    }
                }
            }

            // Task List
            ListView {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                clip: true
                spacing: 5
                model: root.widgetsState && root.widgetsState.ttTasks ? root.widgetsState.ttTasks : []

                delegate: Rectangle {
                    width: parent ? parent.width : 320
                    height: 28
                    radius: 6
                    color: Qt.rgba(1, 1, 1, 0.05)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 6

                        Rectangle {
                            width: 14
                            height: 14
                            radius: 7
                            color: modelData.done ? (modelData.tag_color || "#30D158") : "transparent"
                            border.color: modelData.done ? (modelData.tag_color || "#30D158") : Qt.rgba(1, 1, 1, 0.4)
                            border.width: 1.5

                            Text {
                                anchors.centerIn: parent
                                text: "✓"
                                font.pixelSize: 8
                                font.weight: Font.Black
                                color: "#FFFFFF"
                                visible: modelData.done
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: if (root.widgetsState) root.widgetsState.toggleTimetableTask(modelData.id)
                            }
                        }

                        Text {
                            text: modelData.title
                            font.family: "SF Pro Display"
                            font.pixelSize: 10
                            font.strikeout: !!modelData.done
                            color: modelData.done ? Qt.rgba(1, 1, 1, 0.4) : "#FFFFFF"
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            height: 14
                            radius: 4
                            implicitWidth: tagTxtL.implicitWidth + 8
                            color: Qt.rgba(1, 1, 1, 0.08)
                            Text {
                                id: tagTxtL
                                anchors.centerIn: parent
                                text: modelData.tag || "UNaB"
                                font.family: "SF Pro Display"
                                font.pixelSize: 8
                                font.weight: Font.Bold
                                color: modelData.tag_color || "#007AFF"
                            }
                        }
                    }
                }
            }

            // Separator
            Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(1, 1, 1, 0.10) }

            // Notes / Scratchpad section
            Text {
                text: "APUNTES & NOTAS RÁPIDAS"
                font.family: "SF Pro Display"
                font.pixelSize: 9
                font.weight: Font.Bold
                color: Qt.rgba(1, 1, 1, 0.55)
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: Qt.rgba(1, 1, 1, 0.05)
                border.color: Qt.rgba(1, 1, 1, 0.10)
                border.width: 1

                TextEdit {
                    id: largeNotesEdit
                    anchors.fill: parent
                    anchors.margins: 8
                    text: root.widgetsState && root.widgetsState.ttNotes ? root.widgetsState.ttNotes : ""
                    font.family: "SF Pro Display"
                    font.pixelSize: 10
                    color: "#FFFFFF"
                    wrapMode: TextEdit.Wrap
                    onTextChanged: {
                        if (root.widgetsState) root.widgetsState.setTimetableNotes(text);
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 4. MODAL: AGREGAR NUEVO EVENTO DE AGENDA / TAREA ──
        // ═══════════════════════════════════════════════════════════════════
        Rectangle {
            anchors.fill: parent
            radius: 22
            color: root.widgetsState && root.widgetsState.isDarkTheme ? "#161B26" : "#FFFFFF"
            visible: root.addTaskModalOpen
            border.color: "#007AFF"
            border.width: 1.5
            property int modalTab: 0
            property string selectedTag: "UNaB"
            property string selectedColor: "#007AFF"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6

                // Modal Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    // Segmented Selector: Agenda vs Tarea
                    Rectangle {
                        height: 20
                        radius: 10
                        implicitWidth: 130
                        color: Qt.rgba(1, 1, 1, 0.08)

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 2
                            spacing: 2

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 8
                                color: parent.parent.parent.parent.modalTab === 0 ? "#007AFF" : "transparent"
                                Text {
                                    anchors.centerIn: parent
                                    text: "Agenda / Horario"
                                    font.family: "SF Pro Display"
                                    font.pixelSize: 8
                                    font.weight: Font.Bold
                                    color: parent.parent.parent.parent.parent.modalTab === 0 ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.55)
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: parent.parent.parent.parent.modalTab = 0
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 8
                                color: parent.parent.parent.parent.modalTab === 1 ? "#AF52DE" : "transparent"
                                Text {
                                    anchors.centerIn: parent
                                    text: "Tarea"
                                    font.family: "SF Pro Display"
                                    font.pixelSize: 8
                                    font.weight: Font.Bold
                                    color: parent.parent.parent.parent.parent.modalTab === 1 ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.55)
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: parent.parent.parent.parent.modalTab = 1
                                }
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: "✕"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: Qt.rgba(1, 1, 1, 0.6)
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.addTaskModalOpen = false
                        }
                    }
                }

                // Campo Título
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: parent.parent.parent.modalTab === 0 ? "Título del Evento / Clase" : "Descripción de la Tarea"
                        font.family: "SF Pro Display"
                        font.pixelSize: 9
                        color: Qt.rgba(1, 1, 1, 0.6)
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        height: 26
                        radius: 6
                        color: Qt.rgba(1, 1, 1, 0.08)
                        border.color: titleInput.activeFocus ? "#007AFF" : Qt.rgba(1, 1, 1, 0.15)
                        border.width: 1
                        TextInput {
                            id: titleInput
                            anchors.fill: parent
                            anchors.margins: 4
                            font.family: "SF Pro Display"
                            font.pixelSize: 10
                            color: "#FFFFFF"
                            verticalAlignment: TextInput.AlignVCenter
                        }
                    }
                }

                // Campo Horario (Solo visible en Agenda)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    visible: parent.parent.modalTab === 0
                    Text { text: "Horario (ej: 18:00 - 20:00)"; font.family: "SF Pro Display"; font.pixelSize: 9; color: Qt.rgba(1, 1, 1, 0.6) }
                    Rectangle {
                        Layout.fillWidth: true
                        height: 24
                        radius: 6
                        color: Qt.rgba(1, 1, 1, 0.08)
                        border.color: timeInput.activeFocus ? "#007AFF" : Qt.rgba(1, 1, 1, 0.15)
                        border.width: 1
                        TextInput {
                            id: timeInput
                            anchors.fill: parent
                            anchors.margins: 4
                            font.family: "SF Pro Display"
                            font.pixelSize: 10
                            text: "18:00 - 20:00"
                            color: "#FFFFFF"
                            verticalAlignment: TextInput.AlignVCenter
                        }
                    }
                }

                // Selector de Categoría (Tag)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Repeater {
                        model: [
                            { tag: "UNaB", col: "#007AFF" },
                            { tag: "Trabajo", col: "#AF52DE" },
                            { tag: "Examen", col: "#FF9F0A" },
                            { tag: "General", col: "#30D158" }
                        ]

                        Rectangle {
                            height: 18
                            radius: 9
                            implicitWidth: 44
                            color: parent.parent.parent.parent.selectedTag === modelData.tag ? modelData.col : Qt.rgba(1, 1, 1, 0.08)

                            Text {
                                anchors.centerIn: parent
                                text: modelData.tag
                                font.family: "SF Pro Display"
                                font.pixelSize: 8
                                font.weight: Font.Bold
                                color: parent.parent.parent.parent.parent.selectedTag === modelData.tag ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.6)
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    parent.parent.parent.parent.selectedTag = modelData.tag;
                                    parent.parent.parent.parent.selectedColor = modelData.col;
                                }
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                // Botón Guardar
                Rectangle {
                    Layout.fillWidth: true
                    height: 26
                    radius: 7
                    color: parent.parent.modalTab === 0 ? "#007AFF" : "#AF52DE"

                    Text {
                        anchors.centerIn: parent
                        text: parent.parent.parent.modalTab === 0 ? "Guardar en Calendario y Agenda" : "Guardar Tarea"
                        font.family: "SF Pro Display"
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (titleInput.text.trim() !== "") {
                                if (parent.parent.parent.modalTab === 0) {
                                    var todayDate = new Date();
                                    var dStr = (root.widgetsState && root.widgetsState.calSelectedDateStr) ? root.widgetsState.calSelectedDateStr : (todayDate.getFullYear() + "-" + ("0" + (todayDate.getMonth()+1)).slice(-2) + "-" + ("0" + todayDate.getDate()).slice(-2));
                                    if (root.widgetsState) {
                                        root.widgetsState.addCalendarEvent(dStr, timeInput.text.trim() || "Todo el día", titleInput.text.trim(), parent.parent.parent.selectedTag, parent.parent.parent.selectedColor);
                                        root.widgetsState.refreshTimetable();
                                    }
                                } else {
                                    if (root.widgetsState) {
                                        root.widgetsState.addTimetableTask(titleInput.text.trim(), parent.parent.parent.selectedTag, "Pendiente");
                                    }
                                }
                                titleInput.text = "";
                            }
                            root.addTaskModalOpen = false;
                        }
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 5. MODAL: APUNTES & NOTAS SCRATCHPAD ──
        // ═══════════════════════════════════════════════════════════════════
        Rectangle {
            anchors.fill: parent
            radius: 22
            color: root.widgetsState && root.widgetsState.isDarkTheme ? "#161B26" : "#FFFFFF"
            visible: root.notesModalOpen
            border.color: "#FF9F0A"
            border.width: 1.5

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "󰠮"; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 12; color: "#FF9F0A" }
                    Text {
                        text: "APUNTES DE TRABAJO & ESTUDIO"
                        font.family: "SF Pro Display"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: "✕"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: Qt.rgba(1, 1, 1, 0.6)
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.notesModalOpen = false
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 8
                    color: Qt.rgba(1, 1, 1, 0.08)
                    border.color: Qt.rgba(1, 1, 1, 0.15)
                    border.width: 1

                    TextEdit {
                        id: modalNotesEdit
                        anchors.fill: parent
                        anchors.margins: 6
                        text: root.widgetsState && root.widgetsState.ttNotes ? root.widgetsState.ttNotes : ""
                        font.family: "SF Pro Display"
                        font.pixelSize: 10
                        color: "#FFFFFF"
                        wrapMode: TextEdit.Wrap
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 28
                    radius: 8
                    color: "#FF9F0A"

                    Text {
                        anchors.centerIn: parent
                        text: "Guardar Apuntes"
                        font.family: "SF Pro Display"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.widgetsState) {
                                root.widgetsState.setTimetableNotes(modalNotesEdit.text);
                            }
                            root.notesModalOpen = false;
                        }
                    }
                }
            }
        }
    }
}
