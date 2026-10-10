import QtQuick
import "."

Row {
    id: root
    spacing: 8

    property real pillWidth: (width - spacing * 2) / 3

    signal requestPanel(string mode)

    readonly property bool netDevice: Net.connected
    readonly property bool isWifi: Net.isWifi
    readonly property bool isEthernet: Net.connected && (!Net.isWifi || Net.ethernetConnected)

    // ── 1. Tarjeta Red (Ethernet / Wi-Fi) ──
    Rectangle {
        id: netPill
        width: root.pillWidth
        height: 52
        radius: Theme.shapeLg
        color: root.netDevice ? Theme.inverted : (netMa.containsMouse ? Theme.surfaceHigh : Theme.surface)
        border.width: 1
        border.color: root.netDevice ? "transparent" : Theme.outline

        Behavior on color {
            ColorAnimation { duration: Theme.durShort }
        }

        MouseArea {
            id: netMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                    root.requestPanel("wifi");
                } else {
                    Net.toggleWifi();
                }
            }
        }

        // Icono circular
        Rectangle {
            id: netIconBg
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            width: 34
            height: 34
            radius: height / 2
            color: root.netDevice ? Theme.invertedFg : Theme.surfaceHigh

            Behavior on color {
                ColorAnimation { duration: Theme.durShort }
            }

            Text {
                anchors.centerIn: parent
                text: !root.netDevice ? "wifi_off" : root.isEthernet ? "lan" : "wifi"
                color: root.netDevice ? Theme.inverted : Theme.fg
                font.family: Theme.fontIcons
                font.pixelSize: 18
            }
        }

        Column {
            anchors.left: netIconBg.right
            anchors.leftMargin: 9
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            Text {
                width: parent.width
                text: {
                    if (!root.netDevice) return "Sin red";
                    if (root.isEthernet) return Net.ethernetName || "Ethernet";
                    return Net.connectionName || "Wi-Fi";
                }
                color: root.netDevice ? Theme.invertedFg : Theme.fg
                font.family: Theme.fontUi
                font.pixelSize: Theme.bodySmall
                font.weight: Font.Medium
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: root.netDevice ? "CONECTADO" : "SIN RED"
                color: root.netDevice ? Theme.invertedFg : Theme.alert
                font.letterSpacing: Theme.labelSpacing
                font.family: Theme.fontUi
                font.pixelSize: Theme.labelSmall
                font.weight: Font.Medium
                elide: Text.ElideRight
            }
        }
    }

    // ── 2. Tarjeta Bluetooth (Invertida/Blanca cuando está activa/encendida) ──
    Rectangle {
        id: btPill
        readonly property bool on: Net.btEnabled
        width: root.pillWidth
        height: 52
        radius: Theme.shapeLg
        color: on ? Theme.inverted : (btMa.containsMouse ? Theme.surfaceHigh : Theme.surface)
        border.width: 1
        border.color: on ? "transparent" : Theme.outline

        Behavior on color {
            ColorAnimation { duration: Theme.durMedium }
        }

        MouseArea {
            id: btMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: mouse => {
                if (mouse.button === Qt.RightButton) {
                    root.requestPanel("bt");
                } else {
                    Net.toggleBt();
                }
            }
        }

        Rectangle {
            id: btIconBg
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            width: 34
            height: 34
            radius: height / 2
            color: btPill.on ? Theme.invertedFg : Theme.surfaceHigh

            Text {
                anchors.centerIn: parent
                text: btPill.on ? "bluetooth" : "bluetooth_disabled"
                color: btPill.on ? Theme.inverted : Theme.fgDim
                font.family: Theme.fontIcons
                font.pixelSize: 18
            }
        }

        Column {
            anchors.left: btIconBg.right
            anchors.leftMargin: 9
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            Text {
                width: parent.width
                text: "Bluetooth"
                color: btPill.on ? Theme.invertedFg : Theme.fg
                font.family: Theme.fontUi
                font.pixelSize: Theme.bodySmall
                font.weight: Font.Medium
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: {
                    if (!btPill.on) return "APAGADO";
                    return Net.btConnectedName || "ENCENDIDO";
                }
                color: btPill.on ? Theme.invertedFg : Theme.fgDim
                font.letterSpacing: Theme.labelSpacing
                font.family: Theme.fontUi
                font.pixelSize: Theme.labelSmall
                font.weight: Font.Medium
                elide: Text.ElideRight
            }
        }
    }

    // ── 3. Tarjeta Sonido / Volumen ──
    Rectangle {
        id: volPill
        width: root.pillWidth
        height: 52
        radius: Theme.shapeLg
        color: Theme.surface
        border.width: 1
        border.color: Theme.outline

        // Clic derecho en toda la pastilla abre el selector de fuentes de audio
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onClicked: root.requestPanel("audio")
        }

        Text {
            id: soundLabel
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.top: parent.top
            anchors.topMargin: 8
            text: "SONIDO"
            color: Theme.fg
            font.letterSpacing: Theme.labelSpacing
            font.family: Theme.fontUi
            font.pixelSize: Theme.bodySmall
            font.weight: Font.Medium
        }

        Text {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: soundLabel.verticalCenter
            width: parent.width - soundLabel.implicitWidth - 28
            horizontalAlignment: Text.AlignRight
            text: Audio.description
            color: Theme.fgDim
            font.family: Theme.fontUi
            font.pixelSize: Theme.labelSmall
            elide: Text.ElideLeft
        }

        Text {
            id: volIcon
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 9
            text: Audio.muted || Audio.percent === 0 ? "volume_off" : Audio.percent < 33 ? "volume_mute" : Audio.percent < 66 ? "volume_down" : "volume_up"
            color: Audio.muted || Audio.percent === 0 ? Theme.alert : Audio.boosted ? Theme.alert : Theme.fg
            font.family: Theme.fontIcons
            font.pixelSize: 18

            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        root.requestPanel("audio");
                        return;
                    }
                    Audio.toggleMute();
                }
            }
        }

        // Barra de progreso y ajuste arrastrable con límite al 100%
        Rectangle {
            id: volTrack
            readonly property real maxVolume: 1.0
            anchors.left: volIcon.right
            anchors.leftMargin: 8
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: volIcon.verticalCenter
            height: 6
            radius: 3
            color: Theme.surfaceHigh

            Rectangle {
                width: volTrack.width * (Audio.muted ? 0 : Math.min(Audio.volume, 1.0))
                height: parent.height
                radius: parent.radius
                color: Theme.fg

                Behavior on width {
                    NumberAnimation { duration: Theme.durShort }
                }
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -6
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                function apply(mx) {
                    Audio.setVolume(Math.max(0, Math.min(1.0, mx / volTrack.width)));
                }

                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton)
                        root.requestPanel("audio");
                }
                onPressed: mouse => {
                    if (mouse.button !== Qt.LeftButton)
                        return;
                    Audio.holding = true;
                    apply(mouse.x);
                }
                onReleased: Audio.holding = false
                onPositionChanged: mouse => {
                    if (pressed)
                        apply(mouse.x);
                }
            }
        }
    }
}
