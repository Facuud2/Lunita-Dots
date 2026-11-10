import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root

    required property var barState
    property int currentPage: 0
    signal pageSelected(int pageIndex)

    readonly property var pages: [
        { id: 0, num: "01", name: "Home", icon: "󰋜" },
        { id: 1, num: "02", name: "Media", icon: "󰝚" },
        { id: 2, num: "03", name: "System", icon: "󰍹" },
        { id: 3, num: "04", name: "Network", icon: "󰤨" },
        { id: 4, num: "05", name: "Shelf", icon: "󰉋" },
        { id: 5, num: "06", name: "Tools", icon: "󰒓" },
        { id: 6, num: "07", name: "Settings", icon: "󰅒" }
    ]

    implicitWidth: 54
    implicitHeight: railCol.implicitHeight

    // Active Indicator Capsule (Sliding animated pill behind active tab)
    Rectangle {
        id: activeIndicator
        width: 44
        height: 38
        radius: 10
        color: root.barState.themeSurfaceContainerHigh
        border.color: root.barState.themeBorderSpecular
        border.width: 1
        x: 5
        y: root.currentPage * (38 + 6) + 4

        Behavior on y {
            NumberAnimation {
                duration: 220
                easing.type: Easing.OutCubic
            }
        }

        // Left Accent Bar (2px)
        Rectangle {
            width: 3
            height: 18
            radius: 1.5
            color: root.barState.themeAccent
            anchors.left: parent.left
            anchors.leftMargin: 2
            anchors.verticalCenter: parent.verticalCenter
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
                width: 44
                height: 38

                readonly property bool isActive: root.currentPage === index
                readonly property bool isHovered: tabHover.hovered

                HoverHandler { id: tabHover }

                Column {
                    anchors.centerIn: parent
                    spacing: 1

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: modelData.icon
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                        color: parent.parent.isActive ? root.barState.themeAccent : (parent.parent.isHovered ? root.barState.themeOnSurface : root.barState.themeOnSurfaceLow)

                        Behavior on color { ColorAnimation { duration: 140 } }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: modelData.num
                        font.family: root.barState.themeFontInterface
                        font.pixelSize: 8
                        font.weight: Font.DemiBold
                        color: parent.parent.isActive ? root.barState.themeOnSurface : root.barState.themeOnSurfaceLow
                        opacity: parent.parent.isActive ? 0.9 : 0.5
                    }
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
