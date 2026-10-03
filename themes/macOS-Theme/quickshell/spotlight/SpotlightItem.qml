import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Item {
    id: root

    required property var spotlightState
    required property var modelData
    required property int index

    readonly property var itemData: modelData
    readonly property bool isSelected: index === spotlightState.selectedIndex

    implicitWidth: parent ? parent.width : 340
    implicitHeight: 46

    // Selection / Hover Pill Background
    Rectangle {
        id: pillBg
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        anchors.topMargin: 2
        anchors.bottomMargin: 2
        radius: 8
        color: root.isSelected
            ? root.spotlightState.selectedBgColor
            : (mouseArea.containsMouse ? root.spotlightState.itemHoverBg : "transparent")

        Behavior on color {
            ColorAnimation { duration: 100 }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 12

        // ── Item Icon ──
        Item {
            implicitWidth: 26
            implicitHeight: 26
            Layout.alignment: Qt.AlignVCenter

            Image {
                id: itemImg
                anchors.fill: parent
                source: (root.itemData && root.itemData.icon) ? root.itemData.icon : "assets/document.svg"
                sourceSize.width: 52
                sourceSize.height: 52
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
            }
        }

        // ── Title & Subtitle Column ──
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 1

            Text {
                text: (root.itemData && root.itemData.title) ? root.itemData.title : ""
                color: root.isSelected ? root.spotlightState.selectedTextColor : root.spotlightState.textColor
                font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                font.pixelSize: 13
                font.weight: Font.DemiBold
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                visible: !!(root.itemData && root.itemData.subtitle && root.itemData.subtitle.length > 0)
                text: (root.itemData && root.itemData.subtitle) ? root.itemData.subtitle : ""
                color: root.isSelected ? root.spotlightState.selectedSubColor : root.spotlightState.textDimColor
                font.family: "SF Pro Text, Inter, -apple-system, system-ui, sans-serif"
                font.pixelSize: 11
                font.weight: Font.Normal
                elide: Text.ElideMiddle
                Layout.fillWidth: true
            }
        }

        // ── Category / Shortcut Hint Tag ──
        Rectangle {
            visible: !!(root.itemData && (root.itemData.category === "TOP HIT" || root.itemData.type === "calc"))
            implicitWidth: catTagText.implicitWidth + 10
            implicitHeight: 18
            radius: 4
            color: root.isSelected ? Qt.rgba(1, 1, 1, 0.22) : (root.spotlightState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.06))

            Text {
                id: catTagText
                anchors.centerIn: parent
                text: (root.itemData && root.itemData.type === "calc") ? "↵ Copiar" : "Top Hit"
                color: root.isSelected ? "#FFFFFF" : root.spotlightState.textDimColor
                font.family: "SF Pro Text, Inter, -apple-system, system-ui, sans-serif"
                font.pixelSize: 9
                font.weight: Font.Medium
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor

        onEntered: {
            root.spotlightState.selectIndex(root.index)
        }

        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                root.spotlightState.revealCurrentItem()
            } else {
                root.spotlightState.activateCurrentItem()
            }
        }
    }
}
