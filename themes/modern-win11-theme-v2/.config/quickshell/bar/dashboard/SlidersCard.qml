import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root

    required property var barState

    color: Qt.rgba(1, 1, 1, 0.08)
    radius: 16
    border.color: Qt.rgba(1, 1, 1, 0.12)
    border.width: 1

    implicitWidth: 388
    implicitHeight: 120

    // Component for Astraeus Thin Glass Slider with Circular White Thumb Knob
    component AstraeusSlider: RowLayout {
        id: sRow
        property string icon: ""
        property int value: 100
        property bool isMuted: false
        property color activeColor: root.barState.themeAccent
        signal valueChangedByUser(int newValue)
        signal iconClicked()

        Layout.fillWidth: true
        spacing: 10

        // Leading Icon
        Rectangle {
            width: 26
            height: 26
            radius: 13
            color: iconHov.hovered ? Qt.rgba(1, 1, 1, 0.12) : "transparent"

            HoverHandler { id: iconHov }

            Text {
                anchors.centerIn: parent
                text: sRow.icon
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 13
                color: sRow.isMuted ? "#E81123" : root.barState.themeOnSurface
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: sRow.iconClicked()
            }
        }

        // Sleek Thin Track with Thumb Knob
        Item {
            id: trackContainer
            Layout.fillWidth: true
            height: 20

            // Background Track Line (4px)
            Rectangle {
                id: bgTrack
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: 4
                radius: 2
                color: Qt.rgba(1, 1, 1, 0.18)

                // Active Progress Fill
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * Math.min(1.0, Math.max(0.0, sRow.value / 100.0))
                    radius: 2
                    color: sRow.isMuted ? Qt.rgba(1, 1, 1, 0.35) : sRow.activeColor
                }
            }

            // Circular White Thumb Knob (14x14)
            Rectangle {
                id: thumbKnob
                width: 14
                height: 14
                radius: 7
                color: "#FFFFFF"
                anchors.verticalCenter: parent.verticalCenter
                x: Math.max(0, Math.min(trackContainer.width - width, (trackContainer.width * (sRow.value / 100.0)) - (width / 2)))

                // Soft specular shadow
                border.color: Qt.rgba(0, 0, 0, 0.25)
                border.width: 1

                scale: trackArea.pressed ? 1.15 : (trackHover.hovered ? 1.08 : 1.0)
                Behavior on scale { NumberAnimation { duration: 100 } }
            }

            HoverHandler { id: trackHover }

            MouseArea {
                id: trackArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                function handleMove(mouse) {
                    var pct = Math.round(Math.min(100, Math.max(0, (mouse.x / trackContainer.width) * 100)));
                    sRow.valueChangedByUser(pct);
                }

                onPressed: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        sRow.iconClicked();
                    } else {
                        handleMove(mouse);
                    }
                }
                onPositionChanged: mouse => {
                    if (pressed) handleMove(mouse);
                }
            }
        }

        // Trailing Percentage Tag
        Text {
            width: 32
            horizontalAlignment: Text.AlignRight
            text: sRow.value + "%"
            font.family: root.barState.themeFontInterface
            font.pixelSize: 10
            color: root.barState.themeOnSurfaceDim
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 6

        // 1. Master Volume
        AstraeusSlider {
            icon: root.barState.isMuted ? "󰝟" : (root.barState.volumePercent > 50 ? "󰕾" : "󰖀")
            value: root.barState.volumePercent
            isMuted: root.barState.isMuted
            activeColor: root.barState.themeAccent
            onValueChangedByUser: pct => root.barState.setVolume(pct)
            onIconClicked: root.barState.openSheet("volume_mixer")
        }

        // 2. Microphone Gain
        AstraeusSlider {
            icon: root.barState.micMuted ? "󰍭" : "󰍬"
            value: root.barState.micPercent
            isMuted: root.barState.micMuted
            activeColor: root.barState.themeAccent
            onValueChangedByUser: pct => root.barState.setMicVolume(pct)
            onIconClicked: root.barState.toggleMicMute()
        }

        // 3. Screen Brightness
        AstraeusSlider {
            icon: "󰃠"
            value: root.barState.brightnessPercent
            activeColor: root.barState.themeAccent
            onValueChangedByUser: pct => root.barState.setBrightness(pct)
            onIconClicked: {}
        }
    }
}
