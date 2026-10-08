import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    required property var dockState

    visible: root.dockState ? root.dockState.contextMenuVisible : false
    anchors.fill: parent
    z: 9999

    // Dismiss context menu on click outside
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: if (root.dockState) root.dockState.closeContextMenu()
    }

    readonly property var currentApp: root.dockState ? root.dockState.contextMenuApp : null
    readonly property bool isStartMenu: currentApp ? !!currentApp.isStart : false
    readonly property bool isAppPinned: (root.dockState && root.currentApp) ? root.dockState.isPinned(root.currentApp.id) : false
    readonly property bool isAppRunning: (root.dockState && root.currentApp) ? root.dockState.isAppRunning(root.currentApp) : false
    readonly property var currentWindows: {
        if (!root.currentApp) return [];
        if (root.currentApp.windows && Array.isArray(root.currentApp.windows)) return root.currentApp.windows;
        if (root.currentApp.windowsJson) {
            try { return JSON.parse(root.currentApp.windowsJson); } catch (e) { return []; }
        }
        return [];
    }

    // Context Menu Box
    Rectangle {
        id: menuBox
        width: 220
        height: Math.max(80, menuLayout.childrenRect.height + 20)
        radius: 12

        // Smoked Acrylic & Liquid Glass Tint
        color: Qt.rgba(0.12, 0.13, 0.17, 0.92)
        border.color: Qt.rgba(1, 1, 1, 0.18)
        border.width: 1

        // Position directly above the clicked dock icon
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 74
        x: root.dockState
            ? Math.max(16, Math.min(parent.width - width - 16, root.dockState.contextMenuX - width / 2))
            : 16

        // Pop & Fade animation
        scale: root.visible ? 1.0 : 0.95
        opacity: root.visible ? 1.0 : 0.0
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

        // Outer Ambient Elevation Shadow
        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: parent.radius + 1
            color: "transparent"
            border.color: Qt.rgba(0, 0, 0, 0.45)
            border.width: 1
            z: -1
        }

        // Top Specular Sheen (Liquid Glass Refraction)
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 1
            height: parent.height * 0.45
            radius: parent.radius - 1
            clip: true
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.12) }
                GradientStop { position: 0.35; color: Qt.rgba(1, 1, 1, 0.03) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        Column {
            id: menuLayout
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                topMargin: 8
                leftMargin: 8
                rightMargin: 8
            }
            spacing: 3

            // ── Menu Header ──
            Item {
                width: parent.width
                height: 26
                implicitHeight: 26

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 6
                    anchors.rightMargin: 6
                    spacing: 8

                    Image {
                        source: root.isStartMenu
                            ? Qt.resolvedUrl("assets/icons/win11-start.svg")
                            : (root.currentApp && root.currentApp.icon ? root.currentApp.icon : "assets/icons/appstore.svg")
                        width: 16
                        height: 16
                        anchors.verticalCenter: parent.verticalCenter
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }

                    Text {
                        text: root.isStartMenu
                            ? "Sistema Windows 11"
                            : (root.currentApp ? (root.currentApp.name || root.currentApp.clazz) : "")
                        color: "#FFFFFF"
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        font.family: "Segoe UI, Inter, sans-serif"
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 24
                        elide: Text.ElideRight
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                implicitHeight: 1
                color: Qt.rgba(1, 1, 1, 0.12)
            }

            // ==========================================
            // CASE 1: WINDOWS START BUTTON OPTIONS
            // ==========================================
            MenuItemBtn {
                visible: root.isStartMenu
                label: "Bloquear pantalla"
                iconSource: Qt.resolvedUrl("assets/lock.svg")
                onClicked: {
                    root.dockState.closeContextMenu();
                    Quickshell.execDetached(["bash", "-c", "hyprlock || lunita-lock || swaylock &"]);
                }
            }

            MenuItemBtn {
                visible: root.isStartMenu
                label: "Cerrar sesión"
                iconSource: Qt.resolvedUrl("assets/logout.svg")
                onClicked: {
                    root.dockState.closeContextMenu();
                    Quickshell.execDetached(["bash", "-c", "hyprctl dispatch exit &"]);
                }
            }

            MenuItemBtn {
                visible: root.isStartMenu
                label: "Suspender"
                iconSource: Qt.resolvedUrl("assets/moon.svg")
                onClicked: {
                    root.dockState.closeContextMenu();
                    Quickshell.execDetached(["bash", "-c", "systemctl suspend &"]);
                }
            }

            MenuItemBtn {
                visible: root.isStartMenu
                label: "Reiniciar equipo"
                iconSource: Qt.resolvedUrl("assets/reload.svg")
                onClicked: {
                    root.dockState.closeContextMenu();
                    Quickshell.execDetached(["bash", "-c", "systemctl reboot &"]);
                }
            }

            MenuItemBtn {
                visible: root.isStartMenu
                label: "Apagar el equipo"
                iconSource: Qt.resolvedUrl("assets/power.svg")
                isDestructive: true
                onClicked: {
                    root.dockState.closeContextMenu();
                    Quickshell.execDetached(["bash", "-c", "systemctl poweroff &"]);
                }
            }

            Rectangle {
                visible: root.isStartMenu
                width: parent.width
                height: 1
                implicitHeight: 1
                color: Qt.rgba(1, 1, 1, 0.12)
            }

            MenuItemBtn {
                visible: root.isStartMenu
                label: "Terminal"
                iconSource: Qt.resolvedUrl("assets/icons/win11-terminal.svg")
                onClicked: {
                    root.dockState.closeContextMenu();
                    Quickshell.execDetached(["kitty &"]);
                }
            }

            MenuItemBtn {
                visible: root.isStartMenu
                label: "Configuración"
                iconSource: Qt.resolvedUrl("assets/gear.svg")
                onClicked: {
                    root.dockState.closeContextMenu();
                    Quickshell.execDetached(["systemsettings || xfce4-settings-manager &"]);
                }
            }

            // ==========================================
            // CASE 2: REGULAR APP OPTIONS (PINNED OR RUNNING)
            // ==========================================
            // Case 2A: App is closed (pinned only)
            MenuItemBtn {
                visible: !root.isStartMenu && !root.isAppRunning && !!root.currentApp
                label: "Abrir"
                iconSource: Qt.resolvedUrl("assets/new-window.svg")
                onClicked: {
                    let app = root.currentApp;
                    root.dockState.closeContextMenu();
                    root.dockState.launchApp(app);
                }
            }

            // Case 2B: Multiple window instances (if more than 1 window)
            Repeater {
                model: (!root.isStartMenu && root.isAppRunning && root.currentWindows.length > 1) ? root.currentWindows : 0
                MenuItemBtn {
                    label: modelData.title.length > 24 ? (modelData.title.slice(0, 24) + "…") : modelData.title
                    iconSource: Qt.resolvedUrl("assets/bring-to-front.svg")
                    onClicked: {
                        let addr = modelData.address;
                        root.dockState.closeContextMenu();
                        root.dockState.focusAddress(addr);
                    }
                }
            }

            Rectangle {
                visible: (!root.isStartMenu && root.isAppRunning && root.currentWindows.length > 1)
                width: parent.width
                height: 1
                implicitHeight: 1
                color: Qt.rgba(1, 1, 1, 0.12)
            }

            // Focus window
            MenuItemBtn {
                visible: !root.isStartMenu && root.isAppRunning && !!root.currentApp
                label: "Traer al frente"
                iconSource: Qt.resolvedUrl("assets/bring-to-front.svg")
                onClicked: {
                    let addr = root.currentApp.address;
                    root.dockState.closeContextMenu();
                    root.dockState.focusAddress(addr);
                }
            }

            // Launch new instance
            MenuItemBtn {
                visible: !root.isStartMenu && root.isAppRunning && !!root.currentApp && (root.currentApp.cmd && root.currentApp.cmd.length > 0)
                label: "Nueva ventana"
                iconSource: Qt.resolvedUrl("assets/new-window.svg")
                onClicked: {
                    let cmd = root.currentApp.cmd;
                    root.dockState.closeContextMenu();
                    Quickshell.execDetached(["bash", "-c", cmd + " &"]);
                }
            }

            // Minimize / Toggle
            MenuItemBtn {
                visible: !root.isStartMenu && root.isAppRunning && !!root.currentApp
                label: "Minimizar ventana"
                iconSource: Qt.resolvedUrl("assets/minimize.svg")
                onClicked: {
                    let addr = root.currentApp.address;
                    root.dockState.closeContextMenu();
                    Quickshell.execDetached(["bash", "-c", "hyprctl dispatch movetoworkspacesilent special:minimized,address:" + addr]);
                }
            }

            Rectangle {
                visible: !root.isStartMenu && !!root.currentApp
                width: parent.width
                height: 1
                implicitHeight: 1
                color: Qt.rgba(1, 1, 1, 0.12)
            }

            // Pin to taskbar (if not pinned)
            MenuItemBtn {
                visible: !root.isStartMenu && !!root.currentApp && !root.isAppPinned
                label: "Anclar a la barra de tareas"
                iconSource: Qt.resolvedUrl("assets/pin.svg")
                onClicked: {
                    let app = root.currentApp;
                    root.dockState.closeContextMenu();
                    root.dockState.pinApp(app);
                }
            }

            // Unpin from taskbar (if pinned)
            MenuItemBtn {
                visible: !root.isStartMenu && !!root.currentApp && root.isAppPinned
                label: "Desanclar de la barra de tareas"
                iconSource: Qt.resolvedUrl("assets/unpin.svg")
                onClicked: {
                    let appId = root.currentApp.id;
                    root.dockState.closeContextMenu();
                    root.dockState.unpinApp(appId);
                }
            }

            // Move Left
            MenuItemBtn {
                visible: !root.isStartMenu && !!root.currentApp && root.dockState && root.dockState.canMoveLeft(root.currentApp)
                label: "Mover a la izquierda"
                iconSource: Qt.resolvedUrl("assets/chevron-left.svg")
                onClicked: {
                    let app = root.currentApp;
                    root.dockState.closeContextMenu();
                    root.dockState.moveApp(app, -1);
                }
            }

            // Move Right
            MenuItemBtn {
                visible: !root.isStartMenu && !!root.currentApp && root.dockState && root.dockState.canMoveRight(root.currentApp)
                label: "Mover a la derecha"
                iconSource: Qt.resolvedUrl("assets/chevron-right.svg")
                onClicked: {
                    let app = root.currentApp;
                    root.dockState.closeContextMenu();
                    root.dockState.moveApp(app, 1);
                }
            }

            Rectangle {
                visible: !root.isStartMenu && root.isAppRunning && !!root.currentApp
                width: parent.width
                height: 1
                implicitHeight: 1
                color: Qt.rgba(1, 1, 1, 0.12)
            }

            // Close Window
            MenuItemBtn {
                visible: !root.isStartMenu && root.isAppRunning && !!root.currentApp
                label: "Cerrar ventana"
                iconSource: Qt.resolvedUrl("assets/close-window.svg")
                isDestructive: true
                onClicked: {
                    let addr = root.currentApp.address;
                    root.dockState.closeContextMenu();
                    Quickshell.execDetached(["bash", "-c", "hyprctl dispatch closewindow address:" + addr]);
                }
            }
        }
    }

    // ── Reusable Menu Item Button ──
    component MenuItemBtn: Rectangle {
        id: btnRoot
        property string label: ""
        property var iconSource: ""
        property bool isDestructive: false
        signal clicked()

        width: parent ? parent.width : 204
        height: visible ? 28 : 0
        implicitWidth: width
        implicitHeight: height
        radius: 6
        color: btnMouse.containsMouse
            ? (btnRoot.isDestructive ? Qt.rgba(1.0, 0.23, 0.23, 0.25) : Qt.rgba(1.0, 1.0, 1.0, 0.12))
            : "transparent"

        border.color: btnMouse.containsMouse
            ? (btnRoot.isDestructive ? Qt.rgba(1.0, 0.23, 0.23, 0.4) : Qt.rgba(1.0, 1.0, 1.0, 0.08))
            : "transparent"
        border.width: 1

        Behavior on color { ColorAnimation { duration: 100 } }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 8

            Image {
                source: btnRoot.iconSource
                width: 14
                height: 14
                sourceSize.width: 14
                sourceSize.height: 14
                anchors.verticalCenter: parent.verticalCenter
                visible: btnRoot.iconSource.toString().length > 0
                opacity: btnMouse.containsMouse ? 1.0 : 0.8
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            Text {
                text: btnRoot.label
                color: btnRoot.isDestructive && btnMouse.containsMouse ? "#FF6B6B" : "#FFFFFF"
                font.pixelSize: 12
                font.weight: Font.Normal
                font.family: "Segoe UI, Inter, sans-serif"
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 24
                elide: Text.ElideRight
            }
        }

        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btnRoot.clicked()
        }
    }
}
