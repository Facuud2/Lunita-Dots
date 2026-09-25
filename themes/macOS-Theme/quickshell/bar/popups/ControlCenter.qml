import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell

Item {
    id: root
    required property var barState

    visible: barState.activePopup === "controlcenter"
    x: Math.max(10, parent.width - width - 12)
    y: 4
    width: 320
    implicitHeight: mainCol.implicitHeight + 24
    height: implicitHeight
    z: 10

    opacity: visible ? 1 : 0
    scale: visible ? 1 : 0.96
    Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 16
        color: barState.popupBgColor
        border.color: barState.popupBorderColor
        border.width: 1

        Behavior on color { ColorAnimation { duration: 200 } }
        Behavior on border.color { ColorAnimation { duration: 200 } }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: 17
            color: "transparent"
            border.color: Qt.rgba(0, 0, 0, barState.isDarkTheme ? 0.4 : 0.12)
            border.width: 1
            z: -1
        }
    }

    component CIcon: Item {
        id: cIconRoot
        property string source: ""
        property color iconColor: barState.popupTextColor
        property real iconWidth: 14
        property real iconHeight: 14

        implicitWidth: iconWidth
        implicitHeight: iconHeight

        Image {
            id: rawSvg
            anchors.fill: parent
            source: cIconRoot.source
            sourceSize.width: Math.round(cIconRoot.iconWidth * 2)
            sourceSize.height: Math.round(cIconRoot.iconHeight * 2)
            visible: false
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
        }

        ColorOverlay {
            anchors.fill: rawSvg
            source: rawSvg
            color: cIconRoot.iconColor
            Behavior on color { ColorAnimation { duration: 200 } }
        }
    }

    ColumnLayout {
        id: mainCol
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 12
        spacing: 10

        // ── TOP SECTION: 2-COLUMN GRID (Fixed width side-by-side) ──
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 136

            // Left Block: Connectivity Card (Wi-Fi/Ethernet, Bluetooth, Night Shift)
            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 142
                radius: 12
                color: barState.popupCardBg
                border.color: barState.popupCardBorder
                border.width: 1
                Behavior on color { ColorAnimation { duration: 200 } }

                Column {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 3

                    // 1. Network Row
                    Rectangle {
                        width: parent.width
                        height: 38
                        radius: 8
                        color: netRowMouse.containsMouse 
                            ? (barState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.06)) 
                            : "transparent"

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 5
                            anchors.rightMargin: 5
                            spacing: 6

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 26
                                height: 26
                                radius: 13
                                color: barState.networkConnected ? "#007AFF" : (barState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.08))

                                CIcon {
                                    anchors.centerIn: parent
                                    iconWidth: 14
                                    iconHeight: 14
                                    source: barState.isEthernet 
                                        ? "../assets/ethernet.svg" 
                                        : (barState.networkConnected ? "../assets/wifi.svg" : "../assets/wifi-off.svg")
                                    iconColor: barState.networkConnected ? "#FFFFFF" : barState.popupTextColor
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 34
                                spacing: 1

                                Text {
                                    text: barState.isEthernet ? "Ethernet" : "Wi-Fi"
                                    color: barState.popupTextColor
                                    font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                }

                                Text {
                                    width: parent.width
                                    text: barState.networkConnected ? barState.networkName : "Desconectado"
                                    color: barState.popupTextDim
                                    font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                }
                            }
                        }

                        MouseArea {
                            id: netRowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                barState.togglePopup("network", root.x, 28, root.parent.screen);
                            }
                        }
                    }

                    // 2. Bluetooth Row
                    Rectangle {
                        width: parent.width
                        height: 38
                        radius: 8
                        color: btRowMouse.containsMouse 
                            ? (barState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.06)) 
                            : "transparent"

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 5
                            anchors.rightMargin: 5
                            spacing: 6

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 26
                                height: 26
                                radius: 13
                                color: barState.bluetoothEnabled ? "#007AFF" : (barState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.08))

                                CIcon {
                                    anchors.centerIn: parent
                                    iconWidth: 14
                                    iconHeight: 14
                                    source: "../assets/bluetooth.svg"
                                    iconColor: barState.bluetoothEnabled ? "#FFFFFF" : barState.popupTextColor
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 34
                                spacing: 1

                                Text {
                                    text: "Bluetooth"
                                    color: barState.popupTextColor
                                    font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                }

                                Text {
                                    width: parent.width
                                    text: barState.bluetoothEnabled 
                                        ? (barState.bluetoothConnectedDevice !== "" ? barState.bluetoothConnectedDevice : "Activado") 
                                        : "Desactivado"
                                    color: barState.popupTextDim
                                    font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                }
                            }
                        }

                        MouseArea {
                            id: btRowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                barState.togglePopup("bluetooth", root.x, 28, root.parent.screen);
                            }
                        }
                    }

                    // 3. Night Shift Row
                    Rectangle {
                        width: parent.width
                        height: 38
                        radius: 8
                        color: nsRowMouse.containsMouse 
                            ? (barState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.06)) 
                            : "transparent"

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 5
                            anchors.rightMargin: 5
                            spacing: 6

                            Rectangle {
                                anchors.verticalCenter: parent.verticalCenter
                                width: 26
                                height: 26
                                radius: 13
                                color: barState.nightLightEnabled ? "#FF9500" : (barState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.08))

                                CIcon {
                                    anchors.centerIn: parent
                                    iconWidth: 14
                                    iconHeight: 14
                                    source: "../assets/moon.svg"
                                    iconColor: barState.nightLightEnabled ? "#FFFFFF" : barState.popupTextColor
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - 34
                                spacing: 1

                                Text {
                                    text: "Night Shift"
                                    color: barState.popupTextColor
                                    font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                }

                                Text {
                                    width: parent.width
                                    text: barState.nightLightEnabled ? "Activado" : "Desactivado"
                                    color: barState.popupTextDim
                                    font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                                    font.pixelSize: 10
                                    elide: Text.ElideRight
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                }
                            }
                        }

                        MouseArea {
                            id: nsRowMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                barState.nightLightEnabled = !barState.nightLightEnabled;
                                barState.runSilent("hyprsunset -t 4000 || hyprshade toggle blue-light-filter");
                            }
                        }
                    }
                }
            }

            // Right Block: Dark Mode & Screen Record Cards
            Column {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 144
                spacing: 8

                // Dark Mode Switcher Card
                Rectangle {
                    width: parent.width
                    height: 64
                    radius: 12
                    color: barState.popupCardBg
                    border.color: barState.popupCardBorder
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 200 } }

                    Row {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 32
                            height: 32
                            radius: 16
                            color: barState.isDarkTheme ? "#007AFF" : Qt.rgba(0, 0, 0, 0.08)
                            Behavior on color { ColorAnimation { duration: 200 } }

                            CIcon {
                                anchors.centerIn: parent
                                iconWidth: 16
                                iconHeight: 16
                                source: barState.isDarkTheme ? "../assets/moon.svg" : "../assets/brightness.svg"
                                iconColor: barState.isDarkTheme ? "#FFFFFF" : "#1D1D1F"
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 44
                            spacing: 1

                            Text {
                                text: "Dark Mode"
                                color: barState.popupTextColor
                                font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }

                            Text {
                                text: barState.isDarkTheme ? "Activado" : "Desactivado"
                                color: barState.popupTextDim
                                font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                                font.pixelSize: 10
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: barState.toggleThemeMode()
                    }
                }

                // Screen Capture / Record Card
                Rectangle {
                    width: parent.width
                    height: 64
                    radius: 12
                    color: barState.popupCardBg
                    border.color: barState.popupCardBorder
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 200 } }

                    Row {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 32
                            height: 32
                            radius: 16
                            color: barState.isRecording ? "#AF52DE" : (barState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.08))

                            CIcon {
                                anchors.centerIn: parent
                                iconWidth: 16
                                iconHeight: 16
                                source: "../assets/camera.svg"
                                iconColor: barState.isRecording ? "#FFFFFF" : barState.popupTextColor
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 44
                            spacing: 1

                            Text {
                                text: "Record"
                                color: barState.popupTextColor
                                font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }

                            Text {
                                text: barState.isRecording ? "Grabando" : "Capturar"
                                color: barState.isRecording ? "#AF52DE" : barState.popupTextDim
                                font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                                font.pixelSize: 10
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: barState.toggleRecording()
                    }
                }
            }
        }

        // ── DISPLAY BRIGHTNESS SLIDER CARD ──
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            radius: 12
            color: barState.popupCardBg
            border.color: barState.popupCardBorder
            border.width: 1
            Behavior on color { ColorAnimation { duration: 200 } }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4

                Text {
                    text: "Pantalla"
                    color: barState.popupTextColor
                    font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                MacSlider {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 24
                    value: barState.brightnessPercent
                    iconSource: "../assets/brightness.svg"
                    onMoved: val => barState.setBrightness(val)
                }
            }
        }

        // ── SOUND VOLUME SLIDER CARD ──
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            radius: 12
            color: barState.popupCardBg
            border.color: barState.popupCardBorder
            border.width: 1
            Behavior on color { ColorAnimation { duration: 200 } }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Sonido"
                        color: barState.popupTextColor
                        font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: barState.activeAudioSink || ""
                        color: barState.popupTextDim
                        font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                        font.pixelSize: 10
                        elide: Text.ElideRight
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                }

                MacSlider {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 24
                    value: barState.isMuted ? 0 : barState.volumePercent
                    iconSource: barState.isMuted ? "../assets/volume-muted.svg" : "../assets/volume.svg"
                    onMoved: val => barState.setVolume(val)
                }
            }
        }

        // ── NOW PLAYING / MUSIC CARD ──
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            radius: 12
            color: barState.popupCardBg
            border.color: barState.popupCardBorder
            border.width: 1
            Behavior on color { ColorAnimation { duration: 200 } }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 10

                // Album Art or Music Icon
                Rectangle {
                    Layout.preferredWidth: 44
                    Layout.preferredHeight: 44
                    radius: 8
                    color: "#FA243C"
                    clip: true

                    Image {
                        anchors.fill: parent
                        visible: barState.mprisArtUrl !== ""
                        source: barState.mprisArtUrl
                        fillMode: Image.PreserveAspectCrop
                    }

                    CIcon {
                        anchors.centerIn: parent
                        visible: barState.mprisArtUrl === ""
                        iconWidth: 22
                        iconHeight: 22
                        source: "../assets/music.svg"
                        iconColor: "#FFFFFF"
                    }
                }

                // Track Info
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        text: barState.mprisAvailable ? barState.mprisTitle : "Sin reproducción"
                        color: barState.popupTextColor
                        font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: barState.mprisAvailable ? barState.mprisArtist : "Música"
                        color: barState.popupTextDim
                        font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                        font.pixelSize: 11
                        elide: Text.ElideRight
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }
                }

                // Playback Controls
                RowLayout {
                    spacing: 6

                    Text {
                        text: "⏮"
                        color: barState.popupTextColor
                        font.pixelSize: 14
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: barState.mediaPrevious()
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        radius: 14
                        color: barState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(0, 0, 0, 0.08)

                        Text {
                            anchors.centerIn: parent
                            text: barState.mprisPlaying ? "⏸" : "▶"
                            color: barState.popupTextColor
                            font.pixelSize: 12
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: barState.mediaPlayPause()
                        }
                    }

                    Text {
                        text: "⏭"
                        color: barState.popupTextColor
                        font.pixelSize: 14
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: barState.mediaNext()
                        }
                    }
                }
            }
        }
    }

    // ── Helper: macOS Slider Component ──
    component MacSlider: Item {
        id: sliderRoot
        property int value: 50
        property string iconSource: ""
        signal moved(int val)

        implicitHeight: 24

        Rectangle {
            id: track
            anchors.fill: parent
            radius: 12
            color: barState.sliderTrackColor
            clip: true

            Rectangle {
                id: fillRect
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: Math.max(24, track.width * (sliderRoot.value / 100))
                radius: 12
                color: barState.sliderFillColor
                Behavior on color { ColorAnimation { duration: 200 } }
            }

            CIcon {
                anchors.left: parent.left
                anchors.leftMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                iconWidth: 14
                iconHeight: 14
                source: sliderRoot.iconSource
                iconColor: (sliderRoot.value > 12) ? barState.sliderIconCovered : barState.sliderIconUncovered
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onPositionChanged: mouse => updateValue(mouse.x)
            onClicked: mouse => updateValue(mouse.x)

            function updateValue(mX) {
                var ratio = Math.max(0, Math.min(1, mX / track.width));
                var newVal = Math.round(ratio * 100);
                sliderRoot.moved(newVal);
            }
        }
    }
}
