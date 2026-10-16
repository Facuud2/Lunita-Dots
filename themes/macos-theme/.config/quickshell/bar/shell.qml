//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "popups"

Scope {
    id: root

    // Global Shared Bar State
    BarState {
        id: globalBarState
    }

    // IPC interface for toggling menus & controls
    IpcHandler {
        target: "bar"

        function toggle(popupName: string, menuTitle: string) {
            var title = menuTitle || "File";
            if (popupName === "file" || popupName === "appmenu" || popupName === "edit" || popupName === "view" || popupName === "window" || popupName === "help") {
                if (popupName === "edit") title = "Edit";
                else if (popupName === "view") title = "View";
                else if (popupName === "window") title = "Window";
                else if (popupName === "help") title = "Help";
                else if (popupName === "file") title = "File";
                globalBarState.openAppMenu(title, 40, 28);
            } else if (popupName === "network" || popupName === "net" || popupName === "wifi") {
                globalBarState.togglePopup("network", 1540, 28);
            } else if (popupName === "sound" || popupName === "audio" || popupName === "vol" || popupName === "volume") {
                globalBarState.togglePopup("sound", 1560, 28);
            } else if (popupName === "controlcenter" || popupName === "cc") {
                globalBarState.togglePopup("controlcenter", 1580, 28);
            } else if (popupName === "bluetooth" || popupName === "bt") {
                globalBarState.togglePopup("bluetooth", 1620, 28);
            } else if (popupName === "calendar" || popupName === "clock") {
                globalBarState.togglePopup("calendar", 1610, 28);
            } else if (popupName === "apple") {
                globalBarState.togglePopup("apple", 10, 28);
            } else {
                globalBarState.closePopups();
            }
        }
    }

    // Top Bar & Overlay on each active screen
    Variants {
        model: Quickshell.screens

        delegate: Scope {
            id: screenScope
            required property var modelData

            // ── 1. Top macOS Status Bar Window ──
            PanelWindow {
                id: barWindow
                screen: screenScope.modelData
                color: "transparent"
                implicitHeight: 28

                anchors {
                    top: true
                    left: true
                    right: true
                }

                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.namespace: "macos-statusbar"
                WlrLayershell.exclusiveZone: 28

                BarView {
                    id: barView
                    barState: globalBarState
                    panelWindow: barWindow
                }
            }

            // ── 2. Overlay Dropdown / Popups Window ──
            PanelWindow {
                id: overlayWindow
                screen: screenScope.modelData
                color: "transparent"
                visible: globalBarState.activePopup !== "" && (globalBarState.activeScreen === null || globalBarState.activeScreen === screenScope.modelData || (globalBarState.activeScreen && globalBarState.activeScreen.name === screenScope.modelData.name))

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }
                margins {
                    top: 28
                }

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "macos-statusbar-overlay"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                // Dismiss backdrop
                MouseArea {
                    anchors.fill: parent
                    z: 0
                    onClicked: {
                        globalBarState.closePopups();
                    }
                }

                // Apple Menu Dropdown
                AppleMenu {
                    barState: globalBarState
                }

                // App Menu Dropdown (File / Edit / View / Window / Help)
                AppMenuDropdown {
                    barState: globalBarState
                }

                // macOS Control Center
                ControlCenter {
                    barState: globalBarState
                }

                // Sound / Audio Menu Flyout
                SoundMenu {
                    barState: globalBarState
                }

                // Network & Wi-Fi Menu Flyout
                NetworkMenu {
                    barState: globalBarState
                }

                // Bluetooth Menu Flyout
                BluetoothMenu {
                    barState: globalBarState
                }

                // Calendar & Clock Flyout
                CalendarMenu {
                    barState: globalBarState
                }
            }
        }
    }
}
