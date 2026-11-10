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

    implicitWidth: 340
    implicitHeight: 120

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        // ── 1. Master Volume Slider ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // Speaker Icon Button
            Rectangle {
                width: 28
                height: 28
                radius: 14
                color: volBtnHover.hovered ? root.barState.themeSurfaceContainerHigh : "transparent"

                HoverHandler { id: volBtnHover }

                Text {
                    anchors.centerIn: parent
                    text: root.barState.isMuted ? "󰝟" : (root.barState.volumePercent > 50 ? "󰕾" : "󰖀")
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    color: root.barState.isMuted ? "#E81123" : root.barState.themeAccent
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.barState.openPopup("mixer");
                    }
                }
            }

            // Volume Track Slider
            Rectangle {
                id: volTrack
                Layout.fillWidth: true
                height: 24
                radius: 12
                color: root.barState.themeSurfaceContainerHigh
                clip: true

                Rectangle {
                    height: parent.height
                    width: parent.width * (root.barState.volumePercent / 100.0)
                    radius: 12
                    color: root.barState.isMuted ? root.barState.themeOnSurfaceLow : root.barState.themeAccent

                    Behavior on width { NumberAnimation { duration: 80 } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    function updateVol(mouse) {
                        var pct = Math.round(Math.min(100, Math.max(0, (mouse.x / volTrack.width) * 100)));
                        root.barState.setVolume(pct);
                    }

                    onPressed: mouse => {
                        if (mouse.button === Qt.RightButton) {
                            root.barState.openPopup("mixer");
                        } else {
                            updateVol(mouse);
                        }
                    }
                    onPositionChanged: mouse => {
                        if (pressed) updateVol(mouse);
                    }
                }
            }

            Text {
                width: 32
                horizontalAlignment: Text.AlignRight
                text: root.barState.volumePercent + "%"
                font.family: root.barState.themeFontInterface
                font.pixelSize: 11
                color: root.barState.themeOnSurfaceDim
            }
        }

        // ── 2. Brightness Slider ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // Sun Icon
            Rectangle {
                width: 28
                height: 28
                radius: 14
                color: "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "󰃠"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    color: root.barState.themeAccent
                }
            }

            // Brightness Track Slider
            Rectangle {
                id: brightTrack
                Layout.fillWidth: true
                height: 24
                radius: 12
                color: root.barState.themeSurfaceContainerHigh
                clip: true

                Rectangle {
                    height: parent.height
                    width: parent.width * (root.barState.brightnessPercent / 100.0)
                    radius: 12
                    color: root.barState.themeAccent

                    Behavior on width { NumberAnimation { duration: 80 } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    function updateBright(mouse) {
                        var pct = Math.round(Math.min(100, Math.max(5, (mouse.x / brightTrack.width) * 100)));
                        root.barState.setBrightness(pct);
                    }

                    onPressed: mouse => updateBright(mouse)
                    onPositionChanged: mouse => {
                        if (pressed) updateBright(mouse);
                    }
                }
            }

            Text {
                width: 32
                horizontalAlignment: Text.AlignRight
                text: root.barState.brightnessPercent + "%"
                font.family: root.barState.themeFontInterface
                font.pixelSize: 11
                color: root.barState.themeOnSurfaceDim
            }
        }
    }
}
