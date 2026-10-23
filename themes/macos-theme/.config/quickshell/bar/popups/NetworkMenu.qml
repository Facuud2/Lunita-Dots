import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    required property var barState

    visible: barState.activePopup === "network"
    x: Math.max(10, parent.width - width - 12)
    y: 4
    width: 310
    implicitHeight: mainCol.implicitHeight + 24
    height: implicitHeight
    z: 10
    opacity: visible ? 1 : 0
    scale: visible ? 1 : 0.96

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: barState.popupBgColor
        border.color: barState.popupBorderColor
        border.width: 1

        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: 15
            color: "transparent"
            border.color: Qt.rgba(0, 0, 0, barState.isDarkTheme ? 0.4 : 0.12)
            border.width: 1
            z: -1
        }

        Behavior on color {
            ColorAnimation {
                duration: 200
            }

        }

        Behavior on border.color {
            ColorAnimation {
                duration: 200
            }

        }

    }

    ColumnLayout {
        id: mainCol

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 12
        spacing: 10

        // ════════════════════════════════════════════════════════════════
        // ── 1. ETHERNET SECTION ──
        // ════════════════════════════════════════════════════════════════
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: ethCol.implicitHeight + 16
            radius: 10
            color: barState.popupCardBg
            border.color: barState.popupCardBorder
            border.width: 1

            ColumnLayout {
                id: ethCol

                anchors.fill: parent
                anchors.margins: 8
                spacing: 6

                // Ethernet Header with Toggle Switch
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        radius: 14
                        color: barState.ethernetConnected ? "#007AFF" : (barState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.08))

                        NetIcon {
                            anchors.centerIn: parent
                            iconWidth: 14
                            iconHeight: 14
                            source: "../assets/ethernet.svg"
                            iconColor: barState.ethernetConnected ? "#FFFFFF" : barState.popupTextColor
                        }

                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: "Ethernet"
                            color: barState.popupTextColor
                            font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold

                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                }

                            }

                        }

                        Text {
                            Layout.fillWidth: true
                            text: barState.ethernetConnected ? (barState.ethernetName + (barState.ethernetIp !== "" ? " • " + barState.ethernetIp : "")) : "Desconectado"
                            color: barState.popupTextDim
                            font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                            font.pixelSize: 10
                            elide: Text.ElideRight

                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                }

                            }

                        }

                    }

                    // Ethernet Master Toggle Pill
                    Rectangle {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 20
                        radius: 10
                        color: barState.ethernetConnected ? "#34C759" : (barState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(0, 0, 0, 0.15))

                        Rectangle {
                            x: barState.ethernetConnected ? parent.width - width - 2 : 2
                            anchors.verticalCenter: parent.verticalCenter
                            width: 16
                            height: 16
                            radius: 8
                            color: "#FFFFFF"

                            Behavior on x {
                                NumberAnimation {
                                    duration: 150
                                }

                            }

                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: barState.toggleEthernet()
                        }

                    }

                }

                // Ethernet Active Connection Details
                Rectangle {
                    visible: barState.ethernetConnected
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    radius: 6
                    color: barState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(0, 0, 0, 0.04)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        Rectangle {
                            Layout.preferredWidth: 6
                            Layout.preferredHeight: 6
                            radius: 3
                            color: "#34C759"
                        }

                        Text {
                            Layout.fillWidth: true
                            text: barState.ethernetDevice + " (Cable conectado)"
                            color: barState.popupTextColor
                            font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }

                        Text {
                            text: "✓"
                            color: "#007AFF"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                        }

                    }

                }

            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }

            }

        }

        // ════════════════════════════════════════════════════════════════
        // ── 2. WI-FI SECTION ──
        // ════════════════════════════════════════════════════════════════
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: wifiCol.implicitHeight + 16
            radius: 10
            color: barState.popupCardBg
            border.color: barState.popupCardBorder
            border.width: 1

            ColumnLayout {
                id: wifiCol

                anchors.fill: parent
                anchors.margins: 8
                spacing: 8

                // Wi-Fi Header with Toggle Switch
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        radius: 14
                        color: barState.wifiEnabled ? "#007AFF" : (barState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.08))

                        NetIcon {
                            anchors.centerIn: parent
                            iconWidth: 14
                            iconHeight: 14
                            source: barState.wifiEnabled ? "../assets/wifi.svg" : "../assets/wifi-off.svg"
                            iconColor: barState.wifiEnabled ? "#FFFFFF" : barState.popupTextColor
                        }

                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: "Wi-Fi"
                            color: barState.popupTextColor
                            font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold

                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                }

                            }

                        }

                        Text {
                            Layout.fillWidth: true
                            text: barState.wifiEnabled ? (barState.wifiConnected ? (barState.wifiName + (barState.wifiIp !== "" ? " • " + barState.wifiIp : "")) : "Buscando redes...") : "Desactivado"
                            color: barState.popupTextDim
                            font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                            font.pixelSize: 10
                            elide: Text.ElideRight

                            Behavior on color {
                                ColorAnimation {
                                    duration: 200
                                }

                            }

                        }

                    }

                    // Wi-Fi Master Toggle Pill
                    Rectangle {
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 20
                        radius: 10
                        color: barState.wifiEnabled ? "#34C759" : (barState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(0, 0, 0, 0.15))

                        Rectangle {
                            x: barState.wifiEnabled ? parent.width - width - 2 : 2
                            anchors.verticalCenter: parent.verticalCenter
                            width: 16
                            height: 16
                            radius: 8
                            color: "#FFFFFF"

                            Behavior on x {
                                NumberAnimation {
                                    duration: 150
                                }

                            }

                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: barState.toggleWifi()
                        }

                    }

                }

                // Available Wi-Fi Networks List
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: barState.wifiEnabled
                    spacing: 4

                    // Subheader with Rescan Button
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            Layout.fillWidth: true
                            text: "Redes Disponibles"
                            color: barState.popupTextDim
                            font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                            font.pixelSize: 10
                            font.weight: Font.DemiBold
                        }

                        Text {
                            text: "↻ Buscar"
                            color: "#007AFF"
                            font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                            font.pixelSize: 10
                            font.weight: Font.DemiBold

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: barState.rescanWifi()
                            }

                        }

                    }

                    // Repeater for Networks
                    Repeater {
                        model: barState.wifiNetworks || []

                        delegate: Rectangle {
                            id: wifiRow

                            required property var modelData

                            Layout.fillWidth: true
                            Layout.preferredHeight: 30
                            radius: 6
                            color: wifiRowMouse.containsMouse ? (barState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.06)) : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 6
                                anchors.rightMargin: 6
                                spacing: 8

                                NetIcon {
                                    iconWidth: 12
                                    iconHeight: 12
                                    source: "../assets/wifi.svg"
                                    iconColor: wifiRow.modelData.active ? "#007AFF" : barState.popupTextColor
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: wifiRow.modelData.ssid || "Red oculta"
                                    color: wifiRow.modelData.active ? "#007AFF" : barState.popupTextColor
                                    font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                                    font.pixelSize: 11
                                    font.weight: wifiRow.modelData.active ? Font.DemiBold : Font.Normal
                                    elide: Text.ElideRight
                                }

                                Text {
                                    visible: !!wifiRow.modelData.security && wifiRow.modelData.security !== ""
                                    text: "🔒"
                                    font.pixelSize: 9
                                    opacity: 0.6
                                }

                                Text {
                                    text: (wifiRow.modelData.signal || 50) + "%"
                                    color: barState.popupTextDim
                                    font.pixelSize: 9
                                }

                                Text {
                                    visible: wifiRow.modelData.active
                                    text: "✓"
                                    color: "#007AFF"
                                    font.pixelSize: 11
                                    font.weight: Font.Bold
                                }

                            }

                            MouseArea {
                                id: wifiRowMouse

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    barState.connectWifi(wifiRow.modelData.ssid);
                                }
                            }

                        }

                    }

                    Text {
                        visible: (!barState.wifiNetworks || barState.wifiNetworks.length === 0)
                        text: "No se encontraron redes Wi-Fi cercanas"
                        color: barState.popupTextDim
                        font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                        font.pixelSize: 10
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 4
                        Layout.bottomMargin: 4
                    }

                }

            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }

            }

        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: barState.popupCardBorder
        }

        // ════════════════════════════════════════════════════════════════
        // ── 3. NETWORK SETTINGS BUTTON ──
        // ════════════════════════════════════════════════════════════════
        Rectangle {
            id: netSettingsBtn

            Layout.fillWidth: true
            Layout.preferredHeight: 28
            radius: 6
            color: netSettingsMouse.containsMouse ? barState.barActiveHoverColor : "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 6
                anchors.rightMargin: 6
                spacing: 8

                NetIcon {
                    iconWidth: 12
                    iconHeight: 12
                    source: "../assets/control-center.svg"
                    iconColor: barState.popupTextColor
                }

                Text {
                    text: "Ajustes de Red..."
                    color: barState.popupTextColor
                    font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                    font.pixelSize: 11

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }

                    }

                }

            }

            MouseArea {
                id: netSettingsMouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    barState.closePopups();
                    barState.launchCommand("nm-connection-editor || nmtui");
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 120
                }

            }

        }

    }

    Behavior on opacity {
        NumberAnimation {
            duration: 140
            easing.type: Easing.OutCubic
        }

    }

    Behavior on scale {
        NumberAnimation {
            duration: 140
            easing.type: Easing.OutCubic
        }

    }

    // Helper SVG icon with ColorOverlay
    component NetIcon: Item {
        id: netIconRoot

        property string source: ""
        property color iconColor: barState.popupTextColor
        property real iconWidth: 14
        property real iconHeight: 14

        implicitWidth: iconWidth
        implicitHeight: iconHeight

        Image {
            id: rawSvg

            anchors.fill: parent
            source: netIconRoot.source
            sourceSize.width: Math.round(netIconRoot.iconWidth * 2)
            sourceSize.height: Math.round(netIconRoot.iconHeight * 2)
            visible: false
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
        }

        ColorOverlay {
            anchors.fill: rawSvg
            source: rawSvg
            color: netIconRoot.iconColor

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }

            }

        }

    }

}
