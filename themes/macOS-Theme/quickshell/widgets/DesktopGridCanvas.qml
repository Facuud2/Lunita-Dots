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
        implicitWidth: pillRow.implicitWidth + 32
        radius: 18
        color: pillMa.containsMouse
            ? (root.widgetsState.isDarkTheme ? Qt.rgba(0.20, 0.22, 0.28, 0.90) : "#FFFFFF")
            : (root.widgetsState.isDarkTheme ? Qt.rgba(0.14, 0.16, 0.20, 0.80) : Qt.rgba(0.96, 0.96, 0.98, 0.85))
        border.color: root.widgetsState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(0, 0, 0, 0.10)
        border.width: 1

        scale: pillMa.containsMouse ? 1.05 : 1.0
        Behavior on scale { NumberAnimation { duration: 120 } }

        RowLayout {
            id: pillRow
            anchors.centerIn: parent
            spacing: 6
            Text {
                text: "󰏫"
                font.family: "CaskaydiaCove Nerd Font"
                font.pixelSize: 13
                color: root.widgetsState.textColor
            }
            Text {
                text: "Edit Widgets"
                font.family: "SF Pro Display"
                font.pixelSize: 12
                font.weight: Font.Bold
                color: root.widgetsState.textColor
            }
        }

        MouseArea {
            id: pillMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.widgetsState.toggleEdit()
        }
    }
}
