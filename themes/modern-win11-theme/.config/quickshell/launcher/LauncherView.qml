import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import Quickshell

Item {
    id: root

    required property var launcherState
    readonly property alias cardY: cardContainer.y

    implicitWidth: 640
    implicitHeight: 760
    width: 640
    height: 760
    Component.onCompleted: {
        if (root.launcherState.isOpen) {
            enterAnim.restart();
        } else {
            cardContainer.y = 56;
            cardContainer.opacity = 0;
            cardContainer.scale = 0.93;
        }
    }
    Keys.onEscapePressed: launcherState.closeLauncher()

    // ── Windows 11 Fluent Motion Entrance & Exit Animations ──
    ParallelAnimation {
        id: enterAnim

        NumberAnimation {
            target: cardContainer
            property: "y"
            from: 56
            to: 0
            duration: 270
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.1, 0.9, 0.2, 1, 1, 1]
        }

        NumberAnimation {
            target: cardContainer
            property: "scale"
            from: 0.93
            to: 1
            duration: 270
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.1, 0.9, 0.2, 1, 1, 1]
        }

        NumberAnimation {
            target: cardContainer
            property: "opacity"
            from: 0
            to: 1
            duration: 220
            easing.type: Easing.OutCubic
        }

    }

    ParallelAnimation {
        id: exitAnim

        onFinished: {
            if (!root.launcherState.isOpen) {
                root.launcherState.windowVisible = false;
                root.launcherState.powerMenuOpen = false;
            }
        }

        NumberAnimation {
            target: cardContainer
            property: "y"
            from: cardContainer.y
            to: 56
            duration: 180
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.7, 0, 1, 0.5, 1, 1]
        }

        NumberAnimation {
            target: cardContainer
            property: "scale"
            from: cardContainer.scale
            to: 0.93
            duration: 180
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.7, 0, 1, 0.5, 1, 1]
        }

        NumberAnimation {
            target: cardContainer
            property: "opacity"
            from: cardContainer.opacity
            to: 0
            duration: 150
            easing.type: Easing.InQuad
        }

    }

    Item {
        id: cardContainer

        x: 0
        y: 0
        width: 640
        height: 700
        opacity: root.launcherState.isOpen ? 1 : 0
        scale: root.launcherState.isOpen ? 1 : 0.93
        transformOrigin: Item.Bottom

        // Outer Ambient Drop Shadow
        RectangularGlow {
            anchors.fill: panelCard
            glowRadius: 28
            spread: 0.02
            color: root.launcherState.panelShadowColor
            cornerRadius: panelCard.radius + glowRadius
            opacity: cardContainer.opacity
        }

        // ── Main Pure Transparent Acrylic Card ──
        Rectangle {
            id: panelCard

            anchors.fill: parent
            radius: 14
            color: root.launcherState.panelBgColor
            border.color: Qt.rgba(1, 1, 1, 0.14)
            border.width: 1

            // Prevent clicking inside launcher card from bubbling to outside dismissal backdrop
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onPressed: {
                    if (root.launcherState.powerMenuOpen)
                        root.launcherState.powerMenuOpen = false;

                }
            }

            // ── Main Content Column ──
            Column {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: footerBar.top
                anchors.margins: 24
                anchors.bottomMargin: 8
                spacing: 14

                // 1. Windows 11 Top Search Bar
                HeaderBar {
                    id: headerBar

                    launcherState: root.launcherState
                    width: parent.width
                }

                // 2. Dynamic View Area
                Item {
                    id: bodyContainer

                    width: parent.width
                    height: parent.height - headerBar.height - 14
                    clip: true

                    // ── A. SEARCH RESULTS VIEW (when typing in search field) ──
                    CategoryDetailView {
                        anchors.fill: parent
                        launcherState: root.launcherState
                        appsList: root.launcherState.getFilteredApps()
                        viewTitle: "Resultados de búsqueda"
                        visible: root.launcherState.searchQuery.trim().length > 0
                    }

                    // ── B. FOLDER CATEGORY DETAIL VIEW (when opening a folder card) ──
                    CategoryDetailView {
                        anchors.fill: parent
                        launcherState: root.launcherState
                        appsList: root.launcherState.activeCategoryDetail ? (root.launcherState.activeCategoryDetail.apps || []) : []
                        viewTitle: root.launcherState.activeCategoryDetail ? (root.launcherState.activeCategoryDetail.title || "") : ""
                        visible: root.launcherState.searchQuery.trim().length === 0 && root.launcherState.activeViewMode === "detail"
                    }

                    // ── C. ALL APPS ALPHABETICAL VIEW (when toggled via selector) ──
                    CategoryDetailView {
                        anchors.fill: parent
                        launcherState: root.launcherState
                        appsList: root.launcherState.allAppsList
                        viewTitle: "Todas las aplicaciones"
                        visible: root.launcherState.searchQuery.trim().length === 0 && root.launcherState.activeViewMode === "all_apps"
                    }

                    // ── D. STANDARD WINDOWS 11 LAYOUT ──
                    Flickable {
                        id: standardFlickable

                        anchors.fill: parent
                        visible: root.launcherState.searchQuery.trim().length === 0 && root.launcherState.activeViewMode === "standard"
                        contentWidth: width
                        contentHeight: standardContent.implicitHeight + 8
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        Column {
                            id: standardContent

                            width: parent.width
                            spacing: 14

                            // ── SECTION 1: ANCLADO (PINNED) ──
                            Column {
                                width: parent.width
                                spacing: 8

                                // Section 1 Header: "Anclado" ... "Mostrar menos ⌃"
                                Item {
                                    width: parent.width
                                    height: 26

                                    Text {
                                        text: "Anclado"
                                        anchors.left: parent.left
                                        anchors.leftMargin: 4
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: root.launcherState.headerTitleColor
                                        font.pixelSize: 14
                                        font.weight: Font.DemiBold
                                        font.italic: false
                                        font.family: "Adwaita Sans, sans-serif"
                                    }

                                    // Right Action: "Mostrar menos ⌃" / "Mostrar más ⌄"
                                    Rectangle {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: actionRow.implicitWidth + 14
                                        height: 24
                                        radius: 6
                                        color: actionMouse.containsMouse ? root.launcherState.appHoverBg : "transparent"

                                        Row {
                                            id: actionRow

                                            anchors.centerIn: parent
                                            spacing: 4

                                            Text {
                                                text: root.launcherState.isPinnedExpanded ? "Mostrar menos" : "Mostrar más"
                                                color: root.launcherState.headerSubColor
                                                font.pixelSize: 12
                                                font.weight: Font.Medium
                                                font.italic: false
                                                font.family: "Adwaita Sans, sans-serif"
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            Text {
                                                text: root.launcherState.isPinnedExpanded ? "⌃" : "⌄"
                                                color: root.launcherState.headerSubColor
                                                font.pixelSize: 12
                                                font.weight: Font.Bold
                                                font.italic: false
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                        }

                                        MouseArea {
                                            id: actionMouse

                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.launcherState.togglePinnedExpanded()
                                        }

                                    }

                                }

                                // 6-Column Pinned Grid (18 apps in 3 rows)
                                Grid {
                                    id: pinnedGrid

                                    width: parent.width
                                    columns: 6
                                    spacing: Math.max(2, Math.floor((parent.width - (6 * 94)) / 5))
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    Repeater {
                                        model: root.launcherState.isPinnedExpanded ? root.launcherState.pinnedAppsList : (root.launcherState.pinnedAppsList ? root.launcherState.pinnedAppsList.slice(0, 12) : [])

                                        delegate: AppItem {
                                            required property var modelData

                                            launcherState: root.launcherState
                                            app: modelData
                                        }

                                    }

                                }

                            }

                            // ── SECTION 2: TODO (ALL / CATEGORY FOLDERS) ──
                            Column {
                                width: parent.width
                                spacing: 8

                                // Section 2 Header: "Todo" ... "Visualización: Categoría ⌄"
                                Item {
                                    width: parent.width
                                    height: 26

                                    Text {
                                        text: "Todo"
                                        anchors.left: parent.left
                                        anchors.leftMargin: 4
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: root.launcherState.headerTitleColor
                                        font.pixelSize: 14
                                        font.weight: Font.DemiBold
                                        font.italic: false
                                        font.family: "Adwaita Sans, sans-serif"
                                    }

                                    // Right Action: "Visualización: Categoría ⌄"
                                    Rectangle {
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: viewModeRow.implicitWidth + 14
                                        height: 24
                                        radius: 6
                                        color: viewModeMouse.containsMouse ? root.launcherState.appHoverBg : "transparent"

                                        Row {
                                            id: viewModeRow

                                            anchors.centerIn: parent
                                            spacing: 4

                                            Text {
                                                text: "Visualización: Categoría"
                                                color: root.launcherState.headerSubColor
                                                font.pixelSize: 12
                                                font.weight: Font.Medium
                                                font.italic: false
                                                font.family: "Adwaita Sans, sans-serif"
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                            Text {
                                                text: "⌄"
                                                color: root.launcherState.headerSubColor
                                                font.pixelSize: 12
                                                font.weight: Font.Bold
                                                font.italic: false
                                                anchors.verticalCenter: parent.verticalCenter
                                            }

                                        }

                                        MouseArea {
                                            id: viewModeMouse

                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: root.launcherState.toggleAllApps()
                                        }

                                    }

                                }

                                // 3 Horizontal Category Folder Cards (Clean, borderless acrylic capsules)
                                Row {
                                    id: folderRow

                                    width: parent.width
                                    spacing: Math.max(6, Math.floor((parent.width - (3 * 184)) / 2))
                                    anchors.horizontalCenter: parent.horizontalCenter

                                    Repeater {
                                        model: root.launcherState.folderCategories

                                        delegate: CategoryFolderCard {
                                            required property var modelData

                                            launcherState: root.launcherState
                                            category: modelData
                                        }

                                    }

                                }

                            }

                        }

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                            width: 4
                            anchors.right: standardFlickable.right
                            anchors.rightMargin: 2
                        }

                    }

                }

            }

            // ── 3. Bottom Footer Bar (User Profile & Power Button) ──
            Rectangle {
                id: footerBar

                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 60
                color: root.launcherState.footerBg
                radius: 14

                // Top Divider Line (Ultra subtle)
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: root.launcherState.dividerColor
                }

                // Left: User Account Profile
                Rectangle {
                    id: userPill

                    anchors.left: parent.left
                    anchors.leftMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    width: userRow.implicitWidth + 18
                    height: 42
                    radius: 6
                    color: userMouse.containsMouse ? root.launcherState.appHoverBg : "transparent"

                    Row {
                        id: userRow

                        anchors.centerIn: parent
                        spacing: 12

                        // Circular Avatar
                        Item {
                            width: 32
                            height: 32
                            anchors.verticalCenter: parent.verticalCenter

                            Rectangle {
                                id: avatarBg

                                anchors.fill: parent
                                radius: 16
                                color: Qt.rgba(255, 255, 255, 0.15)
                                clip: true

                                Image {
                                    anchors.fill: parent
                                    source: root.launcherState.userAvatar ? root.launcherState.userAvatar : Qt.resolvedUrl("assets/icons/win11-user.svg")
                                    fillMode: Image.PreserveAspectCrop
                                    smooth: true
                                    mipmap: true
                                }

                            }

                        }

                        // User Name
                        Text {
                            text: root.launcherState.userName
                            color: root.launcherState.headerTitleColor
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            font.italic: false
                            font.family: "Segoe UI Variable, Segoe UI, Inter, sans-serif"
                            anchors.verticalCenter: parent.verticalCenter
                        }

                    }

                    MouseArea {
                        id: userMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["bash", "-c", "command -v systemsettings >/dev/null 2>&1 && systemsettings kcm_users || true"]);
                            root.launcherState.closeLauncher();
                        }
                    }

                }

                // Right: Power / Shutdown Button
                Rectangle {
                    id: powerBtn

                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    width: 38
                    height: 38
                    radius: 6
                    color: powerMouse.containsMouse ? root.launcherState.appHoverBg : "transparent"

                    Image {
                        source: Qt.resolvedUrl("assets/icons/win11-power.svg")
                        width: 20
                        height: 20
                        anchors.centerIn: parent
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        opacity: powerMouse.containsMouse ? 1 : 0.85
                    }

                    MouseArea {
                        id: powerMouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.launcherState.powerMenuOpen = !root.launcherState.powerMenuOpen;
                        }
                    }

                }

                // Windows 11 Power Options Flyout
                PowerFlyout {
                    id: powerFlyout

                    launcherState: root.launcherState
                    anchors.bottom: powerBtn.top
                    anchors.bottomMargin: 8
                    anchors.right: powerBtn.right
                    visible: root.launcherState.powerMenuOpen
                }

            }

        }

    }

    // Windows 11 Animation triggers & search focus
    Connections {
        function onIsOpenChanged() {
            if (launcherState.isOpen) {
                exitAnim.stop();
                enterAnim.restart();
                headerBar.searchInputField.forceActiveFocus();
            } else {
                enterAnim.stop();
                exitAnim.restart();
            }
        }

        target: launcherState
    }

}
