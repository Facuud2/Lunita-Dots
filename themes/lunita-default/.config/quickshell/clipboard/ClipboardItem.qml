import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Item {
    id: root

    required property var clipboardState
    required property var modelData
    required property int index

    readonly property var itemData: modelData
    readonly property bool isSelected: index === clipboardState.selectedIndex
    readonly property string itemType: (root.itemData && root.itemData.type) ? root.itemData.type : "text"

    readonly property color badgeBgColor: {
        if (itemType === "image") return root.clipboardState.badgeImageBg;
        if (itemType === "code") return root.clipboardState.badgeCodeBg;
        if (itemType === "link" || itemType === "url") return root.clipboardState.badgeLinkBg;
        return root.clipboardState.badgeTextBg;
    }

    readonly property color badgeFgColor: {
        if (itemType === "image") return root.clipboardState.badgeImageFg;
        if (itemType === "code") return root.clipboardState.badgeCodeFg;
        if (itemType === "link" || itemType === "url") return root.clipboardState.badgeLinkFg;
        return root.clipboardState.badgeTextFg;
    }

    readonly property color badgeBorderColor: {
        if (itemType === "image") return root.clipboardState.badgeImageBorder;
        if (itemType === "code") return root.clipboardState.badgeCodeBorder;
        if (itemType === "link" || itemType === "url") return root.clipboardState.badgeLinkBorder;
        return root.clipboardState.badgeTextBorder;
    }

    readonly property color tagFgColor: {
        if (itemType === "image") return root.clipboardState.badgeImageFg;
        if (itemType === "code") return root.clipboardState.badgeCodeFg;
        if (itemType === "link" || itemType === "url") return root.clipboardState.badgeLinkFg;
        return root.clipboardState.badgeTextFg;
    }

    readonly property string badgeIconGlyph: {
        if (itemType === "image") return "image";
        if (itemType === "code") return "code";
        if (itemType === "link" || itemType === "url") return "link";
        return "description";
    }

    readonly property string badgeTagText: {
        if (root.itemData && root.itemData.tag) return root.itemData.tag;
        if (itemType === "image") return "IMAGEN";
        if (itemType === "code") return "CÓDIGO";
        if (itemType === "link" || itemType === "url") return "ENLACE";
        return "TEXTO";
    }

    implicitWidth: parent ? parent.width : 428
    implicitHeight: 54

    // ── Row Card Background (.cliphist-row) ──
    Rectangle {
        id: rowBg
        anchors.fill: parent
        anchors.topMargin: 1
        anchors.bottomMargin: 1
        radius: 14
        color: root.isSelected
            ? root.clipboardState.selectedBgColor
            : (itemMouseArea.containsMouse ? root.clipboardState.itemHoverBg : root.clipboardState.rowBgColor)
        border.color: root.isSelected
            ? root.clipboardState.selectedBorderColor
            : root.clipboardState.rowBorderColor
        border.width: 1

        // Vivid left accent pill when selected
        Rectangle {
            visible: root.isSelected
            width: 3
            height: 24
            radius: 2
            anchors.left: parent.left
            anchors.leftMargin: 3
            anchors.verticalCenter: parent.verticalCenter
            color: root.clipboardState.accentRedBright
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 10
        spacing: 10

        // ── 1. Type Badge Icon (.cliphist-type-icon) ──
        Rectangle {
            id: typeIconBox
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            Layout.alignment: Qt.AlignVCenter
            radius: 10
            color: root.badgeBgColor
            border.color: root.badgeBorderColor
            border.width: 1

            Image {
                id: thumbImg
                visible: !!(root.itemData && root.itemData.thumbnail && root.itemData.thumbnail.length > 0)
                anchors.fill: parent
                source: (root.itemData && root.itemData.thumbnail) ? root.itemData.thumbnail : ""
                fillMode: Image.PreserveAspectCrop
                smooth: true
                mipmap: true

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: 32
                        height: 32
                        radius: 10
                    }
                }
            }

            Text {
                visible: !thumbImg.visible
                anchors.centerIn: parent
                text: root.badgeIconGlyph
                font.family: root.clipboardState.fontIcons
                font.pixelSize: 16
                color: root.badgeFgColor
            }
        }

        // ── 2. Text Content Column (Tag + Timestamp on top, Preview below) ──
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: root.badgeTagText
                    font.family: root.clipboardState.fontDots
                    font.pixelSize: 9
                    font.letterSpacing: 0.8
                    font.weight: Font.Bold
                    color: root.tagFgColor
                }

                Text {
                    text: (root.itemData && root.itemData.timestamp) ? root.itemData.timestamp : ""
                    font.family: root.clipboardState.fontUi
                    font.pixelSize: 10
                    font.letterSpacing: 0.2
                    color: root.clipboardState.textFaintColor
                }

                Item { Layout.fillWidth: true }
            }

            Text {
                text: (root.itemData && root.itemData.title) ? root.itemData.title : ""
                color: root.clipboardState.textColor
                font.family: root.clipboardState.fontUi
                font.pixelSize: 12
                font.weight: root.isSelected ? Font.Medium : Font.Normal
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        // ── 3. Action Buttons (.cliphist-row-actions) ──
        RowLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: 4

            // Copy & Paste Button (.cliphist-copy-btn)
            Rectangle {
                id: copyBtn
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                radius: 8
                color: copyBtnMouse.containsMouse
                    ? root.clipboardState.copyBtnHoverBg
                    : root.clipboardState.actionBtnBg
                border.color: copyBtnMouse.containsMouse
                    ? root.clipboardState.copyBtnHoverBorder
                    : root.clipboardState.actionBtnBorder
                border.width: 1

                Behavior on color { ColorAnimation { duration: 140 } }
                Behavior on border.color { ColorAnimation { duration: 140 } }

                Text {
                    anchors.centerIn: parent
                    text: "content_copy"
                    font.family: root.clipboardState.fontIcons
                    font.pixelSize: 15
                    color: copyBtnMouse.containsMouse
                        ? root.clipboardState.textColor
                        : root.clipboardState.textDimColor
                }

                MouseArea {
                    id: copyBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    preventStealing: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.itemData && root.itemData.id) {
                            root.clipboardState.copyItem(root.itemData.id);
                        }
                    }
                }
            }

            // Delete Button (.cliphist-del-btn)
            Rectangle {
                id: deleteBtn
                Layout.preferredWidth: 28
                Layout.preferredHeight: 28
                radius: 8
                color: deleteBtnMouse.containsMouse
                    ? root.clipboardState.delBtnHoverBg
                    : root.clipboardState.actionBtnBg
                border.color: deleteBtnMouse.containsMouse
                    ? root.clipboardState.delBtnHoverBorder
                    : root.clipboardState.actionBtnBorder
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "delete"
                    font.family: root.clipboardState.fontIcons
                    font.pixelSize: 15
                    color: deleteBtnMouse.containsMouse
                        ? root.clipboardState.accentRedBright
                        : root.clipboardState.textDimColor
                }

                MouseArea {
                    id: deleteBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    preventStealing: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.itemData && root.itemData.id) {
                            root.clipboardState.deleteItem(root.itemData.id);
                        }
                    }
                }
            }
        }
    }

    // ── Row MouseArea for Hover Selection & Click-to-Paste ──
    MouseArea {
        id: itemMouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        z: -1

        onEntered: {
            root.clipboardState.selectIndex(root.index);
        }

        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                if (root.itemData && root.itemData.id) {
                    root.clipboardState.deleteItem(root.itemData.id);
                }
            } else {
                root.clipboardState.selectIndex(root.index);
                root.clipboardState.activateCurrentItem();
            }
        }
    }
}
