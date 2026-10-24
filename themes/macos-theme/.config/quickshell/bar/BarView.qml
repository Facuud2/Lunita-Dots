import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray

Item {
    id: root

    required property var barState
    required property var panelWindow

    anchors.fill: parent

    // ── Frosted Glass Background (Liquid Glass macOS 27) ──
    Rectangle {
        id: barBackground

        anchors.fill: parent
        color: barState.barBgColor

        // Subtle Bottom Divider Line
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: barState.barDividerColor

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }

            }

        }

        Behavior on color {
            ColorAnimation {
                duration: 200
            }

        }

    }

    // ── Main Horizontal Bar Row ──
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 0

        // ════════════════════════════════════════════════════════════════
        // ── LEFT SECTION: Apple Logo, App Name, Global App Menus ──
        // ════════════════════════════════════════════════════════════════
        RowLayout {
            spacing: 2
            Layout.alignment: Qt.AlignVCenter

            // 1. Apple Logo Button
            Item {
                implicitWidth: 26
                implicitHeight: 22

                Rectangle {
                    anchors.fill: parent
                    radius: 4
                    color: (appleMouseArea.containsMouse || barState.activePopup === "apple") ? barState.barActiveHoverColor : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }

                    }

                }

                BarIcon {
                    anchors.centerIn: parent
                    iconWidth: 14
                    iconHeight: 14
                    source: "assets/apple.svg"
                    iconColor: barState.barTextColor
                }

                MouseArea {
                    id: appleMouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        barState.togglePopup("apple", 10, 28, panelWindow.screen);
                    }
                }

            }

            // 2. Active Application Name (Dynamic focus tracking)
            Item {
                implicitWidth: appTitleText.implicitWidth + 14
                implicitHeight: 22

                Rectangle {
                    anchors.fill: parent
                    radius: 4
                    color: appMouseArea.containsMouse ? barState.barHoverColor : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }

                    }

                }

                Text {
                    id: appTitleText

                    anchors.centerIn: parent
                    text: barState.activeAppName
                    color: barState.barTextColor
                    font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }

                    }

                }

                MouseArea {
                    id: appMouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var pos = mapToItem(null, 0, 0);
                        barState.openAppMenu(barState.activeAppName, pos.x, 28, panelWindow.screen);
                    }
                }

            }

            // 3. Application Menus (File, Edit, View, Window, Help)
            Repeater {
                model: ["File", "Edit", "View", "Window", "Help"]

                delegate: Item {
                    id: menuBtn

                    required property string modelData
                    property var stateRef: root.barState
                    property var winRef: root.panelWindow

                    implicitWidth: menuText.implicitWidth + 14
                    implicitHeight: 22

                    Rectangle {
                        anchors.fill: parent
                        radius: 4
                        color: (menuMouseArea.containsMouse || (menuBtn.stateRef.activePopup === "appmenu" && menuBtn.stateRef.activeMenuTitle === modelData)) ? menuBtn.stateRef.barActiveHoverColor : "transparent"

                        Behavior on color {
                            ColorAnimation {
                                duration: 120
                            }

                        }

                    }

                    Text {
                        id: menuText

                        anchors.centerIn: parent
                        text: modelData
                        color: menuBtn.stateRef.barTextColor
                        opacity: 0.92
                        font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                        font.pixelSize: 13
                        font.weight: Font.Normal

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                            }

                        }

                    }

                    MouseArea {
                        id: menuMouseArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var pos = menuBtn.mapToItem(null, 0, 0);
                            menuBtn.stateRef.openAppMenu(modelData, pos.x, 28, menuBtn.winRef.screen);
                        }
                    }

                }

            }

        }

        // ════════════════════════════════════════════════════════════════
        // ── CENTER SPACER ──
        // ════════════════════════════════════════════════════════════════
        Item {
            Layout.fillWidth: true
        }

        // ════════════════════════════════════════════════════════════════
        // ── RIGHT SECTION: Tray, Bluetooth, Network, Audio, Date/Time ──
        // ════════════════════════════════════════════════════════════════
        RowLayout {
            spacing: 5
            Layout.alignment: Qt.AlignVCenter

            // ── 1. Screen Recording Indicator (Purple Pill) ──
            Item {
                visible: barState.isRecording
                implicitWidth: 30
                implicitHeight: 20

                Rectangle {
                    anchors.fill: parent
                    radius: 10
                    color: "#AF52DE"

                    BarIcon {
                        anchors.centerIn: parent
                        iconWidth: 12
                        iconHeight: 12
                        source: "assets/camera.svg"
                        iconColor: "#FFFFFF"
                    }

                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: barState.toggleRecording()
                }

            }

            // ── 2. System Tray Icons (Immediately left of Widgets Modifier Icon, growing right-to-left) ──
            Timer {
                id: traySyncTimer

                interval: 1500
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    var icons = [];
                    var items = SystemTray.items.values;
                    for (var i = 0; i < items.length; i++) {
                        var it = items[i];
                        if (it && it.icon && it.icon.indexOf("image://qsimage/") !== 0)
                            icons.push(it.icon);

                    }
                    if (icons.length > 0)
                        barState.resolveTrayIcons(icons);

                }
            }

            Row {
                id: systemTrayRow

                spacing: 3
                layoutDirection: Qt.RightToLeft
                Layout.alignment: Qt.AlignVCenter

                Repeater {
                    model: SystemTray.items.values

                    delegate: Item {
                        id: trayItemRoot

                        required property var modelData
                        readonly property string resolvedIconSource: {
                            if (!modelData || !modelData.icon)
                                return "";

                            var raw = modelData.icon;
                            if (raw.indexOf("image://qsimage/") === 0)
                                return raw;

                            if (root.barState.trayIconsMap && root.barState.trayIconsMap[raw])
                                return root.barState.trayIconsMap[raw];

                            return raw;
                        }

                        visible: !!(modelData && modelData.icon && resolvedIconSource !== "")
                        width: visible ? 24 : 0
                        height: 22
                        implicitWidth: width
                        implicitHeight: height
                        Component.onCompleted: {
                            if (modelData && modelData.icon && modelData.icon.indexOf("image://qsimage/") !== 0)
                                root.barState.resolveTrayIcons([modelData.icon]);

                        }

                        Connections {
                            function onIconChanged() {
                                if (modelData && modelData.icon && modelData.icon.indexOf("image://qsimage/") !== 0)
                                    root.barState.resolveTrayIcons([modelData.icon]);

                            }

                            target: modelData
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: 4
                            color: trayMouseArea.containsMouse ? root.barState.barHoverColor : "transparent"

                            Behavior on color {
                                ColorAnimation {
                                    duration: 120
                                }

                            }

                        }

                        Image {
                            id: trayImg

                            anchors.centerIn: parent
                            width: 15
                            height: 15
                            source: trayItemRoot.resolvedIconSource
                            sourceSize.width: 30
                            sourceSize.height: 30
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            mipmap: true
                        }

                        MouseArea {
                            id: trayMouseArea

                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: (mouse) => {
                                var pos = trayItemRoot.mapToItem(null, 0, trayItemRoot.height);
                                if (mouse.button === Qt.RightButton) {
                                    root.barState.openTrayMenu(modelData, trayItemRoot.resolvedIconSource, Math.round(pos.x), panelWindow.screen);
                                } else if (mouse.button === Qt.MiddleButton) {
                                    root.barState.closePopups();
                                    modelData.secondaryActivate();
                                } else {
                                    if (modelData.onlyMenu && modelData.hasMenu) {
                                        root.barState.openTrayMenu(modelData, trayItemRoot.resolvedIconSource, Math.round(pos.x), panelWindow.screen);
                                    } else {
                                        root.barState.closePopups();
                                        modelData.activate();
                                    }
                                }
                            }
                            onWheel: (wheel) => {
                                modelData.scroll(wheel.angleDelta.y, false);
                            }
                        }

                    }

                }

            }

            // ── 2.5 Widgets Modifier Icon (A la izquierda de Bluetooth) ──
            Item {
                id: widgetsBtnItem

                implicitWidth: 24
                implicitHeight: 22

                Rectangle {
                    anchors.fill: parent
                    radius: 4
                    color: (widgetsMouseArea.containsMouse || barState.widgetsEditing) ? (barState.widgetsEditing ? Qt.rgba(0, 122 / 255, 255 / 255, 0.35) : barState.barActiveHoverColor) : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }

                    }

                }

                BarIcon {
                    anchors.centerIn: parent
                    iconWidth: 14
                    iconHeight: 14
                    source: "assets/widgets.svg"
                    iconColor: barState.widgetsEditing ? "#0A84FF" : barState.barTextColor
                }

                MouseArea {
                    id: widgetsMouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.RightButton)
                            Quickshell.execDetached(["lunita-widgets-manager", "--tab", "desktop"]);
                        else
                            Quickshell.execDetached(["lunita-widgets-toggle"]);
                    }
                }

            }

            // ── 3. Bluetooth Indicator & Popover Trigger ──
            Item {
                implicitWidth: (barState.bluetoothConnectedDevice !== "" ? 32 : 24)
                implicitHeight: 22

                Rectangle {
                    anchors.fill: parent
                    radius: 4
                    color: (btMouseArea.containsMouse || barState.activePopup === "bluetooth") ? barState.barActiveHoverColor : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }

                    }

                }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 3

                    BarIcon {
                        iconWidth: 14
                        iconHeight: 14
                        source: "assets/bluetooth.svg"
                        iconColor: barState.barTextColor
                        iconOpacity: barState.bluetoothEnabled ? 1 : 0.45
                    }

                    // Green dot if connected to device
                    Rectangle {
                        visible: barState.bluetoothConnectedDevice !== ""
                        width: 5
                        height: 5
                        radius: 2.5
                        color: "#34C759"
                    }

                }

                MouseArea {
                    id: btMouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        barState.togglePopup("bluetooth", panelWindow.width - 302, 28, panelWindow.screen);
                    }
                }

            }

            // ── 4. Network Status (Ethernet or Wi-Fi) ──
            Item {
                implicitWidth: 24
                implicitHeight: 22

                Rectangle {
                    anchors.fill: parent
                    radius: 4
                    color: (netMouseArea.containsMouse || barState.activePopup === "network") ? barState.barActiveHoverColor : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }

                    }

                }

                BarIcon {
                    anchors.centerIn: parent
                    iconWidth: 15
                    iconHeight: 15
                    source: barState.isEthernet ? "assets/ethernet.svg" : (barState.networkConnected ? "assets/wifi.svg" : "assets/wifi-off.svg")
                    iconColor: barState.barTextColor
                    iconOpacity: barState.networkConnected ? 1 : 0.45
                }

                MouseArea {
                    id: netMouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        barState.togglePopup("network", panelWindow.width - 302, 28, panelWindow.screen);
                    }
                }

            }

            // ── 5. Audio Volume Icon ──
            Item {
                implicitWidth: 24
                implicitHeight: 22

                Rectangle {
                    anchors.fill: parent
                    radius: 4
                    color: (volMouseArea.containsMouse || barState.activePopup === "sound") ? barState.barActiveHoverColor : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }

                    }

                }

                BarIcon {
                    anchors.centerIn: parent
                    iconWidth: 15
                    iconHeight: 15
                    source: barState.isMuted ? "assets/volume-muted.svg" : "assets/volume.svg"
                    iconColor: barState.barTextColor
                }

                MouseArea {
                    id: volMouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        barState.togglePopup("sound", panelWindow.width - 302, 28, panelWindow.screen);
                    }
                }

            }

            // ── 6. Battery Indicator (if present) ──
            Item {
                visible: barState.hasBattery
                implicitWidth: battRow.implicitWidth + 8
                implicitHeight: 22

                Rectangle {
                    anchors.fill: parent
                    radius: 4
                    color: battMouseArea.containsMouse ? barState.barHoverColor : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }

                    }

                }

                RowLayout {
                    id: battRow

                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: barState.batteryPercent + "%"
                        color: barState.barTextColor
                        opacity: 0.88
                        font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                        font.pixelSize: 11
                    }

                    BarIcon {
                        iconWidth: 16
                        iconHeight: 12
                        source: barState.isCharging ? "assets/battery-charging.svg" : "assets/battery.svg"
                        iconColor: barState.barTextColor
                    }

                }

                MouseArea {
                    id: battMouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        barState.togglePopup("controlcenter", panelWindow.width - 332, 28, panelWindow.screen);
                    }
                }

            }

            // ── 6.5. Virtual Keyboard (On-Screen Keyboard) ──
            Item {
                implicitWidth: 24
                implicitHeight: 22

                Rectangle {
                    anchors.fill: parent
                    radius: 4
                    color: (vkbMouseArea.containsMouse || barState.virtualKeyboardVisible) ? (barState.virtualKeyboardVisible ? Qt.rgba(0, 122 / 255, 255 / 255, 0.35) : barState.barActiveHoverColor) : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }

                    }

                }

                BarIcon {
                    anchors.centerIn: parent
                    iconWidth: 15
                    iconHeight: 15
                    source: "assets/keyboard.svg"
                    iconColor: barState.virtualKeyboardVisible ? "#0A84FF" : barState.barTextColor
                }

                MouseArea {
                    id: vkbMouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        barState.toggleVirtualKeyboard();
                    }
                }

            }

            // ── 7. Spotlight Search ──
            Item {
                implicitWidth: 24
                implicitHeight: 22

                Rectangle {
                    anchors.fill: parent
                    radius: 4
                    color: spotMouseArea.containsMouse ? barState.barHoverColor : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }

                    }

                }

                BarIcon {
                    anchors.centerIn: parent
                    iconWidth: 14
                    iconHeight: 14
                    source: "assets/spotlight.svg"
                    iconColor: barState.barTextColor
                }

                MouseArea {
                    id: spotMouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        barState.openSpotlight();
                    }
                }

            }

            // ── 8. Control Center (Two Sliders Icon) ──
            Item {
                implicitWidth: 26
                implicitHeight: 22

                Rectangle {
                    anchors.fill: parent
                    radius: 4
                    color: (ccMouseArea.containsMouse || barState.activePopup === "controlcenter") ? barState.barActiveHoverColor : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }

                    }

                }

                BarIcon {
                    anchors.centerIn: parent
                    iconWidth: 14
                    iconHeight: 14
                    source: "assets/control-center.svg"
                    iconColor: barState.barTextColor
                }

                MouseArea {
                    id: ccMouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        barState.togglePopup("controlcenter", panelWindow.width - 332, 28, panelWindow.screen);
                    }
                }

            }

            // ── 9. Siri / Apple Intelligence Swirl ──
            Item {
                implicitWidth: 24
                implicitHeight: 22

                Rectangle {
                    anchors.fill: parent
                    radius: 4
                    color: siriMouseArea.containsMouse ? barState.barHoverColor : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }

                    }

                }

                BarIcon {
                    anchors.centerIn: parent
                    iconWidth: 15
                    iconHeight: 15
                    source: "assets/siri.svg"
                    iconColor: barState.barTextColor
                }

                MouseArea {
                    id: siriMouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        barState.openAppLauncher();
                    }
                }

            }

            // ── 10. Date & Clock (e.g. "Thu Sep 24  1:39 PM") ──
            Item {
                implicitWidth: clockText.implicitWidth + 12
                implicitHeight: 22

                Rectangle {
                    anchors.fill: parent
                    radius: 4
                    color: (clockMouseArea.containsMouse || barState.activePopup === "calendar") ? barState.barActiveHoverColor : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: 120
                        }

                    }

                }

                Text {
                    id: clockText

                    anchors.centerIn: parent
                    text: barState.fullDateStr
                    color: barState.barTextColor
                    font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                    font.pixelSize: 13
                    font.weight: Font.Normal

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }

                    }

                }

                MouseArea {
                    id: clockMouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        barState.togglePopup("calendar", panelWindow.width - 312, 28, panelWindow.screen);
                    }
                }

            }

        }

    }

    // ── Reusable Tinted SVG Icon Component ──
    component BarIcon: Item {
        id: bIconRoot

        property string source: ""
        property color iconColor: barState.barTextColor
        property real iconWidth: 14
        property real iconHeight: 14
        property real iconOpacity: 1

        implicitWidth: iconWidth
        implicitHeight: iconHeight

        Image {
            id: rawImg

            anchors.fill: parent
            source: bIconRoot.source
            sourceSize.width: Math.round(bIconRoot.iconWidth * 2)
            sourceSize.height: Math.round(bIconRoot.iconHeight * 2)
            visible: false
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
        }

        ColorOverlay {
            anchors.fill: rawImg
            source: rawImg
            color: bIconRoot.iconColor
            opacity: bIconRoot.iconOpacity

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }

            }

        }

    }

}
