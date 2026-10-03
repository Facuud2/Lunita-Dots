import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: root

    // Global Shared Spotlight State
    SpotlightState {
        id: globalSpotlightState
    }

    // IPC Interface to control Spotlight from CLI, scripts, binds, top bar or Dock
    IpcHandler {
        target: "spotlight"

        function toggle() {
            globalSpotlightState.toggleSpotlight()
        }

        function open() {
            globalSpotlightState.openSpotlight()
        }

        function close() {
            globalSpotlightState.closeSpotlight()
        }
    }

    // Spotlight Overlay on all active screens
    Variants {
        model: Quickshell.screens

        delegate: Scope {
            id: screenScope
            required property var modelData

            // ── 1. Fullscreen transparent click-catcher (NO BLUR, no dim) ──
            PanelWindow {
                id: clickCatcherWindow
                screen: screenScope.modelData
                color: "transparent"
                visible: globalSpotlightState.windowVisible

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.namespace: "macos-spotlight-catcher"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                MouseArea {
                    anchors.fill: parent
                    enabled: globalSpotlightState.isOpen
                    onClicked: globalSpotlightState.closeSpotlight()
                }
            }

            // ── 2. Compact Floating Spotlight Card Window (BLURRED BY HYPRLAND) ──
            // Sized ONLY to the card bounds (680x460) so Hyprland blurs ONLY this card!
            PanelWindow {
                id: spotlightWindow
                screen: screenScope.modelData
                color: "transparent"
                visible: globalSpotlightState.windowVisible

                implicitWidth: 680
                implicitHeight: 460

                anchors {
                    top: true
                }
                margins {
                    top: Math.max(80, Math.round(screenScope.modelData.height * 0.18))
                }

                mask: Region {
                    width: 680
                    height: 460
                    radius: 20
                }

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "macos-spotlight"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.keyboardFocus: globalSpotlightState.isOpen
                    ? WlrKeyboardFocus.Exclusive
                    : WlrKeyboardFocus.None

                SpotlightView {
                    id: spotlightView
                    spotlightState: globalSpotlightState
                    anchors.fill: parent
                }
            }
        }
    }
}
