import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    required property var dockState

    readonly property string uiFont: "Adwaita Sans"

    width: 360
    height: mainCard.implicitHeight
    implicitWidth: 360
    implicitHeight: mainCard.implicitHeight

    property string expandedMac: ""

    // Smooth Appearance & Disappearance (Windows 11 Fluent Motion)
    opacity: (root.dockState.flyoutOpen && root.dockState.activeFlyout === "bluetooth") ? 1.0 : 0.0
    scale: (root.dockState.flyoutOpen && root.dockState.activeFlyout === "bluetooth") ? 1.0 : 0.96
    transformOrigin: Item.BottomRight

    Behavior on opacity {
        NumberAnimation {
            duration: root.dockState.flyoutOpen ? 220 : 140
            easing.type: root.dockState.flyoutOpen ? Easing.OutCubic : Easing.InQuad
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.dockState.flyoutOpen ? 240 : 160
            easing.type: root.dockState.flyoutOpen ? Easing.OutCubic : Easing.InQuad
        }
    }

    // Single Unified Windows 11 Mica / Acrylic Flyout Card
    Rectangle {
        id: mainCard
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        implicitHeight: cardCol.implicitHeight
        height: cardCol.implicitHeight
        radius: 12

        // Windows 11 Dark Acrylic Surface
        color: Qt.rgba(0.12, 0.13, 0.16, 0.84)
        border.color: Qt.rgba(1.0, 1.0, 1.0, 0.14)
        border.width: 1
        clip: true

        // Top Specular Highlight Rim
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            height: 1
            color: Qt.rgba(1.0, 1.0, 1.0, 0.16)
        }

        ColumnLayout {
            id: cardCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            spacing: 0

            // ==========================================
            // 1. WINDOWS 11 SUB-FLYOUT TOP HEADER BAR
            // ==========================================
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 52

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 16
                    spacing: 8

                    // Back Button (Returns to Quick Settings / Audio Flyout)
                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        radius: 6
                        color: backMouse.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.08) : "transparent"

                        Image {
                            anchors.centerIn: parent
                            source: "assets/chevron-left.svg"
                            sourceSize.width: 15
                            sourceSize.height: 15
                            opacity: 0.92
                        }

                        MouseArea {
                            id: backMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.dockState.toggleAudioFlyout("")
                        }
                    }

                    // Header Title ("Bluetooth")
                    Text {
                        text: "Bluetooth"
                        font.family: root.uiFont
                        font.styleName: "SemiBold"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        font.italic: false
                        color: "#FFFFFF"
                        Layout.fillWidth: true
                    }

                    // Not-Discoverable / Scanning Sub-label
                    Text {
                        visible: root.dockState.bluetoothEnabled && root.dockState.bluetoothScanning
                        text: "Buscando..."
                        font.family: root.uiFont
                        font.styleName: "Regular"
                        font.pixelSize: 11
                        font.weight: Font.Normal
                        font.italic: false
                        color: Qt.rgba(1.0, 1.0, 1.0, 0.60)
                        Layout.rightMargin: 6
                    }

                    // Windows 11 Authentic Pill Toggle Switch
                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 20
                        radius: 10
                        color: root.dockState.bluetoothEnabled ? "#60CDFF" : Qt.rgba(1.0, 1.0, 1.0, 0.04)
                        border.color: root.dockState.bluetoothEnabled ? "#60CDFF" : Qt.rgba(1.0, 1.0, 1.0, 0.58)
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 140 } }

                        Rectangle {
                            width: 12
                            height: 12
                            radius: 6
                            anchors.verticalCenter: parent.verticalCenter
                            x: root.dockState.bluetoothEnabled ? (parent.width - width - 4) : 4
                            color: root.dockState.bluetoothEnabled ? "#000000" : Qt.rgba(1.0, 1.0, 1.0, 0.85)
                            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.dockState.toggleBluetooth()
                        }
                    }
                }
            }

            // Subtle Header Divider
            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                height: 1
                color: Qt.rgba(1.0, 1.0, 1.0, 0.08)
                visible: root.dockState.bluetoothEnabled && root.dockState.bluetoothDevices.length > 0
            }

            // ==========================================
            // 2. BLUETOOTH DEVICES LIST AREA
            // ==========================================

            // Disabled or Empty State (Windows 11 Centered Placeholder)
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                visible: !root.dockState.bluetoothEnabled || root.dockState.bluetoothDevices.length === 0

                ColumnLayout {
                    anchors.centerIn: parent
                    width: parent.width - 48
                    spacing: 8

                    Image {
                        Layout.alignment: Qt.AlignHCenter
                        source: "assets/bluetooth.svg"
                        sourceSize.width: 28
                        sourceSize.height: 28
                        opacity: root.dockState.bluetoothEnabled ? 0.80 : 0.55
                    }

                    Text {
                        Layout.fillWidth: true
                        text: !root.dockState.bluetoothEnabled
                            ? "El Bluetooth está desactivado"
                            : (root.dockState.bluetoothScanning
                                ? "Buscando dispositivos..."
                                : "No se encontraron dispositivos Bluetooth")
                        font.family: root.uiFont
                        font.styleName: "SemiBold"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        font.italic: false
                        color: "#FFFFFF"
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        Layout.fillWidth: true
                        text: !root.dockState.bluetoothEnabled
                            ? "Activa el Bluetooth para conectarte a dispositivos inalámbricos emparejados o cercanos."
                            : "Asegúrate de que tu dispositivo esté encendido y en modo de emparejamiento."
                        font.family: root.uiFont
                        font.styleName: "Regular"
                        font.pixelSize: 12
                        font.weight: Font.Normal
                        font.italic: false
                        color: Qt.rgba(1.0, 1.0, 1.0, 0.65)
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                }
            }

            // Scrollable Bluetooth Devices List (Windows 11 Style)
            Flickable {
                id: devicesFlick
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(290, devicesListCol.implicitHeight + 16)
                contentWidth: width
                contentHeight: devicesListCol.implicitHeight + 16
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                visible: root.dockState.bluetoothEnabled && root.dockState.bluetoothDevices.length > 0

                ColumnLayout {
                    id: devicesListCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    anchors.topMargin: 8
                    spacing: 2

                    // Section Header ("Tus dispositivos")
                    Text {
                        text: "Tus dispositivos"
                        font.family: root.uiFont
                        font.styleName: "SemiBold"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        font.italic: false
                        color: Qt.rgba(1.0, 1.0, 1.0, 0.72)
                        Layout.leftMargin: 10
                        Layout.bottomMargin: 4
                    }

                    Repeater {
                        model: root.dockState.bluetoothDevices

                        delegate: Rectangle {
                            id: devDelegate
                            required property var modelData

                            readonly property bool isBusy: root.dockState.bluetoothPendingMac === modelData.mac
                            readonly property bool isExpanded: (root.expandedMac === modelData.mac) || (root.expandedMac === "" && modelData.connected)

                            Layout.fillWidth: true
                            Layout.preferredHeight: isExpanded ? 96 : 52
                            radius: 6
                            color: isExpanded
                                ? Qt.rgba(1.0, 1.0, 1.0, 0.08)
                                : (devRowHover.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.05) : "transparent")
                            Behavior on Layout.preferredHeight { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                            MouseArea {
                                id: devRowHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.expandedMac === devDelegate.modelData.mac) {
                                        root.expandedMac = "__none__";
                                    } else {
                                        root.expandedMac = devDelegate.modelData.mac;
                                    }
                                }
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                anchors.topMargin: 8
                                anchors.bottomMargin: 10
                                spacing: 8

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 14

                                    Image {
                                        source: devDelegate.modelData.type === "audio"
                                            ? "assets/headphones.svg"
                                            : (devDelegate.modelData.type === "keyboard" ? "assets/keyboard.svg" : "assets/bluetooth.svg")
                                        sourceSize.width: 20
                                        sourceSize.height: 20
                                        opacity: devDelegate.modelData.connected ? 1.0 : 0.80
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1

                                        Text {
                                            text: devDelegate.modelData.name
                                            font.family: root.uiFont
                                            font.styleName: (devDelegate.modelData.connected || devDelegate.isExpanded) ? "SemiBold" : "Regular"
                                            font.pixelSize: 13
                                            font.weight: (devDelegate.modelData.connected || devDelegate.isExpanded) ? Font.DemiBold : Font.Normal
                                            font.italic: false
                                            color: "#FFFFFF"
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }

                                        Text {
                                            text: devDelegate.isBusy
                                                ? (devDelegate.modelData.connected ? "Desconectando..." : "Conectando...")
                                                : (devDelegate.modelData.connected
                                                    ? "Conectado"
                                                    : (devDelegate.modelData.paired ? "Emparejado" : "Disponible"))
                                            font.family: root.uiFont
                                            font.styleName: "Regular"
                                            font.pixelSize: 12
                                            font.weight: Font.Normal
                                            font.italic: false
                                            color: devDelegate.modelData.connected ? "#60CDFF" : Qt.rgba(1.0, 1.0, 1.0, 0.65)
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                    }
                                }

                                // Expanded Windows 11 Action Button Row ("Conectar" / "Desconectar")
                                RowLayout {
                                    Layout.fillWidth: true
                                    visible: devDelegate.isExpanded

                                    Item { Layout.fillWidth: true }

                                    Rectangle {
                                        Layout.preferredWidth: 116
                                        Layout.preferredHeight: 32
                                        radius: 4
                                        color: devDelegate.modelData.connected
                                            ? (btActMouse.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.12) : Qt.rgba(1.0, 1.0, 1.0, 0.08))
                                            : (btActMouse.containsMouse ? "#78D6FF" : "#60CDFF")
                                        border.color: devDelegate.modelData.connected
                                            ? Qt.rgba(1.0, 1.0, 1.0, 0.14)
                                            : "#60CDFF"
                                        border.width: 1

                                        Text {
                                            anchors.centerIn: parent
                                            text: devDelegate.isBusy
                                                ? (devDelegate.modelData.connected ? "Desconectando..." : "Conectando...")
                                                : (devDelegate.modelData.connected ? "Desconectar" : "Conectar")
                                            font.family: root.uiFont
                                            font.styleName: devDelegate.modelData.connected ? "Regular" : "SemiBold"
                                            font.pixelSize: 12
                                            font.weight: devDelegate.modelData.connected ? Font.Normal : Font.DemiBold
                                            font.italic: false
                                            color: devDelegate.modelData.connected ? "#FFFFFF" : "#000000"
                                        }

                                        MouseArea {
                                            id: btActMouse
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
                            }
                        }
                    }
                }
            }

            // ==========================================
            // 3. WINDOWS 11 BOTTOM FOOTER BAR
            // ==========================================
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(1.0, 1.0, 1.0, 0.10)
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                color: Qt.rgba(0.06, 0.07, 0.09, 0.38)

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 12
                    spacing: 8

                    Text {
                        text: "Más opciones de configuración de Bluetooth"
                        font.family: root.uiFont
                        font.styleName: "Regular"
                        font.pixelSize: 12
                        font.weight: Font.Normal
                        font.italic: false
                        color: btSettingsMouse.containsMouse ? "#88DCFF" : "#60CDFF"
                        Layout.fillWidth: true
                        elide: Text.ElideRight

                        MouseArea {
                            id: btSettingsMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Quickshell.execDetached(["bash", "-c", "blueman-manager || overskride || kitty -e bluetoothctl &"]);
                            }
                        }
                    }

                    // Rescan / Refresh Bluetooth Devices Button
                    Rectangle {
                        visible: root.dockState.bluetoothEnabled
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        radius: 6
                        color: btScanMouse.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.08) : "transparent"

                        Image {
                            id: btScanIcon
                            anchors.centerIn: parent
                            source: "assets/reload.svg"
                            sourceSize.width: 15
                            sourceSize.height: 15
                            opacity: root.dockState.bluetoothScanning ? 0.55 : 0.88

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
                }
            }
        }
    }
}
