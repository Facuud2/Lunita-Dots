import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: root

    // Global Shared Launcher State
    LauncherState {
        id: globalLauncherState
    }

    // Target screen detection (defaults to focused Hyprland monitor or primary screen)
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

    function updateTargetScreen(preferredName) {
        let s = resolveScreen(preferredName);
        if (s) root.targetScreen = s;
    }

    Connections {
        target: Hyprland
        function onFocusedMonitorChanged() {
            if (!globalLauncherState.isOpen) {
                root.updateTargetScreen("");
            }
        }

        // Close launcher immediately if user focuses or clicks any other window in Hyprland
        function onActiveToplevelChanged() {
            if (globalLauncherState.isOpen) {
                globalLauncherState.closeLauncher();
            }
        }

        function onRawEvent(event) {
            if (!event || !globalLauncherState.isOpen) return;
            var ev = event.name;
            if (ev === "activewindow" || ev === "activewindowv2" || ev === "focusedmon") {
                globalLauncherState.closeLauncher();
            }
        }
    }

    // Capture focus grab under Hyprland: auto-clears / closes when clicking outside windows
    HyprlandFocusGrab {
        id: focusGrab
        active: globalLauncherState.isOpen
        windows: []
        onCleared: {
            if (globalLauncherState.isOpen) {
                globalLauncherState.closeLauncher();
            }
        }
    }

    // IPC Interface to control launcher from CLI, scripts, binds or Dock
    IpcHandler {
        target: "launcher"

        function toggle() {
            root.updateTargetScreen("");
            globalLauncherState.toggleLauncher();
        }

        function toggleOn(screenName: string) {
            root.updateTargetScreen(screenName);
            globalLauncherState.toggleLauncher();
        }

        function open() {
            root.updateTargetScreen("");
            globalLauncherState.openLauncher();
        }

        function openOn(screenName: string) {
            root.updateTargetScreen(screenName);
            globalLauncherState.openLauncher();
        }

        function close() {
            globalLauncherState.closeLauncher();
        }
    }

    // ── Fullscreen Overlay Window per screen with Click-Catcher Backdrop and LauncherView ──
    Variants {
        model: Quickshell.screens

        delegate: Scope {
            id: screenScope
            required property var modelData

            readonly property bool isTargetScreen: root.targetScreen !== null &&
                (root.targetScreen === screenScope.modelData || root.targetScreen.name === screenScope.modelData.name)

            PanelWindow {
                id: overlayWindow
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
                WlrLayershell.keyboardFocus: (globalLauncherState.isOpen && screenScope.isTargetScreen)
                    ? WlrKeyboardFocus.Exclusive
                    : WlrKeyboardFocus.None

                // 1. Outside Click Catcher Backdrop
                MouseArea {
                    anchors.fill: parent
                    z: 0
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onPressed: {
                        if (globalLauncherState.isOpen) {
                            globalLauncherState.closeLauncher();
                        }
                    }
                }

                // 2. LauncherView anchored at bottom center on the target screen
                LauncherView {
                    id: launcherView
                    visible: screenScope.isTargetScreen
                    launcherState: globalLauncherState
                    z: 1

                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom: parent.bottom
                        bottomMargin: 76
                    }
                }
            }
        }
    }
}
