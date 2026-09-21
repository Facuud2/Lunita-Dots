import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell

Item {
    id: root

    property var dockState: null
    property var app: null
    property var runningApp: null
    property bool isTrash: false
    property bool isFolder: false
    property bool isAdd: false
    property int itemIndex: -1

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

    readonly property string iconSource: {
        if (isTrash) {
            let tc = dockState ? dockState.trashCount : 0
            return Qt.resolvedUrl("assets/icons/" + (tc > 0 ? "trash-full.svg" : "trash-empty.svg"))
        }
        if (isFolder) return Qt.resolvedUrl("assets/icons/folder.svg")
        if (isAdd) return Qt.resolvedUrl("assets/icons/add.svg")
        if (app && app.iconFile) return Qt.resolvedUrl("assets/icons/" + app.iconFile)
        if (app && app.fallbackIcon) return "image://icon/" + app.fallbackIcon
        if (runningApp && runningApp.icon) return "image://icon/" + runningApp.icon
        return "image://icon/application-x-executable"
    }

    width: 52
    height: 58
    z: mouseArea.isDragging ? 999 : 1

    // ── Tooltip Pill ──
    Rectangle {
        id: tooltipPill
        visible: mouseArea.containsMouse && !mouseArea.isDragging && (dockState ? !dockState.contextMenuVisible : true)
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

        layer.enabled: true
        layer.effect: DropShadow {
            color: "#66000000"
            radius: 8
            samples: 14
            horizontalOffset: 0
            verticalOffset: 3
        }

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
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        radius: 13

        transform: Translate {
            id: iconTranslate
            x: 0
        }

        // macOS Halo Highlight on Hover & Drag
        color: mouseArea.isDragging ? "#38ffffff" : (mouseArea.containsMouse ? "#2effffff" : "transparent")
        border.color: mouseArea.isDragging ? "#66ffffff" : (mouseArea.containsMouse ? "#4dffffff" : "transparent")
        border.width: 1

        scale: mouseArea.isDragging ? 1.12 : (mouseArea.pressed ? 0.94 : (mouseArea.containsMouse ? 1.04 : 1.0))

        Behavior on color { ColorAnimation { duration: 140 } }
        Behavior on border.color { ColorAnimation { duration: 140 } }
        Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }

        layer.enabled: true
        layer.effect: DropShadow {
            color: mouseArea.isDragging ? "#73000000" : (mouseArea.containsMouse ? "#4d000000" : "#26000000")
            radius: mouseArea.isDragging ? 16 : (mouseArea.containsMouse ? 10 : 5)
            samples: 16
            horizontalOffset: 0
            verticalOffset: mouseArea.isDragging ? 8 : (mouseArea.containsMouse ? 4 : 2)
        }

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

        visible: !isTrash && !isFolder && !isAdd
        opacity: root.isRunning ? 0.95 : 0.0
        color: "#ffffff"

        Behavior on opacity { NumberAnimation { duration: 200 } }

        layer.enabled: true
        layer.effect: DropShadow {
            color: "#ccffffff"
            radius: 4
            samples: 8
            horizontalOffset: 0
            verticalOffset: 0
        }
    }

    // ── Interactive Mouse Area & DnD ──
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: isDragging ? Qt.ClosedHandCursor : Qt.PointingHandCursor

        property real pressStartX: 0
        property real pressStartY: 0
        property bool isDragging: false

        onPressed: function(mouse) {
            pressStartX = mouse.x
            pressStartY = mouse.y
            isDragging = false

            if (mouse.button === Qt.RightButton) {
                // Map center of the icon to the screen window
                let mapped = root.mapToItem(null, root.width / 2, root.height / 2)
                if (dockState) {
                    dockState.openContextMenu(root.app, root.runningApp, root.isTrash, root.isFolder, mapped.x, mapped.y)
                }
            } else {
                if (dockState) dockState.closeContextMenu()
            }
        }

        onPositionChanged: function(mouse) {
            if (mouse.buttons & Qt.LeftButton && root.app && root.itemIndex >= 0) {
                let dx = mouse.x - pressStartX
                if (Math.abs(dx) > 6) {
                    isDragging = true
                    iconTranslate.x = dx
                }
            }
        }

        onReleased: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                if (isDragging && root.app && dockState && root.itemIndex >= 0) {
                    let dx = iconTranslate.x
                    let steps = Math.round(dx / 52)
                    if (steps !== 0) {
                        let targetIdx = Math.max(0, Math.min(dockState.pinnedList.length - 1, root.itemIndex + steps))
                        if (targetIdx !== root.itemIndex) {
                            dockState.reorderPinnedApp(root.itemIndex, targetIdx)
                        }
                    }
                } else if (!isDragging && Math.abs(mouse.x - pressStartX) < 12 && Math.abs(mouse.y - pressStartY) < 12) {
                    // Trigger click
                    root.triggerAction()
                }

                isDragging = false
                iconTranslate.x = 0
            }
        }
    }

    function triggerAction() {
        if (!dockState) return

        if (root.isAdd) {
            dockState.openAddModal()
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
