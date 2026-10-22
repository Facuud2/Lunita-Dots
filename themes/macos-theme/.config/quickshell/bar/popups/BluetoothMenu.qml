import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    required property var barState

    visible: barState.activePopup === "bluetooth"
    x: Math.max(10, parent.width - width - 12)
    y: 4
    width: 290
    implicitHeight: mainCol.implicitHeight + 20
    height: implicitHeight
    z: 10
    opacity: visible ? 1 : 0
    scale: visible ? 1 : 0.96

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: barState.popupBgColor
        border.color: barState.popupBorderColor
        border.width: 1

        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: 13
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
        anchors.margins: 10
        spacing: 8

        // ── 1. Header with Master Power Switch ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                width: 28
                height: 28
                radius: 14
                color: barState.bluetoothEnabled ? "#007AFF" : (barState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.08))

                BtIcon {
                    anchors.centerIn: parent
                    iconWidth: 14
                    iconHeight: 14
                    source: "../assets/bluetooth.svg"
                    iconColor: barState.bluetoothEnabled ? "#FFFFFF" : barState.popupTextColor
                }

            }

            ColumnLayout {
                spacing: 1

                Text {
                    text: "Bluetooth"
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
                    text: barState.bluetoothEnabled ? (barState.bluetoothConnectedDevice !== "" ? barState.bluetoothConnectedDevice : "Activado") : "Desactivado"
                    color: barState.popupTextDim
                    font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                    font.pixelSize: 10
                    elide: Text.ElideRight
                    Layout.maximumWidth: 160

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }

                    }

                }

            }

            Item {
                Layout.fillWidth: true
            }

            // macOS Toggle Pill
            Rectangle {
                width: 36
                height: 20
                radius: 10
                color: barState.bluetoothEnabled ? "#34C759" : (barState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(0, 0, 0, 0.15))

                Rectangle {
                    x: barState.bluetoothEnabled ? parent.width - width - 2 : 2
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
                    onClicked: barState.toggleBluetooth()
                }

            }

        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: barState.popupSeparatorColor
        }

        // ── 2. Devices Section (when enabled) ──
        ColumnLayout {
            Layout.fillWidth: true
            visible: barState.bluetoothEnabled
            spacing: 4

            Text {
                text: "DISPOSITIVOS"
                color: barState.popupTextDim
                font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                font.pixelSize: 10
                font.weight: Font.DemiBold
                Layout.leftMargin: 4
                Layout.topMargin: 2
            }

            Repeater {
                model: barState.bluetoothDevices

                delegate: Rectangle {
                    id: devRow

                    required property var modelData
                    required property int index
                    property var stateRef: root.barState

                    Layout.fillWidth: true
                    implicitHeight: 34
                    radius: 8
                    color: devMouse.containsMouse ? (stateRef.isDarkTheme ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.06)) : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        Text {
                            text: modelData.isAudio ? "🎧" : "📱"
                            font.pixelSize: 14
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                text: modelData.name || modelData.mac
                                color: devRow.stateRef.popupTextColor
                                font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                                font.pixelSize: 12
                                font.weight: modelData.connected ? Font.DemiBold : Font.Normal
                                elide: Text.ElideRight

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 200
                                    }

                                }

                            }

                            Text {
                                text: modelData.connected ? "Conectado" : "Emparejado"
                                color: modelData.connected ? "#34C759" : devRow.stateRef.popupTextDim
                                font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                                font.pixelSize: 10
                            }

                        }

                        // Status Badge / Disconnect Button
                        Rectangle {
                            width: 32
                            height: 18
                            radius: 9
                            color: modelData.connected ? Qt.rgba(0.2, 0.78, 0.35, 0.2) : (devRow.stateRef.isDarkTheme ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.06))

                            Text {
                                anchors.centerIn: parent
                                text: modelData.connected ? "ON" : "OFF"
                                color: modelData.connected ? "#34C759" : devRow.stateRef.popupTextDim
                                font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                                font.pixelSize: 9
                                font.weight: Font.Bold
                            }

                        }

                    }

                    MouseArea {
                        id: devMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            devRow.stateRef.connectBluetoothDevice(modelData.mac, modelData.connected);
                        }
                    }

                }

            }

            Text {
                visible: (!barState.bluetoothDevices || barState.bluetoothDevices.length === 0)
                text: "No hay dispositivos emparejados"
                color: barState.popupTextDim
                font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                font.pixelSize: 11
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 4
                Layout.bottomMargin: 4
            }

        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: barState.popupSeparatorColor
        }

        // ── 3. Bottom Action Buttons ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 26
                radius: 6
                color: scanMouse.containsMouse ? (barState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.08)) : (barState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(0, 0, 0, 0.04))

                Text {
                    anchors.centerIn: parent
                    text: "Buscar dispositivos"
                    color: barState.popupTextColor
                    font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                    font.pixelSize: 11
                }

                MouseArea {
                    id: scanMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: barState.rescanBluetooth()
                }

            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 26
                radius: 6
                color: mgrMouse.containsMouse ? (barState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.08)) : (barState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(0, 0, 0, 0.04))

                Text {
                    anchors.centerIn: parent
                    text: "Ajustes..."
                    color: barState.popupTextColor
                    font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                    font.pixelSize: 11
                }

                MouseArea {
                    id: mgrMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: barState.openBluetoothSettings()
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
    component BtIcon: Item {
        id: btIconRoot

        property string source: ""
        property color iconColor: barState.popupTextColor
        property real iconWidth: 14
        property real iconHeight: 14

        implicitWidth: iconWidth
        implicitHeight: iconHeight

        Image {
            id: rawSvg

            anchors.fill: parent
            source: btIconRoot.source
            sourceSize.width: Math.round(btIconRoot.iconWidth * 2)
            sourceSize.height: Math.round(btIconRoot.iconHeight * 2)
            visible: false
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
        }

        ColorOverlay {
            anchors.fill: rawSvg
            source: rawSvg
            color: btIconRoot.iconColor

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }

            }

        }

    }

}
