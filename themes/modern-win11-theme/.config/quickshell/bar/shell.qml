import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "popups"
import "panels"

Scope {
    id: root

    // Global Shared State
    BarState {
        id: globalBarState
    }

    // Connections for monitor/workspace switching: close edge panels immediately!
    Connections {
        target: Hyprland
        function onFocusedMonitorChanged() {
            globalBarState.closeEdgePanels();
        }
        function onFocusedWorkspaceChanged() {
            globalBarState.closeEdgePanels();
        }
    }

    // IPC interface for toggling popups from external scripts / Hyprland keybinds
    IpcHandler {
        target: "bar"

        function toggle(popupName: string) {
            if (popupName === "sound" || popupName === "volume") {
                var targetVol = (Hyprland.focusedMonitor && Hyprland.focusedMonitor.name) ? Hyprland.focusedMonitor.name : "";
                globalBarState.toggleSound(targetVol);
            } else if (popupName === "media" || popupName === "music" || popupName === "player") {
                Quickshell.execDetached(["bash", "-c", "quickshell ipc -c dock call dock toggle audio 2>/dev/null || true"]);
            } else if (popupName === "calendar" || popupName === "clock" || popupName === "time" || popupName === "notifications") {
                Quickshell.execDetached(["bash", "-c", "quickshell ipc -c dock call dock toggle calendar 2>/dev/null || true"]);
            } else if (popupName === "controlcenter" || popupName === "cc" || popupName === "options" || popupName === "settings") {
                Quickshell.execDetached(["bash", "-c", "quickshell ipc -c dock call dock toggle audio 2>/dev/null || true"]);
            } else if (popupName === "brightness") {
                var target = (Hyprland.focusedMonitor && Hyprland.focusedMonitor.name) ? Hyprland.focusedMonitor.name : "";
                globalBarState.toggleBrightness(target);
            } else {
                Quickshell.execDetached(["bash", "-c", "quickshell ipc -c dock call dock closeFlyouts 2>/dev/null || true"]);
                globalBarState.closePopups();
            }
        }

        function soundFeedback() {
            globalBarState.triggerSoundFeedback();
        }

        function setIslandMode(mode: string) {
            globalBarState.activePopup = mode;
        }
    }

    // Displays on each screen
    Variants {
        model: Quickshell.screens

        delegate: Scope {
            id: screenScope
            required property var modelData

            // ── 1. Top Dynamic Island Notch Window (Attached to Top Edge y: 0) ──
            PanelWindow {
                id: notchWindow
                screen: screenScope.modelData
                color: "transparent"
                implicitHeight: 300
                implicitWidth: 440

                anchors {
                    top: true
                }
                margins {
                    top: 0
                }

                mask: Region {
                    width: island.islandMode === "collapsed" ? island.width : 412
                    height: island.islandMode === "collapsed" ? 34 : (island.islandMode === "media" ? 172 : 280)
                    x: (notchWindow.width - width) / 2
                    y: 0
                    radius: island.islandMode === "collapsed" ? 18 : 22
                }

                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.namespace: "win11-dynamic-island"
                WlrLayershell.exclusiveZone: 34
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                DynamicIsland {
                    id: island
                    barState: globalBarState
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                }
            }

            // ── 2. Top Calendar Overlay Window (Only when Calendar popup is requested) ──
            PanelWindow {
                id: calendarOverlayWindow
                screen: screenScope.modelData
                color: "transparent"
                visible: globalBarState.activePopup === "calendar"

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }
                margins {
                    top: 0
                }

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "win11-calendar-overlay"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                // Dismiss Backdrop
                MouseArea {
                    anchors.fill: parent
                    onClicked: globalBarState.closePopups()
                }

                CalendarIslandCard {
                    barState: globalBarState
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                }
            }

            // ── 3. Left Edge Sound Panel Window (Localized only to Left Edge) ──
            PanelWindow {
                id: leftSoundWindow
                screen: screenScope.modelData
                color: "transparent"

                anchors {
                    top: true
                    bottom: true
                    left: true
                }

                implicitWidth: 44

                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.namespace: "win11-sound-edge"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                mask: Region {
                    // Full-height 8px edge sensor strip (always active)
                    Region {
                        x: 0
                        y: 0
                        width: 8
                        height: leftSoundWindow.height > 0 ? leftSoundWindow.height : (screenScope.modelData ? screenScope.modelData.height : 1080)
                    }
                    // Tab flyout body (only when open or animating)
                    Region {
                        x: 0
                        y: leftSoundFlyout.tabY
                        width: (leftSoundFlyout.isOpen || leftSoundFlyout.animating) ? 44 : 0
                        height: (leftSoundFlyout.isOpen || leftSoundFlyout.animating) ? 220 : 0
                    }
                }

                LeftSoundFlyout {
                    id: leftSoundFlyout
                    barState: globalBarState
                    screenName: screenScope.modelData ? screenScope.modelData.name : ""
                    anchors.fill: parent
                }
            }

            // ── 4. Right Edge Brightness Panel Window (Localized only to Right Edge) ──
            PanelWindow {
                id: rightBrightnessWindow
                screen: screenScope.modelData
                color: "transparent"

                anchors {
                    top: true
                    bottom: true
                    right: true
                }

                implicitWidth: 44

                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.namespace: "win11-brightness-edge"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                mask: Region {
                    // Full-height 8px edge sensor strip on the rightmost edge (local x: 36..44)
                    Region {
                        x: 36
                        y: 0
                        width: 8
                        height: rightBrightnessWindow.height > 0 ? rightBrightnessWindow.height : (screenScope.modelData ? screenScope.modelData.height : 1080)
                    }
                    // Tab flyout body (only when open or animating)
                    Region {
                        x: 0
                        y: rightBrightnessFlyout.tabY
                        width: (rightBrightnessFlyout.isOpen || rightBrightnessFlyout.animating) ? 44 : 0
                        height: (rightBrightnessFlyout.isOpen || rightBrightnessFlyout.animating) ? 220 : 0
                    }
                }

                RightBrightnessFlyout {
                    id: rightBrightnessFlyout
                    barState: globalBarState
                    screenName: screenScope.modelData ? screenScope.modelData.name : ""
                    anchors.fill: parent
                }
            }
        }
    }
}
