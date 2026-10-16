import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property var dockState

    width: 360
    height: mainCol.implicitHeight
    implicitWidth: 360
    implicitHeight: mainCol.implicitHeight

    // Smooth Appearance & Disappearance (Windows 11 Fluent Motion)
    opacity: (root.dockState.flyoutOpen && root.dockState.activeFlyout === "bluetooth") ? 1.0 : 0.0
    scale: (root.dockState.flyoutOpen && root.dockState.activeFlyout === "bluetooth") ? 1.0 : 0.96
    transformOrigin: Item.BottomRight

    Behavior on opacity {
        NumberAnimation {
            duration: root.dockState.flyoutOpen ? 240 : 150
            easing.type: root.dockState.flyoutOpen ? Easing.OutCubic : Easing.InQuad
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.dockState.flyoutOpen ? 260 : 170
            easing.type: root.dockState.flyoutOpen ? Easing.OutCubic : Easing.InQuad
        }
    }

    ColumnLayout {
        id: mainCol
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 10

        // ==========================================
        // BLUETOOTH CONTROL & PAIRED DEVICES CARD
        // ==========================================
        Rectangle {
            id: btCard
            Layout.fillWidth: true
            Layout.preferredHeight: btCol.implicitHeight + 28
            radius: 18

            // Pure Transparent Liquid Glass Base
            color: Qt.rgba(0.12, 0.13, 0.17, 0.45)
            border.color: Qt.rgba(1.0, 1.0, 1.0, 0.16)
            border.width: 1

            // Specular Top Rim Line
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                height: 1
                color: Qt.rgba(1.0, 1.0, 1.0, 0.22)
            }

            ColumnLayout {
                id: btCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 14
                spacing: 10

                // Header Row: Icon, Title/Status, Scan Button, Adapter Switch
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        radius: 18
                        color: root.dockState.bluetoothEnabled
                            ? Qt.rgba(0.0, 0.75, 1.0, 0.85)
                            : Qt.rgba(1.0, 1.0, 1.0, 0.08)
                        border.color: root.dockState.bluetoothEnabled
                            ? Qt.rgba(0.0, 0.85, 1.0, 0.90)
                            : Qt.rgba(1.0, 1.0, 1.0, 0.16)
                        border.width: 1

                        Image {
                            anchors.centerIn: parent
                            source: root.dockState.bluetoothEnabled ? "assets/bluetooth-dark.svg" : "assets/bluetooth.svg"
                            sourceSize.width: 18
                            sourceSize.height: 18
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: "Bluetooth y dispositivos"
                            font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            font.italic: false
                            color: "#FFFFFF"
                        }

                        Text {
                            text: !root.dockState.bluetoothEnabled
                                ? "Adaptador apagado"
                                : (root.dockState.bluetoothDeviceName && root.dockState.bluetoothDeviceName !== ""
                                    ? ("Conectado a " + root.dockState.bluetoothDeviceName)
                                    : (root.dockState.bluetoothScanning ? "Buscando dispositivos..." : "Activado • Listo para conectar"))
                            font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                            font.pixelSize: 10
                            font.weight: Font.Normal
                            font.italic: false
                            color: (root.dockState.bluetoothEnabled && root.dockState.bluetoothDeviceName !== "")
                                ? "#00E5FF"
                                : Qt.rgba(1.0, 1.0, 1.0, 0.70)
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    // Scan Devices Button
                    Rectangle {
                        visible: root.dockState.bluetoothEnabled
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        radius: 8
                        color: btScanMouse.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.18) : Qt.rgba(1.0, 1.0, 1.0, 0.06)
                        border.color: btScanMouse.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.28) : Qt.rgba(1.0, 1.0, 1.0, 0.14)
                        border.width: 1

                        Image {
                            anchors.centerIn: parent
                            source: "assets/reload.svg"
                            sourceSize.width: 14
                            sourceSize.height: 14
                            opacity: root.dockState.bluetoothScanning ? 0.55 : 0.90

                            RotationAnimator on rotation {
                                from: 0
                                to: 360
                                duration: 900
                                loops: Animation.Infinite
                                running: root.dockState.bluetoothScanning
                            }
                        }

                        MouseArea {
                            id: btScanMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.dockState.scanBluetoothDevices()
                        }
                    }

                    // Fluent Toggle Pill (Bluetooth Power On/Off)
                    Rectangle {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 24
                        radius: 12
                        color: root.dockState.bluetoothEnabled
                            ? Qt.rgba(0.0, 0.75, 1.0, 0.85)
                            : Qt.rgba(1.0, 1.0, 1.0, 0.12)
                        border.color: root.dockState.bluetoothEnabled
                            ? Qt.rgba(0.0, 0.85, 1.0, 0.95)
                            : Qt.rgba(1.0, 1.0, 1.0, 0.28)
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Rectangle {
                            width: 16
                            height: 16
                            radius: 8
                            anchors.verticalCenter: parent.verticalCenter
                            x: root.dockState.bluetoothEnabled ? (parent.width - width - 4) : 4
                            color: root.dockState.bluetoothEnabled ? "#0E1218" : "#FFFFFF"
                            Behavior on x { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.dockState.toggleBluetooth()
                        }
                    }
                }

                // Divider
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(1.0, 1.0, 1.0, 0.14)
                }

                // Section Label
                RowLayout {
                    Layout.fillWidth: true
                    visible: root.dockState.bluetoothEnabled

                    Text {
                        text: "Dispositivos emparejados y cercanos"
                        font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        font.italic: false
                        color: Qt.rgba(1.0, 1.0, 1.0, 0.85)
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: root.dockState.bluetoothDevices.length + (root.dockState.bluetoothDevices.length === 1 ? " dispositivo" : " dispositivos")
                        font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                        font.pixelSize: 10
                        color: Qt.rgba(1.0, 1.0, 1.0, 0.55)
                    }
                }

                // Disabled or Empty Message
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 64
                    visible: !root.dockState.bluetoothEnabled || root.dockState.bluetoothDevices.length === 0

                    Text {
                        anchors.centerIn: parent
                        text: !root.dockState.bluetoothEnabled
                            ? "Enciende el adaptador Bluetooth para conectar tus dispositivos."
                            : (root.dockState.bluetoothScanning
                                ? "Buscando dispositivos Bluetooth cercanos..."
                                : "No hay dispositivos emparejados ni detectados.")
                        font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                        font.pixelSize: 11
                        color: Qt.rgba(1.0, 1.0, 1.0, 0.65)
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width - 20
                        wrapMode: Text.WordWrap
                    }
                }

                // Scrollable Bluetooth Devices List
                Flickable {
                    id: btDevicesFlick
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(250, btDevicesCol.implicitHeight)
                    contentWidth: width
                    contentHeight: btDevicesCol.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    visible: root.dockState.bluetoothEnabled && root.dockState.bluetoothDevices.length > 0

                    ColumnLayout {
                        id: btDevicesCol
                        width: btDevicesFlick.width
                        spacing: 6

                        Repeater {
                            model: root.dockState.bluetoothDevices

                            delegate: Rectangle {
                                id: devDelegate
                                required property var modelData
                                readonly property bool isBusy: root.dockState.bluetoothPendingMac === modelData.mac

                                Layout.fillWidth: true
                                Layout.preferredHeight: 50
                                radius: 10
                                color: modelData.connected
                                    ? Qt.rgba(0.0, 0.75, 1.0, 0.22)
                                    : (devRowHover.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.14) : Qt.rgba(1.0, 1.0, 1.0, 0.06))
                                border.color: modelData.connected
                                    ? "#00E5FF"
                                    : Qt.rgba(1.0, 1.0, 1.0, 0.14)
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    spacing: 10

                                    // Device Category Icon Circle
                                    Rectangle {
                                        Layout.preferredWidth: 32
                                        Layout.preferredHeight: 32
                                        radius: 16
                                        color: devDelegate.modelData.connected
                                            ? Qt.rgba(0.0, 0.75, 1.0, 0.32)
                                            : Qt.rgba(1.0, 1.0, 1.0, 0.08)
                                        border.color: devDelegate.modelData.connected
                                            ? "#00E5FF"
                                            : Qt.rgba(1.0, 1.0, 1.0, 0.18)
                                        border.width: 1

                                        Image {
                                            anchors.centerIn: parent
                                            source: devDelegate.modelData.type === "audio"
                                                ? "assets/headphones.svg"
                                                : (devDelegate.modelData.type === "keyboard" ? "assets/keyboard.svg" : "assets/bluetooth.svg")
                                            sourceSize.width: 15
                                            sourceSize.height: 15
                                        }
                                    }

                                    // Device Name & Status
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1

                                        Text {
                                            text: devDelegate.modelData.name
                                            font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                                            font.pixelSize: 11
                                            font.weight: devDelegate.modelData.connected ? Font.DemiBold : Font.Normal
                                            font.italic: false
                                            color: devDelegate.modelData.connected ? "#00E5FF" : "#FFFFFF"
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }

                                        Text {
                                            text: devDelegate.isBusy
                                                ? (devDelegate.modelData.connected ? "Desconectando..." : "Conectando...")
                                                : (devDelegate.modelData.connected
                                                    ? ("Conectado • " + devDelegate.modelData.mac)
                                                    : ((devDelegate.modelData.paired ? "Emparejado • " : "Disponible • ") + devDelegate.modelData.mac))
                                            font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                                            font.pixelSize: 9
                                            font.italic: false
                                            color: Qt.rgba(1.0, 1.0, 1.0, 0.65)
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                    }

                                    // Connect / Disconnect Action Button
                                    Rectangle {
                                        Layout.preferredHeight: 26
                                        Layout.preferredWidth: btActionLabel.implicitWidth + 18
                                        radius: 7
                                        color: devDelegate.modelData.connected
                                            ? Qt.rgba(1.0, 1.0, 1.0, 0.14)
                                            : (btActionMouse.containsMouse ? Qt.rgba(0.0, 0.82, 1.0, 0.95) : Qt.rgba(0.0, 0.75, 1.0, 0.80))
                                        border.color: devDelegate.modelData.connected
                                            ? Qt.rgba(1.0, 1.0, 1.0, 0.25)
                                            : "#00E5FF"
                                        border.width: 1

                                        Text {
                                            id: btActionLabel
                                            anchors.centerIn: parent
                                            text: devDelegate.isBusy
                                                ? "..."
                                                : (devDelegate.modelData.connected ? "Desconectar" : "Conectar")
                                            font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                                            font.pixelSize: 10
                                            font.weight: Font.DemiBold
                                            color: devDelegate.modelData.connected ? "#FFFFFF" : "#0E1218"
                                        }

                                        MouseArea {
                                            id: btActionMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            enabled: !devDelegate.isBusy
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (devDelegate.modelData.connected) {
                                                    root.dockState.disconnectBluetoothDevice(devDelegate.modelData.mac);
                                                } else {
                                                    root.dockState.connectBluetoothDevice(devDelegate.modelData.mac);
                                                }
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    id: devRowHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    acceptedButtons: Qt.NoButton
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
