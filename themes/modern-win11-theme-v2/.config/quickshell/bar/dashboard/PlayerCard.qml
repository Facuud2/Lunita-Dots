import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

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
        width: 150
        height: 150
        radius: 75
        x: 8
        y: 8
        opacity: root.barState.mprisPlaying ? 0.32 : 0.08
        color: root.barState.themeAccentGlow

        Behavior on opacity { NumberAnimation { duration: 250 } }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // ── 1. Album Cover with 3D Flip on song change ──
        Item {
            id: coverContainer
            width: 112
            height: 112
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
                origin.x: 56
                origin.y: 56
                axis { x: 0; y: 1; z: 0 }
                angle: coverContainer.flipAngle
            }

            Rectangle {
                anchors.fill: parent
                radius: 12
                color: Qt.rgba(0.18, 0.18, 0.22, 0.85)
                border.color: Qt.rgba(1, 1, 1, 0.20)
                border.width: 1
                clip: true

                Image {
                    anchors.fill: parent
                    source: root.barState.mprisArtUrl || ""
                    fillMode: Image.PreserveAspectCrop
                    visible: root.barState.mprisArtUrl !== ""
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.barState.mprisArtUrl === ""
                    text: "󰝚"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 36
                    color: root.barState.themeAccent
                }
            }
        }

        // ── 2. Track Details & Transport Controls ──
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 3

            // Uppercase Tag (SPOTIFY / IDLE)
            Text {
                text: root.barState.mprisActive ? "SPOTIFY" : "IDLE"
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

            Item { height: 6 }

            // Transport Control Buttons
            Row {
                spacing: 14
                Layout.alignment: Qt.AlignLeft

                // Previous Button
                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: prevHover.hovered ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

                    HoverHandler { id: prevHover }

                    Text {
                        anchors.centerIn: parent
                        text: "󰒮"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 15
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.barState.previousTrack()
                    }
                }

                // Play / Pause Prominent Circle Button (Astraeus Coral Accent)
                Rectangle {
                    width: 38
                    height: 38
                    radius: 19
                    color: root.barState.themeAccent
                    scale: playHover.hovered ? 1.06 : 1.0
                    Behavior on scale { NumberAnimation { duration: 120 } }

                    HoverHandler { id: playHover }

                    Text {
                        anchors.centerIn: parent
                        text: root.barState.mprisPlaying ? "󰏤" : "󰐊"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.barState.playPause()
                    }
                }

                // Next Button
                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: nextHover.hovered ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

                    HoverHandler { id: nextHover }

                    Text {
                        anchors.centerIn: parent
                        text: "󰒭"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 15
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.barState.nextTrack()
                    }
                }
            }

            Item { height: 4 }

            // Seekbar Track
            Item {
                id: seekContainer
                Layout.fillWidth: true
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
