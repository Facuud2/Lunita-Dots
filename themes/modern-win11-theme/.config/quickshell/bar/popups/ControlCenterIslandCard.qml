import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

Item {
    id: root

    required property var barState

    width: 370 + 24 // include ear wings
    height: 280
    anchors.top: parent.top
    anchors.topMargin: 0

    visible: barState.activePopup === "controlcenter"
    opacity: visible ? 1.0 : 0.0
    y: visible ? 0 : -20

    Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

    Item {
        id: cardContainer
        width: 370
        height: 280
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        // Main Card Rectangle (flat top, rounded bottom)
        Rectangle {
            id: mainCardBg
            anchors.fill: parent
            topLeftRadius: 0
            topRightRadius: 0
            bottomLeftRadius: 22
            bottomRightRadius: 22

            color: Qt.rgba(0.04, 0.05, 0.06, 0.97)
            border.color: Qt.rgba(1, 1, 1, 0.14)
            border.width: 1
        }

        // Left Inverted Ear
        Shape {
            anchors.right: mainCardBg.left
            anchors.top: parent.top
            width: 12
            height: 12

            ShapePath {
                fillColor: Qt.rgba(0.04, 0.05, 0.06, 0.97)
                strokeColor: "transparent"
                startX: 0; startY: 0
                PathLine { x: 12; y: 0 }
                PathLine { x: 12; y: 12 }
                PathArc {
                    x: 0; y: 0
                    radiusX: 12; radiusY: 12
                    direction: PathArc.Counterclockwise
                }
            }
        }

        // Right Inverted Ear
        Shape {
            anchors.left: mainCardBg.right
            anchors.top: parent.top
            width: 12
            height: 12

            ShapePath {
                fillColor: Qt.rgba(0.04, 0.05, 0.06, 0.97)
                strokeColor: "transparent"
                startX: 0; startY: 0
                PathLine { x: 12; y: 0 }
                PathArc {
                    x: 0; y: 12
                    radiusX: 12; radiusY: 12
                    direction: PathArc.Counterclockwise
                }
                PathLine { x: 0; y: 0 }
            }
        }

        // Internal Content
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            anchors.topMargin: 8
            spacing: 10

            // 1. Top Header Row: Weather, Time, Battery (Vector SVG Icons)
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 18

                // Weather
                Row {
                    spacing: 5
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                    Image {
                        source: "../assets/moon.svg"
                        sourceSize.width: 12
                        sourceSize.height: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: root.barState.weatherTemp
                        font.family: "Segoe UI, Inter, Cantarell, sans-serif"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: Qt.rgba(1, 1, 1, 0.85)
                    }
                }

                Item { Layout.fillWidth: true }

                // Time
                Text {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    text: root.barState.timeStr
                    font.family: "Segoe UI, Inter, Cantarell, sans-serif"
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    color: "#FFFFFF"
                }

                Item { Layout.fillWidth: true }

                // Battery
                Row {
                    spacing: 4
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                    Image {
                        source: "../assets/battery.svg"
                        sourceSize.width: 15
                        sourceSize.height: 15
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: root.barState.batteryPercent + "%"
                        font.family: "Segoe UI, Inter, Cantarell, sans-serif"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: Qt.rgba(1, 1, 1, 0.85)
                    }
                }
            }

            // 2. 4 Large Toggles (2x2 Grid)
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 8
                rowSpacing: 8

                // Wi-Fi Toggle
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    radius: 12
                    color: root.barState.wifiConnected ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.08)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 8

                        Image {
                            source: "../assets/wifi.svg"
                            sourceSize.width: 16
                            sourceSize.height: 16
                            // Color invert when container is white
                            opacity: root.barState.wifiConnected ? 0.9 : 0.7
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                text: "Wi-Fi"
                                font.family: "Segoe UI, Inter, sans-serif"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: root.barState.wifiConnected ? "#111215" : "#FFFFFF"
                            }
                            Text {
                                text: root.barState.wifiConnected ? "Connected" : "Disconnected"
                                font.family: "Segoe UI, Inter, sans-serif"
                                font.pixelSize: 9
                                color: root.barState.wifiConnected ? Qt.rgba(0.1, 0.1, 0.1, 0.7) : Qt.rgba(1, 1, 1, 0.5)
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.barState.toggleWifi()
                    }
                }

                // Dock Mode Toggle
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    radius: 12
                    color: root.barState.dockMode === "Smart" ? Qt.rgba(1, 1, 1, 0.08) : "#FFFFFF"
                    border.color: Qt.rgba(1, 1, 1, 0.12)
                    border.width: 0.5

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 8

                        Image {
                            source: "../assets/dock-mode.svg"
                            sourceSize.width: 16
                            sourceSize.height: 16
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                text: "Dock Mode"
                                font.family: "Segoe UI, Inter, sans-serif"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: root.barState.dockMode === "Smart" ? "#FFFFFF" : "#111215"
                            }
                            Text {
                                text: root.barState.dockMode
                                font.family: "Segoe UI, Inter, sans-serif"
                                font.pixelSize: 9
                                color: root.barState.dockMode === "Smart" ? Qt.rgba(1, 1, 1, 0.5) : Qt.rgba(0.1, 0.1, 0.1, 0.7)
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.barState.cycleDockMode()
                    }
                }

                // Bluetooth Toggle
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    radius: 12
                    color: root.barState.bluetoothConnected ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.08)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 8

                        Image {
                            source: "../assets/bluetooth.svg"
                            sourceSize.width: 15
                            sourceSize.height: 15
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                text: "Bluetooth"
                                font.family: "Segoe UI, Inter, sans-serif"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: root.barState.bluetoothConnected ? "#111215" : "#FFFFFF"
                            }
                            Text {
                                text: root.barState.bluetoothConnected ? "On" : "Off"
                                font.family: "Segoe UI, Inter, sans-serif"
                                font.pixelSize: 9
                                color: root.barState.bluetoothConnected ? Qt.rgba(0.1, 0.1, 0.1, 0.7) : Qt.rgba(1, 1, 1, 0.5)
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.barState.toggleBluetooth()
                    }
                }

                // Notch Mode Toggle
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    radius: 12
                    color: root.barState.notchMode === "Fixed" ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.08)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 8

                        Image {
                            source: "../assets/notch-mode.svg"
                            sourceSize.width: 16
                            sourceSize.height: 16
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                text: "Notch Mode"
                                font.family: "Segoe UI, Inter, sans-serif"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: root.barState.notchMode === "Fixed" ? "#111215" : "#FFFFFF"
                            }
                            Text {
                                text: root.barState.notchMode
                                font.family: "Segoe UI, Inter, sans-serif"
                                font.pixelSize: 9
                                color: root.barState.notchMode === "Fixed" ? Qt.rgba(0.1, 0.1, 0.1, 0.7) : Qt.rgba(1, 1, 1, 0.5)
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.barState.cycleNotchMode()
                    }
                }
            }

            // 3. 6 Circular Quick Action Buttons (Vector SVG Icons)
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 12

                // Moon / Night Light Button
                Rectangle {
                    width: 34; height: 34; radius: 17
                    color: root.barState.nightLightEnabled ? "#FFFFFF" : (btn1.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.08))
                    Image {
                        anchors.centerIn: parent
                        source: "../assets/moon.svg"
                        sourceSize.width: 15
                        sourceSize.height: 15
                    }
                    MouseArea { id: btn1; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.barState.toggleNightLight() }
                }

                // Screen record / screenshot
                Rectangle {
                    width: 34; height: 34; radius: 17
                    color: btn2.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.08)
                    Image {
                        anchors.centerIn: parent
                        source: "../assets/screen-record.svg"
                        sourceSize.width: 15
                        sourceSize.height: 15
                    }
                    MouseArea { id: btn2; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.barState.triggerScreenshot() }
                }

                // App Launcher Grid
                Rectangle {
                    width: 34; height: 34; radius: 17
                    color: btn3.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.08)
                    Image {
                        anchors.centerIn: parent
                        source: "../assets/grid-launcher.svg"
                        sourceSize.width: 14
                        sourceSize.height: 14
                    }
                    MouseArea { id: btn3; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.barState.openLauncher() }
                }

                // Notifications Bell
                Rectangle {
                    width: 34; height: 34; radius: 17
                    color: root.barState.dndActive ? Qt.rgba(1, 0.3, 0.3, 0.3) : (btn4.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.08))
                    Image {
                        anchors.centerIn: parent
                        source: "../assets/bell.svg"
                        sourceSize.width: 15
                        sourceSize.height: 15
                    }
                    MouseArea { id: btn4; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.barState.toggleDnd() }
                }

                // Settings Gear
                Rectangle {
                    width: 34; height: 34; radius: 17
                    color: btn5.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.08)
                    Image {
                        anchors.centerIn: parent
                        source: "../assets/gear.svg"
                        sourceSize.width: 15
                        sourceSize.height: 15
                    }
                    MouseArea { id: btn5; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Quickshell.execDetached(["bash", "-c", "systemsettings 2>/dev/null || xfce4-settings-manager 2>/dev/null || true"]) }
                }

                // Reload
                Rectangle {
                    width: 34; height: 34; radius: 17
                    color: btn6.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.08)
                    Image {
                        anchors.centerIn: parent
                        source: "../assets/reload.svg"
                        sourceSize.width: 15
                        sourceSize.height: 15
                    }
                    MouseArea { id: btn6; anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.barState.reloadInterface() }
                }
            }

            // 4. Sliders (Volume & Brightness)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 7

                // Volume Slider
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Image {
                        source: "../assets/volume.svg"
                        sourceSize.width: 14
                        sourceSize.height: 14
                    }

                    Text {
                        text: "Volume"
                        font.family: "Segoe UI, Inter, sans-serif"
                        font.pixelSize: 10
                        font.weight: Font.Medium
                        color: Qt.rgba(1, 1, 1, 0.7)
                        Layout.preferredWidth: 44
                    }

                    Rectangle {
                        id: volTrack
                        Layout.fillWidth: true
                        Layout.preferredHeight: 5
                        radius: 2.5
                        color: Qt.rgba(1, 1, 1, 0.15)

                        Rectangle {
                            height: parent.height
                            radius: 2.5
                            color: "#FFFFFF"
                            width: parent.width * (root.barState.volumePercent / 100.0)
                        }

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            cursorShape: Qt.PointingHandCursor
                            onPositionChanged: mouse => {
                                var pct = Math.max(0, Math.min(100, (mouse.x / volTrack.width) * 100));
                                root.barState.setVolume(pct);
                            }
                            onClicked: mouse => {
                                var pct = Math.max(0, Math.min(100, (mouse.x / volTrack.width) * 100));
                                root.barState.setVolume(pct);
                            }
                        }
                    }

                    Text {
                        text: root.barState.volumePercent + "%"
                        font.family: "Segoe UI, Inter, sans-serif"
                        font.pixelSize: 10
                        font.weight: Font.Medium
                        color: Qt.rgba(1, 1, 1, 0.70)
                        Layout.preferredWidth: 26
                        horizontalAlignment: Text.AlignRight
                    }
                }

                // Brightness Slider
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Image {
                        source: "../assets/brightness.svg"
                        sourceSize.width: 14
                        sourceSize.height: 14
                    }

                    Text {
                        text: "Brightness"
                        font.family: "Segoe UI, Inter, sans-serif"
                        font.pixelSize: 10
                        font.weight: Font.Medium
                        color: Qt.rgba(1, 1, 1, 0.7)
                        Layout.preferredWidth: 44
                    }

                    Rectangle {
                        id: brightTrack
                        Layout.fillWidth: true
                        Layout.preferredHeight: 5
                        radius: 2.5
                        color: Qt.rgba(1, 1, 1, 0.15)

                        Rectangle {
                            height: parent.height
                            radius: 2.5
                            color: "#FFFFFF"
                            width: parent.width * (root.barState.brightnessPercent / 100.0)
                        }

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            cursorShape: Qt.PointingHandCursor
                            onPositionChanged: mouse => {
                                var pct = Math.max(5, Math.min(100, (mouse.x / brightTrack.width) * 100));
                                root.barState.setBrightness(pct);
                            }
                            onClicked: mouse => {
                                var pct = Math.max(5, Math.min(100, (mouse.x / brightTrack.width) * 100));
                                root.barState.setBrightness(pct);
                            }
                        }
                    }

                    Text {
                        text: root.barState.brightnessPercent + "%"
                        font.family: "Segoe UI, Inter, sans-serif"
                        font.pixelSize: 10
                        font.weight: Font.Medium
                        color: Qt.rgba(1, 1, 1, 0.70)
                        Layout.preferredWidth: 26
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }
    }
}
