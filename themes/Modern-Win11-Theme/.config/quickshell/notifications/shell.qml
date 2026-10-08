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

    // IPC Interface for CLI, Dock flyouts & scripts
    IpcHandler {
        target: "notifications"

        function clear() {
            globalNotifState.clearAll();
        }

        function dismiss(id: string) {
            globalNotifState.dismiss(parseInt(id));
        }

        function dismissPopup(id: string) {
            globalNotifState.dismissPopup(parseInt(id));
        }

        function invoke(id: string, actionIndex: string) {
            globalNotifState.invokeAction(parseInt(id), parseInt(actionIndex || 0));
        }

        function toggleSound() {
            globalNotifState.soundEnabled = !globalNotifState.soundEnabled;
        }

        function toggleDnd() {
            globalNotifState.dndEnabled = !globalNotifState.dndEnabled;
        }

        function sample(name: string) {
            var home = Quickshell.env("HOME") || "/home/facuud2";
            var cmd = home + "/.config/quickshell/notifications/scripts/test_notification.sh " + (name || "whatsapp");
            Quickshell.execDetached(["bash", "-c", cmd]);
        }
    }

    // Overlay Window on screen (Bottom-right corner above dock, Windows 11 style)
    Variants {
        model: Quickshell.screens

        delegate: Scope {
            id: screenScope
            required property var modelData

            PanelWindow {
                id: notifWindow
                screen: screenScope.modelData
                color: "transparent"
                visible: globalNotifState.activePopups.length > 0

                anchors {
                    bottom: true
                    right: true
                }
                margins {
                    bottom: 12
                    right: 28
                }
                implicitWidth: 360
                implicitHeight: notifView.implicitHeight

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "win11-dock-notification"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                NotificationView {
                    id: notifView
                    notifState: globalNotifState
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    z: 1
                }
            }
        }
    }
}
