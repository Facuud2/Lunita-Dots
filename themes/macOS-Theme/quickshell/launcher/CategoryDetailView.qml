import QtQuick
import QtQuick.Controls

Item {
    id: root

    required property var launcherState
    property var appsList: []

    width: parent ? parent.width : 500
    height: parent ? parent.height : 400

    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: appsGrid.implicitHeight + 20
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Grid {
            id: appsGrid
            width: parent.width
            columns: 5
            spacing: Math.max(2, Math.floor((root.width - (5 * 96)) / 4))
            anchors.horizontalCenter: parent.horizontalCenter
            topPadding: 6
            bottomPadding: 16

            Repeater {
                model: root.appsList
                delegate: AppItem {
                    required property var modelData
                    launcherState: root.launcherState
                    app: modelData
                    isDetailed: true
                }
            }
        }

        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
            width: 5
            anchors.right: flick.right
            anchors.rightMargin: 2
        }
    }
}
