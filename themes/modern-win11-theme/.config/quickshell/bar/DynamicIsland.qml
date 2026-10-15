import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Qt5Compat.GraphicalEffects

Item {
    id: root

    required property var barState
    property alias islandBg: islandBg

    // Island modes: "collapsed" | "options" | "wifi" | "bluetooth" | "media"
    property string islandMode: "collapsed"
    property bool wasHeld: false

    // Sizing
    property real targetWidth: {
        if (root.islandMode === "options" || root.islandMode === "wifi" || root.islandMode === "bluetooth" || root.islandMode === "media") {
            return 380;
        }
        return root.barState.mprisActive ? 230 : 130; // collapsed notch
    }

    property real targetHeight: {
        if (root.islandMode === "options" || root.islandMode === "wifi" || root.islandMode === "bluetooth") {
            return 280;
        }
        if (root.islandMode === "media") {
            return 172;
        }
        return 34; // collapsed notch
    }

    width: targetWidth
    height: targetHeight
    clip: false

    implicitWidth: width
    implicitHeight: height

    property bool isExpanding: root.islandMode !== "collapsed"

    // iOS / iPadOS Dynamic Island Fluid Physics (Organic Pill-Stretch + Bloom)
    Behavior on width {
        NumberAnimation {
            duration: root.isExpanding ? 360 : 280
            easing.type: Easing.OutCubic
        }
    }
    Behavior on height {
        NumberAnimation {
            duration: root.isExpanding ? 360 : 280
            easing.type: Easing.OutCubic
        }
    }

    // Master hover tracker across the dynamic island and its controls
    HoverHandler {
        id: islandHover
        onHoveredChanged: {
            if (islandHover.hovered) {
                collapseTimer.stop();
                if (root.islandMode === "collapsed") {
                    root.islandMode = "options";
                }
            } else {
                collapseTimer.restart();
            }
        }
    }

    // Synchronize external IPC / BarState popup requests
    Connections {
        target: root.barState
        function onActivePopupChanged() {
            if (root.barState.activePopup === "media") {
                root.islandMode = "media";
            } else if (root.barState.activePopup === "controlcenter" || root.barState.activePopup === "options") {
                root.islandMode = "options";
            } else if (root.barState.activePopup === "") {
                root.islandMode = "collapsed";
            }
        }
    }

    // Grace timer for smooth mouse leave collapse
    Timer {
        id: collapseTimer
        interval: (root.islandMode === "media") ? 400 : 320
        repeat: false
        onTriggered: {
            if (!islandHover.hovered) {
                root.islandMode = "collapsed";
                root.barState.closePopups();
            }
        }
    }

    // ── 1. Main Background Surface Flush with Screen Top (y: 0) ──
    Rectangle {
        id: islandBg
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.top: parent.top
        anchors.topMargin: -2 // Pushes top border stroke offscreen so top edge is 100% flush
        topLeftRadius: 0
        topRightRadius: 0
        bottomLeftRadius: (root.islandMode === "collapsed") ? 18 : 22
        bottomRightRadius: (root.islandMode === "collapsed") ? 18 : 22
        clip: true

        Behavior on bottomLeftRadius {
            NumberAnimation {
                duration: root.isExpanding ? 360 : 280
                easing.type: Easing.OutCubic
            }
        }
        Behavior on bottomRightRadius {
            NumberAnimation {
                duration: root.isExpanding ? 360 : 280
                easing.type: Easing.OutCubic
            }
        }

        // Background color & gradient
        color: (root.islandMode === "media") ? "transparent" : "#08090C"
        border.color: Qt.rgba(1, 1, 1, 0.15)
        border.width: 1

        Behavior on color { ColorAnimation { duration: 220 } }

        // Warm amber / orange gradient for Music Player Card (Refined to match Image 2)
        gradient: (root.islandMode === "media") ? mediaGradient : null

        Gradient {
            id: mediaGradient
            GradientStop { position: 0.0; color: "#140602" }
            GradientStop { position: 0.28; color: "#6A2206" }
            GradientStop { position: 0.48; color: "#B8430A" }
            GradientStop { position: 0.72; color: "#541B05" }
            GradientStop { position: 1.0; color: "#110401" }
        }
    }

    // ── Inverted Ear Wings (Seamless Notch Fillets matching Image 2) ──
    Shape {
        id: leftEar
        anchors.right: islandBg.left
        anchors.top: islandBg.top
        anchors.topMargin: 2
        width: 14
        height: 14
        visible: root.islandMode !== "collapsed"
        opacity: visible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 220 } }

        ShapePath {
            fillColor: "#000000"
            strokeColor: "transparent"
            startX: 0; startY: 0
            PathLine { x: 14; y: 0 }
            PathLine { x: 14; y: 14 }
            PathArc {
                x: 0; y: 0
                radiusX: 14; radiusY: 14
                direction: PathArc.Counterclockwise
            }
        }
    }

    Shape {
        id: rightEar
        anchors.left: islandBg.right
        anchors.top: islandBg.top
        anchors.topMargin: 2
        width: 14
        height: 14
        visible: root.islandMode !== "collapsed"
        opacity: visible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 220 } }

        ShapePath {
            fillColor: "#000000"
            strokeColor: "transparent"
            startX: 0; startY: 0
            PathLine { x: 14; y: 0 }
            PathArc {
                x: 0; y: 14
                radiusX: 14; radiusY: 14
                direction: PathArc.Counterclockwise
            }
            PathLine { x: 0; y: 0 }
        }
    }

    // ── 2. Master Interactive MouseArea (Hold / Click on Island Body) ──
    MouseArea {
        id: islandMouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        pressAndHoldInterval: 300

        onPressAndHold: {
            root.wasHeld = true;
            if (root.islandMode === "media") {
                root.islandMode = "options";
            } else {
                root.islandMode = "media";
            }
        }

        onClicked: {
            if (root.wasHeld) {
                root.wasHeld = false;
                return;
            }
            if (root.islandMode === "collapsed") {
                root.islandMode = "options";
            } else if (root.islandMode === "media") {
                root.islandMode = "options";
            }
        }

        onReleased: {
            resetHeldTimer.restart();
        }
    }

    Timer {
        id: resetHeldTimer
        interval: 60
        onTriggered: root.wasHeld = false
    }

    // ── Content Container (Clips all interior layers during pill stretch) ──
    Item {
        id: contentContainer
        anchors.fill: parent
        clip: true

        // =========================================================================
        // LAYER A: COLLAPSED NOTCH CONTENT (Dynamic width, height: 34)
        // =========================================================================
        Item {
            id: collapsedContent
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            width: root.width
            height: 34
            visible: opacity > 0.001
            opacity: (root.islandMode === "collapsed") ? 1.0 : 0.0

            Behavior on opacity {
                SequentialAnimation {
                    PauseAnimation { duration: (root.islandMode === "collapsed") ? 200 : 0 }
                    NumberAnimation {
                        duration: (root.islandMode === "collapsed") ? 120 : 60
                        easing.type: (root.islandMode === "collapsed") ? Easing.OutCubic : Easing.OutQuad
                    }
                }
            }

            transform: Translate {
                y: (root.islandMode === "collapsed") ? 0 : -6
                Behavior on y {
                    SequentialAnimation {
                        PauseAnimation { duration: (root.islandMode === "collapsed") ? 180 : 0 }
                        NumberAnimation {
                            duration: 180
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }

            // 1. Symmetrical Waveform / CAVA Bars (Only visible if media active)
            Item {
                id: leftMediaSlot
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                width: waveformBars.implicitWidth
                height: 20
                visible: opacity > 0.001
                opacity: root.barState.mprisActive ? 1.0 : 0.0
                scale: root.barState.mprisActive ? 1.0 : 0.5
                transformOrigin: Item.Center

                Behavior on opacity {
                    SequentialAnimation {
                        PauseAnimation { duration: root.barState.mprisActive ? 90 : 0 }
                        NumberAnimation {
                            duration: root.barState.mprisActive ? 180 : 100
                            easing.type: root.barState.mprisActive ? Easing.OutCubic : Easing.OutQuad
                        }
                    }
                }

                Behavior on scale {
                    SequentialAnimation {
                        PauseAnimation { duration: root.barState.mprisActive ? 90 : 0 }
                        NumberAnimation {
                            duration: root.barState.mprisActive ? 180 : 100
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                WaveformBars {
                    id: waveformBars
                    anchors.centerIn: parent
                    isPlaying: root.barState.mprisPlaying
                    values: root.barState.cavaBars
                    barColor: root.barState.mprisPlaying ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.65)
                }
            }

            // 2. Center Clock Typography (Always rock-solid centered)
            Text {
                id: notchClock
                anchors.centerIn: parent
                text: root.barState.timeStr
                font.family: "Segoe UI, Inter, Cantarell, sans-serif"
                font.pixelSize: 13
                font.weight: Font.Bold
                color: "#FFFFFF"
            }

            // 3. Mini Art Thumbnail (Only visible if media active, iOS-Like Rounded Corners)
            Item {
                id: rightMediaSlot
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                width: 22
                height: 22
                visible: opacity > 0.001
                opacity: root.barState.mprisActive ? 1.0 : 0.0
                scale: root.barState.mprisActive ? 1.0 : 0.5
                transformOrigin: Item.Center

                Behavior on opacity {
                    SequentialAnimation {
                        PauseAnimation { duration: root.barState.mprisActive ? 90 : 0 }
                        NumberAnimation {
                            duration: root.barState.mprisActive ? 180 : 100
                            easing.type: root.barState.mprisActive ? Easing.OutCubic : Easing.OutQuad
                        }
                    }
                }

                Behavior on scale {
                    SequentialAnimation {
                        PauseAnimation { duration: root.barState.mprisActive ? 90 : 0 }
                        NumberAnimation {
                            duration: root.barState.mprisActive ? 180 : 100
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                Image {
                    id: miniCoverImg
                    anchors.fill: parent
                    source: root.barState.mprisArtUrl !== "" ? root.barState.mprisArtUrl : ""
                    visible: false
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }

                Rectangle {
                    id: miniCoverMask
                    anchors.fill: parent
                    radius: 7
                    visible: false
                }

                OpacityMask {
                    anchors.fill: parent
                    source: miniCoverImg
                    maskSource: miniCoverMask
                    visible: root.barState.mprisArtUrl !== ""
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 7
                    visible: root.barState.mprisArtUrl === ""
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#D47A3B" }
                        GradientStop { position: 1.0; color: "#542D15" }
                    }
                    Image {
                        anchors.centerIn: parent
                        source: "assets/music.svg"
                        sourceSize.width: 11
                        sourceSize.height: 11
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 7
                    color: "transparent"
                    border.color: Qt.rgba(1, 1, 1, 0.20)
                    border.width: 1
                }
            }
    }

    // =========================================================================
    // LAYER B: GENERAL OPTIONS MENU CONTENT (width: 380, height: 280)
    // =========================================================================
    Item {
        id: optionsContent
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: 380
        height: 280
        visible: opacity > 0.001

        property bool isActive: root.islandMode === "options"

        opacity: isActive ? 1.0 : 0.0
        Behavior on opacity {
            SequentialAnimation {
                PauseAnimation { duration: (optionsContent.isActive && root.height < 120) ? 260 : 0 }
                NumberAnimation {
                    duration: optionsContent.isActive ? 160 : 60
                    easing.type: optionsContent.isActive ? Easing.OutCubic : Easing.OutQuad
                }
            }
        }

        transform: Translate {
            y: optionsContent.isActive ? 0 : (root.islandMode === "collapsed" ? -12 : 0)
            x: (root.islandMode === "wifi" || root.islandMode === "bluetooth") ? -28 : 0
            Behavior on y {
                SequentialAnimation {
                    PauseAnimation { duration: (optionsContent.isActive && root.height < 120) ? 240 : 0 }
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
            }
            Behavior on x {
                NumberAnimation { duration: 260; easing.type: Easing.OutCubic }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            anchors.topMargin: 10
            spacing: 11

            // 1. Top Header Row: Weather, Time, Battery (Clean Vector SVGs)
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 18

                // Weather
                Row {
                    spacing: 5
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                    Image {
                        source: "assets/moon.svg"
                        sourceSize.width: 12
                        sourceSize.height: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: root.barState.weatherTemp
                        font.family: "Segoe UI, Inter, Cantarell, sans-serif"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: Qt.rgba(1, 1, 1, 0.85)
                    }
                }

                Item { Layout.fillWidth: true }

                // Time
                Text {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    text: root.barState.timeStr
                    font.family: "Segoe UI, Inter, Cantarell, sans-serif"
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    color: "#FFFFFF"
                }

                Item { Layout.fillWidth: true }

                // Battery
                Row {
                    spacing: 4
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                    Image {
                        source: "assets/battery.svg"
                        sourceSize.width: 15
                        sourceSize.height: 15
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: root.barState.batteryPercent + "%"
                        font.family: "Segoe UI, Inter, Cantarell, sans-serif"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: Qt.rgba(1, 1, 1, 0.85)
                    }
                }
            }

            // 2. Wi-Fi & Bluetooth Buttons (Row of 2, opens subviews)
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // Wi-Fi Submenu Button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    radius: 12
                    color: root.barState.wifiConnected ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.08)
                    border.color: Qt.rgba(1, 1, 1, 0.12)
                    border.width: root.barState.wifiConnected ? 0 : 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        Image {
                            source: root.barState.wifiConnected ? "assets/wifi-dark.svg" : "assets/wifi.svg"
                            sourceSize.width: 17
                            sourceSize.height: 17
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                text: "Wi-Fi"
                                font.family: "Segoe UI, Inter, sans-serif"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: root.barState.wifiConnected ? "#111215" : "#FFFFFF"
                            }
                            Text {
                                text: root.barState.wifiConnected ? (root.barState.wifiSsid || "Conectado") : (root.barState.wifiEnabled ? "Desconectado" : "Desactivado")
                                font.family: "Segoe UI, Inter, sans-serif"
                                font.pixelSize: 9
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                color: root.barState.wifiConnected ? Qt.rgba(0.1, 0.1, 0.1, 0.7) : Qt.rgba(1, 1, 1, 0.5)
                            }
                        }

                        Image {
                            source: "assets/chevron-right.svg"
                            sourceSize.width: 10
                            sourceSize.height: 10
                            opacity: root.barState.wifiConnected ? 0.6 : 0.4
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.barState.rescanWifi();
                            root.islandMode = "wifi";
                        }
                    }
                }

                // Bluetooth Submenu Button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    radius: 12
                    color: root.barState.bluetoothConnected ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.08)
                    border.color: Qt.rgba(1, 1, 1, 0.12)
                    border.width: root.barState.bluetoothConnected ? 0 : 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 8

                        Image {
                            source: root.barState.bluetoothConnected ? "assets/bluetooth-dark.svg" : "assets/bluetooth.svg"
                            sourceSize.width: 16
                            sourceSize.height: 16
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                text: "Bluetooth"
                                font.family: "Segoe UI, Inter, sans-serif"
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: root.barState.bluetoothConnected ? "#111215" : "#FFFFFF"
                            }
                            Text {
                                text: root.barState.bluetoothConnected ? (root.barState.bluetoothConnectedDevice || "Conectado") : (root.barState.bluetoothEnabled ? "Activado" : "Desactivado")
                                font.family: "Segoe UI, Inter, sans-serif"
                                font.pixelSize: 9
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                color: root.barState.bluetoothConnected ? Qt.rgba(0.1, 0.1, 0.1, 0.7) : Qt.rgba(1, 1, 1, 0.5)
                            }
                        }

                        Image {
                            source: "assets/chevron-right.svg"
                            sourceSize.width: 10
                            sourceSize.height: 10
                            opacity: root.barState.bluetoothConnected ? 0.6 : 0.4
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.islandMode = "bluetooth";
                        }
                    }
                }
            }

            // 3. 6 Circular Quick Action Buttons (High Contrast & Clean White SVGs)
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 12

                // Moon / Night Light Button
                Rectangle {
                    width: 36; height: 36; radius: 18
                    color: root.barState.nightLightEnabled ? Qt.rgba(1, 0.65, 0.2, 0.35) : (btn1.containsMouse ? Qt.rgba(1, 1, 1, 0.22) : Qt.rgba(1, 1, 1, 0.12))
                    border.color: root.barState.nightLightEnabled ? Qt.rgba(1, 0.65, 0.2, 0.7) : Qt.rgba(1, 1, 1, 0.2)
                    border.width: 1

                    Image {
                        anchors.centerIn: parent
                        source: "assets/moon.svg"
                        sourceSize.width: 16
                        sourceSize.height: 16
                    }
                    MouseArea { id: btn1; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.barState.toggleNightLight() }
                }

                // Screen record / screenshot
                Rectangle {
                    width: 36; height: 36; radius: 18
                    color: btn2.containsMouse ? Qt.rgba(1, 1, 1, 0.22) : Qt.rgba(1, 1, 1, 0.12)
                    border.color: Qt.rgba(1, 1, 1, 0.2)
                    border.width: 1

                    Image {
                        anchors.centerIn: parent
                        source: "assets/screen-record.svg"
                        sourceSize.width: 16
                        sourceSize.height: 16
                    }
                    MouseArea { id: btn2; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.barState.triggerScreenshot() }
                }

                // App Launcher Grid
                Rectangle {
                    width: 36; height: 36; radius: 18
                    color: btn3.containsMouse ? Qt.rgba(1, 1, 1, 0.22) : Qt.rgba(1, 1, 1, 0.12)
                    border.color: Qt.rgba(1, 1, 1, 0.2)
                    border.width: 1

                    Image {
                        anchors.centerIn: parent
                        source: "assets/grid-launcher.svg"
                        sourceSize.width: 15
                        sourceSize.height: 15
                    }
                    MouseArea { id: btn3; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.barState.openLauncher() }
                }

                // Notifications Bell
                Rectangle {
                    width: 36; height: 36; radius: 18
                    color: root.barState.dndActive ? Qt.rgba(1, 0.3, 0.3, 0.35) : (btn4.containsMouse ? Qt.rgba(1, 1, 1, 0.22) : Qt.rgba(1, 1, 1, 0.12))
                    border.color: root.barState.dndActive ? Qt.rgba(1, 0.3, 0.3, 0.7) : Qt.rgba(1, 1, 1, 0.2)
                    border.width: 1

                    Image {
                        anchors.centerIn: parent
                        source: "assets/bell.svg"
                        sourceSize.width: 16
                        sourceSize.height: 16
                    }
                    MouseArea { id: btn4; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.barState.toggleDnd() }
                }

                // Settings Gear
                Rectangle {
                    width: 36; height: 36; radius: 18
                    color: btn5.containsMouse ? Qt.rgba(1, 1, 1, 0.22) : Qt.rgba(1, 1, 1, 0.12)
                    border.color: Qt.rgba(1, 1, 1, 0.2)
                    border.width: 1

                    Image {
                        anchors.centerIn: parent
                        source: "assets/gear.svg"
                        sourceSize.width: 16
                        sourceSize.height: 16
                    }
                    MouseArea { id: btn5; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Quickshell.execDetached(["bash", "-c", "systemsettings 2>/dev/null || xfce4-settings-manager 2>/dev/null || true"]) }
                }

                // Reload
                Rectangle {
                    width: 36; height: 36; radius: 18
                    color: btn6.containsMouse ? Qt.rgba(1, 1, 1, 0.22) : Qt.rgba(1, 1, 1, 0.12)
                    border.color: Qt.rgba(1, 1, 1, 0.2)
                    border.width: 1

                    Image {
                        anchors.centerIn: parent
                        source: "assets/reload.svg"
                        sourceSize.width: 16
                        sourceSize.height: 16
                    }
                    MouseArea { id: btn6; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.barState.reloadInterface() }
                }
            }

            // 4. Sliders (Volume & Brightness)
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                // Volume Slider
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Image {
                        source: "assets/volume.svg"
                        sourceSize.width: 14
                        sourceSize.height: 14
                    }

                    Text {
                        text: "Volume"
                        font.family: "Segoe UI, Inter, sans-serif"
                        font.pixelSize: 10
                        font.weight: Font.Medium
                        color: Qt.rgba(1, 1, 1, 0.7)
                        Layout.preferredWidth: 44
                    }

                    Rectangle {
                        id: volTrack
                        Layout.fillWidth: true
                        Layout.preferredHeight: 5
                        radius: 2.5
                        color: Qt.rgba(1, 1, 1, 0.15)

                        Rectangle {
                            height: parent.height
                            radius: 2.5
                            color: "#FFFFFF"
                            width: parent.width * (root.barState.volumePercent / 100.0)
                        }

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            cursorShape: Qt.PointingHandCursor
                            onPositionChanged: mouse => {
                                var pct = Math.max(0, Math.min(100, (mouse.x / volTrack.width) * 100));
                                root.barState.setVolume(pct);
                            }
                            onClicked: mouse => {
                                var pct = Math.max(0, Math.min(100, (mouse.x / volTrack.width) * 100));
                                root.barState.setVolume(pct);
                            }
                        }
                    }

                    Text {
                        text: root.barState.volumePercent + "%"
                        font.family: "Segoe UI, Inter, sans-serif"
                        font.pixelSize: 10
                        font.weight: Font.Medium
                        color: Qt.rgba(1, 1, 1, 0.70)
                        Layout.preferredWidth: 26
                        horizontalAlignment: Text.AlignRight
                    }
                }

                // Brightness Slider
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Image {
                        source: "assets/brightness.svg"
                        sourceSize.width: 14
                        sourceSize.height: 14
                    }

                    Text {
                        text: "Brightness"
                        font.family: "Segoe UI, Inter, sans-serif"
                        font.pixelSize: 10
                        font.weight: Font.Medium
                        color: Qt.rgba(1, 1, 1, 0.7)
                        Layout.preferredWidth: 44
                    }

                    Rectangle {
                        id: brightTrack
                        Layout.fillWidth: true
                        Layout.preferredHeight: 5
                        radius: 2.5
                        color: Qt.rgba(1, 1, 1, 0.15)

                        Rectangle {
                            height: parent.height
                            radius: 2.5
                            color: "#FFFFFF"
                            width: parent.width * (root.barState.brightnessPercent / 100.0)
                        }

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            cursorShape: Qt.PointingHandCursor
                            onPositionChanged: mouse => {
                                var pct = Math.max(5, Math.min(100, (mouse.x / brightTrack.width) * 100));
                                root.barState.setBrightness(pct);
                            }
                            onClicked: mouse => {
                                var pct = Math.max(5, Math.min(100, (mouse.x / brightTrack.width) * 100));
                                root.barState.setBrightness(pct);
                            }
                        }
                    }

                    Text {
                        text: root.barState.brightnessPercent + "%"
                        font.family: "Segoe UI, Inter, sans-serif"
                        font.pixelSize: 10
                        font.weight: Font.Medium
                        color: Qt.rgba(1, 1, 1, 0.70)
                        Layout.preferredWidth: 26
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }
    }

    // =========================================================================
    // LAYER C: MUSIC PLAYER CARD CONTENT (width: 380, height: 172)
    // =========================================================================
    Item {
        id: mediaContent
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: 380
        height: 172
        visible: opacity > 0.001

        property bool isActive: root.islandMode === "media"

        opacity: isActive ? 1.0 : 0.0
        Behavior on opacity {
            SequentialAnimation {
                PauseAnimation { duration: (mediaContent.isActive && root.height < 120) ? 240 : 0 }
                NumberAnimation {
                    duration: mediaContent.isActive ? 160 : 60
                    easing.type: mediaContent.isActive ? Easing.OutCubic : Easing.OutQuad
                }
            }
        }

        transform: Translate {
            y: mediaContent.isActive ? 0 : -10
            Behavior on y {
                SequentialAnimation {
                    PauseAnimation { duration: (mediaContent.isActive && root.height < 120) ? 220 : 0 }
                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            anchors.topMargin: 10
            spacing: 12

            // 1. Top Section: Album Art + Titles + Waveform
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // Album Art (iOS-Like Rounded Corners)
                Item {
                    Layout.preferredWidth: 46
                    Layout.preferredHeight: 46

                    Image {
                        id: expandedCoverImg
                        anchors.fill: parent
                        source: root.barState.mprisArtUrl !== "" ? root.barState.mprisArtUrl : ""
                        visible: false
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                    }

                    Rectangle {
                        id: expandedCoverMask
                        anchors.fill: parent
                        radius: 10
                        visible: false
                    }

                    OpacityMask {
                        anchors.fill: parent
                        source: expandedCoverImg
                        maskSource: expandedCoverMask
                        visible: root.barState.mprisArtUrl !== ""
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 10
                        visible: root.barState.mprisArtUrl === ""
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#A85324" }
                            GradientStop { position: 1.0; color: "#3B1B0A" }
                        }
                        Image {
                            anchors.centerIn: parent
                            source: "assets/music.svg"
                            sourceSize.width: 20
                            sourceSize.height: 20
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 10
                        color: "transparent"
                        border.color: Qt.rgba(1, 1, 1, 0.16)
                        border.width: 1
                    }
                }

                // Title & Artist
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: root.barState.mprisTitle !== "" ? root.barState.mprisTitle : "Sin reproducción"
                        font.family: "Segoe UI, Inter, Cantarell, sans-serif"
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: root.barState.mprisArtist !== "" ? root.barState.mprisArtist : "Media Player"
                        font.family: "Segoe UI, Inter, Cantarell, sans-serif"
                        font.pixelSize: 11
                        font.weight: Font.Normal
                        color: Qt.rgba(1, 1, 1, 0.70)
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                // Symmetrical Waveform Bars
                WaveformBars {
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    isPlaying: root.barState.mprisPlaying
                    values: root.barState.cavaBars
                    barColor: "#FFFFFF"
                }
            }

            // 2. Middle Section: Progress Slider & Timestamps (Single Unified Row matching Image 2)
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                // Elapsed Timestamp
                Text {
                    text: root.barState.mprisPositionStr
                    font.family: "Segoe UI, Inter, Cantarell, sans-serif"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: Qt.rgba(1, 1, 1, 0.75)
                    Layout.preferredWidth: 32
                }

                // Dynamic Audio CAVA Waveform Progress Track
                CavaProgressTrack {
                    id: cavaProgress
                    Layout.fillWidth: true
                    Layout.preferredHeight: 20
                    cavaBars: root.barState.cavaBars
                    isPlaying: root.barState.mprisPlaying
                    progress: Math.max(0.0, Math.min(1.0, root.barState.mprisPosition / Math.max(1.0, root.barState.mprisLength)))
                    onSeekRequested: ratio => root.barState.seekPosition(ratio)
                }

                // Remaining Timestamp
                Text {
                    text: root.barState.mprisRemainingStr
                    font.family: "Segoe UI, Inter, Cantarell, sans-serif"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: Qt.rgba(1, 1, 1, 0.75)
                    Layout.preferredWidth: 34
                    horizontalAlignment: Text.AlignRight
                }
            }

            // 3. Bottom Section: Controls & Audio Devices (Clean Pure White Controls matching Image 2)
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter

                // Volume / Speaker Icon
                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    radius: 16
                    color: volHover.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

                    Image {
                        anchors.centerIn: parent
                        source: "assets/volume.svg"
                        sourceSize.width: 17
                        sourceSize.height: 17
                    }

                    MouseArea {
                        id: volHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.barState.toggleMute()
                    }
                }

                Item { Layout.fillWidth: true }

                // Playback Controls (Previous, Play/Pause, Next)
                Row {
                    spacing: 24
                    Layout.alignment: Qt.AlignHCenter

                    // Previous Track (Double Left Triangles <<)
                    Rectangle {
                        width: 34
                        height: 34
                        radius: 17
                        color: prevHover.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

                        Image {
                            anchors.centerIn: parent
                            source: "assets/prev.svg"
                            sourceSize.width: 19
                            sourceSize.height: 19
                        }

                        MouseArea {
                            id: prevHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.barState.previousTrack()
                        }
                    }

                    // Play / Pause (Solid White || or ▶, No White Circle)
                    Rectangle {
                        width: 40
                        height: 40
                        radius: 20
                        color: playHover.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

                        Image {
                            anchors.centerIn: parent
                            source: root.barState.mprisPlaying ? "assets/pause.svg" : "assets/play.svg"
                            sourceSize.width: root.barState.mprisPlaying ? 18 : 22
                            sourceSize.height: root.barState.mprisPlaying ? 22 : 22
                        }

                        MouseArea {
                            id: playHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.barState.playPause()
                        }
                    }

                    // Next Track (Double Right Triangles >>)
                    Rectangle {
                        width: 34
                        height: 34
                        radius: 17
                        color: nextHover.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

                        Image {
                            anchors.centerIn: parent
                            source: "assets/next.svg"
                            sourceSize.width: 19
                            sourceSize.height: 19
                        }

                        MouseArea {
                            id: nextHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.barState.nextTrack()
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Headphones Output Icon (Clicking switches back to Options)
                Rectangle {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    radius: 16
                    color: hpHover.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"

                    Image {
                        anchors.centerIn: parent
                        source: "assets/headphones.svg"
                        sourceSize.width: 17
                        sourceSize.height: 17
                    }

                    MouseArea {
                        id: hpHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.islandMode = "options";
                        }
                    }
                }
            }
        }
    }

    // =========================================================================
    // LAYER D: WI-FI NETWORKS SUBVIEW (width: 380, height: 280)
    // =========================================================================
    Item {
        id: wifiContent
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: 380
        height: 280
        visible: opacity > 0.001

        property bool isActive: root.islandMode === "wifi"

        opacity: isActive ? 1.0 : 0.0
        Behavior on opacity {
            SequentialAnimation {
                PauseAnimation { duration: (wifiContent.isActive && root.height < 120) ? 260 : 0 }
                NumberAnimation {
                    duration: wifiContent.isActive ? 180 : 70
                    easing.type: wifiContent.isActive ? Easing.OutCubic : Easing.OutQuad
                }
            }
        }

        transform: Translate {
            x: wifiContent.isActive ? 0 : 32
            Behavior on x {
                NumberAnimation { duration: 320; easing.type: Easing.OutCubic }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            anchors.topMargin: 10
            spacing: 8

            // Top Header: Back button + Title + Rescan + On/Off Switch
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                spacing: 8

                // Back Button
                Rectangle {
                    Layout.preferredWidth: 70
                    Layout.preferredHeight: 28
                    radius: 14
                    color: backWifiHover.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.08)
                    border.color: Qt.rgba(1, 1, 1, 0.12)
                    border.width: 0.5

                    Row {
                        anchors.centerIn: parent
                        spacing: 4
                        Image {
                            source: "assets/chevron-left.svg"
                            sourceSize.width: 12
                            sourceSize.height: 12
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Volver"
                            font.family: "Segoe UI, Inter, sans-serif"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: "#FFFFFF"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: backWifiHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.islandMode = "options"
                    }
                }

                Text {
                    text: "Redes Wi-Fi"
                    font.family: "Segoe UI, Inter, sans-serif"
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    color: "#FFFFFF"
                    Layout.alignment: Qt.AlignVCenter
                }

                Item { Layout.fillWidth: true }

                // Refresh / Scan Button
                Rectangle {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    radius: 14
                    color: scanWifiHover.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.08)
                    border.color: Qt.rgba(1, 1, 1, 0.12)
                    border.width: 0.5

                    Image {
                        anchors.centerIn: parent
                        source: "assets/reload.svg"
                        sourceSize.width: 13
                        sourceSize.height: 13
                    }

                    MouseArea {
                        id: scanWifiHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.barState.rescanWifi()
                    }
                }

                // Wi-Fi On/Off Toggle Switch
                Rectangle {
                    Layout.preferredWidth: 42
                    Layout.preferredHeight: 24
                    radius: 12
                    color: root.barState.wifiEnabled ? "#3A72EC" : Qt.rgba(1, 1, 1, 0.2)

                    Rectangle {
                        width: 18
                        height: 18
                        radius: 9
                        color: "#FFFFFF"
                        anchors.verticalCenter: parent.verticalCenter
                        x: root.barState.wifiEnabled ? parent.width - width - 3 : 3

                        Behavior on x {
                            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.barState.toggleWifi()
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Qt.rgba(1, 1, 1, 0.1)
            }

            // Network List Container
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                // Wi-Fi Disabled Message
                ColumnLayout {
                    anchors.centerIn: parent
                    visible: !root.barState.wifiEnabled
                    spacing: 8

                    Text {
                        text: "El Wi-Fi está desactivado"
                        font.family: "Segoe UI, Inter, sans-serif"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: Qt.rgba(1, 1, 1, 0.6)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 28
                        radius: 14
                        color: "#3A72EC"
                        Layout.alignment: Qt.AlignHCenter

                        Text {
                            anchors.centerIn: parent
                            text: "Activar Wi-Fi"
                            font.family: "Segoe UI, Inter, sans-serif"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: "#FFFFFF"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.barState.toggleWifi()
                        }
                    }
                }

                // Networks Empty Message
                Text {
                    anchors.centerIn: parent
                    visible: root.barState.wifiEnabled && root.barState.wifiNetworks.length === 0
                    text: "Buscando redes disponibles..."
                    font.family: "Segoe UI, Inter, sans-serif"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: Qt.rgba(1, 1, 1, 0.5)
                }

                // Scrollable Network List
                ListView {
                    anchors.fill: parent
                    visible: root.barState.wifiEnabled && root.barState.wifiNetworks.length > 0
                    model: root.barState.wifiNetworks
                    spacing: 4
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 38
                        radius: 8
                        color: netHover.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : (modelData.active ? Qt.rgba(1, 1, 1, 0.08) : "transparent")

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 8

                            Image {
                                source: "assets/wifi.svg"
                                sourceSize.width: 15
                                sourceSize.height: 15
                                opacity: modelData.active ? 1.0 : 0.7
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                Text {
                                    text: modelData.ssid || "Red oculta"
                                    font.family: "Segoe UI, Inter, sans-serif"
                                    font.pixelSize: 11
                                    font.weight: modelData.active ? Font.Bold : Font.Normal
                                    color: "#FFFFFF"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: modelData.active ? "Conectado" : (modelData.security && modelData.security !== "--" ? modelData.security : "Abierta")
                                    font.family: "Segoe UI, Inter, sans-serif"
                                    font.pixelSize: 9
                                    color: modelData.active ? "#6CE686" : Qt.rgba(1, 1, 1, 0.5)
                                }
                            }

                            // Security Lock
                            Image {
                                visible: modelData.security && modelData.security !== "--"
                                source: "assets/lock.svg"
                                sourceSize.width: 11
                                sourceSize.height: 11
                                opacity: 0.5
                            }

                            // Signal %
                            Text {
                                text: modelData.signal + "%"
                                font.family: "Segoe UI, Inter, sans-serif"
                                font.pixelSize: 10
                                color: Qt.rgba(1, 1, 1, 0.5)
                            }

                            // Active checkmark
                            Image {
                                visible: !!modelData.active
                                source: "assets/check.svg"
                                sourceSize.width: 13
                                sourceSize.height: 13
                            }
                        }

                        MouseArea {
                            id: netHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData.ssid) {
                                    root.barState.connectWifi(modelData.ssid);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // =========================================================================
    // LAYER E: BLUETOOTH DEVICES SUBVIEW (width: 380, height: 280)
    // =========================================================================
    Item {
        id: bluetoothContent
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: 380
        height: 280
        visible: opacity > 0.001

        property bool isActive: root.islandMode === "bluetooth"

        opacity: isActive ? 1.0 : 0.0
        Behavior on opacity {
            SequentialAnimation {
                PauseAnimation { duration: (bluetoothContent.isActive && root.height < 120) ? 260 : 0 }
                NumberAnimation {
                    duration: bluetoothContent.isActive ? 180 : 70
                    easing.type: bluetoothContent.isActive ? Easing.OutCubic : Easing.OutQuad
                }
            }
        }

        transform: Translate {
            x: bluetoothContent.isActive ? 0 : 32
            Behavior on x {
                NumberAnimation { duration: 320; easing.type: Easing.OutCubic }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            anchors.topMargin: 10
            spacing: 8

            // Top Header: Back button + Title + On/Off Switch
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                spacing: 8

                // Back Button
                Rectangle {
                    Layout.preferredWidth: 70
                    Layout.preferredHeight: 28
                    radius: 14
                    color: backBtHover.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.08)
                    border.color: Qt.rgba(1, 1, 1, 0.12)
                    border.width: 0.5

                    Row {
                        anchors.centerIn: parent
                        spacing: 4
                        Image {
                            source: "assets/chevron-left.svg"
                            sourceSize.width: 12
                            sourceSize.height: 12
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Volver"
                            font.family: "Segoe UI, Inter, sans-serif"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: "#FFFFFF"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: backBtHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.islandMode = "options"
                    }
                }

                Text {
                    text: "Bluetooth"
                    font.family: "Segoe UI, Inter, sans-serif"
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    color: "#FFFFFF"
                    Layout.alignment: Qt.AlignVCenter
                }

                Item { Layout.fillWidth: true }

                // Bluetooth On/Off Toggle Switch
                Rectangle {
                    Layout.preferredWidth: 42
                    Layout.preferredHeight: 24
                    radius: 12
                    color: root.barState.bluetoothEnabled ? "#3A72EC" : Qt.rgba(1, 1, 1, 0.2)

                    Rectangle {
                        width: 18
                        height: 18
                        radius: 9
                        color: "#FFFFFF"
                        anchors.verticalCenter: parent.verticalCenter
                        x: root.barState.bluetoothEnabled ? parent.width - width - 3 : 3

                        Behavior on x {
                            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.barState.toggleBluetooth()
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Qt.rgba(1, 1, 1, 0.1)
            }

            // Device List Container
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                // Bluetooth Disabled Message
                ColumnLayout {
                    anchors.centerIn: parent
                    visible: !root.barState.bluetoothEnabled
                    spacing: 8

                    Text {
                        text: "Bluetooth está desactivado"
                        font.family: "Segoe UI, Inter, sans-serif"
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: Qt.rgba(1, 1, 1, 0.6)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 28
                        radius: 14
                        color: "#3A72EC"
                        Layout.alignment: Qt.AlignHCenter

                        Text {
                            anchors.centerIn: parent
                            text: "Activar Bluetooth"
                            font.family: "Segoe UI, Inter, sans-serif"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: "#FFFFFF"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.barState.toggleBluetooth()
                        }
                    }
                }

                // Devices Empty Message
                Text {
                    anchors.centerIn: parent
                    visible: root.barState.bluetoothEnabled && root.barState.bluetoothDevices.length === 0
                    text: "No se encontraron dispositivos vinculados"
                    font.family: "Segoe UI, Inter, sans-serif"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: Qt.rgba(1, 1, 1, 0.5)
                }

                // Scrollable Device List
                ListView {
                    anchors.fill: parent
                    visible: root.barState.bluetoothEnabled && root.barState.bluetoothDevices.length > 0
                    model: root.barState.bluetoothDevices
                    spacing: 4
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 42
                        radius: 8
                        color: btDevHover.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : (modelData.connected ? Qt.rgba(1, 1, 1, 0.08) : "transparent")

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 8

                            Image {
                                source: modelData.isAudio ? "assets/headphones.svg" : "assets/bluetooth.svg"
                                sourceSize.width: 15
                                sourceSize.height: 15
                                opacity: modelData.connected ? 1.0 : 0.7
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1

                                Text {
                                    text: modelData.name || modelData.mac
                                    font.family: "Segoe UI, Inter, sans-serif"
                                    font.pixelSize: 11
                                    font.weight: modelData.connected ? Font.Bold : Font.Normal
                                    color: "#FFFFFF"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: modelData.connected ? "Conectado" : "Emparejado"
                                    font.family: "Segoe UI, Inter, sans-serif"
                                    font.pixelSize: 9
                                    color: modelData.connected ? "#6CE686" : Qt.rgba(1, 1, 1, 0.5)
                                }
                            }

                            // Connect / Disconnect Action Button
                            Rectangle {
                                Layout.preferredWidth: modelData.connected ? 82 : 72
                                Layout.preferredHeight: 24
                                radius: 12
                                color: modelData.connected ? Qt.rgba(1, 0.3, 0.3, 0.25) : Qt.rgba(1, 1, 1, 0.15)
                                border.color: modelData.connected ? Qt.rgba(1, 0.3, 0.3, 0.5) : Qt.rgba(1, 1, 1, 0.25)
                                border.width: 0.5

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.connected ? "Desconectar" : "Conectar"
                                    font.family: "Segoe UI, Inter, sans-serif"
                                    font.pixelSize: 10
                                    font.weight: Font.Medium
                                    color: modelData.connected ? "#FFA5A5" : "#FFFFFF"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (modelData.connected) {
                                            root.barState.disconnectBluetooth(modelData.mac);
                                        } else {
                                            root.barState.connectBluetooth(modelData.mac);
                                        }
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: btDevHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData.connected) {
                                    root.barState.disconnectBluetooth(modelData.mac);
                                } else {
                                    root.barState.connectBluetooth(modelData.mac);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    }
}
