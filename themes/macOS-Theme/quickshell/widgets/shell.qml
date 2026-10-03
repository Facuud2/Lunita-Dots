import QtQuick
import Quickshell
import Quickshell.Wayland

Scope {
    id: root

    // Global Shared Widgets State
    WidgetsState {
        id: globalWidgetsState
    }

    // Fullscreen Desktop Widgets Canvas on each screen
    Variants {
        model: Quickshell.screens

        delegate: Scope {
            id: screenScope
            required property var modelData

            PanelWindow {
                id: widgetsWindow
                screen: screenScope.modelData
                color: "transparent"

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                WlrLayershell.layer: WlrLayer.Bottom
                WlrLayershell.namespace: "macos-desktop-widgets"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore

                DesktopGridCanvas {
                    anchors.fill: parent
                    screenName: screenScope.modelData ? (screenScope.modelData.name || "default") : "default"
                    widgetsState: globalWidgetsState
                }
            }
        }
    }
}
