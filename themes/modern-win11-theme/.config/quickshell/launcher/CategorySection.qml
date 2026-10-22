import QtQuick
import QtQuick.Controls

Item {
    id: root

    required property var launcherState
    property var category: null
    property bool isLastSection: false

    width: parent ? parent.width : 500
    height: sectionColumn.implicitHeight + 16

    Column {
        id: sectionColumn

        width: parent.width
        spacing: 10

        // ── Section Header (Title & Show All Action) ──
        Item {
            width: parent.width
            height: 24

            Text {
                text: (root.category && root.category.displayName) ? root.category.displayName : ""
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                color: launcherState.categoryHeaderColor
                font.pixelSize: 13
                font.weight: Font.DemiBold
                font.italic: false
                font.family: "SF Pro Text, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, sans-serif"
            }

            // "Show All" / "Show More" Button
            Item {
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                width: actionLabel.implicitWidth + 8
                height: 22

                Text {
                    id: actionLabel

                    anchors.centerIn: parent
                    text: (root.category && root.category.actionText) ? root.category.actionText : "Show All"
                    color: actionMouse.containsMouse ? launcherState.categoryActionHover : launcherState.categoryActionColor
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    font.italic: false
                    font.family: "SF Pro Text, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, sans-serif"

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }

                    }

                }

                MouseArea {
                    id: actionMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.category)
                            launcherState.showCategoryDetail(root.category);

                    }
                }

            }

        }

        // ── App Items Row (5-column Grid) ──
        Row {
            id: appsRow

            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Math.max(2, Math.floor((root.width - (5 * 96)) / 4))

            Repeater {
                model: root.category ? root.category.previewApps : []

                delegate: AppItem {
                    required property var modelData

                    launcherState: root.launcherState
                    app: modelData
                }

            }

        }

        // ── Subtle Divider Line ──
        Rectangle {
            width: parent.width - 16
            anchors.horizontalCenter: parent.horizontalCenter
            height: 1
            color: launcherState.dividerColor
            visible: !root.isLastSection
        }

    }

}
