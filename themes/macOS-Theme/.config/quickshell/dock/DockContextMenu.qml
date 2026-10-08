import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell

Item {
    id: root
    property var dockState: null

    visible: dockState ? dockState.contextMenuVisible : false
    anchors.fill: parent
    z: 9999

    // Close on click outside
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onPressed: if (dockState) dockState.closeContextMenu()
    }

    // Shadow Glow behind Context Menu
    RectangularGlow {
        anchors.fill: menuBox
        anchors.topMargin: 4
        glowRadius: 16
        spread: 0.1
        color: "#99000000"
        cornerRadius: menuBox.radius + glowRadius
        scale: menuBox.scale
        opacity: menuBox.opacity
    }

    // Context Menu Capsule Container
    Rectangle {
        id: menuBox
        width: 210
        height: menuLayout.implicitHeight + 16
        radius: 14
        color: "#eb181a24"
        border.color: "#47ffffff"
        border.width: 1

        // Position clamped right on top of the dock and clicked icon
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 72
        x: dockState ? Math.max(12, Math.min(parent.width - width - 12, dockState.contextMenuX - width / 2)) : 12

        // Smooth fade / pop animation
        scale: root.visible ? 1.0 : 0.94
        opacity: root.visible ? 1.0 : 0.0
        Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

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

            // ── Header (App Name / Item Name) ──
            Item {
                width: parent.width
                height: 24

                Text {
                    id: headerTitle
                    text: {
                        if (!dockState) return ""
                        if (dockState.contextMenuIsTrash) return "Papelera"
                        if (dockState.contextMenuIsFolder) return "Descargas"
                        if (dockState.contextMenuApp) return dockState.contextMenuApp.name || ""
                        if (dockState.contextMenuRunning) return dockState.contextMenuRunning.name || ""
                        return ""
                    }
                    color: "#ccffffff"
                    font.pixelSize: 12
                    font.bold: true
                    font.family: "SF Pro Text, Space Grotesk, sans-serif"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    elide: Text.ElideRight
                }
            }

            MenuSeparator {}

            // ── 1. Trash Actions ──
            MenuItemBtn {
                visible: dockState ? dockState.contextMenuIsTrash : false
                label: "Abrir Papelera"
                iconSource: "image://icon/folder-open"
                onClicked: {
                    dockState.closeContextMenu()
                    dockState.openTrash()
                }
            }

            MenuItemBtn {
                visible: dockState ? (dockState.contextMenuIsTrash && dockState.trashCount > 0) : false
                label: "Vaciar Papelera (" + (dockState ? dockState.trashCount : 0) + ")"
                iconSource: "image://icon/user-trash"
                isDestructive: true
                onClicked: {
                    dockState.closeContextMenu()
                    dockState.emptyTrash()
                }
            }

            // ── 2. Downloads Folder Actions ──
            MenuItemBtn {
                visible: dockState ? dockState.contextMenuIsFolder : false
                label: "Abrir «Descargas»"
                iconSource: "image://icon/folder-download"
                onClicked: {
                    dockState.closeContextMenu()
                    dockState.openDownloads()
                }
            }

            MenuItemBtn {
                visible: dockState ? dockState.contextMenuIsFolder : false
                label: "Mostrar en gestor de archivos"
                iconSource: "image://icon/system-file-manager"
                onClicked: {
                    dockState.closeContextMenu()
                    dockState.openDownloads()
                }
            }

            // ── 3. App Actions (Pinned or Running) ──
            readonly property var curApp: dockState ? dockState.contextMenuApp : null
            readonly property var curRunning: dockState ? dockState.contextMenuRunning : null
            readonly property var matchingClients: (dockState && curApp) ? dockState.getMatchingClients(curApp) : []
            readonly property bool isAppRunning: (matchingClients.length > 0) || !!curRunning
            readonly property int pinnedIdx: (dockState && curApp) ? dockState.getPinnedIndex(curApp.id) : -1

            // Multiple window instances
            Repeater {
                model: (menuLayout.matchingClients.length > 1) ? menuLayout.matchingClients : 0
                MenuItemBtn {
                    label: (modelData.title || "Ventana").slice(0, 24)
                    iconSource: "image://icon/window-new"
                    onClicked: {
                        let addr = modelData.address
                        dockState.closeContextMenu()
                        dockState.focusAddress(addr)
                    }
                }
            }

            MenuSeparator {
                visible: (menuLayout.matchingClients.length > 1)
            }

            // Primary: Focus or Launch
            MenuItemBtn {
                visible: dockState ? (!dockState.contextMenuIsTrash && !dockState.contextMenuIsFolder) : false
                label: menuLayout.isAppRunning ? "Traer al frente" : "Abrir"
                iconSource: "image://icon/media-playback-start"
                onClicked: {
                    let appObj = menuLayout.curApp
                    let runObj = menuLayout.curRunning
                    dockState.closeContextMenu()
                    if (appObj) dockState.focusOrLaunch(appObj)
                    else if (runObj) dockState.focusAddress(runObj.address)
                }
            }

            // New Window
            MenuItemBtn {
                visible: menuLayout.isAppRunning && !!menuLayout.curApp && (menuLayout.curApp.cmd && menuLayout.curApp.cmd.length > 0)
                label: "Nueva ventana"
                iconSource: "image://icon/window-new"
                onClicked: {
                    let cmdStr = menuLayout.curApp ? menuLayout.curApp.cmd : ""
                    dockState.closeContextMenu()
                    if (cmdStr) dockState.launchNew(cmdStr)
                }
            }

            MenuSeparator {
                visible: dockState ? (!dockState.contextMenuIsTrash && !dockState.contextMenuIsFolder) : false
            }

            // Reorder: Move Left
            MenuItemBtn {
                visible: menuLayout.pinnedIdx > 0
                label: "Mover a la izquierda"
                iconSource: "image://icon/go-previous"
                onClicked: {
                    let appId = menuLayout.curApp ? menuLayout.curApp.id : ""
                    dockState.closeContextMenu()
                    if (appId) dockState.movePinnedApp(appId, -1)
                }
            }

            // Reorder: Move Right
            MenuItemBtn {
                visible: (dockState && menuLayout.pinnedIdx >= 0 && menuLayout.pinnedIdx < dockState.pinnedList.length - 1)
                label: "Mover a la derecha"
                iconSource: "image://icon/go-next"
                onClicked: {
                    let appId = menuLayout.curApp ? menuLayout.curApp.id : ""
                    dockState.closeContextMenu()
                    if (appId) dockState.movePinnedApp(appId, 1)
                }
            }

            // Unpin from Dock
            MenuItemBtn {
                visible: menuLayout.pinnedIdx >= 0
                label: "Quitar del Dock"
                iconSource: "image://icon/list-remove"
                onClicked: {
                    let appId = menuLayout.curApp ? menuLayout.curApp.id : ""
                    dockState.closeContextMenu()
                    if (appId) dockState.unpinApp(appId)
                }
            }

            // Keep in Dock (for running unpinned apps)
            MenuItemBtn {
                visible: !!menuLayout.curRunning && (dockState ? !dockState.isPinned(menuLayout.curRunning.clazz.toLowerCase().replace(/[^a-z0-9_-]/g, "-")) : false)
                label: "Mantener en el Dock"
                iconSource: "image://icon/bookmark-new"
                onClicked: {
                    let runObj = menuLayout.curRunning
                    dockState.closeContextMenu()
                    if (runObj) {
                        dockState.pinApp({
                            id: runObj.clazz.toLowerCase().replace(/[^a-z0-9_-]/g, "-"),
                            name: runObj.name,
                            fallbackIcon: runObj.icon || "application-x-executable",
                            cmd: "gtk-launch " + runObj.clazz + " || " + runObj.clazz,
                            matchClasses: [runObj.clazz.toLowerCase()]
                        })
                    }
                }
            }

            MenuSeparator {
                visible: menuLayout.isAppRunning
            }

            // Close / Quit
            MenuItemBtn {
                visible: menuLayout.isAppRunning
                label: "Cerrar"
                iconSource: "image://icon/application-exit"
                isDestructive: true
                onClicked: {
                    let appObj = menuLayout.curApp
                    let runObj = menuLayout.curRunning
                    dockState.closeContextMenu()
                    if (appObj) dockState.closeApp(appObj)
                    else if (runObj) dockState.closeApp(null, runObj.address)
                }
            }
        }
    }

    // ── Helper Components ──
    component MenuItemBtn: Rectangle {
        property string label: ""
        property string iconSource: ""
        property bool isDestructive: false
        signal clicked()

        width: parent ? parent.width : 194
        height: visible ? 28 : 0
        radius: 6
        color: mouseArea.containsMouse
            ? (isDestructive ? "#e6ff453a" : "#e60a84ff")
            : "transparent"

        Behavior on color { ColorAnimation { duration: 90 } }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 8

            Text {
                text: label
                color: "#ffffff"
                font.pixelSize: 13
                font.bold: false
                font.family: "SF Pro Text, Space Grotesk, sans-serif"
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - (iconImg.visible ? 22 : 0)
                elide: Text.ElideRight
            }

            Image {
                id: iconImg
                source: iconSource
                width: 14
                height: 14
                anchors.verticalCenter: parent.verticalCenter
                visible: iconSource.length > 0
                opacity: 0.85
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }

    component MenuSeparator: Rectangle {
        width: parent ? parent.width : 194
        height: visible ? 1 : 0
        color: "#24ffffff"
        anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
    }
}
