import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Item {
    id: root

    required property var spotlightState
    property alias searchInput: searchField

    implicitWidth: 680
    implicitHeight: mainCard.height
    width: 680
    height: 460

    // ── Deep Ambient Shadow ──
    RectangularGlow {
        anchors.fill: mainCard
        anchors.topMargin: 8
        glowRadius: 36
        spread: 0.15
        color: root.spotlightState.panelShadowColor
        cornerRadius: mainCard.radius + glowRadius
    }

    // ── Main Frosted Glass Card ──
    Rectangle {
        id: mainCard
        anchors.fill: parent
        radius: 20
        color: root.spotlightState.panelBgColor
        border.color: root.spotlightState.panelBorderColor
        border.width: 1

        // Smooth Appearance Animation
        scale: root.spotlightState.isOpen ? 1.0 : 0.94
        opacity: root.spotlightState.isOpen ? 1.0 : 0.0
        visible: opacity > 0.01

        transform: Translate {
            y: root.spotlightState.isOpen ? 0 : -20
            Behavior on y {
                NumberAnimation {
                    duration: root.spotlightState.isOpen ? 220 : 160
                    easing.type: root.spotlightState.isOpen ? Easing.OutCubic : Easing.InCubic
                }
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: root.spotlightState.isOpen ? 220 : 160
                easing.type: root.spotlightState.isOpen ? Easing.OutCubic : Easing.InCubic
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: root.spotlightState.isOpen ? 180 : 130
                easing.type: Easing.OutQuad
            }
        }

        // Inner Specular Sheen Border
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: 19
            color: "transparent"
            border.color: root.spotlightState.panelInnerSheen
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ════════════════════════════════════════════════════════════
            // ── TOP SEARCH BAR ──
            // ════════════════════════════════════════════════════════════
            Item {
                Layout.fillWidth: true
                implicitHeight: 56

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18
                    spacing: 14

                    // Spotlight Search Icon
                    Image {
                        source: "assets/spotlight.svg"
                        sourceSize.width: 44
                        sourceSize.height: 44
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 22
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }

                    // Main Search Input Field
                    TextInput {
                        id: searchField
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        text: root.spotlightState.searchQuery
                        color: root.spotlightState.searchInputText
                        font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                        font.pixelSize: 18
                        font.weight: Font.Normal
                        selectByMouse: true
                        selectionColor: root.spotlightState.selectedBgColor
                        selectedTextColor: "#FFFFFF"
                        focus: true
                        clip: true

                        onTextChanged: {
                            if (root.spotlightState.searchQuery !== text) {
                                root.spotlightState.searchQuery = text;
                            }
                        }

                        // Placeholder
                        Text {
                            anchors.fill: parent
                            anchors.verticalCenter: parent.verticalCenter
                            visible: !searchField.text && !searchField.inputMethodComposing
                            text: "Spotlight Search..."
                            color: root.spotlightState.searchPlaceholderText
                            font: searchField.font
                        }

                        // Keyboard Navigation Handling
                        Keys.onDownPressed: event => {
                            root.spotlightState.moveSelectionDown();
                            event.accepted = true;
                        }

                        Keys.onUpPressed: event => {
                            root.spotlightState.moveSelectionUp();
                            event.accepted = true;
                        }

                        Keys.onReturnPressed: event => {
                            if (event.modifiers & (Qt.ControlModifier | Qt.MetaModifier)) {
                                root.spotlightState.revealCurrentItem();
                            } else {
                                root.spotlightState.activateCurrentItem();
                            }
                            event.accepted = true;
                        }

                        Keys.onEnterPressed: event => {
                            if (event.modifiers & (Qt.ControlModifier | Qt.MetaModifier)) {
                                root.spotlightState.revealCurrentItem();
                            } else {
                                root.spotlightState.activateCurrentItem();
                            }
                            event.accepted = true;
                        }

                        Keys.onEscapePressed: event => {
                            root.spotlightState.closeSpotlight();
                            event.accepted = true;
                        }

                        Keys.onTabPressed: event => {
                            root.spotlightState.moveSelectionDown();
                            event.accepted = true;
                        }

                        Keys.onBacktabPressed: event => {
                            root.spotlightState.moveSelectionUp();
                            event.accepted = true;
                        }
                    }

                    // Clear Text Button (×)
                    Rectangle {
                        visible: searchField.text.length > 0
                        implicitWidth: 20
                        implicitHeight: 20
                        radius: 10
                        color: clearMouse.containsMouse ? (root.spotlightState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(0, 0, 0, 0.18)) : (root.spotlightState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(0, 0, 0, 0.08))

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: root.spotlightState.textColor
                            font.pixelSize: 10
                            font.weight: Font.Bold
                        }

                        MouseArea {
                            id: clearMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                searchField.text = "";
                                searchField.forceActiveFocus();
                            }
                        }
                    }
                }
            }

            // Horizontal Divider
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: root.spotlightState.dividerColor
            }

            // ════════════════════════════════════════════════════════════
            // ── BODY: TWO-PANE RESULTS & INSPECTOR ──
            // ════════════════════════════════════════════════════════════
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                // ── Left Pane: Results List ──
                Item {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 380
                    Layout.minimumWidth: 340

                    ListView {
                        id: resultsListView
                        anchors.fill: parent
                        anchors.topMargin: 6
                        anchors.bottomMargin: 6
                        clip: true
                        model: root.spotlightState.resultsList
                        boundsBehavior: Flickable.StopAtBounds

                        // Keep selection visible in scroll
                        currentIndex: root.spotlightState.selectedIndex
                        onCurrentIndexChanged: {
                            positionViewAtIndex(currentIndex, ListView.Contain);
                        }

                        // Section Header Support
                        section.property: "category"
                        section.criteria: ViewSection.FullString
                        section.delegate: Item {
                            width: resultsListView.width
                            implicitHeight: 22

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 18
                                anchors.verticalCenter: parent.verticalCenter
                                text: section
                                color: root.spotlightState.categoryHeaderColor
                                font.family: "SF Pro Text, Inter, -apple-system, system-ui, sans-serif"
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                font.letterSpacing: 0.5
                            }
                        }

                        delegate: SpotlightItem {
                            width: resultsListView.width
                            spotlightState: root.spotlightState
                        }

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                            width: 5
                            anchors.right: resultsListView.right
                            anchors.rightMargin: 2
                        }
                    }
                }

                // Vertical Divider
                Rectangle {
                    Layout.fillHeight: true
                    implicitWidth: 1
                    color: root.spotlightState.dividerColor
                }

                // ── Right Pane: Inspector / Preview ──
                SpotlightPreview {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spotlightState: root.spotlightState
                }
            }

            // Horizontal Divider
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: root.spotlightState.dividerColor
            }

            // ════════════════════════════════════════════════════════════
            // ── BOTTOM FOOTER / KEYBOARD SHORTCUTS HINT ──
            // ════════════════════════════════════════════════════════════
            Item {
                Layout.fillWidth: true
                implicitHeight: 28

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18
                    spacing: 16

                    RowLayout {
                        spacing: 4
                        Text { text: "↵"; color: root.spotlightState.textDimColor; font.pixelSize: 11; font.weight: Font.Bold }
                        Text { text: "Open"; color: root.spotlightState.textDimColor; font.pixelSize: 10 }
                    }

                    RowLayout {
                        spacing: 4
                        Text { text: "⌘↵"; color: root.spotlightState.textDimColor; font.pixelSize: 11; font.weight: Font.Bold }
                        Text { text: "In Finder"; color: root.spotlightState.textDimColor; font.pixelSize: 10 }
                    }

                    RowLayout {
                        spacing: 4
                        Text { text: "↑↓"; color: root.spotlightState.textDimColor; font.pixelSize: 11; font.weight: Font.Bold }
                        Text { text: "Navigate"; color: root.spotlightState.textDimColor; font.pixelSize: 10 }
                    }

                    Item { Layout.fillWidth: true }

                    RowLayout {
                        spacing: 4
                        Text { text: "⎋"; color: root.spotlightState.textDimColor; font.pixelSize: 11; font.weight: Font.Bold }
                        Text { text: "Close"; color: root.spotlightState.textDimColor; font.pixelSize: 10 }
                    }
                }
            }
        }
    }

    // Auto focus search field when opened
    Connections {
        target: root.spotlightState
        function onIsOpenChanged() {
            if (root.spotlightState.isOpen) {
                searchField.forceActiveFocus();
                searchField.selectAll();
            }
        }
    }
}
