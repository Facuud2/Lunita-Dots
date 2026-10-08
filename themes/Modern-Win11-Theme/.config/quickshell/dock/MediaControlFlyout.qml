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
    opacity: (root.dockState.flyoutOpen && root.dockState.activeFlyout === "audio") ? 1.0 : 0.0
    scale: (root.dockState.flyoutOpen && root.dockState.activeFlyout === "audio") ? 1.0 : 0.96
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
        // CARD 1: SPOTIFY / MEDIA PLAYER WIDGET
        // ==========================================
        Rectangle {
            id: mediaCard
            Layout.fillWidth: true
            Layout.preferredHeight: 395
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
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10

                // Header: Spotify Logo & Name
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Image {
                        source: "assets/icons/win11-spotify.svg"
                        sourceSize.width: 18
                        sourceSize.height: 18
                        smooth: true
                    }

                    Text {
                        text: root.dockState.mprisPlayerName || "Spotify"
                        font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        font.italic: false
                        color: "#FFFFFF"
                    }

                    Item { Layout.fillWidth: true }
                }

                // Album Art Cover (Centered Rounded Square with Glass Inset)
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 200
                    radius: 14
                    clip: true
                    color: Qt.rgba(0, 0, 0, 0.25)
                    border.color: Qt.rgba(1.0, 1.0, 1.0, 0.20)
                    border.width: 1

                    Image {
                        id: coverImage
                        anchors.fill: parent
                        source: root.dockState.mprisArtUrl && root.dockState.mprisArtUrl !== ""
                            ? root.dockState.mprisArtUrl
                            : "assets/default-album-art.png"
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        asynchronous: true
                    }
                }

                // Track Title & Artist (Centered, Strict Non-Italic)
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 3

                    Text {
                        text: root.dockState.mprisTitle || "Lil Mama (with Trevor Daniel)"
                        font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        font.italic: false
                        color: "#FFFFFF"
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: root.dockState.mprisArtist || "Miles Wesley"
                        font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                        font.pixelSize: 11
                        font.weight: Font.Normal
                        font.italic: false
                        color: Qt.rgba(1.0, 1.0, 1.0, 0.80)
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                // Playback Controls (Prev, Play/Pause, Next - Generous padding & perfectly centered)
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 28

                        // Previous Track Button
                        Rectangle {
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            Layout.alignment: Qt.AlignVCenter
                            radius: 18
                            color: prevMouse.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.18) : "transparent"
                            border.color: prevMouse.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.25) : "transparent"
                            border.width: 1

                            Image {
                                anchors.centerIn: parent
                                source: "assets/prev.svg"
                                sourceSize.width: 19
                                sourceSize.height: 19
                                opacity: prevMouse.containsMouse ? 1.0 : 0.90
                            }

                            MouseArea {
                                id: prevMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.dockState.previousTrack()
                            }
                        }

                        // Play / Pause Button
                        Rectangle {
                            Layout.preferredWidth: 46
                            Layout.preferredHeight: 46
                            Layout.alignment: Qt.AlignVCenter
                            radius: 23
                            color: playMouse.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.25) : Qt.rgba(1.0, 1.0, 1.0, 0.12)
                            border.color: Qt.rgba(1.0, 1.0, 1.0, 0.26)
                            border.width: 1

                            Image {
                                anchors.centerIn: parent
                                anchors.horizontalCenterOffset: root.dockState.mprisPlaying ? 0 : 2
                                source: root.dockState.mprisPlaying ? "assets/pause.svg" : "assets/play.svg"
                                sourceSize.width: root.dockState.mprisPlaying ? 22 : 24
                                sourceSize.height: root.dockState.mprisPlaying ? 22 : 24
                                opacity: 1.0
                            }

                            MouseArea {
                                id: playMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.dockState.playPause()
                            }
                        }

                        // Next Track Button
                        Rectangle {
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            Layout.alignment: Qt.AlignVCenter
                            radius: 18
                            color: nextMouse.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.18) : "transparent"
                            border.color: nextMouse.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.25) : "transparent"
                            border.width: 1

                            Image {
                                anchors.centerIn: parent
                                source: "assets/next.svg"
                                sourceSize.width: 19
                                sourceSize.height: 19
                                opacity: nextMouse.containsMouse ? 1.0 : 0.90
                            }

                            MouseArea {
                                id: nextMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.dockState.nextTrack()
                            }
                        }
                    }
                }
            }
        }

        // ==========================================
        // CARD 2: CONTROL CENTER & AUDIO OUTPUTS
        // ==========================================
        Rectangle {
            id: controlCard
            Layout.fillWidth: true
            Layout.preferredHeight: contentCol.implicitHeight + 28
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
                id: contentCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 14
                spacing: 12

                // 1. Top Quick Toggles Row (3 Pill Buttons)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    // Pill 1: Wi-Fi
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        radius: 19
                        color: root.dockState.wifiConnected ? Qt.rgba(0.0, 0.75, 1.0, 0.85) : Qt.rgba(1.0, 1.0, 1.0, 0.08)
                        border.color: root.dockState.wifiConnected ? Qt.rgba(0.0, 0.85, 1.0, 0.90) : Qt.rgba(1.0, 1.0, 1.0, 0.16)
                        border.width: 1

                        Image {
                            anchors.centerIn: parent
                            source: root.dockState.wifiConnected ? "assets/wifi-dark.svg" : "assets/tray-wifi-off.svg"
                            sourceSize.width: 18
                            sourceSize.height: 18
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.dockState.openNetwork()
                        }
                    }

                    // Pill 2: Bluetooth
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        radius: 19
                        color: root.dockState.bluetoothEnabled ? Qt.rgba(0.0, 0.75, 1.0, 0.85) : Qt.rgba(1.0, 1.0, 1.0, 0.08)
                        border.color: root.dockState.bluetoothEnabled ? Qt.rgba(0.0, 0.85, 1.0, 0.90) : Qt.rgba(1.0, 1.0, 1.0, 0.16)
                        border.width: 1

                        Image {
                            anchors.centerIn: parent
                            source: root.dockState.bluetoothEnabled ? "assets/bluetooth-dark.svg" : "assets/bluetooth.svg"
                            sourceSize.width: 18
                            sourceSize.height: 18
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.dockState.toggleBluetooth()
                        }
                    }

                    // Pill 3: Audio Sources Selector (Glass Pill)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        radius: 19
                        color: root.dockState.audioSinksExpanded ? Qt.rgba(0.0, 0.75, 1.0, 0.85) : Qt.rgba(1.0, 1.0, 1.0, 0.08)
                        border.color: root.dockState.audioSinksExpanded ? Qt.rgba(0.0, 0.85, 1.0, 0.90) : Qt.rgba(1.0, 1.0, 1.0, 0.16)
                        border.width: 1

                        Row {
                            anchors.centerIn: parent
                            spacing: 4

                            Image {
                                source: "assets/headphones.svg"
                                sourceSize.width: 16
                                sourceSize.height: 16
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Image {
                                source: "assets/chevron-right.svg"
                                sourceSize.width: 12
                                sourceSize.height: 12
                                rotation: root.dockState.audioSinksExpanded ? 90 : 0
                                anchors.verticalCenter: parent.verticalCenter
                                Behavior on rotation { NumberAnimation { duration: 180 } }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.dockState.toggleAudioSinksExpanded()
                        }
                    }
                }

                // 2. Brightness Slider Row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Image {
                        source: "assets/brightness.svg"
                        sourceSize.width: 18
                        sourceSize.height: 18
                        opacity: 0.90
                    }

                    Item {
                        id: brightTrack
                        Layout.fillWidth: true
                        Layout.preferredHeight: 24

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            height: 4
                            radius: 2
                            color: Qt.rgba(1.0, 1.0, 1.0, 0.12)

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: parent.width * (root.dockState.brightnessPercent / 100.0)
                                radius: 2
                                color: Qt.rgba(0.0, 0.75, 1.0, 0.85)
                            }
                        }

                        // Thumb Knob (Solid White Circle with Refined Blue Glow)
                        Rectangle {
                            width: 14
                            height: 14
                            radius: 7
                            color: "#FFFFFF"
                            border.color: Qt.rgba(0.0, 0.75, 1.0, 0.85)
                            border.width: 1.5
                            anchors.verticalCenter: parent.verticalCenter
                            x: Math.max(0, Math.min(parent.width - width, (parent.width * (root.dockState.brightnessPercent / 100.0)) - (width / 2)))
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mouse => {
                                var ratio = Math.max(0, Math.min(1.0, mouse.x / width));
                                root.dockState.setBrightness(ratio * 100);
                            }
                            onPositionChanged: mouse => {
                                if (pressed) {
                                    var ratio = Math.max(0, Math.min(1.0, mouse.x / width));
                                    root.dockState.setBrightness(ratio * 100);
                                }
                            }
                        }
                    }
                }

                // 3. Volume Slider & Output Sources Row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    // Speaker Mute Toggle
                    Item {
                        width: 22
                        height: 22

                        Image {
                            anchors.centerIn: parent
                            source: root.dockState.isVolumeMuted ? "assets/tray-volume-muted.svg" : "assets/tray-volume.svg"
                            sourceSize.width: 18
                            sourceSize.height: 18
                            opacity: 0.90
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.dockState.toggleVolumeMute()
                        }
                    }

                    // Volume Track Slider
                    Item {
                        id: volTrack
                        Layout.fillWidth: true
                        Layout.preferredHeight: 24

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            height: 4
                            radius: 2
                            color: Qt.rgba(1.0, 1.0, 1.0, 0.12)

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: parent.width * (root.dockState.volumePercent / 100.0)
                                radius: 2
                                color: Qt.rgba(0.0, 0.75, 1.0, 0.85)
                            }
                        }

                        // Thumb Knob
                        Rectangle {
                            width: 14
                            height: 14
                            radius: 7
                            color: "#FFFFFF"
                            border.color: Qt.rgba(0.0, 0.75, 1.0, 0.85)
                            border.width: 1.5
                            anchors.verticalCenter: parent.verticalCenter
                            x: Math.max(0, Math.min(parent.width - width, (parent.width * (root.dockState.volumePercent / 100.0)) - (width / 2)))
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mouse => {
                                var ratio = Math.max(0, Math.min(1.0, mouse.x / width));
                                var target = Math.round(ratio * 100);
                                root.dockState.changeVolume(target - root.dockState.volumePercent);
                            }
                            onPositionChanged: mouse => {
                                if (pressed) {
                                    var ratio = Math.max(0, Math.min(1.0, mouse.x / width));
                                    var target = Math.round(ratio * 100);
                                    root.dockState.changeVolume(target - root.dockState.volumePercent);
                                }
                            }
                        }
                    }

                    // Output Selector Trigger Button (Mixer Icon + Chevron)
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 6
                        color: root.dockState.audioSinksExpanded ? Qt.rgba(0.0, 0.75, 1.0, 0.85) : (outputMouse.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.15) : "transparent")
                        border.color: root.dockState.audioSinksExpanded ? Qt.rgba(0.0, 0.85, 1.0, 0.90) : (outputMouse.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.22) : "transparent")
                        border.width: 1

                        Image {
                            anchors.centerIn: parent
                            source: "assets/audio-mixer.svg"
                            sourceSize.width: 18
                            sourceSize.height: 18
                            smooth: true
                        }

                        MouseArea {
                            id: outputMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.dockState.toggleAudioSinksExpanded()
                        }
                    }
                }

                // 4. Collapsible Audio Sinks (Fuentes de reproducción) Drawer
                ColumnLayout {
                    Layout.fillWidth: true
                    visible: root.dockState.audioSinksExpanded
                    spacing: 6

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Qt.rgba(1.0, 1.0, 1.0, 0.25)
                    }

                    Text {
                        text: "Fuentes de reproducción"
                        font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        font.italic: false
                        color: Qt.rgba(1.0, 1.0, 1.0, 0.85)
                        Layout.topMargin: 2
                    }

                    Repeater {
                        model: root.dockState.audioSinks

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 34
                            radius: 8
                            color: modelData.active ? Qt.rgba(0, 0.9, 1, 0.25) : (sinkHover.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.20) : Qt.rgba(1.0, 1.0, 1.0, 0.08))
                            border.color: modelData.active ? "#00E5FF" : Qt.rgba(1.0, 1.0, 1.0, 0.18)
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 8

                                Image {
                                    source: modelData.active ? "assets/headphones.svg" : "assets/tray-volume.svg"
                                    sourceSize.width: 14
                                    sourceSize.height: 14
                                }

                                Text {
                                    text: modelData.name
                                    font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                                    font.pixelSize: 11
                                    font.weight: modelData.active ? Font.DemiBold : Font.Normal
                                    font.italic: false
                                    color: modelData.active ? "#00E5FF" : "#FFFFFF"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Rectangle {
                                    width: 14
                                    height: 14
                                    radius: 7
                                    color: modelData.active ? "#00E5FF" : "transparent"
                                    border.color: modelData.active ? "#00E5FF" : Qt.rgba(1.0, 1.0, 1.0, 0.45)
                                    border.width: 1.5

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: 6
                                        height: 6
                                        radius: 3
                                        color: "#0E1218"
                                        visible: modelData.active
                                    }
                                }
                            }

                            MouseArea {
                                id: sinkHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.dockState.setAudioSink(modelData.id)
                            }
                        }
                    }
                }

                // 5. Bottom Status Bar (Battery + Settings)
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 4

                    // Battery Indicator
                    Row {
                        spacing: 6
                        Layout.alignment: Qt.AlignVCenter

                        Image {
                            source: root.dockState.batteryCharging ? "assets/tray-battery-charging.svg" : "assets/tray-battery.svg"
                            sourceSize.width: 18
                            sourceSize.height: 12
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: (root.dockState.hasBattery ? root.dockState.batteryPercent : 90) + "%"
                            font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            font.italic: false
                            color: "#FFFFFF"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Settings Gear Button
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 6
                        color: gearMouse.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.25) : "transparent"
                        border.color: gearMouse.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.35) : "transparent"
                        border.width: 1

                        Image {
                            anchors.centerIn: parent
                            source: "assets/gear.svg"
                            sourceSize.width: 16
                            sourceSize.height: 16
                        }

                        MouseArea {
                            id: gearMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Quickshell.execDetached(["bash", "-c", "hyprland-run || pavucontrol || kitty &"]);
                            }
                        }
                    }
                }
            }
        }
    }
}
