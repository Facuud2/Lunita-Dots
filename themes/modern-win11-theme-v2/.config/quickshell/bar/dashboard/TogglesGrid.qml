import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root

    required property var barState

    implicitWidth: 280
    implicitHeight: 168

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
            radius: root.barState.themeControlRadius
            color: root.barState.wifiConnected ? root.barState.themeAccentGlow : root.barState.themeSurfaceContainer
            border.color: wifiHover.hovered ? root.barState.themeBorderSpecular : root.barState.themeBorder
            border.width: 1

            HoverHandler { id: wifiHover }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                Text {
                    text: root.barState.wifiConnected ? "󰤨" : "󰤭"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18
                    color: root.barState.wifiConnected ? root.barState.themeAccent : root.barState.themeOnSurfaceLow
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        text: "Wi-Fi"
                        font.family: root.barState.themeFontInterface
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: root.barState.themeOnSurface
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.barState.wifiConnected ? (root.barState.wifiSsid || "Conectado") : "Desactivado"
                        font.family: root.barState.themeFontInterface
                        font.pixelSize: 10
                        color: root.barState.themeOnSurfaceDim
                        elide: Text.ElideRight
                    }
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
            radius: root.barState.themeControlRadius
            color: root.barState.bluetoothConnected ? root.barState.themeAccentGlow : root.barState.themeSurfaceContainer
            border.color: btHover.hovered ? root.barState.themeBorderSpecular : root.barState.themeBorder
            border.width: 1

            HoverHandler { id: btHover }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                Text {
                    text: root.barState.bluetoothEnabled ? "󰂯" : "󰂲"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18
                    color: root.barState.bluetoothConnected ? root.barState.themeAccent : (root.barState.bluetoothEnabled ? root.barState.themeOnSurface : root.barState.themeOnSurfaceLow)
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        text: "Bluetooth"
                        font.family: root.barState.themeFontInterface
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: root.barState.themeOnSurface
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.barState.bluetoothConnected ? (root.barState.bluetoothDeviceName || "Conectado") : (root.barState.bluetoothEnabled ? "Activo" : "Desactivado")
                        font.family: root.barState.themeFontInterface
                        font.pixelSize: 10
                        color: root.barState.themeOnSurfaceDim
                        elide: Text.ElideRight
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        root.barState.openPopup("bt_orbit");
                    } else {
                        root.barState.toggleBluetooth();
                    }
                }
            }
        }

        // ── Tile 3: Batería / Modo de Energía ──
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: root.barState.themeControlRadius
            color: root.barState.themeSurfaceContainer
            border.color: pwrHover.hovered ? root.barState.themeBorderSpecular : root.barState.themeBorder
            border.width: 1

            HoverHandler { id: pwrHover }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                Text {
                    text: root.barState.isBatteryCharging ? "󰂄" : (root.barState.hasBattery ? (root.barState.batteryPercent > 20 ? "󰁹" : "󰂃") : "󰓅")
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18
                    color: root.barState.isBatteryCharging ? "#107C41" : root.barState.themeAccent
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        text: root.barState.hasBattery ? "Batería" : "Energía"
                        font.family: root.barState.themeFontInterface
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: root.barState.themeOnSurface
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.barState.hasBattery ? (root.barState.batteryPercent + "% · " + (root.barState.isBatteryCharging ? "Cargando" : "En uso")) : "Equilibrado"
                        font.family: root.barState.themeFontInterface
                        font.pixelSize: 10
                        color: root.barState.themeOnSurfaceDim
                        elide: Text.ElideRight
                    }
                }
            }
        }

        // ── Tile 4: Micrófono ──
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: root.barState.themeControlRadius
            color: root.barState.themeSurfaceContainer
            border.color: micHover.hovered ? root.barState.themeBorderSpecular : root.barState.themeBorder
            border.width: 1

            HoverHandler { id: micHover }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                Text {
                    text: "󰍬"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18
                    color: root.barState.themeAccent
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        text: "Micrófono"
                        font.family: root.barState.themeFontInterface
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: root.barState.themeOnSurface
                    }

                    Text {
                        Layout.fillWidth: true
                        text: "En línea"
                        font.family: root.barState.themeFontInterface
                        font.pixelSize: 10
                        color: root.barState.themeOnSurfaceDim
                    }
                }
            }
        }
    }
}
