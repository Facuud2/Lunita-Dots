import QtQuick

Item {
    id: root

    property var cavaBars: []
    property real progress: 0.0
    property bool isPlaying: false
    property color activeColor: "#FFFFFF"
    property color inactiveColor: Qt.rgba(1, 1, 1, 0.22)
    property color hoverColor: Qt.rgba(1, 1, 1, 0.45)
    property int barCount: 36
    property real maxBarHeight: 18
    property real minBarHeight: 3.5

    signal seekRequested(real ratio)

    implicitWidth: 260
    implicitHeight: 22

    // Background invisible hit area for seeking
    MouseArea {
        id: seekMouse
        anchors.fill: parent
        anchors.topMargin: -6
        anchors.bottomMargin: -6
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        function updateSeek(mouse) {
            var r = Math.max(0.0, Math.min(1.0, mouse.x / root.width));
            root.seekRequested(r);
        }

        onPressed: mouse => updateSeek(mouse)
        onPositionChanged: mouse => {
            if (pressed) updateSeek(mouse);
        }
    }

    // Dynamic CAVA equalizer bars
    Repeater {
        model: root.barCount

        Rectangle {
            id: barItem
            property real barSlotWidth: root.width / root.barCount
            property real itemWidth: Math.max(2.5, Math.min(4.5, barSlotWidth - 2.8))
            property real ratio: index / Math.max(1, root.barCount - 1)

            x: index * barSlotWidth + (barSlotWidth - itemWidth) / 2
            anchors.verticalCenter: parent.verticalCenter
            width: itemWidth
            radius: itemWidth / 2

            // Dynamic audio height
            property real cavaVal: (root.cavaBars && index < root.cavaBars.length) ? root.cavaBars[index] : 0

            height: {
                if (!root.isPlaying || cavaVal <= 1) {
                    return root.minBarHeight;
                }

                // Audio reactive height
                var norm = Math.min(1.0, cavaVal / 100.0);
                var scaled = Math.pow(norm, 0.82);
                return Math.min(root.maxBarHeight, Math.max(root.minBarHeight, root.minBarHeight + scaled * (root.maxBarHeight - root.minBarHeight)));
            }

            Behavior on height {
                NumberAnimation {
                    duration: 75
                    easing.type: Easing.OutCubic
                }
            }

            // Fill color: filled if played, hover preview if scrubbing ahead, translucent otherwise
            color: {
                if (ratio <= root.progress) {
                    return root.activeColor;
                }
                if (seekMouse.containsMouse && ratio <= (seekMouse.mouseX / root.width)) {
                    return root.hoverColor;
                }
                return root.inactiveColor;
            }

            Behavior on color {
                ColorAnimation { duration: 100 }
            }
        }
    }
}
