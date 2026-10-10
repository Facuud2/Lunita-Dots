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

    implicitWidth: parent ? parent.width : 540
    implicitHeight: 48

    // ── Selection / Hover Pill Background ──
    Rectangle {
        id: pillBg
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        anchors.topMargin: 1
        anchors.bottomMargin: 1
        radius: 10
        visible: root.isSelected || itemMouseArea.containsMouse
        color: root.isSelected
            ? root.clipboardState.selectedBgColor
            : root.clipboardState.itemHoverBg
        border.color: root.isSelected
            ? root.clipboardState.selectedBorderColor
            : "transparent"
        border.width: 1

        Behavior on color {
            ColorAnimation { duration: 80 }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        spacing: 12

        // ── Item Type / App Icon ──
        Item {
            implicitWidth: 30
            implicitHeight: 30
            Layout.alignment: Qt.AlignVCenter

            // If it is an image with thumbnail
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
                        width: 30
                        height: 30
                        radius: 6
                    }
                }
            }

            // Normal SVG Icon
            Image {
                id: svgIcon
                visible: !thumbImg.visible
                anchors.centerIn: parent
                width: 28
                height: 28
                source: {
                    if (!root.itemData) return "assets/document.svg";
                    var iconName = root.itemData.icon || "document";
                    switch(iconName) {
                        case "safari": return "assets/safari.svg";
                        case "photo": return "assets/photo.svg";
                        case "terminal": return "assets/terminal.svg";
                        case "code": return "assets/code.svg";
                        default: return "assets/document.svg";
                    }
                }
                sourceSize.width: 56
                sourceSize.height: 56
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
            }
        }

        // ── Text Title & Subtitle Column ──
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                text: (root.itemData && root.itemData.title) ? root.itemData.title : ""
                color: root.isSelected ? root.clipboardState.selectedTextColor : root.clipboardState.textColor
                font.family: "SF Pro Display, Inter, -apple-system, sans-serif"
                font.styleName: "Regular"
                font.pixelSize: 13
                font.weight: Font.Medium
                font.italic: false
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: (root.itemData && root.itemData.subtitle) ? root.itemData.subtitle : ""
                color: root.isSelected ? root.clipboardState.selectedSubColor : root.clipboardState.textDimColor
                font.family: "SF Pro Display, Inter, -apple-system, sans-serif"
                font.styleName: "Regular"
                font.pixelSize: 11
                font.weight: Font.Normal
                font.italic: false
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        // ── Right Action Buttons (Delete "✕" & Copy Badge) ──
        RowLayout {
            implicitHeight: 24
            Layout.alignment: Qt.AlignVCenter
            spacing: 6

            // ── ✕ Delete Button ──
            Rectangle {
                id: deleteBtn
                implicitWidth: 22
                implicitHeight: 22
                radius: 11
                color: deleteBtnMouse.containsMouse
                    ? Qt.rgba(0.85, 0.18, 0.18, 0.90)
                    : (root.isSelected ? Qt.rgba(5, 59, 85, 0.22) : Qt.rgba(5, 59, 85, 0.12))

                opacity: (root.isSelected || itemMouseArea.containsMouse || deleteBtnMouse.containsMouse) ? 1.0 : 0.40
                scale: deleteBtnMouse.pressed ? 0.90 : (deleteBtnMouse.containsMouse ? 1.08 : 1.0)

                Behavior on opacity {
                    NumberAnimation { duration: 100 }
                }
                Behavior on scale {
                    NumberAnimation { duration: 80 }
                }
                Behavior on color {
                    ColorAnimation { duration: 80 }
                }

                Text {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -0.5
                    text: "✕"
                    font.family: "SF Pro Display, Inter, -apple-system, sans-serif"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    color: deleteBtnMouse.containsMouse ? "#FFFFFF" : root.clipboardState.textColor
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

            // ── Copy Badge ──
            Rectangle {
                id: copyBtn
                implicitWidth: 22
                implicitHeight: 22
                radius: 11
                color: copyBtnMouse.containsMouse
                    ? Qt.rgba(5, 59, 85, 0.55)
                    : root.clipboardState.copyBtnBg

                scale: copyBtnMouse.pressed ? 0.90 : (copyBtnMouse.containsMouse ? 1.08 : 1.0)
                Behavior on scale {
                    NumberAnimation { duration: 80 }
                }

                Image {
                    anchors.centerIn: parent
                    width: 12
                    height: 12
                    source: "assets/copy.svg"
                    sourceSize.width: 24
                    sourceSize.height: 24
                    fillMode: Image.PreserveAspectFit
                    smooth: true
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
        }
    }

    // ── Row MouseArea for Row Selection / Click-to-Paste ──
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
