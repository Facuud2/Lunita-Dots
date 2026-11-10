//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: root

    // Global Shared Dock State
    DockState {
        id: globalDockState
    }

    IpcHandler {
        target: "dock"

        function openStartMenu() {
            globalDockState.openContextMenu(globalDockState.startApp, 740, "");
        }

        function openAppMenu(index: int) {
            if (globalDockState.openApps.length > index) {
                globalDockState.openContextMenu(globalDockState.openApps[index], 840, "");
            }
        }

        function openPinnedMenu(index: int) {
            if (globalDockState.pinnedArray.length > index) {
                globalDockState.openContextMenu(globalDockState.pinnedArray[index], 740, "");
            }
        }

        function closeContextMenu() {
            globalDockState.closeContextMenu();
        }

        function toggle(popupName: string) {
            if (popupName === "audio" || popupName === "sound" || popupName === "media" || popupName === "player" || popupName === "volume") {
                globalDockState.toggleAudioFlyout("");
            } else if (popupName === "calendar" || popupName === "clock" || popupName === "time" || popupName === "notifications") {
                globalDockState.toggleCalendarFlyout("");
            } else if (popupName === "network" || popupName === "wifi" || popupName === "ethernet") {
                globalDockState.toggleNetworkFlyout("");
            } else if (popupName === "bluetooth" || popupName === "bt") {
                globalDockState.toggleBluetoothFlyout("");
            } else {
                globalDockState.closeFlyouts();
            }
        }

        function toggleAudio() {
            globalDockState.toggleAudioFlyout("");
        }

        function toggleCalendar() {
            globalDockState.toggleCalendarFlyout("");
        }

        function toggleNetwork() {
            globalDockState.toggleNetworkFlyout("");
        }

        function toggleBluetooth() {
            globalDockState.toggleBluetoothFlyout("");
        }

        function closeFlyouts() {
            globalDockState.closeFlyouts();
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Scope {
            id: screenScope
            required property var modelData

            // ── 1. Bottom Dock Window (Floating Liquid Glass Capsules) ──
            PanelWindow {
                id: dockWindow
                screen: screenScope.modelData
                color: "transparent"
                implicitHeight: 96

                anchors {
                    bottom: true
                    left: true
                    right: true
                }

                margins {
                    bottom: 8
                }

                // Overlay layer guarantees tooltips and platter are never covered by windows
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "win11-dock"
                WlrLayershell.exclusiveZone: 52

                mask: Region {
                    Region {
                        item: appsPlatter
                        radius: 26
                    }
                    Region {
                        item: trayPlatter
                        radius: 26
                    }
                }

                Row {
                    id: dockContainer
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    spacing: 8

                    DockPlatter {
                        id: appsPlatter
                        dockState: globalDockState
                        panelWindow: dockWindow
                    }

                    TrayPlatter {
                        id: trayPlatter
                        dockState: globalDockState
                        panelWindow: dockWindow
                    }
                }
            }

            // ── 2. Overlay Window (Full-Screen Surface for Windows 11 Context Menu) ──
            PanelWindow {
                id: overlayWindow
                screen: screenScope.modelData
                color: "transparent"
                visible: globalDockState.contextMenuVisible &&
                         (globalDockState.contextMenuScreen === "" || globalDockState.contextMenuScreen === screenScope.modelData.name)

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "win11-dock-overlay"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.keyboardFocus: globalDockState.contextMenuVisible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

                DockContextMenu {
                    dockState: globalDockState
                }
            }

            // ── 3. Flyout Dismiss Backdrop Window (Captures outside clicks to close flyouts) ──
            // ── 3. Flyout Dismiss Backdrop Window (Captures outside clicks to close flyouts) ──
            PanelWindow {
                id: flyoutDismissWindow
                screen: screenScope.modelData
                color: "transparent"
                visible: globalDockState.flyoutVisible &&
                         (globalDockState.flyoutScreen === "" || globalDockState.flyoutScreen === screenScope.modelData.name)

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.namespace: "win11-flyout-dismiss"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                MouseArea {
                    anchors.fill: parent
                    enabled: globalDockState.flyoutOpen
                    cursorShape: Qt.ArrowCursor
                    onClicked: globalDockState.closeFlyouts()
                }
            }

            // ── 4. Acrylic Liquid Glass Flyout Window (Attached above bottom dock on the right) ──
            PanelWindow {
                id: flyoutWindow
                screen: screenScope.modelData
                color: "transparent"
                visible: globalDockState.flyoutVisible &&
                         (globalDockState.flyoutScreen === "" || globalDockState.flyoutScreen === screenScope.modelData.name)

                anchors {
                    bottom: true
                    right: true
                }

                margins {
                    bottom: globalDockState.flyoutOpen ? 12 : -32
                    right: 28

                    Behavior on bottom {
                        NumberAnimation {
                            duration: globalDockState.flyoutOpen ? 260 : 170
                            easing.type: globalDockState.flyoutOpen ? Easing.OutCubic : Easing.InQuad
                        }
                    }
                }

                implicitWidth: 360
                implicitHeight: Math.max(220, (
                    globalDockState.activeFlyout === "audio" ? mediaFlyout.implicitHeight :
                    (globalDockState.activeFlyout === "network" ? networkFlyout.implicitHeight :
                    (globalDockState.activeFlyout === "bluetooth" ? bluetoothFlyout.implicitHeight : calendarFlyout.implicitHeight))
                ) + 4)

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "win11-dock-flyout"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.keyboardFocus: globalDockState.activeFlyout === "network" ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

                MediaControlFlyout {
                    id: mediaFlyout
                    dockState: globalDockState
                    visible: globalDockState.activeFlyout === "audio"
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                }

                CalendarNotificationFlyout {
                    id: calendarFlyout
                    dockState: globalDockState
                    visible: globalDockState.activeFlyout === "calendar"
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                }

                NetworkControlFlyout {
                    id: networkFlyout
                    dockState: globalDockState
                    visible: globalDockState.activeFlyout === "network"
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                }

                BluetoothControlFlyout {
                    id: bluetoothFlyout
                    dockState: globalDockState
                    visible: globalDockState.activeFlyout === "bluetooth"
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                }
            }
        }
    }
}
