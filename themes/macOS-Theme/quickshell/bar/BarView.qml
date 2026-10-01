import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
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

        Behavior on color { ColorAnimation { duration: 200 } }

        // Subtle Bottom Divider Line
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: 1
            color: barState.barDividerColor
            Behavior on color { ColorAnimation { duration: 200 } }
        }
    }

    // ── Reusable Tinted SVG Icon Component ──
    component BarIcon: Item {
        id: bIconRoot
        property string source: ""
        property color iconColor: barState.barTextColor
        property real iconWidth: 14
        property real iconHeight: 14
        property real iconOpacity: 1.0

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
            Behavior on color { ColorAnimation { duration: 200 } }
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
                    color: (appleMouseArea.containsMouse || barState.activePopup === "apple") 
                        ? barState.barActiveHoverColor 
                        : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }
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
                    Behavior on color { ColorAnimation { duration: 120 } }
                }

                Text {
                    id: appTitleText
                    anchors.centerIn: parent
                    text: barState.activeAppName
                    color: barState.barTextColor
                    font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    Behavior on color { ColorAnimation { duration: 200 } }
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
                        color: (menuMouseArea.containsMouse || (menuBtn.stateRef.activePopup === "appmenu" && menuBtn.stateRef.activeMenuTitle === modelData))
                            ? menuBtn.stateRef.barActiveHoverColor
                            : "transparent"
                        Behavior on color { ColorAnimation { duration: 120 } }
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
                        Behavior on color { ColorAnimation { duration: 200 } }
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

            // ── 1. System Tray Icons (Discord, Steam, Telegram, etc.) ──
            Timer {
                interval: 2000
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    var icons = [];
                    for (var i = 0; i < SystemTray.items.values.length; i++) {
                        var it = SystemTray.items.values[i];
                        if (it && it.icon) icons.push(it.icon);
                    }
                    if (icons.length > 0) barState.resolveTrayIcons(icons);
                }
            }

            RowLayout {
                spacing: 3
                Repeater {
                    model: SystemTray.items.values
                    delegate: Item {
                        id: trayItemRoot
                        required property var modelData
                        property bool isDuplicateApplet: {
                            var id = (modelData.id || "").toLowerCase();
                            var icon = (modelData.icon || "").toLowerCase();
                            return (id.indexOf("nm_applet") !== -1 || id.indexOf("nm-applet") !== -1 || id.indexOf("blueman") !== -1 || id.indexOf("network") !== -1 || icon.indexOf("nm-device") !== -1 || icon.indexOf("nm-signal") !== -1);
                        }
                        visible: !isDuplicateApplet && trayImg.status === Image.Ready
                        implicitWidth: visible ? 22 : 0
                        implicitHeight: 22

                        Rectangle {
                            anchors.fill: parent
                            radius: 4
                            color: trayMouseArea.containsMouse ? root.barState.barHoverColor : "transparent"
                        }

                        Image {
                            id: trayImg
                            anchors.centerIn: parent
                            width: 15
                            height: 15
                            source: root.barState.trayIconsMap[modelData.icon] || ""
                            fillMode: Image.PreserveAspectFit
                        }

                        MouseArea {
                            id: trayMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mouse => {
                                if (mouse.button === Qt.RightButton) {
                                    modelData.secondaryActivate();
                                } else {
                                    modelData.activate();
                                }
                            }
                        }
                    }
                }
            }

            // ── 2. Screen Recording Indicator (Purple Pill) ──
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

            // ── 2.5 Widgets Modifier Icon (A la izquierda de Bluetooth) ──
            Item {
                id: widgetsBtnItem
                implicitWidth: 24
                implicitHeight: 22

                Rectangle {
                    anchors.fill: parent
                    radius: 4
                    color: (widgetsMouseArea.containsMouse || barState.widgetsEditing)
                        ? (barState.widgetsEditing ? Qt.rgba(0, 122/255, 255/255, 0.35) : barState.barActiveHoverColor)
                        : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }
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
                    onClicked: mouse => {
                        if (mouse.button === Qt.RightButton) {
                            Quickshell.execDetached(["lunita-widgets-manager"]);
                        } else {
                            Quickshell.execDetached(["lunita-widgets-toggle"]);
                        }
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
                    color: (btMouseArea.containsMouse || barState.activePopup === "bluetooth") 
                        ? barState.barActiveHoverColor 
                        : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }
                }

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 3

                    BarIcon {
                        iconWidth: 14
                        iconHeight: 14
                        source: "assets/bluetooth.svg"
                        iconColor: barState.barTextColor
                        iconOpacity: barState.bluetoothEnabled ? 1.0 : 0.45
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
                    color: (netMouseArea.containsMouse || barState.activePopup === "network") 
                        ? barState.barActiveHoverColor 
                        : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }
                }

                BarIcon {
                    anchors.centerIn: parent
                    iconWidth: 15
                    iconHeight: 15
                    source: barState.isEthernet 
                        ? "assets/ethernet.svg" 
                        : (barState.networkConnected ? "assets/wifi.svg" : "assets/wifi-off.svg")
                    iconColor: barState.barTextColor
                    iconOpacity: barState.networkConnected ? 1.0 : 0.45
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
                    color: (volMouseArea.containsMouse || barState.activePopup === "sound")
                        ? barState.barActiveHoverColor
                        : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }
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
                    Behavior on color { ColorAnimation { duration: 120 } }
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

            // ── 7. Spotlight Search ──
            Item {
                implicitWidth: 24
                implicitHeight: 22

                Rectangle {
                    anchors.fill: parent
                    radius: 4
                    color: spotMouseArea.containsMouse ? barState.barHoverColor : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }
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
                    color: (ccMouseArea.containsMouse || barState.activePopup === "controlcenter")
                        ? barState.barActiveHoverColor
                        : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }
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
                    Behavior on color { ColorAnimation { duration: 120 } }
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
                    color: (clockMouseArea.containsMouse || barState.activePopup === "calendar")
                        ? barState.barActiveHoverColor
                        : "transparent"
                    Behavior on color { ColorAnimation { duration: 120 } }
                }

                Text {
                    id: clockText
                    anchors.centerIn: parent
                    text: barState.fullDateStr
                    color: barState.barTextColor
                    font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                    font.pixelSize: 13
                    font.weight: Font.Normal
                    Behavior on color { ColorAnimation { duration: 200 } }
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
}
