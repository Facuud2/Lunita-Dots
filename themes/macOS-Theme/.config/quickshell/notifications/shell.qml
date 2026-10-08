import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications

Scope {
    id: root

    // Global Notification State
    NotificationState {
        id: globalNotifState
    }

    // D-Bus Notification Server Service
    NotificationServer {
        id: notifServer
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyImagesSupported: true
        imageSupported: true

        onNotification: notif => {
            globalNotifState.handleIncomingNotification(notif);
        }
    }

    // IPC Interface for CLI & scripts
    IpcHandler {
        target: "notifications"

        function clear() {
            globalNotifState.clearAll();
        }

        function dismiss(id: string) {
            globalNotifState.dismiss(parseInt(id));
        }

        function toggleSound() {
            globalNotifState.soundEnabled = !globalNotifState.soundEnabled;
        }

        function toggleDnd() {
            globalNotifState.dndEnabled = !globalNotifState.dndEnabled;
        }

        function sample(name: string) {
            var home = Quickshell.env("HOME") || "";
            var cmd = home + "/.config/quickshell/notifications/scripts/test_notification.sh " + (name || "brunch");
            Quickshell.execDetached(["bash", "-c", cmd]);
        }
    }

    // Overlay Window on primary screen or active screen
    Variants {
        model: Quickshell.screens

        delegate: Scope {
            id: screenScope
            required property var modelData

            PanelWindow {
                id: notifWindow
                screen: screenScope.modelData
                color: "transparent"
                visible: globalNotifState.activeList.length > 0

                anchors {
                    top: true
                    right: true
                    bottom: true
                }
                implicitWidth: 420

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "macos-notifications"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                // Dismiss open dropdowns if clicking anywhere outside
                MouseArea {
                    anchors.fill: parent
                    z: 0
                    onClicked: {
                        globalNotifState.closeAllOptions();
                    }
                }

                NotificationView {
                    id: notifView
                    notifState: globalNotifState
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 36
                    anchors.rightMargin: 16
                    z: 1
                }
            }
        }
    }
}
