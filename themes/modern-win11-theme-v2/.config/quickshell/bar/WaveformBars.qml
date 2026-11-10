import QtQuick

Item {
    id: root

    property bool isPlaying: false
    property var values: [0, 0, 0, 0, 0]
    property color barColor: "#FFFFFF"
    property real barWidth: 2.5
    property real barSpacing: 2.5
    property real maxSlotHeight: 20

    implicitWidth: 5 * barWidth + 4 * barSpacing
    implicitHeight: maxSlotHeight

    Row {
        anchors.centerIn: parent
        spacing: root.barSpacing

        Repeater {
            model: 5

            // Fixed height slot guarantees symmetrical center-axis growth
            Item {
                width: root.barWidth
                height: root.maxSlotHeight

                property real cavaRaw: {
                    if (!root.values || root.values.length === 0) return 0;
                    if (root.values.length === 5) return root.values[index] || 0;
                    var sampleIdx = Math.min(root.values.length - 1, Math.floor(index * (root.values.length / 5.0)));
                    return root.values[sampleIdx] || 0;
                }

                // Map 0-100 to [barWidth, maxSlotHeight]
                property real targetH: {
                    if (!root.isPlaying || cavaRaw <= 0) {
                        return root.barWidth;
                    }
                    // Exponential/power scaling for rich audio responsiveness
                    var norm = Math.min(1.0, cavaRaw / 100.0);
                    var scaled = Math.pow(norm, 0.85);
                    return Math.min(root.maxSlotHeight, Math.max(root.barWidth, root.barWidth + scaled * (root.maxSlotHeight - root.barWidth)));
                }

                Rectangle {
                    id: barRect
                    width: root.barWidth
                    height: parent.targetH
                    radius: root.barWidth / 2
                    color: root.barColor
                    anchors.centerIn: parent

                    // Ultra-fast responsive interpolation for fluid 240Hz visualizer
                    Behavior on height {
                        NumberAnimation {
                            duration: 85
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }
}
