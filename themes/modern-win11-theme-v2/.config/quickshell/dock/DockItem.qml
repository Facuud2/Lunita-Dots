import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property var app: null
    property var dockState: null
    property var panelWindow: null
    property int itemIndex: -1

    readonly property bool isPermanent: (root.app && (root.app.isStart || root.app.isPinned))
    property real itemWidth: isPermanent ? 44 : 0
    width: itemWidth
    height: 48
    implicitWidth: itemWidth
    implicitHeight: 48

    // Delicate organic bloom entrance (Matching Dynamic Island / Dynamic Bar)
    opacity: isPermanent ? 1.0 : 0.0
    scale: isPermanent ? 1.0 : 0.82

    Component.onCompleted: {
        if (!isPermanent) {
            itemWidth = 44;
            opacity = 1.0;
            scale = 1.0;
        }
    }

    property bool isClosing: (root.app && root.app.isClosing) ? true : false
    onIsClosingChanged: {
        if (isClosing) {
            itemWidth = 0;
            opacity = 0.0;
            scale = 0.82;
        }
    }

    Behavior on itemWidth {
        NumberAnimation {
            duration: 360
            easing.type: Easing.InOutCubic
            onRunningChanged: {
                if (!running && root.isClosing && root.dockState && root.app) {
                    root.dockState.finalizeAppRemoval(root.app.id);
                }
            }
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: 260
            easing.type: Easing.OutQuad
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 340
            easing.type: Easing.OutBack
            easing.overshoot: 1.12
        }
    }

    property bool isRunning: {
        if (!root.app || root.app.isStart) return false;
        if (root.app.isRunning !== undefined) return !!root.app.isRunning;
        return (root.dockState) ? root.dockState.isAppRunning(root.app) : false;
    }
    property bool isFocused: {
        if (!root.app || root.app.isStart) return false;
        if (root.app.isFocused !== undefined) return !!root.app.isFocused;
        return (root.dockState) ? root.dockState.isAppFocused(root.app) : false;
    }
    property bool isHovered: itemMouse.containsMouse || root.isDragging || root.isSnapping

    readonly property string iconSource: {
        if (!app) return Qt.resolvedUrl("assets/icons/appstore.svg");
        if (app.icon) {
            var ic = String(app.icon);
            if (ic.indexOf("file://") === 0 || ic.indexOf("image://qspixmap/") === 0 || ic.indexOf("image://qsimage/") === 0) {
                return ic;
            }
            if (ic.indexOf("image://icon/") === 0) {
                var cleanName = ic.substring(13);
                if (root.dockState && root.dockState.appIconsMap && root.dockState.appIconsMap[cleanName]) {
                    return root.dockState.appIconsMap[cleanName];
                }
            }
            if (root.dockState && root.dockState.appIconsMap && root.dockState.appIconsMap[ic]) {
                return root.dockState.appIconsMap[ic];
            }
            if (ic.indexOf(".svg") !== -1 || ic.indexOf(".png") !== -1) {
                return Qt.resolvedUrl("assets/icons/" + ic);
            }
        }
        if (app.clazz && root.dockState && root.dockState.appIconsMap && root.dockState.appIconsMap[app.clazz]) {
            return root.dockState.appIconsMap[app.clazz];
        }
        if (app.id && root.dockState && root.dockState.appIconsMap && root.dockState.appIconsMap[app.id]) {
            return root.dockState.appIconsMap[app.id];
        }
        if (app.iconFile) return Qt.resolvedUrl("assets/icons/" + app.iconFile);
        return Qt.resolvedUrl("assets/icons/appstore.svg");
    }

    // ── 1. Inner Clipped Slot Container ──
    Item {
        id: slotContent
        anchors.fill: parent
        clip: true

        // Hover Tile Highlight
        Rectangle {
            anchors.fill: parent
            anchors.topMargin: 4
            anchors.bottomMargin: 6
            anchors.leftMargin: 2
            anchors.rightMargin: 2
            radius: 6
            color: root.isDragging ? Qt.rgba(1, 1, 1, 0.28) : (itemMouse.pressed ? Qt.rgba(1, 1, 1, 0.22) : (root.isHovered ? Qt.rgba(1, 1, 1, 0.18) : "transparent"))
            border.color: (root.isDragging || root.isHovered) ? Qt.rgba(1, 1, 1, 0.30) : "transparent"
            border.width: 1
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        // App Icon Container
        Item {
            id: iconContainer
            width: 34
            height: 34
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: (root.isRunning && root.app && !root.app.isStart) ? -2 : 0

            scale: root.isHovered ? 1.08 : 1.0
            y: root.isHovered ? -2 : 0

            Behavior on scale {
                enabled: !root.isDragging
                NumberAnimation { duration: 160; easing.type: Easing.OutQuad }
            }
            Behavior on y {
                enabled: !root.isDragging
                NumberAnimation { duration: 160; easing.type: Easing.OutQuad }
            }

            Image {
                id: iconImg
                anchors.fill: parent
                anchors.margins: (root.app && root.app.isStart) ? 1 : 0
                source: root.iconSource
                sourceSize.width: 34
                sourceSize.height: 34
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            // Notification Badge (OBS or notification status)
            Rectangle {
                id: notifBadge
                visible: (root.app && (root.app.hasBadge || (root.app.id === "obs" && root.isRunning)))
                width: 8
                height: 8
                radius: 4
                color: "#FF3B30"
                border.color: Qt.rgba(0, 0, 0, 0.5)
                border.width: 1
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: -1
                anchors.rightMargin: -1
                z: 10
            }
        }

        // Running Indicator Pill
        Rectangle {
            id: runningIndicator
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 3
            width: root.isHovered ? 14 : (root.isFocused ? 12 : 6)
            height: 3
            radius: 1.5
            color: root.isFocused ? "#60CDFF" : Qt.rgba(1, 1, 1, 0.75)
            visible: (root.app && !root.app.isStart)
            opacity: root.isRunning ? 1.0 : 0.0

            Behavior on opacity { NumberAnimation { duration: 180 } }
            Behavior on width { NumberAnimation { duration: 160; easing.type: Easing.OutQuad } }
            Behavior on color { ColorAnimation { duration: 160 } }
        }
    }

    // ── 2. Tooltip (Elevated, outside clipped container so it is NEVER clipped) ──
    Rectangle {
        id: tooltip
        anchors.bottom: parent.top
        anchors.bottomMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(260, tooltipText.implicitWidth + 18)
        height: 24
        radius: 6
        color: Qt.rgba(0.12, 0.13, 0.16, 0.95)
        border.color: Qt.rgba(1, 1, 1, 0.16)
        border.width: 1
        visible: itemMouse.containsMouse && !root.isDragging && !root.isSnapping && root.app !== null && (root.dockState ? !root.dockState.contextMenuVisible : true)
        opacity: (itemMouse.containsMouse && !root.isDragging && !root.isSnapping && root.app !== null && (root.dockState ? !root.dockState.contextMenuVisible : true)) ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 140 } }
        z: 9999

        Text {
            id: tooltipText
            anchors.centerIn: parent
            text: (root.app && root.app.name) ? root.app.name : ""
            font.family: "Segoe UI, Inter, sans-serif"
            font.pixelSize: 11
            font.weight: Font.Medium
            color: "#FFFFFF"
            elide: Text.ElideRight
            width: Math.min(240, implicitWidth)
        }
    }

    // ── Drag & Drop Reordering ──
    property bool isDragging: false
    property bool isSnapping: false
    property real dragStartParentX: 0
    property real dragOffset: 0
    property real snapOffset: 0
    property real minDragDelta: 0
    property real maxDragDelta: 0
    property bool canDrag: false

    // Live neighbor shift (when another item is dragged over this slot)
    readonly property real neighborShift: {
        if (root.isDragging || !root.dockState || !root.app) return 0;
        var appId = root.app.id || root.app.clazz || "";
        return root.dockState.getNeighborShift(appId);
    }

    property real animatedNeighborShift: 0

    Behavior on animatedNeighborShift {
        id: neighborShiftBehavior
        enabled: root.dockState ? !root.dockState.dragJustCommitted : true
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    onNeighborShiftChanged: {
        animatedNeighborShift = neighborShift;
    }

    z: (isDragging || isSnapping) ? 9999 : (root.isHovered ? 10 : 1)

    transform: Translate {
        id: dragTranslate
        x: root.isDragging ? root.dragOffset : (root.isSnapping ? root.snapOffset : root.animatedNeighborShift)
    }

    NumberAnimation {
        id: snapAnimation
        target: root
        property: "snapOffset"
        to: 0
        duration: 180
        easing.type: Easing.OutQuad
        onFinished: {
            root.isSnapping = false;
            root.snapOffset = 0;
        }
    }

    function updateDragBounds() {
        if (!root.app || root.app.isStart || !root.dockState) {
            canDrag = false;
            minDragDelta = 0;
            maxDragDelta = 0;
            return;
        }

        var appId = root.app.id || root.app.clazz || "";
        if (!appId || appId === "start") {
            canDrag = false;
            minDragDelta = 0;
            maxDragDelta = 0;
            return;
        }

        if (root.dockState.isPinned(appId)) {
            var pIdx = root.dockState.getPinnedIndex(appId);
            var pCount = root.dockState.pinnedAppsModel.count;
            if (pIdx >= 0 && pCount > 1) {
                canDrag = true;
                minDragDelta = -pIdx * 48;
                maxDragDelta = (pCount - 1 - pIdx) * 48;
            } else {
                canDrag = false;
                minDragDelta = 0;
                maxDragDelta = 0;
            }
        } else {
            var uIdx = root.dockState.getUnpinnedIndex(appId);
            var uCount = root.dockState.unpinnedAppsModel.count;
            if (uIdx >= 0 && uCount > 1) {
                canDrag = true;
                minDragDelta = -uIdx * 48;
                maxDragDelta = (uCount - 1 - uIdx) * 48;
            } else {
                canDrag = false;
                minDragDelta = 0;
                maxDragDelta = 0;
            }
        }
    }

    MouseArea {
        id: itemMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.isDragging ? Qt.ClosedHandCursor : Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onPressed: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                snapAnimation.stop();
                root.isSnapping = false;
                root.snapOffset = 0;
                root.dragOffset = 0;
                root.isDragging = false;

                // Track starting position in parent (contentRow) coordinate system
                var pt = root.mapToItem(root.parent, mouse.x, mouse.y);
                root.dragStartParentX = pt.x;

                root.updateDragBounds();
                if (root.dockState) root.dockState.closeContextMenu();
            } else if (mouse.button === Qt.RightButton) {
                // Calculate global coordinate for Context Menu in Overlay
                let screenW = (root.panelWindow && root.panelWindow.screen) ? root.panelWindow.screen.width : 1920;
                let scrName = (root.panelWindow && root.panelWindow.screen) ? root.panelWindow.screen.name : "";
                let winW = root.panelWindow ? root.panelWindow.width : 540;
                let dockScreenX = (screenW - winW) / 2;
                let mapped = root.mapToItem(null, root.width / 2, root.height / 2);
                let globalX = dockScreenX + mapped.x;

                if (root.dockState) {
                    root.dockState.openContextMenu(root.app, globalX, scrName);
                }
            }
        }

        onPositionChanged: function(mouse) {
            if (!root.canDrag) return;
            if (mouse.buttons & Qt.LeftButton) {
                var curPt = root.mapToItem(root.parent, mouse.x, mouse.y);
                var rawDelta = curPt.x - root.dragStartParentX;

                if (!root.isDragging) {
                    // Soft threshold: require 5px of intentional movement before initiating drag
                    if (Math.abs(rawDelta) >= 5) {
                        root.isDragging = true;
                        // Adjust dragStartParentX so drag begins smoothly from 0px
                        root.dragStartParentX += (rawDelta > 0 ? 5 : -5);
                        rawDelta = curPt.x - root.dragStartParentX;
                    }
                }

                if (root.isDragging) {
                    // Clamp strictly within the dock slots so it can never escape the bar
                    var clampedDx = Math.max(root.minDragDelta, Math.min(root.maxDragDelta, rawDelta));
                    root.dragOffset = clampedDx;

                    // Compute live preview steps and notify dockState so neighbors slide aside
                    var steps = Math.round(clampedDx / 48);
                    var appId = root.app.id || root.app.clazz || "";
                    if (root.dockState && appId) {
                        root.dockState.setDragPreview(appId, steps);
                    }
                }
            }
        }

        onReleased: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                if (root.isDragging && root.canDrag && root.dockState && root.app) {
                    var currentDx = root.dragOffset;
                    var steps = Math.round(currentDx / 48);
                    var appId = root.app.id || root.app.clazz || "";

                    var targetOffset = steps * 48;
                    var residual = currentDx - targetOffset;

                    // Commit drag in dockState (moves model item and clears preview)
                    root.dockState.commitDrag(appId, steps);

                    root.isDragging = false;
                    root.dragOffset = 0;

                    // Animate residual offset to 0 so the icon settles seamlessly
                    root.snapOffset = residual;
                    root.isSnapping = true;
                    snapAnimation.from = residual;
                    snapAnimation.to = 0;
                    snapAnimation.restart();
                } else if (!root.isDragging) {
                    var curPt = root.mapToItem(root.parent, mouse.x, mouse.y);
                    if (Math.abs(curPt.x - root.dragStartParentX) < 6) {
                        if (root.app && root.dockState) {
                            root.dockState.launchApp(root.app);
                        }
                    }
                }
                root.isDragging = false;
            }
        }

        onCanceled: function() {
            if (root.isDragging) {
                if (root.dockState) root.dockState.clearDragPreview();
                root.snapOffset = root.dragOffset;
                root.isSnapping = true;
                root.isDragging = false;
                root.dragOffset = 0;
                snapAnimation.from = root.snapOffset;
                snapAnimation.to = 0;
                snapAnimation.restart();
            }
            root.isDragging = false;
        }
    }
}

