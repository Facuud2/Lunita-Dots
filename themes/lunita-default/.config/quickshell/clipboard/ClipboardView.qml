import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Item {
    id: root

    required property var clipboardState
    property alias searchInput: searchField

    implicitWidth: 460
    implicitHeight: 480
    width: 460
    height: 480

    readonly property int itemCount: (root.clipboardState.clipboardList && root.clipboardState.clipboardList.length)
        ? root.clipboardState.clipboardList.length
        : 0

    // ── Main Floating Panel (.cliphist-panel) ──
    Rectangle {
        id: mainCard
        anchors.fill: parent
        radius: 22
        color: root.clipboardState.panelBgColor
        border.color: root.clipboardState.panelBorderColor
        border.width: 1.5

        // Subtle inner rim highlight for vivid depth
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: 21
            color: "transparent"
            border.color: root.clipboardState.panelInnerBorderColor
            border.width: 1
        }

        // Absorb clicks inside the panel so outside click catcher doesn't trigger
        MouseArea {
            anchors.fill: parent
            hoverEnabled: false
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 0

            // ════════════════════════════════════════════════════════════
            // ── 1. CABECERA ESTILO LUNITA / NOTHING OS (.cliphist-header) ──
            // ════════════════════════════════════════════════════════════
            RowLayout {
                Layout.fillWidth: true
                Layout.bottomMargin: 12
                spacing: 10

                // Píldora de estado (.cliphist-title-pill)
                Rectangle {
                    Layout.preferredHeight: 28
                    Layout.preferredWidth: pillRow.implicitWidth + 24
                    radius: 14
                    color: root.clipboardState.titlePillBg
                    border.color: root.clipboardState.titlePillBorder
                    border.width: 1

                    RowLayout {
                        id: pillRow
                        anchors.centerIn: parent
                        spacing: 6

                        Text {
                            text: "content_paste"
                            font.family: root.clipboardState.fontIcons
                            font.pixelSize: 15
                            color: root.clipboardState.accentRedBright
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Text {
                            text: "PORTAPAPELES"
                            font.family: root.clipboardState.fontDots
                            font.pixelSize: 11
                            font.letterSpacing: 1.5
                            font.weight: Font.Bold
                            color: root.clipboardState.textColor
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Contador de elementos (.cliphist-info-badge)
                Rectangle {
                    Layout.preferredHeight: 24
                    Layout.preferredWidth: countLabel.implicitWidth + 18
                    radius: 12
                    color: root.clipboardState.infoBadgeBg
                    border.color: root.clipboardState.infoBadgeBorder
                    border.width: 1

                    Text {
                        id: countLabel
                        anchors.centerIn: parent
                        text: root.itemCount + (root.itemCount === 1 ? " elemento" : " elementos")
                        font.family: root.clipboardState.fontUi
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: root.clipboardState.textColor
                    }
                }

                // Botón para vaciar todo el historial (.cliphist-clear-btn)
                Rectangle {
                    id: clearBtn
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    radius: 14
                    color: clearMouse.containsMouse
                        ? root.clipboardState.clearBtnHoverBg
                        : root.clipboardState.headerBtnBg
                    border.color: clearMouse.containsMouse
                        ? root.clipboardState.clearBtnHoverBorder
                        : root.clipboardState.headerBtnBorder
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 140 } }
                    Behavior on border.color { ColorAnimation { duration: 140 } }

                    Text {
                        anchors.centerIn: parent
                        text: "delete_sweep"
                        font.family: root.clipboardState.fontIcons
                        font.pixelSize: 15
                        color: clearMouse.containsMouse
                            ? root.clipboardState.accentRedBright
                            : root.clipboardState.textColor
                    }

                    MouseArea {
                        id: clearMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.clipboardState.clearAll()
                    }
                }

                // Botón de cerrar (.cliphist-close-btn)
                Rectangle {
                    id: closeBtn
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    radius: 14
                    color: closeMouse.containsMouse
                        ? root.clipboardState.headerBtnHoverBg
                        : root.clipboardState.headerBtnBg
                    border.color: closeMouse.containsMouse
                        ? root.clipboardState.headerBtnHoverBorder
                        : root.clipboardState.headerBtnBorder
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 140 } }
                    Behavior on border.color { ColorAnimation { duration: 140 } }

                    Text {
                        anchors.centerIn: parent
                        text: "close"
                        font.family: root.clipboardState.fontIcons
                        font.pixelSize: 15
                        color: root.clipboardState.textColor
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.clipboardState.closeClipboard()
                    }
                }
            }

            // ════════════════════════════════════════════════════════════
            // ── 2. BARRA DE BÚSQUEDA (.cliphist-search-wrapper) ──
            // ════════════════════════════════════════════════════════════
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                radius: 12
                color: root.clipboardState.searchBgColor
                border.color: searchField.activeFocus
                    ? root.clipboardState.accentRedBright
                    : root.clipboardState.searchBorderColor
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 10
                    spacing: 8

                    Text {
                        text: "search"
                        font.family: root.clipboardState.fontIcons
                        font.pixelSize: 16
                        color: searchField.activeFocus
                            ? root.clipboardState.accentRedBright
                            : root.clipboardState.textDimColor
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        TextInput {
                            id: searchField
                            anchors.fill: parent
                            verticalAlignment: TextInput.AlignVCenter
                            font.family: root.clipboardState.fontUi
                            font.pixelSize: 13
                            font.weight: Font.Normal
                            color: root.clipboardState.textColor
                            selectionColor: Qt.rgba(215 / 255, 25 / 255, 33 / 255, 0.35)
                            selectedTextColor: "#FFFFFF"
                            clip: true
                            cursorVisible: root.clipboardState.isOpen

                            text: root.clipboardState.searchQuery
                            onTextChanged: {
                                if (root.clipboardState.searchQuery !== text) {
                                    root.clipboardState.searchQuery = text;
                                }
                            }

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
                            Keys.onEnterPressed: {
                                root.clipboardState.activateCurrentItem();
                            }
                            Keys.onDeletePressed: {
                                root.clipboardState.deleteCurrentItem();
                            }
                            Keys.onEscapePressed: {
                                if (searchField.text.length > 0) {
                                    root.clipboardState.searchQuery = "";
                                    root.clipboardState.selectedIndex = 0;
                                } else {
                                    root.clipboardState.closeClipboard();
                                }
                            }
                            Keys.onPressed: event => {
                                if ((event.key === Qt.Key_V) && (event.modifiers & Qt.MetaModifier)) {
                                    root.clipboardState.closeClipboard();
                                    event.accepted = true;
                                }
                            }

                            Text {
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                visible: searchField.text.length === 0
                                text: "Buscar en el historial..."
                                font.family: root.clipboardState.fontUi
                                font.pixelSize: 13
                                color: root.clipboardState.textFaintColor
                            }
                        }
                    }

                    // Botón para limpiar búsqueda (.cliphist-search-clear)
                    Rectangle {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        radius: 10
                        color: "transparent"
                        visible: searchField.text.length > 0
                        opacity: searchField.text.length > 0 ? 1.0 : 0.0

                        Text {
                            anchors.centerIn: parent
                            text: "close"
                            font.family: root.clipboardState.fontIcons
                            font.pixelSize: 13
                            color: clearSearchMouse.containsMouse
                                ? root.clipboardState.textColor
                                : root.clipboardState.textDimColor
                        }

                        MouseArea {
                            id: clearSearchMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.clipboardState.searchQuery = "";
                                root.clipboardState.selectedIndex = 0;
                                searchField.forceActiveFocus();
                            }
                        }
                    }
                }
            }

            // ════════════════════════════════════════════════════════════
            // ── 3. SEPARADOR (.cliphist-separator) ──
            // ════════════════════════════════════════════════════════════
            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: 10
                Layout.bottomMargin: 8
                implicitHeight: 1
                color: root.clipboardState.dividerColor
            }

            // ════════════════════════════════════════════════════════════
            // ── 4. LISTA DESPLAZABLE DE ELEMENTOS (.cliphist-scroll-area) ──
            // ════════════════════════════════════════════════════════════
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ListView {
                    id: listView
                    anchors.fill: parent
                    spacing: 4
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
                            color: Qt.rgba(1, 1, 1, 0.22)
                            opacity: vbar.active ? 1.0 : 0.0
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }
                    }
                }

                // Estado Vacío (.cliphist-empty-box)
                ColumnLayout {
                    anchors.centerIn: parent
                    visible: root.itemCount === 0
                    spacing: 8

                    Text {
                        text: "content_paste"
                        font.family: root.clipboardState.fontIcons
                        font.pixelSize: 38
                        color: root.clipboardState.textFaintColor
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: root.clipboardState.searchQuery.length > 0
                            ? "No se encontraron coincidencias"
                            : "Historial de portapapeles vacío"
                        font.family: root.clipboardState.fontUi
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: root.clipboardState.textDimColor
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "Copia texto o capturas para guardarlos automáticamente"
                        font.family: root.clipboardState.fontUi
                        font.pixelSize: 11
                        color: root.clipboardState.textFaintColor
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            // ════════════════════════════════════════════════════════════
            // ── 5. PIE CON ATAJOS DE TECLADO (.cliphist-footer) ──
            // ════════════════════════════════════════════════════════════
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 10
                Layout.alignment: Qt.AlignHCenter
                spacing: 14

                Item { Layout.fillWidth: true }

                Repeater {
                    model: [
                        { key: "↑↓", label: "Navegar" },
                        { key: "↵", label: "Copiar y Pegar" },
                        { key: "Supr", label: "Borrar" },
                        { key: "Esc", label: "Cerrar" }
                    ]

                    delegate: RowLayout {
                        required property var modelData
                        spacing: 4

                        Rectangle {
                            Layout.preferredHeight: 18
                            Layout.preferredWidth: keyLabel.implicitWidth + 10
                            radius: 5
                            color: root.clipboardState.keyPillBg
                            border.color: root.clipboardState.keyPillBorder
                            border.width: 1

                            Text {
                                id: keyLabel
                                anchors.centerIn: parent
                                text: modelData.key
                                font.family: root.clipboardState.fontDots
                                font.pixelSize: 9
                                color: root.clipboardState.textColor
                            }
                        }

                        Text {
                            text: modelData.label
                            font.family: root.clipboardState.fontUi
                            font.pixelSize: 11
                            color: root.clipboardState.textDimColor
                        }
                    }
                }

                Item { Layout.fillWidth: true }
            }
        }
    }

    // Auto focus search field when opened
    Connections {
        target: root.clipboardState
        function onIsOpenChanged() {
            if (root.clipboardState.isOpen) {
                searchField.forceActiveFocus();
            }
        }
    }
}
