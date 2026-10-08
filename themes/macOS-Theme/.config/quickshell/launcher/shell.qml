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

    // ── 1. Fullscreen transparent click-catcher on all active screens (dismiss on outside click) ──
    Variants {
        model: Quickshell.screens

        delegate: Scope {
            id: screenScope
            required property var modelData

            PanelWindow {
                id: clickCatcherWindow
                screen: screenScope.modelData
                color: "transparent"
                visible: globalLauncherState.windowVisible

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.namespace: "macos-launcher-catcher"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                MouseArea {
                    anchors.fill: parent
                    enabled: globalLauncherState.isOpen
                    onClicked: globalLauncherState.closeLauncher()
                }
            }
        }
    }

    // ── 2. Compact Floating Launcher Window (ONLY on focused monitor, BLURRED BY HYPRLAND) ──
    // Sized ONLY to the card bounds (580x640) so Hyprland blurs ONLY this card!
    PanelWindow {
        id: launcherWindow
        screen: root.targetScreen
        color: "transparent"
        visible: globalLauncherState.windowVisible

        implicitWidth: 580
        implicitHeight: 640

        anchors {
            bottom: true
        }
        margins {
            bottom: 76
        }

        mask: Region {
            width: 580
            height: 640
            radius: 26
        }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "macos-launcher"
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: globalLauncherState.isOpen
            ? WlrKeyboardFocus.Exclusive
            : WlrKeyboardFocus.None

        LauncherView {
            id: launcherView
            launcherState: globalLauncherState
            anchors.fill: parent
        }
    }
}
