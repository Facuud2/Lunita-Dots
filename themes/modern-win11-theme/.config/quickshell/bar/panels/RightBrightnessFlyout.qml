import QtQuick

Item {
    id: root

    required property var barState
    property string screenName: ""
    property bool isOpen: false
    property bool animating: false
    property real currentY: (height > 0) ? (height - 220) / 2 : 300
    readonly property real tabY: tabContainer.y
    readonly property int windowWidth: (isOpen || animating) ? 44 : 8

    function updatePosition(my) {
        if (typeof my !== "number" || isNaN(my) || my < 0)
            return ;

        if (root.height <= 0)
            return ;

        var maxBound = root.height - 220 - 16;
        var minBound = 16;
        if (maxBound < minBound)
            maxBound = minBound;

        var targetY = my - 110;
        root.currentY = Math.max(minBound, Math.min(maxBound, targetY));
    }

    function open() {
        graceTimer.restart();
        animating = true;
        isOpen = true;
        tabCanvas.requestPaint();
    }

    function closeGracefully() {
        graceTimer.restart();
    }

    function closeImmediately() {
        graceTimer.stop();
        isOpen = false;
        animating = false;
        tabContainer.x = 44;
    }

    function toggle() {
        if (isOpen)
            closeGracefully();
        else
            open();
    }

    Timer {
        id: graceTimer

        interval: 350
        repeat: false
        onTriggered: {
            if (!sliderMouse.dragActive && !tabHover.containsMouse)
                root.isOpen = false;

        }
    }

    Connections {
        function onRequestCloseEdgePanels() {
            root.closeImmediately();
        }

        function onRequestToggleBrightness(targetScreen) {
            if (!targetScreen || targetScreen === "" || targetScreen === root.screenName)
                root.toggle();

        }

        target: root.barState
    }

    // ── 1. Edge Trigger Sensor (Active along full height at all times) ──
    Rectangle {
        id: edgeSensor

        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 8
        color: "transparent"

        MouseArea {
            id: edgeMouseArea

            function handleEdgeHover(my) {
                if (typeof my !== "number" || isNaN(my) || my < 0)
                    return ;

                var distFromCenter = Math.abs(my - (root.currentY + 110));
                if (!root.isOpen || distFromCenter > 110) {
                    if (distFromCenter > 110 && root.isOpen)
                        tabContainer.x = 44;

                    root.updatePosition(my);
                    root.open();
                }
            }

            anchors.fill: parent
            hoverEnabled: true
            onPositionChanged: (mouse) => {
                return handleEdgeHover(mouse.y);
            }
            onEntered: {
                if (edgeMouseArea.mouseY >= 0)
                    handleEdgeHover(edgeMouseArea.mouseY);
                else
                    root.open();
            }
            onExited: root.closeGracefully()
        }

    }

    // ── 2. Sliding Curved Tab ──
    Item {
        id: tabContainer

        width: 44
        height: 220
        y: root.currentY
        x: root.isOpen ? 0 : 44

        // Curved tab shape using Canvas (Full 42px width from y=30 to y=188)
        Canvas {
            id: tabCanvas

            anchors.fill: parent
            renderTarget: Canvas.FramebufferObject
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                var tabW = 42;
                var startX = 44;
                var leftX = 2;
                var h = 220;
                var r = 12;
                var fh = 20;
                ctx.beginPath();
                ctx.moveTo(startX, 0);
                ctx.bezierCurveTo(startX, 10, startX - tabW * 0.45, fh, leftX + r, fh);
                ctx.arc(leftX + r, fh + r, r, -Math.PI / 2, -Math.PI, true);
                ctx.lineTo(leftX, h - fh - r);
                ctx.arc(leftX + r, h - fh - r, r, Math.PI, Math.PI / 2, true);
                ctx.bezierCurveTo(startX - tabW * 0.45, h - fh, startX, h - 10, startX, h);
                ctx.lineTo(startX, 0);
                ctx.closePath();
                ctx.fillStyle = "#000000";
                ctx.fill();
            }
            Component.onCompleted: requestPaint()
        }

        // MouseArea tracking mouse presence over the open tab
        MouseArea {
            id: tabHover

            anchors.fill: parent
            hoverEnabled: true
            onEntered: graceTimer.stop()
            onExited: {
                if (!sliderMouse.dragActive)
                    graceTimer.restart();

            }
        }

        // ── Vertical Slider Track (Centered at x=23, y=34 to y=152) ──
        Rectangle {
            id: sliderTrack

            x: 18
            y: 34
            width: 10
            height: 118
            radius: 5
            color: "#2C2C2C"
            clip: true

            // Filled Pill (White)
            Rectangle {
                id: sliderFill

                width: parent.width
                height: Math.max(0, Math.min(parent.height, parent.height * (root.barState.brightnessPercent / 100)))
                anchors.bottom: parent.bottom
                radius: 5
                color: "#FFFFFF"

                Behavior on height {
                    enabled: !sliderMouse.dragActive

                    NumberAnimation {
                        duration: 80
                    }

                }

            }

        }

        // Slider Interactive MouseArea
        MouseArea {
            id: sliderMouse

            property bool dragActive: false

            function updateFromY(my) {
                var relY = my - 10;
                var clampedY = Math.max(0, Math.min(sliderTrack.height, relY));
                var pct = Math.max(5, Math.min(100, Math.round((1 - (clampedY / sliderTrack.height)) * 100)));
                root.barState.setBrightness(pct);
            }

            anchors.fill: sliderTrack
            anchors.margins: -10
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onPressed: (mouse) => {
                dragActive = true;
                graceTimer.stop();
                updateFromY(mouse.y);
            }
            onPositionChanged: (mouse) => {
                if (dragActive)
                    updateFromY(mouse.y);

            }
            onReleased: {
                dragActive = false;
                graceTimer.restart();
            }
            onCanceled: {
                dragActive = false;
                graceTimer.restart();
            }
            onWheel: (wheel) => {
                graceTimer.stop();
                if (wheel.angleDelta.y > 0)
                    root.barState.setBrightness(root.barState.brightnessPercent + 5);
                else
                    root.barState.setBrightness(root.barState.brightnessPercent - 5);
                graceTimer.restart();
            }
        }

        // ── Bottom Area: Sun Icon (Centered at x=23, y=162 to y=182, perfectly inside black tab) ──
        Item {
            id: bottomContainer

            anchors.horizontalCenter: sliderTrack.horizontalCenter
            y: 162
            width: 20
            height: 20

            Image {
                id: sunIcon

                anchors.centerIn: parent
                source: "../assets/brightness.svg"
                sourceSize.width: 16
                sourceSize.height: 16
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
            }

        }

        Behavior on x {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
                onRunningChanged: {
                    if (!running && !root.isOpen)
                        root.animating = false;

                }
            }

        }

    }

}
