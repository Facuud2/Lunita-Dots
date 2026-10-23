import QtQuick
import QtQuick.Controls

Item {
    id: root

    required property var launcherState
    property alias searchInputField: searchInput

    width: parent ? parent.width : 540
    height: 82

    Column {
        anchors.fill: parent
        spacing: 12

        // ── Top Title Row: [App Store Icon] Apps ... [Grid Toggle] ──
        Item {
            width: parent.width
            height: 32

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                // App Store / Apps Icon
                Image {
                    source: Qt.resolvedUrl("assets/icons/appstore.svg")
                    width: 26
                    height: 26
                    anchors.verticalCenter: parent.verticalCenter
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

                // Title
                Text {
                    text: launcherState.activeViewMode === "detail" && launcherState.activeCategoryDetail ? launcherState.activeCategoryDetail.displayName : (launcherState.activeViewMode === "all" ? "Todas las Apps" : "Apps")
                    anchors.verticalCenter: parent.verticalCenter
                    color: launcherState.headerTitleColor
                    font.pixelSize: 19
                    font.weight: Font.DemiBold
                    font.italic: false
                    font.family: "SF Pro Display, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, sans-serif"
                }

            }

            // Right Action Controls: Back button or Grid/Category Switcher
            Row {
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                // Back Button (when in detail view)
                Rectangle {
                    visible: launcherState.activeViewMode === "detail"
                    width: backText.implicitWidth + 18
                    height: 28
                    radius: 8
                    color: backMouse.containsMouse ? launcherState.appHoverBg : "transparent"
                    border.color: backMouse.containsMouse ? launcherState.searchBorderColor : "transparent"
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            text: "‹"
                            color: launcherState.categoryActionColor
                            font.pixelSize: 16
                            font.weight: Font.Bold
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            id: backText

                            text: "Categorías"
                            color: launcherState.categoryActionColor
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            font.family: "SF Pro Text, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, sans-serif"
                            anchors.verticalCenter: parent.verticalCenter
                        }

                    }

                    MouseArea {
                        id: backMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: launcherState.backToCategories()
                    }

                }

                // Grid / Categorized Toggle Button (matching `[ ] [ ] v` in reference)
                Rectangle {
                    width: 32
                    height: 28
                    radius: 8
                    color: gridToggleMouse.containsMouse ? launcherState.appHoverBg : "transparent"
                    border.color: gridToggleMouse.containsMouse ? launcherState.searchBorderColor : "transparent"
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 3

                        // 4-dot Grid Icon
                        Column {
                            spacing: 2
                            anchors.verticalCenter: parent.verticalCenter

                            Row {
                                spacing: 2

                                Rectangle {
                                    width: 4
                                    height: 4
                                    radius: 1
                                    color: launcherState.headerSubColor
                                }

                                Rectangle {
                                    width: 4
                                    height: 4
                                    radius: 1
                                    color: launcherState.headerSubColor
                                }

                            }

                            Row {
                                spacing: 2

                                Rectangle {
                                    width: 4
                                    height: 4
                                    radius: 1
                                    color: launcherState.headerSubColor
                                }

                                Rectangle {
                                    width: 4
                                    height: 4
                                    radius: 1
                                    color: launcherState.headerSubColor
                                }

                            }

                        }

                        // Small Chevron
                        Text {
                            text: "⌄"
                            color: launcherState.headerSubColor
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            anchors.verticalCenter: parent.verticalCenter
                        }

                    }

                    MouseArea {
                        id: gridToggleMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: launcherState.toggleAllApps()
                    }

                }

            }

        }

        // ── Integrated macOS Search Field ──
        Rectangle {
            width: parent.width
            height: 36
            radius: 10
            color: launcherState.searchBgColor
            border.color: searchInput.activeFocus ? launcherState.categoryActionColor : launcherState.searchBorderColor
            border.width: 1

            Row {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                // Search Icon
                Image {
                    source: Qt.resolvedUrl("assets/icons/search.svg")
                    width: 15
                    height: 15
                    anchors.verticalCenter: parent.verticalCenter
                    opacity: 0.5
                }

                // Search Input Field
                TextInput {
                    id: searchInput

                    width: parent.width - 48
                    anchors.verticalCenter: parent.verticalCenter
                    color: launcherState.searchTextColor
                    font.pixelSize: 13
                    font.family: "SF Pro Text, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, sans-serif"
                    clip: true
                    text: launcherState.searchQuery
                    onTextChanged: launcherState.searchQuery = text
                    Keys.onReturnPressed: {
                        let filtered = launcherState.getFilteredApps();
                        if (filtered.length > 0)
                            launcherState.launchApp(filtered[0]);

                    }
                    Keys.onEscapePressed: {
                        if (text.length > 0)
                            text = "";
                        else
                            launcherState.closeLauncher();
                    }

                    Text {
                        text: "Buscar en todas las aplicaciones..."
                        color: launcherState.searchPlaceholderColor
                        font: parent.font
                        visible: !parent.text && !parent.activeFocus
                        anchors.verticalCenter: parent.verticalCenter
                    }

                }

                // Clear Search Button (✕)
                Rectangle {
                    visible: searchInput.text.length > 0
                    width: 18
                    height: 18
                    radius: 9
                    color: clearMouse.containsMouse ? launcherState.appActiveBg : launcherState.appHoverBg
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: "✕"
                        color: launcherState.headerSubColor
                        font.pixelSize: 9
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: clearMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            searchInput.text = "";
                            searchInput.forceActiveFocus();
                        }
                    }

                }

            }

            Behavior on border.color {
                ColorAnimation {
                    duration: 150
                }

            }

        }

    }

}
