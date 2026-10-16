import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property var dockState

    width: 360
    height: mainCol.implicitHeight
    implicitWidth: 360
    implicitHeight: mainCol.implicitHeight

    property string selectedSsidForPassword: ""
    property string passwordBuffer: ""

    // Smooth Appearance & Disappearance (Windows 11 Fluent Motion)
    opacity: (root.dockState.flyoutOpen && root.dockState.activeFlyout === "network") ? 1.0 : 0.0
    scale: (root.dockState.flyoutOpen && root.dockState.activeFlyout === "network") ? 1.0 : 0.96
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
        // CARD 1: ETHERNET & ACTIVE CONNECTION STATUS
        // ==========================================
        Rectangle {
            id: ethernetCard
            Layout.fillWidth: true
            Layout.preferredHeight: ethCol.implicitHeight + 28
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
                id: ethCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 14
                spacing: 10

                // Header Row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "Red e Internet"
                        font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        font.italic: false
                        color: "#FFFFFF"
                    }

                    Item { Layout.fillWidth: true }

                    // Global Connectivity Pill Badge
                    Rectangle {
                        height: 22
                        width: statusBadgeRow.implicitWidth + 16
                        radius: 11
                        color: (root.dockState.ethernetConnected || root.dockState.wifiConnected)
                            ? Qt.rgba(0.0, 0.75, 1.0, 0.22)
                            : Qt.rgba(1.0, 1.0, 1.0, 0.08)
                        border.color: (root.dockState.ethernetConnected || root.dockState.wifiConnected)
                            ? "#00E5FF"
                            : Qt.rgba(1.0, 1.0, 1.0, 0.18)
                        border.width: 1

                        Row {
                            id: statusBadgeRow
                            anchors.centerIn: parent
                            spacing: 6

                            Rectangle {
                                width: 6
                                height: 6
                                radius: 3
                                anchors.verticalCenter: parent.verticalCenter
                                color: (root.dockState.ethernetConnected || root.dockState.wifiConnected)
                                    ? "#00E5FF"
                                    : Qt.rgba(1.0, 1.0, 1.0, 0.45)
                            }

                            Text {
                                text: root.dockState.ethernetConnected
                                    ? "Ethernet activo"
                                    : (root.dockState.wifiConnected ? "Wi-Fi activo" : "Sin conexión")
                                font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                color: (root.dockState.ethernetConnected || root.dockState.wifiConnected)
                                    ? "#00E5FF"
                                    : Qt.rgba(1.0, 1.0, 1.0, 0.75)
                            }
                        }
                    }
                }

                // Ethernet Connection Tile
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 58
                    radius: 12
                    color: root.dockState.ethernetConnected
                        ? Qt.rgba(0.0, 0.75, 1.0, 0.16)
                        : Qt.rgba(1.0, 1.0, 1.0, 0.06)
                    border.color: root.dockState.ethernetConnected
                        ? Qt.rgba(0.0, 0.85, 1.0, 0.65)
                        : Qt.rgba(1.0, 1.0, 1.0, 0.14)
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 12

                        // Ethernet Icon Circle
                        Rectangle {
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            radius: 18
                            color: root.dockState.ethernetConnected
                                ? Qt.rgba(0.0, 0.75, 1.0, 0.85)
                                : Qt.rgba(1.0, 1.0, 1.0, 0.10)
                            border.color: root.dockState.ethernetConnected
                                ? Qt.rgba(0.0, 0.90, 1.0, 0.95)
                                : Qt.rgba(1.0, 1.0, 1.0, 0.18)
                            border.width: 1

                            Image {
                                anchors.centerIn: parent
                                source: "assets/ethernet.svg"
                                sourceSize.width: 18
                                sourceSize.height: 18
                                smooth: true
                            }
                        }

                        // Ethernet Details
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: root.dockState.ethernetConnected
                                    ? (root.dockState.ethernetName || "Red cableada (Ethernet)")
                                    : "Ethernet (Red cableada)"
                                font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                font.italic: false
                                color: "#FFFFFF"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: root.dockState.ethernetConnected
                                    ? ("Conectado"
                                       + (root.dockState.ethernetDevice ? " • " + root.dockState.ethernetDevice : "")
                                       + (root.dockState.ethernetIp ? " • " + root.dockState.ethernetIp : ""))
                                    : (root.dockState.ethernetHasDevice ? "Cable desconectado" : "Adaptador no detectado")
                                font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                                font.pixelSize: 10
                                font.weight: Font.Normal
                                font.italic: false
                                color: root.dockState.ethernetConnected
                                    ? "#00E5FF"
                                    : Qt.rgba(1.0, 1.0, 1.0, 0.65)
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                        }

                        // Checkmark when connected
                        Rectangle {
                            visible: root.dockState.ethernetConnected
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            radius: 12
                            color: Qt.rgba(0.0, 0.90, 1.0, 0.20)
                            border.color: "#00E5FF"
                            border.width: 1

                            Image {
                                anchors.centerIn: parent
                                source: "assets/check.svg"
                                sourceSize.width: 13
                                sourceSize.height: 13
                            }
                        }
                    }
                }
            }
        }

        // ==========================================
        // CARD 2: WI-FI CONTROL & NETWORKS LIST
        // ==========================================
        Rectangle {
            id: wifiCard
            Layout.fillWidth: true
            Layout.preferredHeight: wifiCol.implicitHeight + 28
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
                id: wifiCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 14
                spacing: 10

                // Wi-Fi Header & Antenna Switch
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Rectangle {
                        Layout.preferredWidth: 34
                        Layout.preferredHeight: 34
                        radius: 17
                        color: root.dockState.wifiEnabled
                            ? Qt.rgba(0.0, 0.75, 1.0, 0.85)
                            : Qt.rgba(1.0, 1.0, 1.0, 0.08)
                        border.color: root.dockState.wifiEnabled
                            ? Qt.rgba(0.0, 0.85, 1.0, 0.90)
                            : Qt.rgba(1.0, 1.0, 1.0, 0.16)
                        border.width: 1

                        Image {
                            anchors.centerIn: parent
                            source: root.dockState.wifiEnabled ? "assets/wifi-dark.svg" : "assets/tray-wifi-off.svg"
                            sourceSize.width: 17
                            sourceSize.height: 17
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: "Wi-Fi"
                            font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            font.italic: false
                            color: "#FFFFFF"
                        }

                        Text {
                            text: !root.dockState.wifiEnabled
                                ? "Antena desactivada"
                                : (root.dockState.wifiConnected
                                    ? ("Conectado a " + root.dockState.wifiSsid + (root.dockState.wifiIp ? " (" + root.dockState.wifiIp + ")" : ""))
                                    : (root.dockState.networkScanning ? "Buscando redes..." : "Selecciona una red para conectarte"))
                            font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                            font.pixelSize: 10
                            font.weight: Font.Normal
                            font.italic: false
                            color: root.dockState.wifiConnected ? "#00E5FF" : Qt.rgba(1.0, 1.0, 1.0, 0.70)
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    // Rescan Button
                    Rectangle {
                        visible: root.dockState.wifiEnabled
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        radius: 8
                        color: scanMouse.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.18) : Qt.rgba(1.0, 1.0, 1.0, 0.06)
                        border.color: scanMouse.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.28) : Qt.rgba(1.0, 1.0, 1.0, 0.14)
                        border.width: 1

                        Image {
                            id: scanIcon
                            anchors.centerIn: parent
                            source: "assets/reload.svg"
                            sourceSize.width: 14
                            sourceSize.height: 14
                            opacity: root.dockState.networkScanning ? 0.55 : 0.90

                            RotationAnimator on rotation {
                                from: 0
                                to: 360
                                duration: 900
                                loops: Animation.Infinite
                                running: root.dockState.networkScanning
                            }
                        }

                        MouseArea {
                            id: scanMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.dockState.scanWifiNetworks()
                        }
                    }

                    // Fluent Toggle Pill (Wi-Fi Radio On/Off)
                    Rectangle {
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 24
                        radius: 12
                        color: root.dockState.wifiEnabled
                            ? Qt.rgba(0.0, 0.75, 1.0, 0.85)
                            : Qt.rgba(1.0, 1.0, 1.0, 0.12)
                        border.color: root.dockState.wifiEnabled
                            ? Qt.rgba(0.0, 0.85, 1.0, 0.95)
                            : Qt.rgba(1.0, 1.0, 1.0, 0.28)
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Rectangle {
                            width: 16
                            height: 16
                            radius: 8
                            anchors.verticalCenter: parent.verticalCenter
                            x: root.dockState.wifiEnabled ? (parent.width - width - 4) : 4
                            color: root.dockState.wifiEnabled ? "#0E1218" : "#FFFFFF"
                            Behavior on x { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.dockState.toggleWifiRadio()
                        }
                    }
                }

                // Divider
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(1.0, 1.0, 1.0, 0.14)
                    visible: root.dockState.wifiEnabled
                }

                // Empty / Disabled state message
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 54
                    visible: !root.dockState.wifiEnabled || root.dockState.wifiNetworks.length === 0

                    Text {
                        anchors.centerIn: parent
                        text: !root.dockState.wifiEnabled
                            ? "Activa el interruptor Wi-Fi para explorar redes inalámbricas."
                            : (root.dockState.networkScanning
                                ? "Escaneando redes cercanas..."
                                : "No se encontraron redes Wi-Fi cercanas.")
                        font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                        font.pixelSize: 11
                        color: Qt.rgba(1.0, 1.0, 1.0, 0.65)
                        horizontalAlignment: Text.AlignHCenter
                        width: parent.width - 20
                        wrapMode: Text.WordWrap
                    }
                }

                // Scrollable Wi-Fi Networks List
                Flickable {
                    id: networksFlick
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(240, networksListCol.implicitHeight)
                    contentWidth: width
                    contentHeight: networksListCol.implicitHeight
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    visible: root.dockState.wifiEnabled && root.dockState.wifiNetworks.length > 0

                    ColumnLayout {
                        id: networksListCol
                        width: networksFlick.width
                        spacing: 6

                        Repeater {
                            model: root.dockState.wifiNetworks

                            delegate: Rectangle {
                                id: netDelegate
                                required property var modelData
                                readonly property bool askingPass: (root.selectedSsidForPassword === modelData.ssid) && !modelData.active

                                Layout.fillWidth: true
                                Layout.preferredHeight: askingPass ? 92 : 46
                                radius: 10
                                color: modelData.active
                                    ? Qt.rgba(0.0, 0.75, 1.0, 0.22)
                                    : (netRowMouse.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.14) : Qt.rgba(1.0, 1.0, 1.0, 0.06))
                                border.color: modelData.active
                                    ? "#00E5FF"
                                    : (askingPass ? Qt.rgba(0.0, 0.75, 1.0, 0.60) : Qt.rgba(1.0, 1.0, 1.0, 0.14))
                                border.width: 1
                                Behavior on Layout.preferredHeight { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    anchors.topMargin: 6
                                    anchors.bottomMargin: 6
                                    spacing: 6

                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 8

                                        Image {
                                            source: "assets/tray-wifi.svg"
                                            sourceSize.width: 16
                                            sourceSize.height: 16
                                            opacity: Math.max(0.45, Math.min(1.0, (netDelegate.modelData.signal || 50) / 100.0))
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 1

                                            RowLayout {
                                                spacing: 5
                                                Layout.fillWidth: true

                                                Text {
                                                    text: netDelegate.modelData.ssid
                                                    font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                                                    font.pixelSize: 11
                                                    font.weight: netDelegate.modelData.active ? Font.DemiBold : Font.Normal
                                                    font.italic: false
                                                    color: netDelegate.modelData.active ? "#00E5FF" : "#FFFFFF"
                                                    elide: Text.ElideRight
                                                    Layout.fillWidth: true
                                                }

                                                Image {
                                                    visible: !!netDelegate.modelData.secure
                                                    source: "assets/lock.svg"
                                                    sourceSize.width: 11
                                                    sourceSize.height: 11
                                                    opacity: 0.75
                                                }
                                            }

                                            Text {
                                                text: netDelegate.modelData.active
                                                    ? ("Conectado • Señal " + netDelegate.modelData.signal + "%")
                                                    : ((netDelegate.modelData.known ? "Guardada • " : "")
                                                       + "Señal " + netDelegate.modelData.signal + "%"
                                                       + (netDelegate.modelData.security ? " • " + netDelegate.modelData.security : ""))
                                                font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                                                font.pixelSize: 9
                                                font.italic: false
                                                color: Qt.rgba(1.0, 1.0, 1.0, 0.65)
                                                elide: Text.ElideRight
                                                Layout.fillWidth: true
                                            }
                                        }

                                        // Connect / Disconnect Action Pill
                                        Rectangle {
                                            Layout.preferredHeight: 26
                                            Layout.preferredWidth: actionLabel.implicitWidth + 18
                                            radius: 7
                                            color: netDelegate.modelData.active
                                                ? Qt.rgba(1.0, 1.0, 1.0, 0.14)
                                                : (actionMouse.containsMouse ? Qt.rgba(0.0, 0.82, 1.0, 0.95) : Qt.rgba(0.0, 0.75, 1.0, 0.80))
                                            border.color: netDelegate.modelData.active
                                                ? Qt.rgba(1.0, 1.0, 1.0, 0.25)
                                                : "#00E5FF"
                                            border.width: 1

                                            Text {
                                                id: actionLabel
                                                anchors.centerIn: parent
                                                text: netDelegate.modelData.active ? "Desconectar" : "Conectar"
                                                font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                                                font.pixelSize: 10
                                                font.weight: Font.DemiBold
                                                color: netDelegate.modelData.active ? "#FFFFFF" : "#0E1218"
                                            }

                                            MouseArea {
                                                id: actionMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (netDelegate.modelData.active) {
                                                        root.selectedSsidForPassword = "";
                                                        root.dockState.disconnectWifi(netDelegate.modelData.ssid);
                                                    } else if (netDelegate.modelData.known || !netDelegate.modelData.secure) {
                                                        root.selectedSsidForPassword = "";
                                                        root.dockState.connectWifi(netDelegate.modelData.ssid, "");
                                                    } else {
                                                        if (root.selectedSsidForPassword === netDelegate.modelData.ssid) {
                                                            root.selectedSsidForPassword = "";
                                                        } else {
                                                            root.passwordBuffer = "";
                                                            root.selectedSsidForPassword = netDelegate.modelData.ssid;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }

                                    // Inline Password Entry Row for secured unknown networks
                                    RowLayout {
                                        Layout.fillWidth: true
                                        visible: netDelegate.askingPass
                                        spacing: 6

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 28
                                            radius: 6
                                            color: Qt.rgba(0.04, 0.05, 0.07, 0.75)
                                            border.color: passInput.activeFocus ? "#00E5FF" : Qt.rgba(1.0, 1.0, 1.0, 0.22)
                                            border.width: 1

                                            TextInput {
                                                id: passInput
                                                anchors.fill: parent
                                                anchors.leftMargin: 8
                                                anchors.rightMargin: 8
                                                verticalAlignment: TextInput.AlignVCenter
                                                font.family: "Segoe UI, Inter, sans-serif"
                                                font.pixelSize: 11
                                                color: "#FFFFFF"
                                                echoMode: TextInput.Password
                                                clip: true
                                                onVisibleChanged: {
                                                    if (visible) {
                                                        text = "";
                                                        forceActiveFocus();
                                                    }
                                                }
                                                onAccepted: {
                                                    if (text.length > 0) {
                                                        root.dockState.connectWifi(netDelegate.modelData.ssid, text);
                                                        root.selectedSsidForPassword = "";
                                                        text = "";
                                                    }
                                                }

                                                Text {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    text: "Contraseña de red..."
                                                    font.family: "Segoe UI, Inter, sans-serif"
                                                    font.pixelSize: 10
                                                    color: Qt.rgba(1.0, 1.0, 1.0, 0.42)
                                                    visible: passInput.text.length === 0
                                                }
                                            }
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 56
                                            Layout.preferredHeight: 28
                                            radius: 6
                                            color: Qt.rgba(0.0, 0.75, 1.0, 0.85)
                                            border.color: "#00E5FF"
                                            border.width: 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: "Unirse"
                                                font.family: "Segoe UI, Inter, sans-serif"
                                                font.pixelSize: 10
                                                font.weight: Font.DemiBold
                                                color: "#0E1218"
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    if (passInput.text.length > 0) {
                                                        root.dockState.connectWifi(netDelegate.modelData.ssid, passInput.text);
                                                        root.selectedSsidForPassword = "";
                                                        passInput.text = "";
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    id: netRowMouse
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
