import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Qt5Compat.GraphicalEffects

Item {
    id: root

    required property var barState

    width: 380 + 24 // include ear wings
    height: 172
    anchors.top: parent.top
    anchors.topMargin: 0

    visible: barState.activePopup === "media"
    opacity: visible ? 1.0 : 0.0
    y: visible ? 0 : -20

    Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
    Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

    Item {
        id: cardContainer
        width: 380
        height: 172
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top

        // Main Card Rectangle with Warm Orange / Amber Gradient from Reference 2
        Rectangle {
            id: mainCardBg
            anchors.fill: parent
            topLeftRadius: 0
            topRightRadius: 0
            bottomLeftRadius: 22
            bottomRightRadius: 22
            clip: true

            gradient: Gradient {
                GradientStop { position: 0.0; color: "#140602" }
                GradientStop { position: 0.28; color: "#6A2206" }
                GradientStop { position: 0.48; color: "#B8430A" }
                GradientStop { position: 0.72; color: "#541B05" }
                GradientStop { position: 1.0; color: "#110401" }
            }

            border.color: Qt.rgba(1, 1, 1, 0.16)
            border.width: 1
        }

        // Left Inverted Ear Wing
        Shape {
            anchors.right: mainCardBg.left
            anchors.top: parent.top
            width: 12
            height: 12

            ShapePath {
                fillColor: "#000000"
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

        // Right Inverted Ear Wing
        Shape {
            anchors.left: mainCardBg.right
            anchors.top: parent.top
            width: 12
            height: 12

            ShapePath {
                fillColor: "#000000"
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
            anchors.topMargin: 10
            spacing: 10

            // 1. Top Section: Album Art + Titles + Waveform
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // Album Art (iOS-Like Rounded Corners)
                Item {
                    Layout.preferredWidth: 46
                    Layout.preferredHeight: 46

                    Image {
                        id: cardCoverImg
                        anchors.fill: parent
                        source: root.barState.mprisArtUrl !== "" ? root.barState.mprisArtUrl : ""
                        visible: false
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }

                    Rectangle {
                        id: cardCoverMask
                        anchors.fill: parent
                        radius: 10
                        visible: false
                    }

                    OpacityMask {
                        anchors.fill: parent
                        source: cardCoverImg
                        maskSource: cardCoverMask
                        visible: root.barState.mprisArtUrl !== ""
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 10
                        visible: root.barState.mprisArtUrl === ""
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#A85324" }
                            GradientStop { position: 1.0; color: "#3B1B0A" }
                        }
                        Text {
                            anchors.centerIn: parent
                            text: "♫"
                            font.pixelSize: 20
                            color: "#FFFFFF"
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 10
                        color: "transparent"
                        border.color: Qt.rgba(1, 1, 1, 0.16)
                        border.width: 1
                    }
                }

                // Title & Artist
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: root.barState.mprisTitle
                        font.family: "Segoe UI, Inter, Cantarell, sans-serif"
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: root.barState.mprisArtist
                        font.family: "Segoe UI, Inter, Cantarell, sans-serif"
                        font.pixelSize: 11
                        font.weight: Font.Normal
                        color: Qt.rgba(1, 1, 1, 0.70)
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                // Mini Waveform Bars (animated)
                Row {
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    spacing: 2.5

                    Repeater {
                        model: 5
                        Rectangle {
                            width: 2.5
                            radius: 1.5
                            color: root.barState.mprisPlaying ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.6)
                            height: {
                                var heights = [10, 18, 14, 20, 12];
                                return heights[index];
                            }
                            anchors.bottom: parent.bottom
                        }
                    }
                }
            }

            // 2. Middle Section: Progress Slider & Timestamps (Single Unified Row matching Image 2)
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                // Elapsed Timestamp
                Text {
                    text: root.barState.mprisPositionStr
                    font.family: "Segoe UI, Inter, Cantarell, sans-serif"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: Qt.rgba(1, 1, 1, 0.75)
                    Layout.preferredWidth: 32
                }

                // Dynamic Audio CAVA Waveform Progress Track
                CavaProgressTrack {
                    id: cavaProgress
                    Layout.fillWidth: true
                    Layout.preferredHeight: 20
                    cavaBars: root.barState.cavaBars
                    isPlaying: root.barState.mprisPlaying
                    progress: Math.max(0.0, Math.min(1.0, root.barState.mprisPosition / Math.max(1.0, root.barState.mprisLength)))
                    onSeekRequested: ratio => root.barState.seekPosition(ratio)
                }

                // Remaining Timestamp
                Text {
                    text: root.barState.mprisRemainingStr
                    font.family: "Segoe UI, Inter, Cantarell, sans-serif"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: Qt.rgba(1, 1, 1, 0.75)
                    Layout.preferredWidth: 34
                    horizontalAlignment: Text.AlignRight
                }
            }

            // 3. Bottom Section: Controls & Audio Devices (Clean Pure White Controls matching Image 2)
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter

                // Volume / Speaker Icon
                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    radius: 16
                    color: volHover.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

                    Image {
                        anchors.centerIn: parent
                        source: "../assets/volume.svg"
                        sourceSize.width: 17
                        sourceSize.height: 17
                    }

                    MouseArea {
                        id: volHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.barState.toggleMute()
                    }
                }

                Item { Layout.fillWidth: true }

                // Playback Controls (Previous, Play/Pause, Next)
                Row {
                    spacing: 24
                    Layout.alignment: Qt.AlignHCenter

                    // Previous Track (Double Left Triangles <<)
                    Rectangle {
                        width: 34
                        height: 34
                        radius: 17
                        color: prevHover.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

                        Image {
                            anchors.centerIn: parent
                            source: "../assets/prev.svg"
                            sourceSize.width: 19
                            sourceSize.height: 19
                        }

                        MouseArea {
                            id: prevHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.barState.previousTrack()
                        }
                    }

                    // Play / Pause (Solid White || or ▶, No White Circle)
                    Rectangle {
                        width: 40
                        height: 40
                        radius: 20
                        color: playHover.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

                        Image {
                            anchors.centerIn: parent
                            source: root.barState.mprisPlaying ? "../assets/pause.svg" : "../assets/play.svg"
                            sourceSize.width: root.barState.mprisPlaying ? 18 : 22
                            sourceSize.height: root.barState.mprisPlaying ? 22 : 22
                        }

                        MouseArea {
                            id: playHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.barState.playPause()
                        }
                    }

                    // Next Track (Double Right Triangles >>)
                    Rectangle {
                        width: 34
                        height: 34
                        radius: 17
                        color: nextHover.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

                        Image {
                            anchors.centerIn: parent
                            source: "../assets/next.svg"
                            sourceSize.width: 19
                            sourceSize.height: 19
                        }

                        MouseArea {
                            id: nextHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.barState.nextTrack()
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Headphones Output Icon
                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    radius: 16
                    color: hpHover.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

                    Image {
                        anchors.centerIn: parent
                        source: "../assets/headphones.svg"
                        sourceSize.width: 17
                        sourceSize.height: 17
                    }

                    MouseArea {
                        id: hpHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.barState.openPopup("controlcenter")
                    }
                }
            }
        }
    }
}
