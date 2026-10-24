import "."
import QtQuick
import Quickshell.Io

Row {
    id: root

    property bool coffee: false
    property bool widgetsEditing: false
    readonly property string coffeeScript: Qt.resolvedUrl("scripts/coffee.py").toString().replace("file://", "")

    signal requestNotifs()
    signal requestPower()
    signal requestLock()

    function coffeeStart() {
        Exec.run("systemd-inhibit --what=idle:sleep --why='Coffee Mode' sleep infinity >/dev/null 2>&1 &");
    }

    function coffeeStop() {
        Exec.run("pkill -f 'Coffee Mode'");
    }

    spacing: 8
    height: 44
    Component.onCompleted: {
        if (!root.coffee) {
            root.coffeeStop();
        }
    }

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
                root.widgetsEditing = (data.trim() === "1");
            }
        }

    }

    // ── 1. Pastilla Modo Café (Expandida a la izquierda con Switch M3) ──
    Rectangle {
        id: coffeePill

        width: root.width - (44 * 4 + root.spacing * 4)
        height: 44
        radius: Theme.shapeLg
        color: root.coffee ? Theme.inverted : (coffeeMa.containsMouse ? Theme.surfaceHigh : Theme.surface)
        border.width: 1
        border.color: root.coffee ? "transparent" : Theme.outline

        MouseArea {
            id: coffeeMa

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.coffee = !root.coffee;
                if (root.coffee)
                    root.coffeeStart();
                else
                    root.coffeeStop();
            }
        }

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Text {
                text: "coffee"
                color: root.coffee ? Theme.invertedFg : Theme.fgDim
                font.family: Theme.fontIcons
                font.pixelSize: 20
            }

            Text {
                text: "MODO CAFÉ"
                color: root.coffee ? Theme.invertedFg : Theme.fg
                font.letterSpacing: 1.2
                font.family: Theme.fontUi
                font.pixelSize: 12
                font.weight: Font.Medium
            }

        }

        // Switch M3 a la derecha
        Rectangle {
            id: m3Track

            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            width: 44
            height: 24
            radius: height / 2
            color: root.coffee ? Theme.invertedFg : Theme.surfaceHigh
            border.width: root.coffee ? 0 : 2
            border.color: Theme.outline

            Rectangle {
                width: root.coffee ? 18 : 14
                height: width
                radius: width / 2
                anchors.verticalCenter: parent.verticalCenter
                x: root.coffee ? parent.width - width - 3 : 4
                color: root.coffee ? Theme.inverted : Theme.fgFaint

                Behavior on x {
                    NumberAnimation {
                        duration: Theme.durShort
                        easing.type: Easing.Bezier
                        easing.bezierCurve: Theme.emphasized
                    }

                }

            }

        }

        Behavior on color {
            ColorAnimation {
                duration: Theme.durShort
            }

        }

    }

    // ── 2. Botón Bloquear Pantalla ──
    ActionButton {
        icon: "lock"
        onActivated: root.requestLock()
    }

    // ── 3. Botón Widgets de Escritorio (Clic Izq: Edición, Clic Der: Gestor) ──
    ActionButton {
        icon: "widgets"
        activeState: root.widgetsEditing
        onActivated: {
            Exec.run("lunita-widgets-toggle &");
        }
        onRightClicked: {
            Exec.run("lunita-widgets-manager --tab desktop &");
        }
    }

    // ── 4. Botón Notificaciones ──
    ActionButton {
        icon: (Notifs.all && Notifs.all.length ? Notifs.all.length : 0) > 0 ? "notifications_active" : (Notifs.muted ? "notifications_off" : "notifications")
        activeState: (Notifs.all && Notifs.all.length ? Notifs.all.length : 0) > 0
        onActivated: root.requestNotifs()
    }

    // ── 5. Botón Menú de Apagado / Power ──
    ActionButton {
        icon: "power_settings_new"
        danger: true
        onActivated: root.requestPower()
    }

    // ── Componente de Botón de Acción Cuadrado / Redondeado (44x44) ──
    component ActionButton: Rectangle {
        id: ab

        property string icon: ""
        property bool danger: false
        property bool activeState: false

        signal activated()
        signal rightClicked()

        width: 44
        height: 44
        radius: Theme.shapeLg
        color: abMa.containsMouse ? Theme.surfaceHigh : Theme.surface
        border.width: 1
        border.color: Theme.outline
        scale: abMa.pressed ? 0.94 : (abMa.containsMouse ? 1.04 : 1)

        Text {
            anchors.centerIn: parent
            text: ab.icon
            color: ab.danger ? Theme.alert : (ab.activeState ? Theme.alert : Theme.fg)
            font.family: Theme.fontIcons
            font.pixelSize: 20
        }

        MouseArea {
            id: abMa

            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton)
                    ab.rightClicked();
                else
                    ab.activated();
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Theme.durShort
            }

        }

        Behavior on color {
            ColorAnimation {
                duration: Theme.durShort
            }

        }

    }

}
