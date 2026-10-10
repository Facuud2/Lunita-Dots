import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: root

    // Global OSD State
    OSDState {
        id: globalOsdState
    }

    // Detección del monitor enfocado (donde se realizan las acciones)
    property var targetScreen: resolveScreen("")

    function resolveScreen(preferredName) {
        if (preferredName && preferredName !== "") {
            for (let i = 0; i < Quickshell.screens.length; i++) {
                if (Quickshell.screens[i].name === preferredName) {
                    return Quickshell.screens[i];
                }
            }
        }
        if (Hyprland.focusedMonitor && Hyprland.focusedMonitor.name) {
            for (let i = 0; i < Quickshell.screens.length; i++) {
                if (Quickshell.screens[i].name === Hyprland.focusedMonitor.name) {
                    return Quickshell.screens[i];
                }
            }
        }
        return Quickshell.screens.length > 0 ? Quickshell.screens[0] : null;
    }

    Connections {
        target: Hyprland
        function onFocusedMonitorChanged() {
            if (!globalOsdState.isVisible) {
                root.targetScreen = root.resolveScreen("");
            }
        }
    }

    // IPC interface for triggering / testing via CLI
    IpcHandler {
        target: "osd"

        function show(type: string) {
            root.targetScreen = root.resolveScreen("");
            globalOsdState.show(type || "volume");
        }

        function hide() {
            globalOsdState.hideImmediately();
        }

        function toggle() {
            root.targetScreen = root.resolveScreen("");
            if (globalOsdState.isVisible) {
                globalOsdState.hideImmediately();
            } else {
                globalOsdState.show("volume");
            }
        }
    }

    // Floating Nothing OS HUD Window placed on focused display (bottom-center)
    Variants {
        model: Quickshell.screens

        delegate: Scope {
            id: screenScope
            required property var modelData

            PanelWindow {
                id: osdWindow
                screen: screenScope.modelData
                color: "transparent"
                visible: globalOsdState.isVisible && (root.targetScreen === null || root.targetScreen.name === screenScope.modelData.name)

                anchors {
                    bottom: true
                }
                margins {
                    bottom: 64
                }

                implicitWidth: 260
                implicitHeight: 114

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "lunita-volume-osd"
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
