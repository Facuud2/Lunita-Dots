import "."
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    signal requestToggleExpand()
    signal requestHoverEnter()
    signal requestHoverExit()

    implicitWidth: Theme.collapsedWidth
    implicitHeight: Theme.collapsedHeight

    HoverHandler {
        id: pillHover

        onHoveredChanged: {
            if (hovered)
                root.requestHoverEnter();
            else
                root.requestHoverExit();
        }
    }

    Rectangle {
        id: pill

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: Math.min(parent.height, Theme.collapsedHeight)
        // Forma medio circular moderna Nothing (no píldora completa)
        radius: 16
        color: Theme.bg
        border.width: 1
        border.color: Theme.outline
        clip: false

        // ── Línea de acento dinámico Matugen / Nothing OS en el borde inferior ──
        Rectangle {
            id: bottomAccentLine

            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            height: 2.5
            radius: 1
            color: Theme.accent
            z: 10
        }

        // MouseArea de fondo para expandir/fijar al interactuar con el cuerpo de la barra
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.requestToggleExpand()
        }

        // ── 1. Grupo Izquierdo: Workspaces + Clima Nothing + Widgets ──
        Row {
            id: leftGroup

            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12
            z: 2

            Workspaces {
                anchors.verticalCenter: parent.verticalCenter
            }

            WeatherWidget {
                anchors.verticalCenter: parent.verticalCenter
            }

            // ── Botón de Widgets de Escritorio ──
            Item {
                id: widgetsBtn

                property bool isEditing: false

                anchors.verticalCenter: parent.verticalCenter
                width: 24
                height: 24

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: widgetsEditProc.running = true
                }

                Process {
                    id: widgetsEditProc

                    command: ["bash", "-c", "if [ -f /tmp/lunita_widgets_editing ]; then cat /tmp/lunita_widgets_editing; else echo 0; fi"]

                    stdout: SplitParser {
                        splitMarker: "\n"
                        onRead: (data) => {
                            widgetsBtn.isEditing = (data.trim() === "1");
                        }
                    }

                }

                Rectangle {
                    anchors.fill: parent
                    radius: 12
                    color: widgetsBtn.isEditing ? Qt.rgba(0.84, 0.1, 0.13, 0.25) : (widgetsMa.containsMouse ? Theme.surfaceHigh : "transparent")
                    border.width: 1
                    border.color: widgetsBtn.isEditing ? Theme.alert : (widgetsMa.containsMouse ? Theme.outline : "transparent")

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.durShort
                        }

                    }

                }

                Text {
                    anchors.centerIn: parent
                    text: "widgets"
                    color: widgetsBtn.isEditing ? Theme.alert : (widgetsMa.containsMouse ? Theme.fg : Theme.fgDim)
                    font.family: Theme.fontIcons
                    font.pixelSize: 16
                }

                MouseArea {
                    id: widgetsMa

                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.RightButton)
                            Exec.run("lunita-widgets-manager --tab desktop &");
                        else
                            Exec.run("lunita-widgets-toggle &");
                    }
                }

            }

        }

        // ── 2. Centro: Reloj Nothing OS en fuente NDOT 47 ──
        Item {
            id: centerGroup

            anchors.centerIn: parent
            width: clockItem.implicitWidth
            height: clockItem.implicitHeight
            z: 2

            Clock {
                id: clockItem

                anchors.centerIn: parent
                showDate: false
            }

        }

        // ── 3. Grupo Derecho: MiniPlayer multimedia o Estado ──
        Item {
            id: rightGroup

            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            width: mini.shouldShow ? mini.implicitWidth : rightRow.implicitWidth
            height: Math.max(rightRow.implicitHeight, mini.implicitHeight)
            z: 2

            // Si hay reproductor activo y no expiró la gracia de pausa, muestra avatar y controles
            MiniPlayer {
                id: mini

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                opacity: shouldShow ? 1 : 0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.durMedium
                    }

                }

            }

            // Si no está el mini reproductor, muestra fila de estado (Red, Bluetooth, Volumen)
            Row {
                id: rightRow

                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                opacity: mini.shouldShow ? 0 : 1
                visible: opacity > 0

                // Indicador de Red
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: !Net.connected ? "wifi_off" : Net.isWifi ? "wifi" : "lan"
                    color: !Net.connected ? Theme.alert : Theme.fg
                    font.family: Theme.fontIcons
                    font.pixelSize: 16
                }

                // Indicador de Bluetooth
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: !Net.btEnabled ? "bluetooth_disabled" : Net.btConnected ? "bluetooth_connected" : "bluetooth"
                    color: !Net.btEnabled ? Theme.fgFaint : Net.btConnected ? "#4a9eff" : Theme.fg
                    font.family: Theme.fontIcons
                    font.pixelSize: 16
                }

                // Indicador de Volumen
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Audio.muted || Audio.percent === 0 ? "volume_off" : Audio.percent < 33 ? "volume_mute" : Audio.percent < 66 ? "volume_down" : "volume_up"
                        color: Audio.muted || Audio.percent === 0 ? Theme.alert : Theme.fg
                        font.family: Theme.fontIcons
                        font.pixelSize: 16
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Audio.percent + "%"
                        color: Audio.muted || Audio.percent === 0 ? Theme.alert : Theme.fgDim
                        font.family: Theme.fontDots
                        font.pixelSize: 12
                        font.weight: Font.Bold
                    }

                }

                // Indicador de Batería
                Battery {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: present
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.durMedium
                    }

                }

            }

            Behavior on width {
                NumberAnimation {
                    duration: Theme.durMedium
                    easing.type: Easing.Bezier
                    easing.bezierCurve: Theme.emphasizedDecel
                }

            }

        }

    }

}
