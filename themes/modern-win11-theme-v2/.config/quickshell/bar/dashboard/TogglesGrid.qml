import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root

    required property var barState

    implicitWidth: 260
    implicitHeight: 166

    GridLayout {
        anchors.fill: parent
        columns: 2
        rows: 2
        columnSpacing: 10
        rowSpacing: 10

        // ── Tile 1: Wi-Fi ──
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 14
            color: root.barState.wifiConnected ? Qt.rgba(root.barState.themeAccent.r, root.barState.themeAccent.g, root.barState.themeAccent.b, 0.22) : Qt.rgba(1, 1, 1, 0.08)
            border.color: root.barState.wifiConnected ? Qt.rgba(root.barState.themeAccent.r, root.barState.themeAccent.g, root.barState.themeAccent.b, 0.40) : (wifiHover.hovered ? root.barState.themeBorderSpecular : Qt.rgba(1, 1, 1, 0.12))
            border.width: 1

            HoverHandler { id: wifiHover }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 4

                Text {
                    text: root.barState.wifiConnected ? "󰤨" : "󰤭"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18
                    color: root.barState.wifiConnected ? root.barState.themeAccent : Qt.rgba(1, 1, 1, 0.50)
                }

                Item { Layout.fillHeight: true }

                Text {
                    text: "Wi-Fi"
                    font.family: root.barState.themeFontInterface
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    color: "#FFFFFF"
                }

                Text {
                    Layout.fillWidth: true
                    text: root.barState.wifiConnected ? (root.barState.wifiSsid || "Home") : "Off"
                    font.family: root.barState.themeFontInterface
                    font.pixelSize: 10
                    color: Qt.rgba(1, 1, 1, 0.65)
                    elide: Text.ElideRight
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        root.barState.openPopup("wifi_radar");
                    } else {
                        root.barState.toggleWifi();
                    }
                }
            }
        }

        // ── Tile 2: Bluetooth ──
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 14
            color: root.barState.bluetoothConnected ? Qt.rgba(root.barState.themeAccent.r, root.barState.themeAccent.g, root.barState.themeAccent.b, 0.22) : Qt.rgba(1, 1, 1, 0.08)
            border.color: root.barState.bluetoothConnected ? Qt.rgba(root.barState.themeAccent.r, root.barState.themeAccent.g, root.barState.themeAccent.b, 0.40) : (btHover.hovered ? root.barState.themeBorderSpecular : Qt.rgba(1, 1, 1, 0.12))
            border.width: 1

            HoverHandler { id: btHover }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 4

                Text {
                    text: root.barState.bluetoothEnabled ? "󰂯" : "󰂲"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18
                    color: root.barState.bluetoothConnected ? root.barState.themeAccent : (root.barState.bluetoothEnabled ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.50))
                }

                Item { Layout.fillHeight: true }

                Text {
                    text: "Bluetooth"
                    font.family: root.barState.themeFontInterface
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    color: "#FFFFFF"
                }

                Text {
                    Layout.fillWidth: true
                    text: root.barState.bluetoothConnected ? (root.barState.bluetoothDeviceName || "On") : (root.barState.bluetoothEnabled ? "On" : "Off")
                    font.family: root.barState.themeFontInterface
                    font.pixelSize: 10
                    color: Qt.rgba(1, 1, 1, 0.65)
                    elide: Text.ElideRight
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        root.barState.openPopup("bluetooth_orbit");
                    } else {
                        root.barState.toggleBluetooth();
                    }
                }
            }
        }

        // ── Tile 3: Batería / Potencia ──
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 14
            color: root.barState.isBatteryCharging ? Qt.rgba(root.barState.themeAccent.r, root.barState.themeAccent.g, root.barState.themeAccent.b, 0.22) : Qt.rgba(1, 1, 1, 0.08)
            border.color: root.barState.isBatteryCharging ? Qt.rgba(root.barState.themeAccent.r, root.barState.themeAccent.g, root.barState.themeAccent.b, 0.40) : (batHover.hovered ? root.barState.themeBorderSpecular : Qt.rgba(1, 1, 1, 0.12))
            border.width: 1

            HoverHandler { id: batHover }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 4

                Text {
                    text: root.barState.isBatteryCharging ? "󰂄" : "󱐋"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18
                    color: root.barState.isBatteryCharging ? root.barState.themeAccent : Qt.rgba(1, 1, 1, 0.70)
                }

                Item { Layout.fillHeight: true }

                Text {
                    text: root.barState.hasBattery ? (root.barState.batteryPercent + "%") : "Power"
                    font.family: root.barState.themeFontInterface
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    color: "#FFFFFF"
                }

                Text {
                    Layout.fillWidth: true
                    text: root.barState.isBatteryCharging ? "Charging" : "Balanced"
                    font.family: root.barState.themeFontInterface
                    font.pixelSize: 10
                    color: Qt.rgba(1, 1, 1, 0.65)
                    elide: Text.ElideRight
                }
            }
        }

        // ── Tile 4: Micrófono ──
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 14
            color: !root.barState.micMuted ? Qt.rgba(root.barState.themeAccent.r, root.barState.themeAccent.g, root.barState.themeAccent.b, 0.22) : Qt.rgba(1, 1, 1, 0.08)
            border.color: !root.barState.micMuted ? Qt.rgba(root.barState.themeAccent.r, root.barState.themeAccent.g, root.barState.themeAccent.b, 0.40) : (micHover.hovered ? root.barState.themeBorderSpecular : Qt.rgba(1, 1, 1, 0.12))
            border.width: 1

            HoverHandler { id: micHover }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 4

                Text {
                    text: root.barState.micMuted ? "󰍭" : "󰍬"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18
                    color: !root.barState.micMuted ? root.barState.themeAccent : Qt.rgba(1, 1, 1, 0.50)
                }

                Item { Layout.fillHeight: true }

                Text {
                    text: "Mic"
                    font.family: root.barState.themeFontInterface
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    color: "#FFFFFF"
                }

                Text {
                    Layout.fillWidth: true
                    text: root.barState.micMuted ? "Muted" : "Live"
                    font.family: root.barState.themeFontInterface
                    font.pixelSize: 10
                    color: Qt.rgba(1, 1, 1, 0.65)
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.barState.toggleMicMute()
            }
        }
    }
}
