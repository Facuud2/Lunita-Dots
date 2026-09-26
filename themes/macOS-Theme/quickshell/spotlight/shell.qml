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

            PanelWindow {
                id: spotlightWindow
                screen: screenScope.modelData
                color: "transparent"
                visible: globalSpotlightState.windowVisible

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "macos-spotlight"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.keyboardFocus: globalSpotlightState.isOpen
                    ? WlrKeyboardFocus.Exclusive
                    : WlrKeyboardFocus.None

                // Backdrop Dimmer (Smooth Dim)
                Rectangle {
                    anchors.fill: parent
                    color: "#30000000"
                    opacity: globalSpotlightState.isOpen ? 1.0 : 0.0

                    Behavior on opacity {
                        NumberAnimation { duration: 160 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: globalSpotlightState.isOpen
                        onClicked: globalSpotlightState.closeSpotlight()
                    }
                }

                // Centered Upper Spotlight Floating Card
                SpotlightView {
                    id: spotlightView
                    spotlightState: globalSpotlightState
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: Math.max(80, Math.round(spotlightWindow.height * 0.18))
                }
            }
        }
    }
}
