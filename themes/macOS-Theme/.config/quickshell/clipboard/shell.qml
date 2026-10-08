import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: root

    // Global Shared Clipboard State
    ClipboardState {
        id: globalClipboardState
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
            if (!globalClipboardState.isOpen) {
                root.updateTargetScreen("");
            }
        }
    }

    // IPC Interface to control Clipboard from CLI, scripts, and Super+V
    IpcHandler {
        target: "clipboard"

        function toggle() {
            root.updateTargetScreen("");
            globalClipboardState.toggleClipboard();
        }

        function toggleOn(screenName: string) {
            root.updateTargetScreen(screenName);
            globalClipboardState.toggleClipboard();
        }

        function open() {
            root.updateTargetScreen("");
            globalClipboardState.openClipboard();
        }

        function openOn(screenName: string) {
            root.updateTargetScreen(screenName);
            globalClipboardState.openClipboard();
        }

        function close() {
            globalClipboardState.closeClipboard();
        }

        function clear() {
            globalClipboardState.clearAll();
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
                visible: globalClipboardState.windowVisible

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.namespace: "macos-clipboard-catcher"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                MouseArea {
                    anchors.fill: parent
                    enabled: globalClipboardState.isOpen
                    onClicked: globalClipboardState.closeClipboard()
                }
            }
        }
    }

    // ── 2. Compact Floating Clipboard Card Window (ONLY on focused monitor, BLURRED BY HYPRLAND) ──
    // Sized ONLY to the card bounds (540x490) so Hyprland blurs ONLY this card!
    PanelWindow {
        id: clipboardWindow
        screen: root.targetScreen
        color: "transparent"
        visible: globalClipboardState.windowVisible

        implicitWidth: 540
        implicitHeight: 490

        anchors {
            top: true
        }
        margins {
            top: Math.max(80, Math.round((root.targetScreen ? root.targetScreen.height : 1080) * 0.18))
        }

        mask: Region {
            width: 540
            height: 490
            radius: 22
        }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "macos-clipboard"
        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.keyboardFocus: globalClipboardState.isOpen
            ? WlrKeyboardFocus.Exclusive
            : WlrKeyboardFocus.None

        ClipboardView {
            id: clipboardView
            clipboardState: globalClipboardState
            anchors.fill: parent
        }
    }
}
