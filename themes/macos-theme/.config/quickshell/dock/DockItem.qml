import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell

Item {
    id: root

    property var dockState: null
    property var panelWindow: null
    property var app: null
    property var runningApp: null
    property bool isTrash: false
    property bool isFolder: false
    property bool isAdd: false
    property string dragSection: ""
    property int itemIndex: -1

    readonly property bool isDraggable: root.dragSection !== "" && root.itemIndex >= 0
    property real dragDeltaX: 0

    readonly property real neighborShiftX: {
        if (!dockState || !dockState.isDraggingItem || dockState.dragSection !== root.dragSection || mouseArea.isDragging) {
            return 0
        }
        let src = dockState.dragSourceIndex
        let dst = dockState.dragTargetIndex
        let myIdx = root.itemIndex
        if (src < 0 || dst < 0 || myIdx < 0 || src === dst) return 0
        if (src < dst && myIdx > src && myIdx <= dst) return -54
        if (src > dst && myIdx >= dst && myIdx < src) return 54
        return 0
    }

    property real animatedShiftX: neighborShiftX
    Behavior on animatedShiftX {
        enabled: !mouseArea.isDragging && (!dockState || dockState.isDraggingItem)
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }

    readonly property string itemId: isTrash ? "trash"
        : isFolder ? "folder"
        : isAdd ? "add"
        : app ? app.id
        : runningApp ? runningApp.id : "item"

    readonly property string itemName: isTrash
        ? (dockState ? (dockState.trashCount > 0 ? "Papelera (" + dockState.trashCount + ")" : "Papelera") : "Papelera")
        : isFolder ? "Descargas"
        : isAdd ? "Añadir al Dock"
        : app ? app.name
        : runningApp ? runningApp.name : ""

    readonly property bool isRunning: (app && dockState)
        ? dockState.isAppRunning(app)
        : !!runningApp

    readonly property string screenName: (panelWindow && panelWindow.screen && panelWindow.screen.name)
        ? panelWindow.screen.name
        : ""

    readonly property bool isContextMenuOnScreen: dockState
        ? (dockState.contextMenuVisible && dockState.contextMenuScreen === screenName)
        : false

    readonly property string iconSource: {
        if (isTrash) {
            let tc = dockState ? dockState.trashCount : 0
            return Qt.resolvedUrl("assets/icons/" + (tc > 0 ? "trash-full.svg" : "trash-empty.svg"))
        }
        if (isFolder) return Qt.resolvedUrl("assets/icons/folder.svg")
        if (isAdd) return Qt.resolvedUrl("assets/icons/add.svg")

        // 1. Prioridad: Icono nativo pre-resuelto si existe
        if (app && app.iconPath && app.iconPath.length > 0) {
            return app.iconPath
        }

        // 2. Elementos del sistema macOS específicos (Launchpad, Atajos, Llavero)
        if (app && (app.id === "launchpad" || app.id === "shortcuts" || app.id === "keychain")) {
            return Qt.resolvedUrl("assets/icons/" + app.id + ".svg")
        }

        // 3. Resolución para apps ancladas (Dock items)
        if (app) {
            let candidates = [app.iconName, app.fallbackIcon, app.id, app.name]
            for (let i = 0; i < candidates.length; i++) {
                let cand = candidates[i]
                if (cand && cand.length > 0) {
                    let resolved = dockState ? dockState.resolveIconSource(cand) : ""
                    if (resolved && resolved.length > 0 && !resolved.endsWith("launchpad.svg")) {
                        return resolved
                    }
                }
            }
            if (app.iconFile && app.iconFile.length > 0) {
                return Qt.resolvedUrl("assets/icons/" + app.iconFile)
            }
        }

        // 4. Resolución para apps abiertas no ancladas
        if (runningApp) {
            let candidates = [runningApp.icon, runningApp.clazz, runningApp.name]
            for (let i = 0; i < candidates.length; i++) {
                let cand = candidates[i]
                if (cand && cand.length > 0) {
                    let resolved = dockState ? dockState.resolveIconSource(cand) : ""
                    if (resolved && resolved.length > 0 && !resolved.endsWith("launchpad.svg")) {
                        return resolved
                    }
                }
            }
        }

        return Qt.resolvedUrl("assets/icons/launchpad.svg")
    }

    width: 52
    height: 58
    z: mouseArea.isDragging ? 999 : 1

    // ── Tooltip Pill ──
    RectangularGlow {
        visible: tooltipPill.visible
        z: 998
        anchors.fill: tooltipPill
        anchors.topMargin: 2
        glowRadius: 8
        spread: 0.1
        color: "#66000000"
        cornerRadius: tooltipPill.radius + glowRadius
    }

    Rectangle {
        id: tooltipPill
        visible: mouseArea.containsMouse && !mouseArea.isDragging && (!dockState || !dockState.isDraggingItem) && !root.isContextMenuOnScreen
        z: 999
        anchors.bottom: iconContainer.top
        anchors.bottomMargin: 6
        anchors.horizontalCenter: iconContainer.horizontalCenter
        height: 22
        width: tooltipText.implicitWidth + 14
        radius: 6
        color: "#ea1c1e26"
        border.color: "#33ffffff"
        border.width: 1

        Text {
            id: tooltipText
            text: root.itemName
            color: "#ffffff"
            font.pixelSize: 11
            font.bold: true
            font.family: "SF Pro Text, Space Grotesk, sans-serif"
            anchors.centerIn: parent
        }
    }

    // ── Squircle Container & Halo ──
    Rectangle {
        id: iconContainer
        width: 48
        height: 48
        clip: true
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        radius: 10.8

        transform: Translate {
            id: iconTranslate
            x: mouseArea.isDragging ? root.dragDeltaX : root.animatedShiftX
            y: mouseArea.isDragging ? -5 : 0
        }

        // macOS Halo Highlight on Hover & Drag
        color: mouseArea.isDragging ? "#42ffffff" : (mouseArea.containsMouse ? "#2effffff" : "transparent")
        border.color: mouseArea.isDragging ? "#80ffffff" : (mouseArea.containsMouse ? "#4dffffff" : "transparent")
        border.width: 1

        scale: mouseArea.isDragging ? 1.15 : (mouseArea.pressed ? 0.94 : (mouseArea.containsMouse ? 1.04 : 1.0))

        Behavior on color { ColorAnimation { duration: 140 } }
        Behavior on border.color { ColorAnimation { duration: 140 } }
        Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }

        // App Icon Image
        Image {
            id: iconImg
            anchors.fill: parent
            anchors.margins: 1
            source: root.iconSource
            sourceSize.width: 46
            sourceSize.height: 46
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
        }
    }

    // ── Status Indicator Dot ──
    Rectangle {
        id: statusDot
        width: 4
        height: 4
        radius: 2
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 1
        anchors.horizontalCenter: parent.horizontalCenter

        transform: Translate {
            x: mouseArea.isDragging ? root.dragDeltaX : root.animatedShiftX
        }

        visible: !isTrash && !isFolder && !isAdd
        opacity: root.isRunning ? 0.95 : 0.0
        color: "#ffffff"

        Behavior on opacity { NumberAnimation { duration: 200 } }
    }

    // ── Interactive Mouse Area & DnD ──
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        preventStealing: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: isDragging ? Qt.ClosedHandCursor : Qt.PointingHandCursor

        property real pressStartX: 0
        property real pressStartY: 0
        property bool isDragging: false

        onPressed: function(mouse) {
            pressStartX = mouse.x
            pressStartY = mouse.y
            isDragging = false
            root.dragDeltaX = 0

            if (mouse.button === Qt.RightButton) {
                let screenW = (panelWindow && panelWindow.screen) ? panelWindow.screen.width : 1920
                let winW = panelWindow ? panelWindow.width : 540
                let dockScreenX = (screenW - winW) / 2
                let mapped = root.mapToItem(null, root.width / 2, root.height / 2)
                let globalX = dockScreenX + mapped.x

                if (dockState) {
                    dockState.openContextMenu(root.app, root.runningApp, root.isTrash, root.isFolder, globalX, mapped.y, root.screenName)
                }
            } else {
                if (dockState) dockState.closeContextMenu()
            }
        }

        onPositionChanged: function(mouse) {
            if ((mouse.buttons & Qt.LeftButton) && root.isDraggable && dockState) {
                let dx = mouse.x - pressStartX
                if (!isDragging && Math.abs(dx) > 4) {
                    isDragging = true
                    dockState.startDrag(root.dragSection, root.itemIndex)
                }
                if (isDragging) {
                    root.dragDeltaX = dx
                    let steps = Math.round(dx / 54)
                    dockState.updateDragTarget(root.itemIndex + steps)
                }
            }
        }

        onReleased: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                if (isDragging && dockState) {
                    isDragging = false
                    root.dragDeltaX = 0
                    dockState.commitDrag()
                } else {
                    isDragging = false
                    root.dragDeltaX = 0
                    if (Math.abs(mouse.x - pressStartX) < 12 && Math.abs(mouse.y - pressStartY) < 12) {
                        root.triggerAction()
                    }
                }
            }
        }

        onCanceled: {
            if (isDragging && dockState) {
                isDragging = false
                root.dragDeltaX = 0
                dockState.cancelDrag()
            }
        }
    }

    function triggerAction() {
        if (!dockState) return

        if (root.isAdd) {
            dockState.openAddModal(root.screenName)
            return
        }
        if (root.isTrash) {
            dockState.openTrash()
            return
        }
        if (root.isFolder) {
            dockState.openDownloads()
            return
        }
        if (root.app) {
            dockState.focusOrLaunch(root.app)
            return
        }
        if (root.runningApp) {
            dockState.focusAddress(root.runningApp.address)
            return
        }
    }
}
