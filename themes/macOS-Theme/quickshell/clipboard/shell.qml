import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
    id: root

    // Global Shared Clipboard State
    ClipboardState {
        id: globalClipboardState
    }

    // IPC Interface to control Clipboard from CLI, scripts, and Super+V
    IpcHandler {
        target: "clipboard"

        function toggle() {
            globalClipboardState.toggleClipboard()
        }

        function open() {
            globalClipboardState.openClipboard()
        }

        function close() {
            globalClipboardState.closeClipboard()
        }

        function clear() {
            globalClipboardState.clearAll()
        }
    }

    // Clipboard on each active screen
    Variants {
        model: Quickshell.screens

        delegate: Scope {
            id: screenScope
            required property var modelData

            // ── 1. Fullscreen transparent click-catcher (NO BLUR, no dim) ──
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

            // ── 2. Compact Floating Clipboard Card Window (BLURRED BY HYPRLAND) ──
            // Sized ONLY to the card bounds (540x490) so Hyprland blurs ONLY this card!
            PanelWindow {
                id: clipboardWindow
                screen: screenScope.modelData
                color: "transparent"
                visible: globalClipboardState.windowVisible

                implicitWidth: 540
                implicitHeight: 490

                anchors {
                    top: true
                }
                margins {
                    top: Math.max(80, Math.round(screenScope.modelData.height * 0.18))
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
    }
}
