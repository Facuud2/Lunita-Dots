import QtQuick

Item {
    id: root

    property bool isPlaying: false
    property var values: []
    property color barColor: "#0078D4"
    property real barWidth: 2.5
    property real barSpacing: 2.5
    property real maxSlotHeight: 18
    property int barCount: 5

    implicitWidth: barCount * barWidth + (barCount - 1) * barSpacing
    implicitHeight: maxSlotHeight

    Row {
        anchors.centerIn: parent
        spacing: root.barSpacing

        Repeater {
            model: root.barCount

            Item {
                width: root.barWidth
                height: root.maxSlotHeight

                property real cavaRaw: {
                    if (!root.values || root.values.length === 0) return 0;
                    var sampleIdx = Math.min(root.values.length - 1, Math.floor(index * (root.values.length / Math.max(1, root.barCount))));
                    return root.values[sampleIdx] || 0;
                }

                property real targetH: {
                    if (!root.isPlaying || cavaRaw <= 0) {
                        return root.barWidth;
                    }
                    var norm = Math.min(1.0, cavaRaw / 100.0);
                    var scaled = Math.pow(norm, 0.82);
                    return Math.min(root.maxSlotHeight, Math.max(root.barWidth, root.barWidth + scaled * (root.maxSlotHeight - root.barWidth)));
                }

                Rectangle {
                    id: barRect
                    width: root.barWidth
                    height: parent.targetH
                    radius: root.barWidth / 2
                    color: root.barColor
                    anchors.centerIn: parent

                    Behavior on height {
                        NumberAnimation {
                            duration: 75
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }
}
