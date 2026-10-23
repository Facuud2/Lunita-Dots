import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    required property var dockState
    readonly property string uiFont: "Adwaita Sans"
    property string expandedSsid: ""
    property string selectedSsidForPassword: ""
    property bool connectAutoChecked: true
    property bool ethExpanded: false

    width: 360
    height: mainCard.implicitHeight
    implicitWidth: 360
    implicitHeight: mainCard.implicitHeight
    // Smooth Appearance & Disappearance (Windows 11 Fluent Motion)
    opacity: (root.dockState.flyoutOpen && root.dockState.activeFlyout === "network") ? 1 : 0
    scale: (root.dockState.flyoutOpen && root.dockState.activeFlyout === "network") ? 1 : 0.96
    transformOrigin: Item.BottomRight

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
        border.color: Qt.rgba(1, 1, 1, 0.14)
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
            color: Qt.rgba(1, 1, 1, 0.16)
        }

        ColumnLayout {
            // ==========================================
            // 3. WI-FI NETWORKS LIST AREA
            // ==========================================

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
                        color: backMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"

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

                    // Header Title ("Wi-Fi")
                    Text {
                        text: "Wi-Fi"
                        font.family: root.uiFont
                        font.styleName: "SemiBold"
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        font.italic: false
                        color: "#FFFFFF"
                        Layout.fillWidth: true
                    }

                    // Windows 11 Authentic Pill Toggle Switch
                    Rectangle {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 20
                        radius: 10
                        color: root.dockState.wifiEnabled ? "#60CDFF" : Qt.rgba(1, 1, 1, 0.04)
                        border.color: root.dockState.wifiEnabled ? "#60CDFF" : Qt.rgba(1, 1, 1, 0.58)
                        border.width: 1

                        Rectangle {
                            width: 12
                            height: 12
                            radius: 6
                            anchors.verticalCenter: parent.verticalCenter
                            x: root.dockState.wifiEnabled ? (parent.width - width - 4) : 4
                            color: root.dockState.wifiEnabled ? "#000000" : Qt.rgba(1, 1, 1, 0.85)

                            Behavior on x {
                                NumberAnimation {
                                    duration: 150
                                    easing.type: Easing.OutCubic
                                }

                            }

                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.dockState.toggleWifiRadio()
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 140
                            }

                        }

                    }

                }

            }

            // ==========================================
            // 2. ETHERNET ROW (WINDOWS 11 COMPACT LIST ITEM)
            // ==========================================
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: ethItemRect.height + 8
                visible: root.dockState.ethernetConnected || root.dockState.ethernetHasDevice

                Rectangle {
                    id: ethItemRect

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    height: root.ethExpanded ? 78 : 54
                    radius: 6
                    color: root.ethExpanded ? Qt.rgba(1, 1, 1, 0.08) : (ethHover.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : "transparent")

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        anchors.topMargin: 8
                        anchors.bottomMargin: 8
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 14

                            Image {
                                source: "assets/ethernet.svg"
                                sourceSize.width: 22
                                sourceSize.height: 22
                                smooth: true
                                opacity: root.dockState.ethernetConnected ? 1 : 0.65
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                Text {
                                    text: root.dockState.ethernetConnected ? (root.dockState.ethernetName || "Ethernet") : "Ethernet"
                                    font.family: root.uiFont
                                    font.styleName: "Regular"
                                    font.pixelSize: 13
                                    font.weight: Font.Normal
                                    font.italic: false
                                    color: "#FFFFFF"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: root.dockState.ethernetConnected ? "Conectado" : "No conectado"
                                    font.family: root.uiFont
                                    font.styleName: "Regular"
                                    font.pixelSize: 12
                                    font.weight: Font.Normal
                                    font.italic: false
                                    color: Qt.rgba(1, 1, 1, 0.68)
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                            }

                        }

                        // Expanded Ethernet Details (IP & Interface)
                        Text {
                            visible: root.ethExpanded
                            Layout.leftMargin: 36
                            text: (root.dockState.ethernetDevice ? ("Interfaz: " + root.dockState.ethernetDevice) : "Red cableada") + (root.dockState.ethernetIp ? ("  •  IPv4: " + root.dockState.ethernetIp) : "")
                            font.family: root.uiFont
                            font.styleName: "Regular"
                            font.pixelSize: 11
                            font.weight: Font.Normal
                            font.italic: false
                            color: "#60CDFF"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                    }

                    MouseArea {
                        id: ethHover

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.ethExpanded = !root.ethExpanded
                    }

                    Behavior on height {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutCubic
                        }

                    }

                }

            }

            // Subtle Windows 11 Divider between Ethernet and Wi-Fi
            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.bottomMargin: 4
                height: 1
                color: Qt.rgba(1, 1, 1, 0.08)
                visible: root.dockState.ethernetConnected || root.dockState.ethernetHasDevice
            }

            // Wi-Fi Disabled or Empty State (Windows 11 Centered Placeholder)
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 180
                visible: !root.dockState.wifiEnabled || root.dockState.wifiNetworks.length === 0

                ColumnLayout {
                    anchors.centerIn: parent
                    width: parent.width - 48
                    spacing: 8

                    Image {
                        Layout.alignment: Qt.AlignHCenter
                        source: !root.dockState.wifiEnabled ? "assets/tray-wifi-off.svg" : "assets/tray-wifi.svg"
                        sourceSize.width: 28
                        sourceSize.height: 28
                        opacity: 0.7
                    }

                    Text {
                        Layout.fillWidth: true
                        text: !root.dockState.wifiEnabled ? "El Wi-Fi está desactivado" : (root.dockState.networkScanning ? "Buscando redes..." : "No se encontraron redes Wi-Fi")
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
                        visible: !root.dockState.wifiEnabled
                        text: "Activa el Wi-Fi para conectarte a una red inalámbrica disponible."
                        font.family: root.uiFont
                        font.styleName: "Regular"
                        font.pixelSize: 12
                        font.weight: Font.Normal
                        font.italic: false
                        color: Qt.rgba(1, 1, 1, 0.65)
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }

                }

            }

            // Scrollable Wi-Fi List (Windows 11 Style)
            Flickable {
                id: networksFlick

                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(290, networksListCol.implicitHeight + 12)
                contentWidth: width
                contentHeight: networksListCol.implicitHeight + 12
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                visible: root.dockState.wifiEnabled && root.dockState.wifiNetworks.length > 0

                ColumnLayout {
                    id: networksListCol

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    anchors.topMargin: 4
                    spacing: 2

                    Repeater {
                        model: root.dockState.wifiNetworks

                        delegate: Rectangle {
                            id: netDelegate

                            required property var modelData
                            readonly property bool isExpanded: (root.expandedSsid === modelData.ssid) || (root.expandedSsid === "" && modelData.active)
                            readonly property bool askingPass: (root.selectedSsidForPassword === modelData.ssid) && !modelData.active

                            Layout.fillWidth: true
                            Layout.preferredHeight: isExpanded ? (askingPass ? 142 : (modelData.active ? 98 : 124)) : 48
                            radius: 6
                            color: isExpanded ? Qt.rgba(1, 1, 1, 0.08) : (rowHover.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent")

                            // Click handler on row to expand/collapse (Windows 11 behavior)
                            MouseArea {
                                id: rowHover

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.expandedSsid === netDelegate.modelData.ssid) {
                                        root.expandedSsid = "__none__";
                                        root.selectedSsidForPassword = "";
                                    } else {
                                        root.expandedSsid = netDelegate.modelData.ssid;
                                        root.selectedSsidForPassword = "";
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

                                // Top Row: Signal Icon + Lock Badge + SSID + Subtitle
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 14

                                    // Wi-Fi Signal Icon with optional Lock Badge
                                    Item {
                                        Layout.preferredWidth: 22
                                        Layout.preferredHeight: 22

                                        Image {
                                            anchors.centerIn: parent
                                            source: "assets/tray-wifi.svg"
                                            sourceSize.width: 20
                                            sourceSize.height: 20
                                            opacity: Math.max(0.55, Math.min(1, (netDelegate.modelData.signal || 60) / 100))
                                        }

                                        Image {
                                            visible: !!netDelegate.modelData.secure
                                            anchors.right: parent.right
                                            anchors.bottom: parent.bottom
                                            anchors.rightMargin: -2
                                            anchors.bottomMargin: -1
                                            source: "assets/lock.svg"
                                            sourceSize.width: 10
                                            sourceSize.height: 10
                                            opacity: 0.9
                                        }

                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1

                                        Text {
                                            text: netDelegate.modelData.ssid
                                            font.family: root.uiFont
                                            font.styleName: (netDelegate.modelData.active || netDelegate.isExpanded) ? "SemiBold" : "Regular"
                                            font.pixelSize: 13
                                            font.weight: (netDelegate.modelData.active || netDelegate.isExpanded) ? Font.DemiBold : Font.Normal
                                            font.italic: false
                                            color: "#FFFFFF"
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }

                                        Text {
                                            visible: netDelegate.modelData.active || netDelegate.isExpanded
                                            text: netDelegate.modelData.active ? ("Conectado, " + (netDelegate.modelData.secure ? "seguro" : "abierta")) : (netDelegate.modelData.secure ? "Segura" : "Abierta")
                                            font.family: root.uiFont
                                            font.styleName: "Regular"
                                            font.pixelSize: 12
                                            font.weight: Font.Normal
                                            font.italic: false
                                            color: Qt.rgba(1, 1, 1, 0.68)
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }

                                    }

                                }

                                // Expanded Section 1: "Conectar automáticamente" Checkbox (When disconnected & not asking password)
                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.leftMargin: 36
                                    visible: netDelegate.isExpanded && !netDelegate.modelData.active && !netDelegate.askingPass
                                    spacing: 8

                                    Rectangle {
                                        width: 18
                                        height: 18
                                        radius: 4
                                        color: root.connectAutoChecked ? "#60CDFF" : Qt.rgba(1, 1, 1, 0.06)
                                        border.color: root.connectAutoChecked ? "#60CDFF" : Qt.rgba(1, 1, 1, 0.55)
                                        border.width: 1

                                        Text {
                                            anchors.centerIn: parent
                                            visible: root.connectAutoChecked
                                            text: "✓"
                                            font.family: root.uiFont
                                            font.styleName: "SemiBold"
                                            font.pixelSize: 12
                                            font.weight: Font.Bold
                                            font.italic: false
                                            color: "#000000"
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.connectAutoChecked = !root.connectAutoChecked
                                        }

                                    }

                                    Text {
                                        text: "Conectar automáticamente"
                                        font.family: root.uiFont
                                        font.styleName: "Regular"
                                        font.pixelSize: 12
                                        font.weight: Font.Normal
                                        font.italic: false
                                        color: "#FFFFFF"
                                        Layout.fillWidth: true
                                    }

                                }

                                // Expanded Section 2: Action Button ("Conectar" / "Desconectar")
                                RowLayout {
                                    Layout.fillWidth: true
                                    visible: netDelegate.isExpanded && !netDelegate.askingPass

                                    Item {
                                        Layout.fillWidth: true
                                    }

                                    Rectangle {
                                        Layout.preferredWidth: 116
                                        Layout.preferredHeight: 32
                                        radius: 4
                                        color: netDelegate.modelData.active ? (actMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.08)) : (actMouse.containsMouse ? "#78D6FF" : "#60CDFF")
                                        border.color: netDelegate.modelData.active ? Qt.rgba(1, 1, 1, 0.14) : "#60CDFF"
                                        border.width: 1

                                        Text {
                                            anchors.centerIn: parent
                                            text: netDelegate.modelData.active ? "Desconectar" : "Conectar"
                                            font.family: root.uiFont
                                            font.styleName: netDelegate.modelData.active ? "Regular" : "SemiBold"
                                            font.pixelSize: 12
                                            font.weight: netDelegate.modelData.active ? Font.Normal : Font.DemiBold
                                            font.italic: false
                                            color: netDelegate.modelData.active ? "#FFFFFF" : "#000000"
                                        }

                                        MouseArea {
                                            id: actMouse

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
                                                    root.selectedSsidForPassword = netDelegate.modelData.ssid;
                                                }
                                            }
                                        }

                                    }

                                }

                                // Expanded Section 3: Windows 11 Password Entry Box (When secured & unknown)
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.leftMargin: 36
                                    visible: netDelegate.isExpanded && netDelegate.askingPass
                                    spacing: 8

                                    // Fluent Text Box with bottom accent line
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 32
                                        radius: 4
                                        color: Qt.rgba(0.05, 0.06, 0.08, 0.75)
                                        border.color: Qt.rgba(1, 1, 1, 0.18)
                                        border.width: 1
                                        clip: true

                                        // Windows 11 Bottom Focus Accent Bar
                                        Rectangle {
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            anchors.bottom: parent.bottom
                                            height: passInput.activeFocus ? 2 : 1
                                            color: passInput.activeFocus ? "#60CDFF" : Qt.rgba(1, 1, 1, 0.35)
                                        }

                                        TextInput {
                                            id: passInput

                                            anchors.fill: parent
                                            anchors.leftMargin: 10
                                            anchors.rightMargin: 10
                                            verticalAlignment: TextInput.AlignVCenter
                                            font.family: root.uiFont
                                            font.styleName: "Regular"
                                            font.pixelSize: 12
                                            font.italic: false
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
                                                text: "Escriba la clave de seguridad de red"
                                                font.family: root.uiFont
                                                font.styleName: "Regular"
                                                font.pixelSize: 12
                                                font.italic: false
                                                color: Qt.rgba(1, 1, 1, 0.48)
                                                visible: passInput.text.length === 0
                                            }

                                        }

                                    }

                                    // "Siguiente" and "Cancelar" buttons row
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 8

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 30
                                            radius: 4
                                            color: passInput.text.length > 0 ? "#60CDFF" : Qt.rgba(1, 1, 1, 0.12)

                                            Text {
                                                anchors.centerIn: parent
                                                text: "Siguiente"
                                                font.family: root.uiFont
                                                font.styleName: "SemiBold"
                                                font.pixelSize: 12
                                                font.weight: Font.DemiBold
                                                font.italic: false
                                                color: passInput.text.length > 0 ? "#000000" : Qt.rgba(1, 1, 1, 0.45)
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

                                        Rectangle {
                                            Layout.fillWidth: true
                                            Layout.preferredHeight: 30
                                            radius: 4
                                            color: Qt.rgba(1, 1, 1, 0.08)
                                            border.color: Qt.rgba(1, 1, 1, 0.14)
                                            border.width: 1

                                            Text {
                                                anchors.centerIn: parent
                                                text: "Cancelar"
                                                font.family: root.uiFont
                                                font.styleName: "Regular"
                                                font.pixelSize: 12
                                                font.italic: false
                                                color: "#FFFFFF"
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    root.selectedSsidForPassword = "";
                                                    passInput.text = "";
                                                }
                                            }

                                        }

                                    }

                                }

                            }

                            Behavior on Layout.preferredHeight {
                                NumberAnimation {
                                    duration: 150
                                    easing.type: Easing.OutCubic
                                }

                            }

                        }

                    }

                }

            }

            // ==========================================
            // 4. WINDOWS 11 BOTTOM FOOTER BAR
            // ==========================================
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(1, 1, 1, 0.1)
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
                        text: "Más opciones de configuración de Wi-Fi"
                        font.family: root.uiFont
                        font.styleName: "Regular"
                        font.pixelSize: 12
                        font.weight: Font.Normal
                        font.italic: false
                        color: settingsLinkMouse.containsMouse ? "#88DCFF" : "#60CDFF"
                        Layout.fillWidth: true
                        elide: Text.ElideRight

                        MouseArea {
                            id: settingsLinkMouse

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Quickshell.execDetached(["bash", "-c", "nm-connection-editor || kitty -e nmtui &"]);
                            }
                        }

                    }

                    // Rescan / Refresh Wi-Fi Networks Button
                    Rectangle {
                        visible: root.dockState.wifiEnabled
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        radius: 6
                        color: scanMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.08) : "transparent"

                        Image {
                            id: scanIcon

                            anchors.centerIn: parent
                            source: "assets/reload.svg"
                            sourceSize.width: 15
                            sourceSize.height: 15
                            opacity: root.dockState.networkScanning ? 0.55 : 0.88

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

                }

            }

        }

    }

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

}
