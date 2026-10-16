import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: root

    // Global Shared Clipboard State (Lunita-Default)
    ClipboardState {
        id: globalClipboardState
    }

    // IPC Interface to control Clipboard from CLI, scripts, and Super+V
    IpcHandler {
        target: "clipboard"

        function toggle() {
            globalClipboardState.toggleClipboard();
        }

        function toggleOn(screenName: string) {
            if (screenName && screenName !== "") {
                globalClipboardState.targetScreenName = screenName;
            }
            globalClipboardState.toggleClipboard();
        }

        function open() {
            globalClipboardState.openClipboard();
        }

        function openOn(screenName: string) {
            if (screenName && screenName !== "") {
                globalClipboardState.targetScreenName = screenName;
            }
            globalClipboardState.openClipboard();
        }

        function close() {
            globalClipboardState.closeClipboard();
        }

        function clear() {
            globalClipboardState.clearAll();
        }
    }

    // ── Fullscreen transparent surface per monitor (no black backdrop, no Wayland margin interpolation) ──
    Variants {
        model: Quickshell.screens

        delegate: Scope {
            id: screenScope
            required property var modelData

            readonly property bool isTargetScreen: {
                if (globalClipboardState.targetScreenName !== "") {
                    return screenScope.modelData.name === globalClipboardState.targetScreenName;
                }
                if (Hyprland.focusedMonitor && Hyprland.focusedMonitor.name) {
                    return screenScope.modelData.name === Hyprland.focusedMonitor.name;
                }
                return Quickshell.screens.length > 0 && screenScope.modelData.name === Quickshell.screens[0].name;
            }

            PanelWindow {
                id: clipboardSurfaceWindow
                screen: screenScope.modelData
                color: "transparent"
                visible: globalClipboardState.windowVisible

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "lunita-clipboard"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.keyboardFocus: (globalClipboardState.isOpen && screenScope.isTargetScreen)
                    ? WlrKeyboardFocus.Exclusive
                    : WlrKeyboardFocus.None

                // Outside click-catcher (100% transparent, no dark overlay)
                MouseArea {
                    anchors.fill: parent
                    enabled: globalClipboardState.isOpen
                    onClicked: globalClipboardState.closeClipboard()
                }

                // Floating Clipboard Card positioned directly at cursor without position animations
                ClipboardView {
                    id: clipboardView
                    visible: screenScope.isTargetScreen && globalClipboardState.isOpen
                    clipboardState: globalClipboardState
                    x: globalClipboardState.panelX
                    y: globalClipboardState.panelY
                }
            }
        }
    }
}
