import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property var widgetsState
    property var widgetData: null
    property var canvas: null
    property string screenName: canvas ? canvas.screenName : "default"
    readonly property bool isClock: root.widgetData && (root.widgetData.type === "clock" || root.widgetData.id === "clk")
    // Visual State & Jiggle Animation
    property bool isDragging: dragArea.drag.active
    property bool isResizing: false
    property real targetRotation: 0

    function applyData(newData) {
        if (!newData)
            return ;

        root.widgetData = newData;
        if (!root.isDragging) {
            if (root.x !== newData.x)
                root.x = newData.x;

            if (root.y !== newData.y)
                root.y = newData.y;

        }
        if (root.isClock) {
            root.width = 170;
            root.height = 170;
        } else if (!root.isResizing) {
            if (root.width !== newData.width)
                root.width = newData.width;

            if (root.height !== newData.height)
                root.height = newData.height;

        }
    }

    // Position and size properties
    x: widgetData ? widgetData.x : 0
    y: widgetData ? widgetData.y : 0
    width: isClock ? 170 : (widgetData ? widgetData.width : 170)
    height: isClock ? 170 : (widgetData ? widgetData.height : 170)
    Component.onCompleted: {
        if (widgetData) {
            root.x = widgetData.x;
            root.y = widgetData.y;
            root.width = root.isClock ? 170 : widgetData.width;
            root.height = root.isClock ? 170 : widgetData.height;
        }
    }
    // Elevation & Scale feedback while dragging
    scale: isDragging ? 1.05 : 1

    // ── iOS / macOS Jiggle Animation ──
    SequentialAnimation {
        id: jiggleAnim

        running: root.widgetsState.isEditing && !root.isDragging
        loops: Animation.Infinite

        NumberAnimation {
            target: jiggleRotation
            property: "angle"
            from: -1.2
            to: 1.2
            duration: 130
            easing.type: Easing.InOutSine
        }

        NumberAnimation {
            target: jiggleRotation
            property: "angle"
            from: 1.2
            to: -1.2
            duration: 130
            easing.type: Easing.InOutSine
        }

    }

    // Reset rotation when exiting edit mode
    Connections {
        function onIsEditingChanged() {
            if (!root.widgetsState.isEditing) {
                jiggleAnim.stop();
                jiggleRotation.angle = 0;
            }
        }

        target: root.widgetsState
    }

    // ── Inner Widget Component Loader ──
    Loader {
        id: contentLoader

        anchors.fill: parent
        enabled: !root.widgetsState.isEditing
        sourceComponent: {
            if (!root.widgetData)
                return null;

            var t = root.widgetData.type;
            if (t === "calendar")
                return calComp;

            if (t === "resources")
                return sysComp;

            if (t === "network")
                return netComp;

            if (t === "clock")
                return clkComp;

            if (t === "photos")
                return phoComp;

            if (t === "battery")
                return batComp;

            if (t === "git")
                return gitComp;

            if (t === "habits")
                return habComp;

            if (t === "timetable")
                return ttbComp;

            if (t === "weather")
                return wthComp;

            if (t === "files")
                return filesComp;

            if (t === "media")
                return medComp;

            return calComp;
        }
    }

    Component {
        id: calComp

        CalendarWidget {
            widgetsState: root.widgetsState
        }

    }

    Component {
        id: sysComp

        SystemResourcesWidget {
            widgetsState: root.widgetsState
        }

    }

    Component {
        id: netComp

        NetworkWidget {
            widgetsState: root.widgetsState
        }

    }

    Component {
        id: clkComp

        ClockWidget {
            widgetsState: root.widgetsState
            canvas: root.canvas
        }

    }

    Component {
        id: wthComp

        WeatherWidget {
            widgetsState: root.widgetsState
        }

    }

    Component {
        id: filesComp

        FilesWidget {
            widgetsState: root.widgetsState
        }

    }

    Component {
        id: phoComp

        PhotoWidget {
            widgetsState: root.widgetsState
        }

    }

    Component {
        id: batComp

        BatteryWidget {
            widgetsState: root.widgetsState
        }

    }

    Component {
        id: gitComp

        GitActivityWidget {
            widgetsState: root.widgetsState
        }

    }

    Component {
        id: habComp

        HabitTrackerWidget {
            widgetsState: root.widgetsState
        }

    }

    Component {
        id: ttbComp

        TimetableWidget {
            widgetsState: root.widgetsState
        }

    }

    Component {
        id: medComp

        MediaWidget {
            widgetsState: root.widgetsState
            canvas: root.canvas
        }

    }

    // ── Drag & Reposition MouseArea (Whole Card in Edit Mode) ──
    MouseArea {
        id: dragArea

        anchors.fill: parent
        z: 80
        enabled: root.widgetsState.isEditing
        drag.target: root
        drag.axis: Drag.XAndYAxis
        cursorShape: root.widgetsState.isEditing ? (drag.active ? Qt.ClosedHandCursor : Qt.OpenHandCursor) : Qt.ArrowCursor
        onReleased: {
            // Magnetic snap to a 20px desktop grid
            var snappedX = Math.round(root.x / 20) * 20;
            var snappedY = Math.round(root.y / 20) * 20;
            // Boundary constraints
            snappedX = Math.max(20, Math.min(1920 - root.width - 20, snappedX));
            snappedY = Math.max(40, Math.min(1080 - root.height - 80, snappedY));
            root.x = snappedX;
            root.y = snappedY;
            if (root.widgetData) {
                if (root.canvas)
                    root.canvas.updateWidgetPosition(root.widgetData.id, snappedX, snappedY);
                else if (root.widgetsState)
                    root.widgetsState.updateWidgetPosition(root.screenName, root.widgetData.id, snappedX, snappedY);
            }
        }
    }

    // ── Edit Controls Layer (Delete X & Resize Handle) ──
    Item {
        anchors.fill: parent
        visible: root.widgetsState.isEditing

        // 1. Delete '✕' Button (Top-Left Corner)
        Rectangle {
            id: deleteBtn

            x: -8
            y: -8
            width: 26
            height: 26
            radius: 13
            color: deleteMa.containsMouse ? "#FF3B30" : "#E63C32"
            border.color: "#FFFFFF"
            border.width: 1.5
            scale: deleteMa.containsMouse ? 1.15 : 1

            Text {
                anchors.centerIn: parent
                text: "✕"
                font.family: "SF Pro Display"
                font.pixelSize: 11
                font.weight: Font.Black
                color: "#FFFFFF"
            }

            MouseArea {
                id: deleteMa

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.widgetData) {
                        if (root.canvas)
                            root.canvas.removeWidget(root.widgetData.id);
                        else if (root.widgetsState)
                            root.widgetsState.removeWidget(root.screenName, root.widgetData.id);
                    }
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 120
                }

            }

        }

        // 2. Resize Handle Button (Bottom-Right Corner)
        Rectangle {
            id: resizeHandle

            visible: !root.isClock
            enabled: !root.isClock
            x: parent.width - width + 8
            y: parent.height - height + 8
            width: 28
            height: 28
            radius: 14
            color: resizeMa.containsMouse || resizeMa.drag.active ? "#007AFF" : (root.widgetsState.isDarkTheme ? "#2C2C34" : "#FFFFFF")
            border.color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.40)" : "rgba(0,0,0,0.25)"
            border.width: 1.5
            scale: resizeMa.containsMouse || resizeMa.drag.active ? 1.15 : 1

            Text {
                anchors.centerIn: parent
                text: "󰁌"
                font.family: "CaskaydiaCove Nerd Font"
                font.pixelSize: 12
                color: resizeMa.containsMouse || resizeMa.drag.active ? "#FFFFFF" : root.widgetsState.textColor
            }

            // Drag MouseArea for Continuous Dynamic Resizing
            MouseArea {
                id: resizeMa

                property real startX: 0
                property real startY: 0
                property real initialW: 170
                property real initialH: 170

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.SizeFDiagCursor
                onPressed: {
                    startX = mouse.x;
                    startY = mouse.y;
                    initialW = root.width;
                    initialH = root.height;
                    root.isResizing = true;
                }
                onPositionChanged: {
                    if (pressed) {
                        var deltaX = mouse.x - startX;
                        var deltaY = mouse.y - startY;
                        var newW = Math.max(170, initialW + deltaX);
                        var newH = Math.max(170, initialH + deltaY);
                        root.width = newW;
                        root.height = newH;
                    }
                }
                onReleased: {
                    root.isResizing = false;
                    // Snap to standard macOS widget dimensions
                    var finalW = 170;
                    var finalH = 170;
                    var sizeName = "small";
                    if (root.width > 260) {
                        finalW = 354;
                        if (root.height > 260) {
                            finalH = 354;
                            sizeName = "large";
                        } else {
                            finalH = 176;
                            sizeName = "medium";
                        }
                    } else {
                        finalW = 170;
                        finalH = 170;
                        sizeName = "small";
                    }
                    root.width = finalW;
                    root.height = finalH;
                    if (root.widgetData) {
                        if (root.canvas)
                            root.canvas.updateWidgetSize(root.widgetData.id, finalW, finalH, sizeName);
                        else if (root.widgetsState)
                            root.widgetsState.updateWidgetSize(root.screenName, root.widgetData.id, finalW, finalH, sizeName);
                    }
                }
            }

            Behavior on scale {
                NumberAnimation {
                    duration: 120
                }

            }

        }

    }

    Behavior on x {
        enabled: !root.isDragging

        NumberAnimation {
            duration: 340
            easing.type: Easing.OutCubic
        }

    }

    Behavior on y {
        enabled: !root.isDragging

        NumberAnimation {
            duration: 340
            easing.type: Easing.OutCubic
        }

    }

    Behavior on width {
        enabled: !root.isResizing

        NumberAnimation {
            duration: 340
            easing.type: Easing.OutCubic
        }

    }

    Behavior on height {
        enabled: !root.isResizing

        NumberAnimation {
            duration: 340
            easing.type: Easing.OutCubic
        }

    }

    transform: Rotation {
        id: jiggleRotation

        origin.x: root.width / 2
        origin.y: root.height / 2
        angle: 0
    }

    Behavior on scale {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutQuad
        }

    }

}
