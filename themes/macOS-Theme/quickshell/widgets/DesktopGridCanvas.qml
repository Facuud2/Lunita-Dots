import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property var widgetsState

    // ── 1. Render All Active Desktop Widgets ──
    Repeater {
        model: root.widgetsState.widgetsList
        delegate: WidgetFrame {
            widgetsState: root.widgetsState
            widgetData: modelData
        }
    }

    // ── 2. Top Edit Mode Header Bar (Visible only when editing) ──
    Rectangle {
        id: editTopBar
        visible: root.widgetsState.isEditing
        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        height: 44
        implicitWidth: editBarRow.implicitWidth + 32
        radius: 22
        color: root.widgetsState.isDarkTheme ? Qt.rgba(0.14, 0.16, 0.20, 0.92) : Qt.rgba(0.96, 0.96, 0.98, 0.94)
        border.color: root.widgetsState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.20) : Qt.rgba(0, 0, 0, 0.14)
        border.width: 1

        RowLayout {
            id: editBarRow
            anchors.centerIn: parent
            spacing: 8

            // Reset Button
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: resetText.implicitWidth + 16
                color: resetMa.containsMouse ? (root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: resetText
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "↺"; color: root.widgetsState.textColor; font.pixelSize: 11; font.weight: Font.Bold }
                    Text { text: "Reset"; color: root.widgetsState.textColor; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold }
                }

                MouseArea {
                    id: resetMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.widgetsState.resetLayout()
                }
            }

            // Add Photos
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addPhoText.implicitWidth + 16
                color: addPhoMa.containsMouse ? (root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addPhoText
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "+"; color: root.widgetsState.textColor; font.pixelSize: 12; font.weight: Font.Bold }
                    Text { text: "Fotos"; color: root.widgetsState.textColor; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold }
                }

                MouseArea {
                    id: addPhoMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.widgetsState.addWidget("photos")
                }
            }

            // Add Calendar
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addCalText.implicitWidth + 16
                color: addCalMa.containsMouse ? (root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addCalText
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "+"; color: root.widgetsState.textColor; font.pixelSize: 12; font.weight: Font.Bold }
                    Text { text: "Calendario"; color: root.widgetsState.textColor; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold }
                }

                MouseArea {
                    id: addCalMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.widgetsState.addWidget("calendar")
                }
            }

            // Add Resources
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addSysText.implicitWidth + 16
                color: addSysMa.containsMouse ? (root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addSysText
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "+"; color: root.widgetsState.textColor; font.pixelSize: 12; font.weight: Font.Bold }
                    Text { text: "Actividad"; color: root.widgetsState.textColor; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold }
                }

                MouseArea {
                    id: addSysMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.widgetsState.addWidget("resources")
                }
            }

            // Add Clock
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addClkText.implicitWidth + 16
                color: addClkMa.containsMouse ? (root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addClkText
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "+"; color: root.widgetsState.textColor; font.pixelSize: 12; font.weight: Font.Bold }
                    Text { text: "Reloj"; color: root.widgetsState.textColor; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold }
                }

                MouseArea {
                    id: addClkMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.widgetsState.addWidget("clock")
                }
            }

            // Add Network
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addNetText.implicitWidth + 16
                color: addNetMa.containsMouse ? (root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addNetText
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "+"; color: root.widgetsState.textColor; font.pixelSize: 12; font.weight: Font.Bold }
                    Text { text: "Red"; color: root.widgetsState.textColor; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold }
                }

                MouseArea {
                    id: addNetMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.widgetsState.addWidget("network")
                }
            }

            // Add Battery
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addBatText.implicitWidth + 16
                color: addBatMa.containsMouse ? (root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addBatText
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "+"; color: root.widgetsState.textColor; font.pixelSize: 12; font.weight: Font.Bold }
                    Text { text: "Batería"; color: root.widgetsState.textColor; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold }
                }

                MouseArea {
                    id: addBatMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.widgetsState.addWidget("battery")
                }
            }

            // Add Git
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addGitText.implicitWidth + 16
                color: addGitMa.containsMouse ? (root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addGitText
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "+"; color: root.widgetsState.textColor; font.pixelSize: 12; font.weight: Font.Bold }
                    Text { text: "Git"; color: root.widgetsState.textColor; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold }
                }

                MouseArea {
                    id: addGitMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.widgetsState.addWidget("git")
                }
            }

            // Add Habits
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addHabText.implicitWidth + 16
                color: addHabMa.containsMouse ? (root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addHabText
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "+"; color: root.widgetsState.textColor; font.pixelSize: 12; font.weight: Font.Bold }
                    Text { text: "Salud"; color: root.widgetsState.textColor; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold }
                }

                MouseArea {
                    id: addHabMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.widgetsState.addWidget("habits")
                }
            }

            // Add Timetable
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addTtText.implicitWidth + 16
                color: addTtMa.containsMouse ? (root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addTtText
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "+"; color: root.widgetsState.textColor; font.pixelSize: 12; font.weight: Font.Bold }
                    Text { text: "UNaB / Notas"; color: root.widgetsState.textColor; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold }
                }

                MouseArea {
                    id: addTtMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.widgetsState.addWidget("timetable")
                }
            }

            // Add Media
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addMedText.implicitWidth + 16
                color: addMedMa.containsMouse ? (root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addMedText
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "+"; color: root.widgetsState.textColor; font.pixelSize: 12; font.weight: Font.Bold }
                    Text { text: "Música"; color: root.widgetsState.textColor; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold }
                }

                MouseArea {
                    id: addMedMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.widgetsState.addWidget("media")
                }
            }

            // Settings "Ajustes" Button
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: cfgText.implicitWidth + 20
                color: cfgMa.containsMouse ? (root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: cfgText
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "󰒓"; font.family: "CaskaydiaCove Nerd Font"; color: root.widgetsState.accentBlue; font.pixelSize: 11 }
                    Text { text: "Ajustes"; color: root.widgetsState.textColor; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold }
                }

                MouseArea {
                    id: cfgMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Quickshell.execDetached(["lunita-widgets-manager"])
                }
            }

            // Done "Listo" Button
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: doneText.implicitWidth + 24
                color: doneMa.containsMouse ? "#0088FF" : "#007AFF"

                Text {
                    id: doneText
                    anchors.centerIn: parent
                    text: "Listo"
                    font.family: "SF Pro Display"
                    font.pixelSize: 12
                    font.weight: Font.ExtraBold
                    color: "#FFFFFF"
                }

                MouseArea {
                    id: doneMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.widgetsState.toggleEdit()
                }
            }
        }
    }

    // ── 3. Bottom "Edit Widgets" Pill Button (Visible when NOT editing) ──
    Rectangle {
        id: editPillBtn
        visible: !root.widgetsState.isEditing
        x: 1520 + (354 - width) / 2
        y: 610
        height: 36
        implicitWidth: pillRow.implicitWidth + 24
        radius: 18
        color: root.widgetsState.isDarkTheme ? Qt.rgba(0.14, 0.16, 0.20, 0.85) : Qt.rgba(0.96, 0.96, 0.98, 0.88)
        border.color: root.widgetsState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(0, 0, 0, 0.10)
        border.width: 1

        RowLayout {
            id: pillRow
            anchors.centerIn: parent
            spacing: 10

            // Botón Editar
            Rectangle {
                height: 26
                radius: 13
                implicitWidth: editPartRow.implicitWidth + 12
                color: editPartMa.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent"

                RowLayout {
                    id: editPartRow
                    anchors.centerIn: parent
                    spacing: 5
                    Text { text: "󰏫"; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 12; color: root.widgetsState.textColor }
                    Text { text: "Editar"; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold; color: root.widgetsState.textColor }
                }

                MouseArea {
                    id: editPartMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.widgetsState.toggleEdit()
                }
            }

            // Separador vertical sutil
            Rectangle { width: 1; height: 16; color: Qt.rgba(1, 1, 1, 0.18) }

            // Botón Ajustes / Gestor
            Rectangle {
                height: 26
                radius: 13
                implicitWidth: cfgPartRow.implicitWidth + 12
                color: cfgPartMa.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent"

                RowLayout {
                    id: cfgPartRow
                    anchors.centerIn: parent
                    spacing: 5
                    Text { text: "󰒓"; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 12; color: root.widgetsState.accentBlue }
                    Text { text: "Ajustes"; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold; color: root.widgetsState.textColor }
                }

                MouseArea {
                    id: cfgPartMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Quickshell.execDetached(["lunita-widgets-manager"])
                }
            }
        }
    }
}
