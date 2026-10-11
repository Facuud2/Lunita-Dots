import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell

Item {
    id: root

    required property var launcherState

    implicitWidth: 580
    implicitHeight: 640
    width: 580
    height: 640

    // ── Main Frosted Acrylic / Liquid Glass Card ──
    Rectangle {
        id: panelCard
        anchors.fill: parent
        radius: 26
        color: launcherState.panelBgColor
        border.color: launcherState.panelBorderColor
        border.width: 1

        // Smooth Cupertino Appearance & Exit Animations
        opacity: launcherState.isOpen ? 1.0 : 0.0
        scale: launcherState.isOpen ? 1.0 : 0.94
        transformOrigin: Item.Center

        Behavior on opacity {
            NumberAnimation {
                duration: launcherState.isOpen ? 220 : 160
                easing.type: Easing.InOutQuad
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: launcherState.isOpen ? 240 : 170
                easing.type: launcherState.isOpen ? Easing.OutBack : Easing.InQuad
                easing.overshoot: 1.12
            }
        }

        // Inner Specular Sheen Border
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: 25
            color: "transparent"
            border.color: launcherState.panelInnerSheen
            border.width: 1
        }

        // Prevent clicking inside panel from bubbling to backdrop
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 14

            // ── Top Header Bar (App Store icon, Title, Actions, Search) ──
            HeaderBar {
                id: headerBar
                launcherState: root.launcherState
                width: parent.width
            }

            // ── Dynamic Body View ──
            Item {
                width: parent.width
                height: parent.height - headerBar.height - 14
                clip: true

                // 1. Search Results View (Active when searching)
                CategoryDetailView {
                    anchors.fill: parent
                    launcherState: root.launcherState
                    appsList: launcherState.getFilteredApps()
                    visible: launcherState.searchQuery.trim().length > 0
                }

                // 2. Category Detail View (When clicking "Show All")
                CategoryDetailView {
                    anchors.fill: parent
                    launcherState: root.launcherState
                    appsList: (launcherState.activeCategoryDetail && launcherState.activeCategoryDetail.allApps) ? launcherState.activeCategoryDetail.allApps : []
                    visible: launcherState.searchQuery.trim().length === 0 && launcherState.activeViewMode === "detail"
                }

                // 3. All Apps Alphabetical Grid View
                CategoryDetailView {
                    anchors.fill: parent
                    launcherState: root.launcherState
                    appsList: launcherState.allAppsList
                    visible: launcherState.searchQuery.trim().length === 0 && launcherState.activeViewMode === "all"
                }

                // 4. Categorized Sections (Standard Reference Layout)
                ListView {
                    id: sectionsList
                    anchors.fill: parent
                    visible: launcherState.searchQuery.trim().length === 0 && launcherState.activeViewMode === "categorized"
                    model: launcherState.categoriesList
                    clip: true
                    spacing: 4
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: CategorySection {
                        required property var modelData
                        required property int index
                        launcherState: root.launcherState
                        category: modelData
                        isLastSection: index === (launcherState.categoriesList ? launcherState.categoriesList.length - 1 : 0)
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        width: 5
                        anchors.right: sectionsList.right
                        anchors.rightMargin: 2
                    }
                }
            }
        }
    }

    // Auto focus search field when opened
    Connections {
        target: launcherState
        function onIsOpenChanged() {
            if (launcherState.isOpen) {
                headerBar.searchInputField.forceActiveFocus()
            }
        }
    }

    Keys.onEscapePressed: launcherState.closeLauncher()
}
