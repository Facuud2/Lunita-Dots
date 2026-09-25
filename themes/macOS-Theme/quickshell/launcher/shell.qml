import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: root

    // Global Shared Launcher State
    LauncherState {
        id: globalLauncherState
    }

    // IPC Interface to control launcher from CLI, scripts, binds or Dock
    IpcHandler {
        target: "launcher"

        function toggle() {
            globalLauncherState.toggleLauncher()
        }

        function open() {
            globalLauncherState.openLauncher()
        }

        function close() {
            globalLauncherState.closeLauncher()
        }
    }

    // Launcher Overlay on all screens
    Variants {
        model: Quickshell.screens

        delegate: Scope {
            id: screenScope
            required property var modelData

            PanelWindow {
                id: launcherWindow
                screen: screenScope.modelData
                color: "transparent"
                visible: globalLauncherState.windowVisible

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "macos-launcher"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.keyboardFocus: globalLauncherState.isOpen
                    ? WlrKeyboardFocus.Exclusive
                    : WlrKeyboardFocus.None

                // Backdrop Dimmer
                Rectangle {
                    anchors.fill: parent
                    color: "#40000000"
                    opacity: globalLauncherState.isOpen ? 1.0 : 0.0

                    Behavior on opacity {
                        NumberAnimation { duration: 180 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: globalLauncherState.isOpen
                        onClicked: globalLauncherState.closeLauncher()
                    }
                }

                // Frosted Glass App Launcher Emerging from Bottom Dock
                LauncherView {
                    id: launcherView
                    launcherState: globalLauncherState
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 76
                }
            }
        }
    }
}
