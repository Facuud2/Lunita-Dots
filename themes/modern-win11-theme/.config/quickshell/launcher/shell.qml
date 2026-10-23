import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: root

    // Target screen detection (defaults to focused Hyprland monitor or primary screen)
    property var targetScreen: resolveScreen("")

    function resolveScreen(preferredName) {
        if (preferredName && preferredName !== "") {
            for (let i = 0; i < Quickshell.screens.length; i++) {
                if (Quickshell.screens[i].name === preferredName)
                    return Quickshell.screens[i];

            }
        }
        if (Hyprland.focusedMonitor && Hyprland.focusedMonitor.name) {
            for (let i = 0; i < Quickshell.screens.length; i++) {
                if (Quickshell.screens[i].name === Hyprland.focusedMonitor.name)
                    return Quickshell.screens[i];

            }
        }
        return Quickshell.screens.length > 0 ? Quickshell.screens[0] : null;
    }

    function updateTargetScreen(preferredName) {
        let s = resolveScreen(preferredName);
        if (s)
            root.targetScreen = s;

    }

    // Global Shared Launcher State
    LauncherState {
        id: globalLauncherState
    }

    Connections {
        function onFocusedMonitorChanged() {
            if (!globalLauncherState.isOpen)
                root.updateTargetScreen("");

        }

        target: Hyprland
    }

    // IPC Interface to control launcher from CLI, scripts, binds or Dock
    IpcHandler {
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

        function togglePower() {
            if (!globalLauncherState.isOpen) {
                root.updateTargetScreen("");
                globalLauncherState.openLauncher();
            }
            globalLauncherState.powerMenuOpen = !globalLauncherState.powerMenuOpen;
        }

        target: "launcher"
    }

    // ── 1. Fullscreen transparent click-catcher on all active screens ──
    // Closes launcher immediately when clicking outside on any monitor
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
                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.namespace: "win11-launcher-catcher"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: globalLauncherState.isOpen
                    cursorShape: Qt.ArrowCursor
                    onClicked: globalLauncherState.closeLauncher()
                }

            }

        }

    }

    // ── 2. Compact Floating Launcher Window (Layer-Blurred by Hyprland) ──
    PanelWindow {
        id: launcherWindow

        screen: root.targetScreen
        color: "transparent"
        visible: globalLauncherState.windowVisible
        implicitWidth: 640
        implicitHeight: 760
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "win11-launcher"
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: globalLauncherState.isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

        anchors {
            bottom: true
        }

        margins {
            bottom: 8
        }

        LauncherView {
            id: launcherView

            launcherState: globalLauncherState
            anchors.fill: parent
        }

        mask: Region {
            x: 0
            y: launcherView.cardY
            width: 640
            height: 700
            radius: 14
        }

    }

}
