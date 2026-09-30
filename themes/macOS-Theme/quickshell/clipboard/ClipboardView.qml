import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Item {
    id: root

    required property var clipboardState
    property alias searchInput: searchField

    implicitWidth: 540
    implicitHeight: 490
    width: 540
    height: 490

    // ── Main Frosted Glass Card ──
    Rectangle {
        id: mainCard
        anchors.fill: parent
        radius: 22
        color: root.clipboardState.panelBgColor
        border.color: root.clipboardState.panelBorderColor
        border.width: 1

        // Inner Specular Sheen Border
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: 21
            color: "transparent"
            border.color: root.clipboardState.panelInnerSheen
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ════════════════════════════════════════════════════════════
            // ── TOP HEADER / SEARCH BAR ──
            // ════════════════════════════════════════════════════════════
            Item {
                Layout.fillWidth: true
                implicitHeight: 50

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18
                    spacing: 12

                    // Top Left Clipboard Icon (Deep Teal Outline)
                    Image {
                        source: "assets/clipboard-header.svg"
                        sourceSize.width: 44
                        sourceSize.height: 44
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 22
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }

                    // Search Field & Title
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        TextInput {
                            id: searchField
                            anchors.fill: parent
                            verticalAlignment: TextInput.AlignVCenter
                            font.family: "SF Pro Display, Inter, -apple-system, sans-serif"
                            font.styleName: "Regular"
                            font.pixelSize: 18
                            font.weight: Font.Medium
                            font.italic: false
                            color: root.clipboardState.textColor
                            selectionColor: Qt.rgba(5, 59, 85, 0.25)
                            selectedTextColor: root.clipboardState.textColor
                            clip: true
                            cursorVisible: root.clipboardState.isOpen

                            text: root.clipboardState.searchQuery
                            onTextChanged: {
                                if (root.clipboardState.searchQuery !== text) {
                                    root.clipboardState.searchQuery = text;
                                }
                            }

                            // Keys handling
                            Keys.onDownPressed: {
                                root.clipboardState.moveSelectionDown();
                                listView.positionViewAtIndex(root.clipboardState.selectedIndex, ListView.Contain);
                            }
                            Keys.onUpPressed: {
                                root.clipboardState.moveSelectionUp();
                                listView.positionViewAtIndex(root.clipboardState.selectedIndex, ListView.Contain);
                            }
                            Keys.onReturnPressed: {
                                root.clipboardState.activateCurrentItem();
                            }
                            Keys.onEscapePressed: {
                                if (contextMenu.visible) {
                                    contextMenu.visible = false;
                                } else {
                                    root.clipboardState.closeClipboard();
                                }
                            }
                            Keys.onDeletePressed: {
                                root.clipboardState.deleteCurrentItem();
                            }

                            // Placeholder Text "Clipboard"
                            Text {
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                visible: searchField.text.length === 0
                                text: "Clipboard"
                                font.family: searchField.font.family
                                font.pixelSize: searchField.font.pixelSize
                                font.weight: searchField.font.weight
                                font.italic: false
                                color: root.clipboardState.textColor
                                opacity: 0.85
                            }
                        }
                    }

                    // Top Right More Actions Button (···)
                    Item {
                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 26
                        Layout.alignment: Qt.AlignVCenter

                        Rectangle {
                            id: moreBtnBg
                            anchors.fill: parent
                            radius: 13
                            color: moreBtnMouse.containsMouse
                                ? Qt.rgba(255, 255, 255, 0.28)
                                : "transparent"

                            Image {
                                anchors.centerIn: parent
                                width: 22
                                height: 22
                                source: "assets/more.svg"
                                sourceSize.width: 44
                                sourceSize.height: 44
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                            }

                            MouseArea {
                                id: moreBtnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    contextMenu.visible = !contextMenu.visible;
                                }
                            }
                        }
                    }
                }
            }

            // Subtle Divider Line below Header
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: root.clipboardState.dividerColor
            }

            // ════════════════════════════════════════════════════════════
            // ── CLIPBOARD ITEMS LIST ──
            // ════════════════════════════════════════════════════════════
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListView {
                    id: listView
                    anchors.fill: parent
                    anchors.topMargin: 4
                    anchors.bottomMargin: 8
                    clip: true
                    model: root.clipboardState.clipboardList
                    currentIndex: root.clipboardState.selectedIndex

                    boundsBehavior: Flickable.StopAtBounds

                    delegate: ClipboardItem {
                        width: listView.width
                        clipboardState: root.clipboardState
                    }

                    ScrollBar.vertical: ScrollBar {
                        id: vbar
                        active: listView.moving || listView.flicking
                        policy: ScrollBar.AsNeeded
                        contentItem: Rectangle {
                            implicitWidth: 4
                            radius: 2
                            color: Qt.rgba(5, 59, 85, 0.28)
                            opacity: vbar.active ? 1.0 : 0.0
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }
                    }
                }

                // Empty State
                ColumnLayout {
                    anchors.centerIn: parent
                    visible: !root.clipboardState.clipboardList || root.clipboardState.clipboardList.length === 0
                    spacing: 8

                    Image {
                        source: "assets/clipboard-header.svg"
                        Layout.preferredWidth: 36
                        Layout.preferredHeight: 36
                        Layout.alignment: Qt.AlignHCenter
                        opacity: 0.45
                        fillMode: Image.PreserveAspectFit
                    }

                    Text {
                        text: root.clipboardState.searchQuery.length > 0
                            ? "Sin resultados para \"" + root.clipboardState.searchQuery + "\""
                            : "Historial de portapapeles vacío"
                        font.family: "SF Pro Text, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: root.clipboardState.textDimColor
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }

        // ════════════════════════════════════════════════════════════
        // ── FLOATING CONTEXT MENU (···) ──
        // ════════════════════════════════════════════════════════════
        Rectangle {
            id: contextMenu
            visible: false
            width: 210
            height: menuColumn.implicitHeight + 16
            anchors.top: parent.top
            anchors.topMargin: 48
            anchors.right: parent.right
            anchors.rightMargin: 16
            radius: 12
            color: root.clipboardState.menuBgColor
            border.color: root.clipboardState.menuBorderColor
            border.width: 1
            z: 100

            RectangularGlow {
                anchors.fill: parent
                glowRadius: 16
                spread: 0.1
                color: root.clipboardState.panelShadowColor
                cornerRadius: parent.radius + glowRadius
                z: -1
            }

            Column {
                id: menuColumn
                anchors.fill: parent
                anchors.margins: 6
                spacing: 2

                // Item: Copy Selected
                Rectangle {
                    width: parent.width
                    height: 28
                    radius: 6
                    color: copyMouse.containsMouse ? Qt.rgba(5, 59, 85, 0.10) : "transparent"
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        Text {
                            text: "Copiar seleccionado"
                            color: root.clipboardState.textColor
                            font.pixelSize: 12
                            font.family: "SF Pro Text, system-ui, sans-serif"
                            Layout.fillWidth: true
                        }
                        Text {
                            text: "↵"
                            color: root.clipboardState.textDimColor
                            font.pixelSize: 12
                        }
                    }
                    MouseArea {
                        id: copyMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            contextMenu.visible = false;
                            root.clipboardState.activateCurrentItem();
                        }
                    }
                }

                // Item: Delete Selected
                Rectangle {
                    width: parent.width
                    height: 28
                    radius: 6
                    color: delMouse.containsMouse ? Qt.rgba(5, 59, 85, 0.10) : "transparent"
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        Text {
                            text: "Eliminar elemento"
                            color: root.clipboardState.textColor
                            font.pixelSize: 12
                            font.family: "SF Pro Text, system-ui, sans-serif"
                            Layout.fillWidth: true
                        }
                        Text {
                            text: "⌫"
                            color: root.clipboardState.textDimColor
                            font.pixelSize: 12
                        }
                    }
                    MouseArea {
                        id: delMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            contextMenu.visible = false;
                            root.clipboardState.deleteCurrentItem();
                        }
                    }
                }

                // Divider
                Rectangle {
                    width: parent.width
                    height: 1
                    color: root.clipboardState.dividerColor
                }

                // Item: Clear All
                Rectangle {
                    width: parent.width
                    height: 28
                    radius: 6
                    color: wipeMouse.containsMouse ? Qt.rgba(215, 0, 21, 0.15) : "transparent"
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        Text {
                            text: "Limpiar todo el historial"
                            color: "#D70015"
                            font.pixelSize: 12
                            font.family: "SF Pro Text, system-ui, sans-serif"
                            Layout.fillWidth: true
                        }
                    }
                    MouseArea {
                        id: wipeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            contextMenu.visible = false;
                            root.clipboardState.clearAll();
                        }
                    }
                }
            }
        }
    }

    // Auto focus search field when opened
    Connections {
        target: root.clipboardState
        function onIsOpenChanged() {
            if (root.clipboardState.isOpen) {
                searchField.forceActiveFocus();
            } else {
                contextMenu.visible = false;
            }
        }
    }
}
