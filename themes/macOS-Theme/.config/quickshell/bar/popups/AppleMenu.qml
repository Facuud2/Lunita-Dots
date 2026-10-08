import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root
    required property var barState

    visible: barState.activePopup === "apple"
    x: Math.max(10, Math.min(parent.width - width - 10, barState.popupX))
    y: 4
    width: 240
    implicitHeight: mainCol.implicitHeight + 16
    height: implicitHeight
    z: 10

    // Animate Entrance
    opacity: visible ? 1 : 0
    scale: visible ? 1 : 0.96
    Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
    Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 10
        color: barState.popupBgColor
        border.color: barState.popupBorderColor
        border.width: 1

        Behavior on color { ColorAnimation { duration: 200 } }
        Behavior on border.color { ColorAnimation { duration: 200 } }

        // Drop shadow illusion
        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: 11
            color: "transparent"
            border.color: Qt.rgba(0, 0, 0, barState.isDarkTheme ? 0.35 : 0.12)
            border.width: 1
            z: -1
        }
    }

    ColumnLayout {
        id: mainCol
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 8
        spacing: 2

        // 1. About This Mac
        MenuItem {
            text: "About This Mac"
            onClicked: {
                root.barState.launchCommand("kitty --title 'About Lunita OS' -e sh -c 'fastfetch; read -n 1 -s -p \"Press any key to close...\"'");
            }
        }

        MenuSeparator {}

        // 2. System Settings
        MenuItem {
            text: "System Settings..."
            onClicked: {
                root.barState.launchCommand("dolphin ~/.config/hypr || nwg-look || pavucontrol");
            }
        }

        // 3. App Store
        MenuItem {
            text: "App Store..."
            onClicked: {
                root.barState.launchCommand("pamac-manager || bauh || pacseek || lunita-launcher toggle");
            }
        }

        MenuSeparator {}

        // 4. Force Quit
        MenuItem {
            text: "Force Quit..."
            shortcut: "⌥⌘⎋"
            onClicked: {
                root.barState.launchCommand("kitty -e btop || missioncenter || htop");
            }
        }

        MenuSeparator {}

        // 5. Sleep
        MenuItem {
            text: "Sleep"
            onClicked: {
                root.barState.launchCommand("systemctl suspend");
            }
        }

        // 6. Restart
        MenuItem {
            text: "Restart..."
            onClicked: {
                root.barState.launchCommand("systemctl reboot");
            }
        }

        // 7. Shut Down
        MenuItem {
            text: "Shut Down..."
            onClicked: {
                root.barState.launchCommand("systemctl poweroff");
            }
        }

        MenuSeparator {}

        // 8. Lock Screen
        MenuItem {
            text: "Lock Screen"
            shortcut: "⌘L"
            onClicked: {
                root.barState.lockScreen();
            }
        }

        // 9. Log Out
        MenuItem {
            text: "Log Out..."
            shortcut: "⇧⌘Q"
            onClicked: {
                root.barState.launchCommand("hyprctl dispatch 'hl.dsp.exit()'");
            }
        }
    }

    // ── Helper: Menu Item Component ──
    component MenuItem: Rectangle {
        id: itemRoot
        property string text: ""
        property string shortcut: ""
        signal clicked()

        Layout.fillWidth: true
        implicitHeight: 24
        radius: 6
        color: mouseArea.containsMouse ? "#007AFF" : "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 8

            Text {
                Layout.fillWidth: true
                text: itemRoot.text
                color: mouseArea.containsMouse ? "#FFFFFF" : barState.popupTextColor
                font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                font.pixelSize: 13
                font.weight: Font.Normal
                elide: Text.ElideRight
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            Text {
                visible: itemRoot.shortcut !== ""
                text: itemRoot.shortcut
                color: mouseArea.containsMouse ? "#FFFFFF" : barState.popupTextDim
                font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                font.pixelSize: 12
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: itemRoot.clicked()
        }
    }

    // ── Helper: Menu Separator ──
    component MenuSeparator: Rectangle {
        Layout.fillWidth: true
        Layout.topMargin: 4
        Layout.bottomMargin: 4
        implicitHeight: 1
        color: barState.popupSeparatorColor
    }
}
