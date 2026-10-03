import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: root

    // Global Shared Spotlight State
    SpotlightState {
        id: globalSpotlightState
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
            if (!globalSpotlightState.isOpen) {
                root.updateTargetScreen("");
            }
        }
    }

    // IPC Interface to control Spotlight from CLI, scripts, binds, top bar or Dock
    IpcHandler {
        target: "spotlight"

        function toggle() {
            root.updateTargetScreen("");
            globalSpotlightState.toggleSpotlight();
        }

        function toggleOn(screenName: string) {
            root.updateTargetScreen(screenName);
            globalSpotlightState.toggleSpotlight();
        }

        function open() {
            root.updateTargetScreen("");
            globalSpotlightState.openSpotlight();
        }

        function openOn(screenName: string) {
            root.updateTargetScreen(screenName);
            globalSpotlightState.openSpotlight();
        }

        function close() {
            globalSpotlightState.closeSpotlight();
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
        }
    }

    // ── 2. Compact Floating Spotlight Card Window (ONLY on focused monitor, BLURRED BY HYPRLAND) ──
    // Sized ONLY to the card bounds (680x460) so Hyprland blurs ONLY this card!
    PanelWindow {
        id: spotlightWindow
        screen: root.targetScreen
        color: "transparent"
        visible: globalSpotlightState.windowVisible

        implicitWidth: 680
        implicitHeight: 460

        anchors {
            top: true
        }
        margins {
            top: Math.max(80, Math.round((root.targetScreen ? root.targetScreen.height : 1080) * 0.18))
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
