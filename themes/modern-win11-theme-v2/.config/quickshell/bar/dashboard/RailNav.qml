import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root

    required property var barState
    property int currentPage: 0
    signal pageSelected(int pageIndex)

    readonly property var pages: [
        { id: 0, num: "01", name: "Home", icon: "󰕰" },
        { id: 1, num: "02", name: "Media", icon: "󰝚" },
        { id: 2, num: "03", name: "System", icon: "󰄪" },
        { id: 3, num: "04", name: "Network", icon: "󰤨" },
        { id: 4, num: "05", name: "Shelf", icon: "󰉋" },
        { id: 5, num: "06", name: "Tools", icon: "󰒓" },
        { id: 6, num: "07", name: "Settings", icon: "󰅒" }
    ]

    implicitWidth: 48
    implicitHeight: railCol.implicitHeight

    // Active Indicator Capsule (Sliding animated pill behind active tab)
    Rectangle {
        id: activeIndicator
        width: 38
        height: 38
        radius: 10
        color: root.currentPage === 0 ? root.barState.themeAccent : Qt.rgba(root.barState.themeAccent.r, root.barState.themeAccent.g, root.barState.themeAccent.b, 0.28)
        border.color: root.currentPage === 0 ? "transparent" : root.barState.themeAccent
        border.width: 1
        x: 5
        y: root.currentPage * (38 + 6) + 4

        Behavior on y {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }
    }

    Column {
        id: railCol
        anchors.top: parent.top
        anchors.topMargin: 4
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 6

        Repeater {
            model: root.pages

            Item {
                width: 38
                height: 38

                readonly property bool isActive: root.currentPage === index
                readonly property bool isHovered: tabHover.hovered

                HoverHandler { id: tabHover }

                Text {
                    anchors.centerIn: parent
                    text: modelData.icon
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 16
                    color: parent.isActive ? (root.currentPage === 0 ? "#FFFFFF" : root.barState.themeAccent) : (parent.isHovered ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.55))

                    Behavior on color { ColorAnimation { duration: 140 } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.pageSelected(index);
                    }
                }

                // Tooltip
                ToolTip.visible: tabHover.hovered
                ToolTip.delay: 350
                ToolTip.text: modelData.name
            }
        }
    }

    // Wheel navigation between pages
    WheelHandler {
        onWheel: event => {
            if (event.angleDelta.y < 0 && root.currentPage < root.pages.length - 1) {
                root.pageSelected(root.currentPage + 1);
            } else if (event.angleDelta.y > 0 && root.currentPage > 0) {
                root.pageSelected(root.currentPage - 1);
            }
        }
    }
}
