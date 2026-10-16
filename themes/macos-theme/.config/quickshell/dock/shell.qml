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
                implicitWidth: platter.implicitWidth + 60
                implicitHeight: 104

                anchors {
                    bottom: true
                }

                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.namespace: "macos-dock"
                WlrLayershell.exclusiveZone: 62

                DockPlatter {
                    id: platter
                    dockState: globalDockState
                    panelWindow: dockWindow
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 2
                }
            }

            // ── 2. Overlay Window (Context Menu & Add App Modal - Isolated per Monitor) ──
            PanelWindow {
                id: overlayWindow
                screen: screenScope.modelData
                color: "transparent"

                readonly property bool isContextOnThisScreen: globalDockState.contextMenuVisible &&
                    (globalDockState.contextMenuScreen === "" || globalDockState.contextMenuScreen === screenScope.modelData.name)
                readonly property bool isModalOnThisScreen: globalDockState.addModalVisible &&
                    (globalDockState.addModalScreen === "" || globalDockState.addModalScreen === screenScope.modelData.name)

                visible: isContextOnThisScreen || isModalOnThisScreen

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "macos-dock-overlay"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.keyboardFocus: isModalOnThisScreen
                    ? WlrKeyboardFocus.Exclusive
                    : (isContextOnThisScreen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None)

                DockContextMenu {
                    dockState: globalDockState
                    screenName: screenScope.modelData.name
                }

                DockAddAppModal {
                    dockState: globalDockState
                    screenName: screenScope.modelData.name
                }
            }
        }
    }
}
