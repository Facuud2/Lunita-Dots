import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root

    required property var barState

    color: Qt.rgba(0.11, 0.10, 0.14, 0.82)
    radius: 16
    border.color: Qt.rgba(1, 1, 1, 0.12)
    border.width: 1
    clip: true

    implicitWidth: 388
    implicitHeight: 166

    // Subtle audio-reactive glow wash behind album cover
    Rectangle {
        width: 140
        height: 140
        radius: 70
        x: 12
        y: 13
        opacity: root.barState.mprisPlaying ? 0.35 : 0.08
        color: root.barState.themeAccentGlow

        Behavior on opacity { NumberAnimation { duration: 250 } }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // ── 1. Circular Vinyl Album Cover (104x104px) ──
        Item {
            id: coverContainer
            width: 104
            height: 104
            Layout.alignment: Qt.AlignVCenter

            property real flipAngle: 0

            Connections {
                target: root.barState
                function onMprisTitleChanged() {
                    flipAnim.restart();
                }
            }

            SequentialAnimation {
                id: flipAnim
                NumberAnimation { target: coverContainer; property: "flipAngle"; to: 90; duration: 160; easing.type: Easing.InQuad }
                NumberAnimation { target: coverContainer; property: "flipAngle"; from: -90; to: 0; duration: 200; easing.type: Easing.OutQuad }
            }

            transform: Rotation {
                origin.x: 52
                origin.y: 52
                axis { x: 0; y: 1; z: 0 }
                angle: coverContainer.flipAngle
            }

            // Outer Vinyl Disc (Fully Rounded)
            Item {
                id: vinylDisc
                anchors.fill: parent

                // Slow, smooth vinyl rotation when playing
                NumberAnimation on rotation {
                    running: root.barState.mprisPlaying
                    from: 0
                    to: 360
                    duration: 20000
                    loops: Animation.Infinite
                }

                // Disc base background
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: Qt.rgba(0.14, 0.14, 0.18, 0.90)
                    border.color: Qt.rgba(1, 1, 1, 0.22)
                    border.width: 1.5
                }

                // Hidden source image
                Image {
                    id: coverArtImg
                    anchors.fill: parent
                    source: root.barState.mprisArtUrl || ""
                    fillMode: Image.PreserveAspectCrop
                    visible: false
                    cache: false
                }

                // Circular mask item
                Rectangle {
                    id: coverArtMask
                    anchors.fill: parent
                    radius: width / 2
                    visible: false
                }

                // Circular Masked Artwork (True Circle, zero corner overflow)
                OpacityMask {
                    anchors.fill: parent
                    source: coverArtImg
                    maskSource: coverArtMask
                    visible: root.barState.mprisArtUrl !== ""
                }

                // Subtle Vinyl Grooves & Specular Rim
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border.color: Qt.rgba(1, 1, 1, 0.16)
                    border.width: 1
                }

                // Center Spindle Hole / Ring
                Rectangle {
                    anchors.centerIn: parent
                    width: 22
                    height: 22
                    radius: 11
                    color: Qt.rgba(0.08, 0.08, 0.10, 0.90)
                    border.color: Qt.rgba(1, 1, 1, 0.35)
                    border.width: 1.5

                    // Inner center dot
                    Rectangle {
                        anchors.centerIn: parent
                        width: 6
                        height: 6
                        radius: 3
                        color: root.barState.themeAccent
                    }
                }

                // Fallback icon when no art URL
                Text {
                    anchors.centerIn: parent
                    visible: root.barState.mprisArtUrl === ""
                    text: "󰝚"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 32
                    color: root.barState.themeAccent
                    opacity: 0.80
                }
            }
        }

        // ── 2. Track Details & Transport Controls ──
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            // Uppercase Media Tag (YOUTUBE / SPOTIFY / BROWSER / IDLE)
            Text {
                text: root.barState.mprisActive ? (root.barState.mprisSource || "MEDIA") : "IDLE"
                font.family: root.barState.themeFontInterface
                font.pixelSize: 10
                font.weight: Font.DemiBold
                font.letterSpacing: 1.2
                color: root.barState.themeAccent
            }

            // Track Title
            Text {
                Layout.fillWidth: true
                text: root.barState.mprisTitle || "Nothing playing"
                font.family: root.barState.themeFontInterface
                font.pixelSize: 15
                font.weight: Font.Bold
                color: "#FFFFFF"
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            // Artist Name
            Text {
                Layout.fillWidth: true
                text: root.barState.mprisArtist || "Play something in any app"
                font.family: root.barState.themeFontInterface
                font.pixelSize: 12
                font.weight: Font.Normal
                color: Qt.rgba(1, 1, 1, 0.70)
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Item { height: 4 }

            // Transport Control Buttons
            Row {
                Layout.preferredHeight: 38
                Layout.fillWidth: true
                spacing: 14

                // Previous Button
                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: prevMa.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : "transparent"
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "󰒮"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 15
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        id: prevMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.barState.previousTrack()
                    }
                }

                // Play / Pause Prominent Circle Button (Astraeus Coral Accent)
                Rectangle {
                    id: playBtn
                    width: 38
                    height: 38
                    radius: 19
                    color: root.barState.themeAccent
                    anchors.verticalCenter: parent.verticalCenter
                    scale: playMa.containsMouse ? 1.08 : 1.0

                    Behavior on scale { NumberAnimation { duration: 100 } }

                    Text {
                        anchors.centerIn: parent
                        text: root.barState.mprisPlaying ? "󰏤" : "󰐊"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        id: playMa
                        anchors.fill: parent
                        z: 10
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.barState.playPause();
                        }
                    }
                }

                // Next Button
                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: nextMa.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : "transparent"
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: "󰒭"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 15
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        id: nextMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.barState.nextTrack()
                    }
                }
            }

            Item { height: 2 }

            // Seekbar Track
            Item {
                id: seekContainer
                Layout.fillWidth: true
                Layout.preferredHeight: 12
                height: 12

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    height: 3
                    radius: 1.5
                    color: Qt.rgba(1, 1, 1, 0.18)

                    Rectangle {
                        height: parent.height
                        width: parent.width * Math.min(1.0, Math.max(0.0, root.barState.mprisLength > 0 ? (root.barState.mprisPosition / root.barState.mprisLength) : 0.0))
                        radius: 1.5
                        color: root.barState.themeAccent
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mouse => {
                        var ratio = Math.min(1.0, Math.max(0.0, mouse.x / seekContainer.width));
                        root.barState.seekPosition(ratio);
                    }
                }
            }
        }
    }
}
