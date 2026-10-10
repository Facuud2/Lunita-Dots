import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
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
            // Actualizar monitor destino al enfocado al recibir nueva notificación
            root.targetScreen = root.resolveScreen("");
            globalNotifState.handleIncomingNotification(notif);
        }
    }

    // Detección de monitor enfocado para mostrar la notificación en la pantalla activa
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

    Connections {
        target: globalNotifState
        function onActiveListChanged() {
            if (globalNotifState.activeList.length === 1) {
                root.targetScreen = root.resolveScreen("");
            }
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

    // Overlay Window strictly sized and masked to notification cards
    Variants {
        model: Quickshell.screens

        delegate: Scope {
            id: screenScope
            required property var modelData

            PanelWindow {
                id: notifWindow
                screen: screenScope.modelData
                color: "transparent"
                visible: globalNotifState.activeList.length > 0 && (root.targetScreen === null || root.targetScreen.name === screenScope.modelData.name)

                anchors {
                    top: true
                }
                margins {
                    top: 52
                }

                // Tamaño DINÁMICO ajustado estrictamente al contenido de las notificaciones visibles
                implicitWidth: notifView.implicitWidth || 390
                implicitHeight: notifView.implicitHeight

                // Máscara de entrada para que NINGÚN clic fuera de las tarjetas sea interceptado
                mask: Region {
                    width: notifWindow.width
                    height: notifWindow.height
                }

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "lunita-notifications"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                NotificationView {
                    id: notifView
                    notifState: globalNotifState
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
