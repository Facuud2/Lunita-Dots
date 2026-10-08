import QtQuick
import QtQuick.Controls

Item {
    id: root

    required property var launcherState
    property var category: null

    width: 184
    height: 84

    Rectangle {
        id: cardBg
        anchors.fill: parent
        radius: 8
        color: cardMouse.pressed
            ? root.launcherState.appActiveBg
            : (cardMouse.containsMouse ? root.launcherState.folderCardHover : root.launcherState.folderCardBg)
        border.color: cardMouse.containsMouse ? root.launcherState.accentColor : "transparent"
        border.width: cardMouse.containsMouse ? 1 : 0

        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }

        // 2x2 Mini Icon Grid Container
        Grid {
            anchors.centerIn: parent
            columns: 2
            rows: 2
            spacing: 8

            Repeater {
                model: root.category ? (root.category.previewApps || []) : []

                Item {
                    required property var modelData
                    width: 26
                    height: 26

                    readonly property string itemIcon: {
                        if (!modelData) return "image://icon/application-x-executable";
                        var s = (modelData.resolvedIcon || modelData.iconName || "").toString();
                        if (s.startsWith("assets/")) return Qt.resolvedUrl(s);
                        if (s.startsWith("/")) return "file://" + s;
                        if (s.startsWith("file://") || s.startsWith("image://")) return s;
                        return "image://icon/" + s;
                    }

                    Image {
                        anchors.fill: parent
                        source: parent.itemIcon
                        sourceSize: Qt.size(48, 48)
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                    }
                }
            }
        }
    }

    MouseArea {
        id: cardMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (root.category) {
                root.launcherState.openCategoryFolder(root.category);
            }
        }
    }

    ToolTip.visible: cardMouse.containsMouse && root.category && root.category.title
    ToolTip.delay: 500
    ToolTip.timeout: 3000
    ToolTip.text: root.category ? root.category.title : ""
}
