import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: root

    // Global OSD State
    OSDState {
        id: globalOsdState
    }

    // IPC interface for triggering / testing via CLI
    IpcHandler {
        target: "osd"

        function show(type: string) {
            globalOsdState.show(type || "volume");
        }

        function hide() {
            globalOsdState.hideImmediately();
        }

        function toggle() {
            if (globalOsdState.isVisible) {
                globalOsdState.hideImmediately();
            } else {
                globalOsdState.show("volume");
            }
        }
    }

    // Floating OSD Window placed on each display (bottom-center)
    Variants {
        model: Quickshell.screens

        delegate: Scope {
            id: screenScope
            required property var modelData

            PanelWindow {
                id: osdWindow
                screen: screenScope.modelData
                color: "transparent"
                visible: globalOsdState.isVisible

                anchors {
                    bottom: true
                }
                margins {
                    bottom: 84
                }

                implicitWidth: 190
                implicitHeight: 190

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "macos-volume-osd"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                VolumeOSDCard {
                    id: osdCard
                    osdState: globalOsdState
                    anchors.fill: parent
                }
            }
        }
    }
}
