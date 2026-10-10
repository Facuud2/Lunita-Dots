import QtQuick
import "."

Item {
    id: root

    implicitWidth: Theme.expandedWidth
    implicitHeight: mainColumn.implicitHeight + 28 + (root.notifying ? Theme.notifStrip : 0)

    property string overlay: ""
    readonly property bool notifying: Notifs.current !== null

    signal closeRequested

    function openOverlay(name) {
        overlay = name;
    }
    function closeOverlay() {
        overlay = "";
    }

    Rectangle {
        id: island
        anchors.fill: parent
        radius: Theme.expandedRadius
        color: Theme.bg
        clip: true

        // ── Notificación entrante (franja inferior Nothing) ──
        Item {
            id: notifView
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: Theme.notifStrip
            opacity: root.notifying ? 1 : 0
            visible: opacity > 0
            z: 3

            Behavior on opacity { NumberAnimation { duration: Theme.durShort } }

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                height: 1
                color: Theme.outline
            }

            Row {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "notifications"
                    color: Theme.alert
                    font.family: Theme.fontIcons
                    font.pixelSize: 22
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 40
                    spacing: 1

                    Text {
                        width: parent.width
                        text: Notifs.current?.summary ?? ""
                        color: Theme.fg
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.bodySmall
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                    }
                    Text {
                        width: parent.width
                        text: Notifs.current?.body ?? ""
                        color: Theme.fgDim
                        font.family: Theme.fontUi
                        font.pixelSize: Theme.labelSmall
                        elide: Text.ElideRight
                    }
                }
            }
        }

        // ── Panel Principal ──
        Item {
            id: panel
            anchors.fill: parent
            anchors.margins: 14
            anchors.bottomMargin: 14 + (root.notifying ? Theme.notifStrip : 0)

            Item {
                id: panelContent
                anchors.fill: parent
                opacity: root.overlay !== "" ? 0.35 : 1
                scale: root.overlay !== "" ? 0.97 : 1

                Behavior on opacity { NumberAnimation { duration: Theme.durMedium } }
                Behavior on scale { NumberAnimation { duration: Theme.durMedium } }

                Column {
                    id: mainColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    spacing: 10

                    // 1. Reloj grande NDOT 47 + Fecha a la derecha
                    HeaderClock {
                        width: parent.width
                        onRequestCalendar: root.openOverlay("cal")
                    }

                    // 2. Tarjetas de Conexión: Red, Bluetooth, Sonido
                    StatusPills {
                        width: parent.width
                        onRequestPanel: mode => root.openOverlay(mode)
                    }

                    // 3. Reproductor Multimedia con ondas y resplandor rojo Nothing
                    MediaCard {
                        width: parent.width
                    }

                    // 4. Grabación de Pantalla + Métricas de Hardware (CPU, RAM, GPU)
                    RecordingAndMetersRow {
                        width: parent.width
                    }

                    // 5. Modo Café + Botones de Acción (Bloquear, Notificaciones, Apagar)
                    QuickActions {
                        width: parent.width
                        onRequestNotifs: root.openOverlay("notif")
                        onRequestPower: root.openOverlay("power")
                        onRequestLock: {
                            Exec.run("~/.config/hypr/scripts/smart_lock.sh classic || hyprlock");
                            root.closeRequested();
                        }
                    }
                }
            }
        }

        // ── Vistas Superpuestas (Overlays: Wifi, Bluetooth, Calendario, etc.) ──
        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: root.overlay !== "" ? 0.65 : 0
            visible: opacity > 0
            z: 4

            Behavior on opacity { NumberAnimation { duration: Theme.durMedium } }

            MouseArea {
                anchors.fill: parent
                onClicked: root.closeOverlay()
            }
        }

        Item {
            anchors.fill: parent
            anchors.margins: 14
            anchors.bottomMargin: 14 + (root.notifying ? Theme.notifStrip : 0)
            z: 5
            visible: overlayBox.opacity > 0

            Rectangle {
                id: overlayBox
                anchors.centerIn: parent
                width: parent.width
                height: Math.min(parent.height, overlayLoader.item ? overlayLoader.item.implicitHeight + 28 : parent.height)
                radius: Theme.shapeLg
                color: Theme.surface
                border.width: 1
                border.color: Theme.outline
                clip: true

                opacity: root.overlay !== "" ? 1 : 0
                scale: root.overlay !== "" ? 1 : 0.94

                Behavior on opacity { NumberAnimation { duration: Theme.durShort } }
                Behavior on scale { SpringAnimation { spring: 9.0; damping: 0.5; mass: 0.35 } }
                Behavior on height { NumberAnimation { duration: Theme.durMedium } }

                Loader {
                    id: overlayLoader
                    anchors.fill: parent
                    anchors.margins: 14
                    active: root.overlay !== ""

                    sourceComponent: {
                        if (root.overlay === "rec") return recComp;
                        if (root.overlay === "wifi" || root.overlay === "bt") return connComp;
                        if (root.overlay === "audio") return audioComp;
                        if (root.overlay === "notif") return notifComp;
                        if (root.overlay === "cal") return calComp;
                        if (root.overlay === "power") return powerComp;
                        if (root.overlay === "apps") return appsComp;
                        return null;
                    }
                }

                Component {
                    id: recComp
                    RecordView { onClosed: root.closeOverlay() }
                }

                Component {
                    id: connComp
                    ConnPanel {
                        mode: root.overlay
                        onClosed: root.closeOverlay()
                    }
                }

                Component {
                    id: audioComp
                    AudioPanel { onClosed: root.closeOverlay() }
                }

                Component {
                    id: notifComp
                    NotifPanel { onClosed: root.closeOverlay() }
                }

                Component {
                    id: calComp
                    CalendarPanel { onClosed: root.closeOverlay() }
                }

                Component {
                    id: powerComp
                    PowerView { onClosed: root.closeOverlay() }
                }

                Component {
                    id: appsComp
                    AppLauncher { onClosed: root.closeOverlay() }
                }
            }
        }
    }
}
