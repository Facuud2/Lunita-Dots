import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray

Item {
    id: root
    required property var barState

    visible: barState.activePopup === "traymenu" && !!barState.activeTrayItem
    x: Math.max(10, Math.min(parent.width - width - 10, barState.popupX + 24 - width))
    y: 4
    z: 10
    width: 220
    implicitHeight: Math.min(520, menuFlickable.contentHeight + 16)
    height: implicitHeight

    opacity: visible ? 1 : 0
    scale: visible ? 1 : 0.96
    Behavior on opacity { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }
    Behavior on scale { NumberAnimation { duration: 130; easing.type: Easing.OutCubic } }

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: barState.popupBgColor
        border.color: barState.popupBorderColor
        border.width: 1

        Behavior on color { ColorAnimation { duration: 200 } }
        Behavior on border.color { ColorAnimation { duration: 200 } }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: 11
            color: "transparent"
            border.color: Qt.rgba(0, 0, 0, barState.isDarkTheme ? 0.35 : 0.12)
            border.width: 1
            z: -1
        }
    }

    QsMenuOpener {
        id: menuOpener
        menu: (barState.activeTrayItem && barState.activeTrayItem.menu) ? barState.activeTrayItem.menu : null
    }

    function cleanLabel(raw) {
        if (!raw) return "";
        return raw.replace(/_([a-zA-Z0-9])/g, "$1").replace(/&([a-zA-Z0-9])/g, "$1").trim();
    }

    Flickable {
        id: menuFlickable
        anchors.fill: parent
        anchors.margins: 8
        contentHeight: mainLayout.implicitHeight
        clip: true
        interactive: contentHeight > height

        ColumnLayout {
            id: mainLayout
            width: parent.width
            spacing: 2

            // ── App Header ──
            Item {
                Layout.fillWidth: true
                implicitHeight: 26
                height: implicitHeight

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 6
                    anchors.rightMargin: 6
                    spacing: 8

                    Image {
                        visible: !!(barState.activeTrayIconSource && barState.activeTrayIconSource !== "")
                        source: barState.activeTrayIconSource
                        sourceSize.width: 16
                        sourceSize.height: 16
                        width: 16
                        height: 16
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                    }

                    Text {
                        Layout.fillWidth: true
                        text: barState.activeTrayTitle
                        color: barState.popupTextDim
                        font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                        font.pixelSize: 12
                        font.bold: true
                        elide: Text.ElideRight
                    }
                }
            }

            // Divider under Header
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 7
                height: 7
                color: "transparent"
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width
                    height: 1
                    color: barState.popupSeparatorColor
                }
            }

            // ── DBusMenu Items (Nativo de la aplicación) ──
            Repeater {
                model: menuOpener.children
                delegate: ColumnLayout {
                    id: entryDelegate
                    required property var modelData
                    required property int index
                    property bool isExpanded: false

                    readonly property bool isSep: modelData.isSeparator || !modelData.text || modelData.text.trim().length === 0
                    readonly property string displayLabel: root.cleanLabel(modelData.text)

                    Layout.fillWidth: true
                    spacing: 2

                    // Separator line
                    Item {
                        visible: entryDelegate.isSep
                        Layout.fillWidth: true
                        implicitHeight: 7
                        height: 7

                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width
                            height: 1
                            color: root.barState.popupSeparatorColor
                        }
                    }

                    // Interactive Menu Item
                    Rectangle {
                        visible: !entryDelegate.isSep
                        Layout.fillWidth: true
                        implicitHeight: 24
                        height: implicitHeight
                        radius: 6
                        color: (itemMouseArea.containsMouse && modelData.enabled) ? "#007AFF" : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 6

                            // Checkbox / Radio indicator
                            Text {
                                visible: modelData.buttonType !== undefined && modelData.buttonType !== QsMenuButtonType.None
                                text: modelData.buttonType === QsMenuButtonType.CheckBox
                                    ? (modelData.checkState === Qt.Checked ? "✓" : "")
                                    : (modelData.checkState === Qt.Checked ? "●" : "")
                                color: (itemMouseArea.containsMouse && modelData.enabled) ? "#FFFFFF" : root.barState.popupTextColor
                                font.pixelSize: 11
                                font.bold: true
                                width: 14
                            }

                            // Optional Icon
                            Image {
                                visible: !!(modelData.icon && modelData.icon.length > 0)
                                source: (modelData.icon && modelData.icon.startsWith("/"))
                                    ? ("file://" + modelData.icon)
                                    : (modelData.icon ? ("image://icon/" + modelData.icon) : "")
                                sourceSize.width: 14
                                sourceSize.height: 14
                                width: 14
                                height: 14
                                fillMode: Image.PreserveAspectFit
                            }

                            // Item Label
                            Text {
                                Layout.fillWidth: true
                                text: entryDelegate.displayLabel
                                color: !modelData.enabled
                                    ? root.barState.popupTextDim
                                    : ((itemMouseArea.containsMouse) ? "#FFFFFF" : root.barState.popupTextColor)
                                font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                                font.pixelSize: 13
                                elide: Text.ElideRight
                                Behavior on color { ColorAnimation { duration: 120 } }
                            }

                            // Submenu indicator
                            Text {
                                visible: !!modelData.hasChildren
                                text: entryDelegate.isExpanded ? "▾" : "›"
                                color: (itemMouseArea.containsMouse && modelData.enabled) ? "#FFFFFF" : root.barState.popupTextDim
                                font.pixelSize: 12
                            }
                        }

                        MouseArea {
                            id: itemMouseArea
                            anchors.fill: parent
                            hoverEnabled: modelData.enabled
                            cursorShape: modelData.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                if (!modelData.enabled) return;
                                if (modelData.hasChildren) {
                                    entryDelegate.isExpanded = !entryDelegate.isExpanded;
                                    return;
                                }
                                if (typeof modelData.sendTriggered === "function") {
                                    modelData.sendTriggered();
                                } else if (typeof modelData.triggered === "function") {
                                    modelData.triggered();
                                }
                                root.barState.closePopups();
                            }
                        }
                    }

                    // Nested Submenu (if entry has children)
                    ColumnLayout {
                        id: subMenuCol
                        visible: entryDelegate.isExpanded && !!modelData.hasChildren
                        Layout.fillWidth: true
                        Layout.leftMargin: 12
                        spacing: 2

                        QsMenuOpener {
                            id: subOpener
                            menu: modelData.hasChildren ? modelData : null
                        }

                        Repeater {
                            model: subOpener.children
                            delegate: Rectangle {
                                id: subItemRect
                                required property var modelData
                                readonly property bool isSubSep: modelData.isSeparator || !modelData.text || modelData.text.trim().length === 0
                                readonly property string subLabel: root.cleanLabel(modelData.text)

                                Layout.fillWidth: true
                                implicitHeight: isSubSep ? 7 : 22
                                height: implicitHeight
                                radius: 5
                                color: (subMouseArea.containsMouse && modelData.enabled && !isSubSep) ? "#007AFF" : "transparent"

                                Rectangle {
                                    visible: subItemRect.isSubSep
                                    anchors.centerIn: parent
                                    width: parent.width
                                    height: 1
                                    color: root.barState.popupSeparatorColor
                                }

                                RowLayout {
                                    visible: !subItemRect.isSubSep
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    spacing: 6

                                    Text {
                                        Layout.fillWidth: true
                                        text: subItemRect.subLabel
                                        color: !modelData.enabled
                                            ? root.barState.popupTextDim
                                            : ((subMouseArea.containsMouse) ? "#FFFFFF" : root.barState.popupTextColor)
                                        font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                                        font.pixelSize: 12
                                        elide: Text.ElideRight
                                    }
                                }

                                MouseArea {
                                    id: subMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: modelData.enabled && !subItemRect.isSubSep
                                    cursorShape: (modelData.enabled && !subItemRect.isSubSep) ? Qt.PointingHandCursor : Qt.ArrowCursor
                                    onClicked: {
                                        if (subItemRect.isSubSep || !modelData.enabled) return;
                                        if (typeof modelData.sendTriggered === "function") {
                                            modelData.sendTriggered();
                                        } else if (typeof modelData.triggered === "function") {
                                            modelData.triggered();
                                        }
                                        root.barState.closePopups();
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ── Fallback Items when DBusMenu is empty or unavailable ──
            ColumnLayout {
                visible: (!menuOpener.children || !menuOpener.children.values || menuOpener.children.values.length === 0)
                Layout.fillWidth: true
                spacing: 2

                // Open App
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 24
                    height: implicitHeight
                    radius: 6
                    color: fbOpenMouse.containsMouse ? "#007AFF" : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8

                        Text {
                            Layout.fillWidth: true
                            text: "Abrir " + root.barState.activeTrayTitle
                            color: fbOpenMouse.containsMouse ? "#FFFFFF" : root.barState.popupTextColor
                            font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                            font.pixelSize: 13
                        }
                    }

                    MouseArea {
                        id: fbOpenMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.barState.activeTrayItem) {
                                root.barState.activeTrayItem.activate();
                            }
                            root.barState.closePopups();
                        }
                    }
                }

                // Secondary Action
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 24
                    height: implicitHeight
                    radius: 6
                    color: fbSecMouse.containsMouse ? "#007AFF" : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8

                        Text {
                            Layout.fillWidth: true
                            text: "Acción secundaria"
                            color: fbSecMouse.containsMouse ? "#FFFFFF" : root.barState.popupTextColor
                            font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                            font.pixelSize: 13
                        }
                    }

                    MouseArea {
                        id: fbSecMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.barState.activeTrayItem) {
                                root.barState.activeTrayItem.secondaryActivate();
                            }
                            root.barState.closePopups();
                        }
                    }
                }

                // Separator
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 7
                    height: 7
                    color: "transparent"
                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width
                        height: 1
                        color: root.barState.popupSeparatorColor
                    }
                }

                // Close Menu
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 24
                    height: implicitHeight
                    radius: 6
                    color: fbCloseMouse.containsMouse ? "#007AFF" : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8

                        Text {
                            Layout.fillWidth: true
                            text: "Cerrar menú"
                            color: fbCloseMouse.containsMouse ? "#FFFFFF" : root.barState.popupTextDim
                            font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                            font.pixelSize: 13
                        }
                    }

                    MouseArea {
                        id: fbCloseMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.barState.closePopups();
                        }
                    }
                }
            }
        }
    }
}
