import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root

    required property var barState

    color: root.barState.themeSurfaceContainer
    radius: root.barState.themeCardRadius
    border.color: root.barState.themeBorder
    border.width: 1
    clip: true

    implicitWidth: 340
    implicitHeight: 168

    // Audio-reactive glow wash behind cover
    Rectangle {
        width: 140
        height: 140
        radius: 70
        x: 10
        y: 10
        opacity: root.barState.mprisPlaybackStatus === "Playing" ? 0.35 : 0.10
        color: root.barState.themeAccentGlow

        Behavior on opacity { NumberAnimation { duration: 250 } }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 14

        // ── 1. Album Cover with 3D Flip Animation ──
        Item {
            id: coverContainer
            width: 108
            height: 108
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
                NumberAnimation { target: coverContainer; property: "flipAngle"; to: 90; duration: 180; easing.type: Easing.InQuad }
                NumberAnimation { target: coverContainer; property: "flipAngle"; from: -90; to: 0; duration: 220; easing.type: Easing.OutQuad }
            }

            transform: Rotation {
                origin.x: 54
                origin.y: 54
                axis { x: 0; y: 1; z: 0 }
                angle: coverContainer.flipAngle
            }

            Rectangle {
                anchors.fill: parent
                radius: 10
                color: root.barState.themeSurfaceContainerHigh
                border.color: root.barState.themeBorderSpecular
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
                    font.pixelSize: 34
                    color: root.barState.themeAccent
                }
            }
        }

        // ── 2. Track Info & Controls ──
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            // Status Tag
            Text {
                text: root.barState.mprisActive ? (root.barState.mprisPlaying ? "REPRODUCIENDO" : "EN PAUSA") : "SIN REPRODUCCIÓN"
                font.family: root.barState.themeFontInterface
                font.pixelSize: 9
                font.weight: Font.DemiBold
                color: root.barState.themeAccent
            }

            // Track Title
            Text {
                Layout.fillWidth: true
                text: root.barState.mprisTitle || "Sin pista activa"
                font.family: root.barState.themeFontInterface
                font.pixelSize: 13
                font.weight: Font.DemiBold
                color: root.barState.themeOnSurface
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            // Artist Name
            Text {
                Layout.fillWidth: true
                text: root.barState.mprisArtist || "Astraeus Music"
                font.family: root.barState.themeFontInterface
                font.pixelSize: 11
                color: root.barState.themeOnSurfaceDim
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Item { height: 4 }

            // Transport Control Buttons
            Row {
                spacing: 12
                Layout.alignment: Qt.AlignLeft

                // Previous Button
                Rectangle {
                    width: 28
                    height: 28
                    radius: 14
                    color: prevHover.hovered ? root.barState.themeSurfaceContainerHigh : "transparent"

                    HoverHandler { id: prevHover }

                    Text {
                        anchors.centerIn: parent
                        text: "󰒮"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                        color: root.barState.themeOnSurface
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.barState.previousTrack()
                    }
                }

                // Play / Pause Master Button
                Rectangle {
                    width: 34
                    height: 34
                    radius: 17
                    color: root.barState.themeAccent
                    border.color: playHover.hovered ? root.barState.themeAccentHover : "transparent"
                    border.width: 1

                    HoverHandler { id: playHover }

                    Text {
                        anchors.centerIn: parent
                        text: root.barState.mprisPlaying ? "󰏤" : "󰐊"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 15
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
                    width: 28
                    height: 28
                    radius: 14
                    color: nextHover.hovered ? root.barState.themeSurfaceContainerHigh : "transparent"

                    HoverHandler { id: nextHover }

                    Text {
                        anchors.centerIn: parent
                        text: "󰒭"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                        color: root.barState.themeOnSurface
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.barState.nextTrack()
                    }
                }
            }

            Item { height: 2 }

            // Seekbar Track
            Rectangle {
                Layout.fillWidth: true
                height: 4
                radius: 2
                color: root.barState.themeTrack

                Rectangle {
                    height: parent.height
                    width: parent.width * Math.min(1.0, Math.max(0.0, root.barState.mprisLength > 0 ? (root.barState.mprisPosition / root.barState.mprisLength) : 0.0))
                    radius: 2
                    color: root.barState.themeAccent
                }
            }
        }
    }
}
