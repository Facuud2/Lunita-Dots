import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray

Rectangle {
    id: root

    required property var dockState
    property var panelWindow: null

    readonly property real targetWidth: contentRow.implicitWidth + 28
    width: targetWidth
    height: 52
    implicitWidth: width
    implicitHeight: height
    radius: 26

    // Pure Transparent Liquid Glass Base
    color: Qt.rgba(1.0, 1.0, 1.0, 0.04)
    border.color: Qt.rgba(1.0, 1.0, 1.0, 0.18)
    border.width: 1

    Behavior on width {
        NumberAnimation {
            duration: 360
            easing.type: Easing.InOutCubic
        }
    }

    // Tray Content Items Row
    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 4

        // 1. Widgets / Copilot Icon
        Item {
            id: widgetsBtn
            width: 30
            height: 38
            anchors.verticalCenter: parent.verticalCenter
            property bool isHovered: widgetsMouse.containsMouse

            Rectangle {
                anchors.fill: parent
                radius: 6
                color: widgetsBtn.isHovered ? Qt.rgba(1, 1, 1, 0.26) : "transparent"
                border.color: widgetsBtn.isHovered ? Qt.rgba(1, 1, 1, 0.35) : "transparent"
                border.width: 1
                Behavior on color { ColorAnimation { duration: 120 } }
            }

            Image {
                anchors.centerIn: parent
                source: "assets/tray-widgets.svg"
                sourceSize.width: 16
                sourceSize.height: 16
                smooth: true
            }

            MouseArea {
                id: widgetsMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.dockState.openLauncher()
            }

            // Tooltip
            Rectangle {
                anchors.bottom: parent.top
                anchors.bottomMargin: 8
                anchors.horizontalCenter: parent.horizontalCenter
                width: widgetsTip.implicitWidth + 14
                height: 22
                radius: 5
                color: Qt.rgba(0.12, 0.13, 0.16, 0.95)
                border.color: Qt.rgba(1, 1, 1, 0.16)
                border.width: 1
                visible: widgetsBtn.isHovered
                z: 999
                Text {
                    id: widgetsTip
                    anchors.centerIn: parent
                    text: "Widgets y aplicaciones"
                    font.family: "Adwaita Sans"
                    font.styleName: "Regular"
                    font.italic: false
                    font.pixelSize: 11
                    color: "#FFFFFF"
                }
            }
        }

        // 2. Microphone Status Icon (Cyan Fluent Mic)
        Item {
            id: micBtn
            width: 30
            height: 38
            anchors.verticalCenter: parent.verticalCenter
            property bool isHovered: micMouse.containsMouse

            Rectangle {
                anchors.fill: parent
                radius: 6
                color: micBtn.isHovered ? Qt.rgba(1, 1, 1, 0.26) : "transparent"
                border.color: micBtn.isHovered ? Qt.rgba(1, 1, 1, 0.35) : "transparent"
                border.width: 1
                Behavior on color { ColorAnimation { duration: 120 } }
            }

            Image {
                anchors.centerIn: parent
                source: root.dockState.micMuted ? "assets/tray-mic-muted.svg" : "assets/tray-mic.svg"
                sourceSize.width: 17
                sourceSize.height: 17
                smooth: true
            }

            MouseArea {
                id: micMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.dockState.toggleMic()
            }

            // Tooltip
            Rectangle {
                anchors.bottom: parent.top
                anchors.bottomMargin: 8
                anchors.horizontalCenter: parent.horizontalCenter
                width: micTip.implicitWidth + 14
                height: 22
                radius: 5
                color: Qt.rgba(0.12, 0.13, 0.16, 0.95)
                border.color: Qt.rgba(1, 1, 1, 0.16)
                border.width: 1
                visible: micBtn.isHovered
                z: 999
                Text {
                    id: micTip
                    anchors.centerIn: parent
                    text: root.dockState.micMuted ? "Micrófono: Silenciado" : "Micrófono: Activo"
                    font.family: "Adwaita Sans"
                    font.styleName: "Regular"
                    font.italic: false
                    font.pixelSize: 11
                    color: "#FFFFFF"
                }
            }
        }

        // 2.5. Background Apps System Tray (Left of Language Indicator, growing right-to-left)
        Row {
            id: systemTrayRow
            height: 38
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            layoutDirection: Qt.RightToLeft
            visible: SystemTray.items.values.length > 0

            Repeater {
                id: trayRepeater
                model: SystemTray.items.values
                onCountChanged: {
                    root.dockState.resolveTrayIcons(SystemTray.items.values);
                }
                Component.onCompleted: {
                    root.dockState.resolveTrayIcons(SystemTray.items.values);
                }

                delegate: Item {
                    id: trayItemDelegate
                    required property var modelData
                    width: 28
                    height: 38
                    property bool isHovered: trayMouseArea.containsMouse

                    property string rawIcon: modelData.icon ? modelData.icon.toString() : ""
                    onRawIconChanged: {
                        if (rawIcon !== "") {
                            root.dockState.resolveTrayIcons(SystemTray.items.values);
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 6
                        color: trayItemDelegate.isHovered ? Qt.rgba(1, 1, 1, 0.26) : "transparent"
                        border.color: trayItemDelegate.isHovered ? Qt.rgba(1, 1, 1, 0.35) : "transparent"
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }

                    Image {
                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        sourceSize: Qt.size(32, 32)
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                        source: {
                            var raw = trayItemDelegate.rawIcon;
                            if (!raw) return "";
                            if (raw.indexOf("image://qspixmap/") === 0 || raw.indexOf("image://qsimage/") === 0 || raw.indexOf("file://") === 0) {
                                return raw;
                            }
                            if (root.dockState.trayIconsMap[raw]) {
                                return root.dockState.trayIconsMap[raw];
                            }
                            var qIdx = raw.indexOf("?");
                            if (qIdx !== -1) {
                                var base = raw.substring(0, qIdx);
                                if (root.dockState.trayIconsMap[base]) {
                                    return root.dockState.trayIconsMap[base];
                                }
                            }
                            return "";
                        }
                    }

                    MouseArea {
                        id: trayMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                        onClicked: mouse => {
                            if (mouse.button === Qt.LeftButton) {
                                if (trayItemDelegate.modelData.onlyMenu && trayItemDelegate.modelData.hasMenu && root.panelWindow) {
                                    var pos = parent.mapToItem(null, 0, 0);
                                    trayItemDelegate.modelData.display(root.panelWindow, Math.round(pos.x), Math.round(pos.y));
                                } else {
                                    trayItemDelegate.modelData.activate();
                                }
                            } else if (mouse.button === Qt.RightButton) {
                                if (trayItemDelegate.modelData.hasMenu && root.panelWindow) {
                                    var posR = parent.mapToItem(null, 0, 0);
                                    trayItemDelegate.modelData.display(root.panelWindow, Math.round(posR.x), Math.round(posR.y));
                                } else {
                                    trayItemDelegate.modelData.secondaryActivate();
                                }
                            } else if (mouse.button === Qt.MiddleButton) {
                                trayItemDelegate.modelData.secondaryActivate();
                            }
                        }
                        onWheel: wheel => {
                            trayItemDelegate.modelData.scroll(wheel.angleDelta.y, false);
                        }
                    }

                    // Tooltip
                    Rectangle {
                        readonly property string tipLabel: trayItemDelegate.modelData.tooltipTitle || trayItemDelegate.modelData.title || trayItemDelegate.modelData.id || ""
                        anchors.bottom: parent.top
                        anchors.bottomMargin: 8
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: trayItemTip.implicitWidth + 14
                        height: 22
                        radius: 5
                        color: Qt.rgba(0.12, 0.13, 0.16, 0.95)
                        border.color: Qt.rgba(1, 1, 1, 0.16)
                        border.width: 1
                        visible: trayItemDelegate.isHovered && tipLabel !== ""
                        z: 999
                        Text {
                            id: trayItemTip
                            anchors.centerIn: parent
                            text: parent.tipLabel
                            font.family: "Adwaita Sans"
                    font.styleName: "Regular"
                    font.italic: false
                            font.pixelSize: 11
                            color: "#FFFFFF"
                        }
                    }
                }
            }
        }

        // 3. Language Indicator (ESP)
        Item {
            id: langBtn
            width: langText.implicitWidth + 12
            height: 38
            anchors.verticalCenter: parent.verticalCenter
            property bool isHovered: langMouse.containsMouse

            Rectangle {
                anchors.fill: parent
                radius: 6
                color: langBtn.isHovered ? Qt.rgba(1, 1, 1, 0.26) : "transparent"
                border.color: langBtn.isHovered ? Qt.rgba(1, 1, 1, 0.35) : "transparent"
                border.width: 1
                Behavior on color { ColorAnimation { duration: 120 } }
            }

            Text {
                id: langText
                anchors.centerIn: parent
                text: root.dockState.keyboardLayout || "ESP"
                font.family: "Adwaita Sans"
                font.styleName: "SemiBold"
                font.pixelSize: 11
                font.weight: Font.DemiBold
                font.italic: false
                color: "#FFFFFF"
            }

            MouseArea {
                id: langMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.dockState.cycleKeyboardLayout()
            }

            // Tooltip
            Rectangle {
                anchors.bottom: parent.top
                anchors.bottomMargin: 8
                anchors.horizontalCenter: parent.horizontalCenter
                width: langTip.implicitWidth + 14
                height: 22
                radius: 5
                color: Qt.rgba(0.12, 0.13, 0.16, 0.95)
                border.color: Qt.rgba(1, 1, 1, 0.16)
                border.width: 1
                visible: langBtn.isHovered
                z: 999
                Text {
                    id: langTip
                    anchors.centerIn: parent
                    text: "Distribución de teclado: " + (root.dockState.keyboardLayout || "ESP")
                    font.family: "Adwaita Sans"
                    font.styleName: "Regular"
                    font.italic: false
                    font.pixelSize: 11
                    color: "#FFFFFF"
                }
            }
        }

        // 3.5. Bluetooth Status Icon (Right of Language Indicator)
        Item {
            id: bluetoothBtn
            width: 30
            height: 38
            anchors.verticalCenter: parent.verticalCenter
            property bool isHovered: btMouse.containsMouse

            Rectangle {
                anchors.fill: parent
                radius: 6
                color: (root.dockState.flyoutOpen && root.dockState.activeFlyout === "bluetooth")
                    ? Qt.rgba(1, 1, 1, 0.42)
                    : (bluetoothBtn.isHovered ? Qt.rgba(1, 1, 1, 0.26) : "transparent")
                border.color: ((root.dockState.flyoutOpen && root.dockState.activeFlyout === "bluetooth") || bluetoothBtn.isHovered) ? Qt.rgba(1, 1, 1, 0.38) : "transparent"
                border.width: 1
                Behavior on color { ColorAnimation { duration: 120 } }
            }

            Image {
                anchors.centerIn: parent
                source: "assets/bluetooth.svg"
                sourceSize.width: 16
                sourceSize.height: 16
                opacity: root.dockState.bluetoothEnabled ? 1.0 : 0.45
                smooth: true
            }

            // Connected Device Indicator Dot
            Rectangle {
                visible: root.dockState.bluetoothEnabled && root.dockState.bluetoothDeviceName !== ""
                width: 5
                height: 5
                radius: 2.5
                color: "#00E5FF"
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: 5
                anchors.topMargin: 8
            }

            MouseArea {
                id: btMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.dockState.openBluetooth(root.panelWindow && root.panelWindow.screen ? root.panelWindow.screen.name : "")
            }

            // Tooltip
            Rectangle {
                anchors.bottom: parent.top
                anchors.bottomMargin: 8
                anchors.horizontalCenter: parent.horizontalCenter
                width: btTip.implicitWidth + 14
                height: 22
                radius: 5
                color: Qt.rgba(0.12, 0.13, 0.16, 0.95)
                border.color: Qt.rgba(1, 1, 1, 0.16)
                border.width: 1
                visible: bluetoothBtn.isHovered
                z: 999
                Text {
                    id: btTip
                    anchors.centerIn: parent
                    text: !root.dockState.bluetoothEnabled
                        ? "Bluetooth: Apagado"
                        : (root.dockState.bluetoothDeviceName !== ""
                            ? ("Bluetooth: " + root.dockState.bluetoothDeviceName)
                            : "Bluetooth: Activado")
                    font.family: "Adwaita Sans"
                    font.styleName: "Regular"
                    font.italic: false
                    font.pixelSize: 11
                    color: "#FFFFFF"
                }
            }
        }

        // 4. Network Status Icon (Ethernet / Wi-Fi)
        Item {
            id: wifiBtn
            width: 30
            height: 38
            anchors.verticalCenter: parent.verticalCenter
            property bool isHovered: wifiMouse.containsMouse

            Rectangle {
                anchors.fill: parent
                radius: 6
                color: (root.dockState.flyoutOpen && root.dockState.activeFlyout === "network")
                    ? Qt.rgba(1, 1, 1, 0.42)
                    : (wifiBtn.isHovered ? Qt.rgba(1, 1, 1, 0.26) : "transparent")
                border.color: ((root.dockState.flyoutOpen && root.dockState.activeFlyout === "network") || wifiBtn.isHovered) ? Qt.rgba(1, 1, 1, 0.38) : "transparent"
                border.width: 1
                Behavior on color { ColorAnimation { duration: 120 } }
            }

            Image {
                anchors.centerIn: parent
                source: root.dockState.ethernetConnected
                    ? "assets/ethernet.svg"
                    : (root.dockState.wifiConnected ? "assets/tray-wifi.svg" : "assets/tray-wifi-off.svg")
                sourceSize.width: 16
                sourceSize.height: 16
                smooth: true
            }

            MouseArea {
                id: wifiMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.dockState.openNetwork(root.panelWindow && root.panelWindow.screen ? root.panelWindow.screen.name : "")
            }

            // Tooltip
            Rectangle {
                anchors.bottom: parent.top
                anchors.bottomMargin: 8
                anchors.horizontalCenter: parent.horizontalCenter
                width: wifiTip.implicitWidth + 14
                height: 22
                radius: 5
                color: Qt.rgba(0.12, 0.13, 0.16, 0.95)
                border.color: Qt.rgba(1, 1, 1, 0.16)
                border.width: 1
                visible: wifiBtn.isHovered
                z: 999
                Text {
                    id: wifiTip
                    anchors.centerIn: parent
                    text: root.dockState.ethernetConnected
                        ? ("Ethernet: " + root.dockState.ethernetName + (root.dockState.ethernetIp ? " (" + root.dockState.ethernetIp + ")" : ""))
                        : (root.dockState.wifiConnected ? ("Wi-Fi: " + root.dockState.wifiSsid) : "Red: Desconectado")
                    font.family: "Adwaita Sans"
                    font.styleName: "Regular"
                    font.italic: false
                    font.pixelSize: 11
                    color: "#FFFFFF"
                }
            }
        }

        // 5. Volume Speaker Icon (Click to toggle flyout / Scroll to change volume)
        Item {
            id: volumeBtn
            width: 30
            height: 38
            anchors.verticalCenter: parent.verticalCenter
            property bool isHovered: volMouse.containsMouse

            Rectangle {
                anchors.fill: parent
                radius: 6
                color: (root.dockState.flyoutOpen && root.dockState.activeFlyout === "audio")
                    ? Qt.rgba(1, 1, 1, 0.42)
                    : (volumeBtn.isHovered ? Qt.rgba(1, 1, 1, 0.26) : "transparent")
                border.color: ((root.dockState.flyoutOpen && root.dockState.activeFlyout === "audio") || volumeBtn.isHovered) ? Qt.rgba(1, 1, 1, 0.38) : "transparent"
                border.width: 1
                Behavior on color { ColorAnimation { duration: 120 } }
            }

            Image {
                anchors.centerIn: parent
                source: root.dockState.isVolumeMuted ? "assets/tray-volume-muted.svg" : "assets/tray-volume.svg"
                sourceSize.width: 16
                sourceSize.height: 16
                smooth: true
            }

            MouseArea {
                id: volMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.dockState.openVolumeFlyout(root.panelWindow && root.panelWindow.screen ? root.panelWindow.screen.name : "")
                onWheel: wheel => {
                    if (wheel.angleDelta.y > 0) {
                        root.dockState.changeVolume(5);
                    } else if (wheel.angleDelta.y < 0) {
                        root.dockState.changeVolume(-5);
                    }
                }
            }

            // Tooltip
            Rectangle {
                anchors.bottom: parent.top
                anchors.bottomMargin: 8
                anchors.horizontalCenter: parent.horizontalCenter
                width: volTip.implicitWidth + 14
                height: 22
                radius: 5
                color: Qt.rgba(0.12, 0.13, 0.16, 0.95)
                border.color: Qt.rgba(1, 1, 1, 0.16)
                border.width: 1
                visible: volumeBtn.isHovered
                z: 999
                Text {
                    id: volTip
                    anchors.centerIn: parent
                    text: root.dockState.isVolumeMuted ? "Volumen: Silenciado" : ("Volumen: " + root.dockState.volumePercent + "%")
                    font.family: "Adwaita Sans"
                    font.styleName: "Regular"
                    font.italic: false
                    font.pixelSize: 11
                    color: "#FFFFFF"
                }
            }
        }

        // 6. Battery Status Icon
        Item {
            id: batteryBtn
            width: 32
            height: 38
            anchors.verticalCenter: parent.verticalCenter
            property bool isHovered: batMouse.containsMouse

            Rectangle {
                anchors.fill: parent
                radius: 6
                color: batteryBtn.isHovered ? Qt.rgba(1, 1, 1, 0.26) : "transparent"
                border.color: batteryBtn.isHovered ? Qt.rgba(1, 1, 1, 0.35) : "transparent"
                border.width: 1
                Behavior on color { ColorAnimation { duration: 120 } }
            }

            Image {
                anchors.centerIn: parent
                source: root.dockState.batteryCharging ? "assets/tray-battery-charging.svg" : "assets/tray-battery.svg"
                sourceSize.width: 20
                sourceSize.height: 14
                smooth: true
            }

            MouseArea {
                id: batMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.ArrowCursor
            }

            // Tooltip
            Rectangle {
                anchors.bottom: parent.top
                anchors.bottomMargin: 8
                anchors.horizontalCenter: parent.horizontalCenter
                width: batTip.implicitWidth + 14
                height: 22
                radius: 5
                color: Qt.rgba(0.12, 0.13, 0.16, 0.95)
                border.color: Qt.rgba(1, 1, 1, 0.16)
                border.width: 1
                visible: batteryBtn.isHovered
                z: 999
                Text {
                    id: batTip
                    anchors.centerIn: parent
                    text: root.dockState.hasBattery
                        ? ("Batería: " + root.dockState.batteryPercent + "%" + (root.dockState.batteryCharging ? " (Cargando)" : ""))
                        : "Alimentación: CA (100%)"
                    font.family: "Adwaita Sans"
                    font.styleName: "Regular"
                    font.italic: false
                    font.pixelSize: 11
                    color: "#FFFFFF"
                }
            }
        }

        // 7. Clock (HH:mm)
        Item {
            id: clockBtn
            width: timeText.implicitWidth + 12
            height: 38
            anchors.verticalCenter: parent.verticalCenter
            property bool isHovered: clockMouse.containsMouse

            Rectangle {
                anchors.fill: parent
                radius: 6
                color: (root.dockState.flyoutOpen && root.dockState.activeFlyout === "calendar")
                    ? Qt.rgba(1, 1, 1, 0.42)
                    : (clockBtn.isHovered ? Qt.rgba(1, 1, 1, 0.26) : "transparent")
                border.color: ((root.dockState.flyoutOpen && root.dockState.activeFlyout === "calendar") || clockBtn.isHovered) ? Qt.rgba(1, 1, 1, 0.38) : "transparent"
                border.width: 1
                Behavior on color { ColorAnimation { duration: 120 } }
            }

            Text {
                id: timeText
                anchors.centerIn: parent
                text: root.dockState.timeStr || "15:43"
                font.family: "Adwaita Sans"
                font.styleName: "SemiBold"
                font.pixelSize: 12
                font.weight: Font.DemiBold
                font.italic: false
                color: "#FFFFFF"
            }

            MouseArea {
                id: clockMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.dockState.openCalendar(root.panelWindow && root.panelWindow.screen ? root.panelWindow.screen.name : "")
            }

            // Tooltip
            Rectangle {
                anchors.bottom: parent.top
                anchors.bottomMargin: 8
                anchors.horizontalCenter: parent.horizontalCenter
                width: clockTip.implicitWidth + 14
                height: 22
                radius: 5
                color: Qt.rgba(0.12, 0.13, 0.16, 0.95)
                border.color: Qt.rgba(1, 1, 1, 0.16)
                border.width: 1
                visible: clockBtn.isHovered
                z: 999
                Text {
                    id: clockTip
                    anchors.centerIn: parent
                    text: root.dockState.dateFullStr
                    font.family: "Adwaita Sans"
                    font.styleName: "Regular"
                    font.italic: false
                    font.pixelSize: 11
                    color: "#FFFFFF"
                }
            }
        }
    }
}
