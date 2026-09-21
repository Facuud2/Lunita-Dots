import QtQuick
import Quickshell
import Quickshell.Wayland

Scope {
    id: root

    // Global Shared Dock State
    DockState {
        id: globalDockState
    }

    // Dock Window on each active screen
    Variants {
        model: Quickshell.screens

        delegate: Scope {
            id: screenScope
            required property var modelData

            // ── 1. Bottom Dock Window ──
            PanelWindow {
                id: dockWindow
                screen: screenScope.modelData
                color: "transparent"
                implicitHeight: 74

                anchors {
                    bottom: true
                    left: true
                    right: true
                }

                mask: Region {
                    item: platter
                }

                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.exclusiveZone: 62

                DockPlatter {
                    id: platter
                    dockState: globalDockState
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4
                }
            }

            // ── 2. Overlay Window (Context Menu & Add App Modal) ──
            PanelWindow {
                id: overlayWindow
                screen: screenScope.modelData
                color: "transparent"
                visible: globalDockState.contextMenuVisible || globalDockState.addModalVisible

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: globalDockState.addModalVisible
                    ? WlrKeyboardFocus.Exclusive
                    : WlrKeyboardFocus.OnDemand

                DockContextMenu {
                    dockState: globalDockState
                }

                DockAddAppModal {
                    dockState: globalDockState
                }
            }
        }
    }
}
