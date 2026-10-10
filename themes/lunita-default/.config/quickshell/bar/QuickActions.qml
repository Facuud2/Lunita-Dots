import QtQuick
import "."

Row {
    id: root
    spacing: 8
    height: 44

    property bool coffee: false

    signal requestNotifs
    signal requestPower
    signal requestLock

    readonly property string coffeeScript: Qt.resolvedUrl("scripts/coffee.py").toString().replace("file://", "")

    function coffeeStart() {
        Exec.run("systemd-inhibit --what=idle:sleep --why='Coffee Mode' sleep infinity >/dev/null 2>&1 &");
    }

    function coffeeStop() {
        Exec.run("pkill -f 'Coffee Mode'");
    }

    Component.onCompleted: if (!root.coffee) root.coffeeStop()

    // ── 1. Pastilla Modo Café (Expandida a la izquierda con Switch M3) ──
    Rectangle {
        id: coffeePill
        width: root.width - (44 * 3 + root.spacing * 3)
        height: 44
        radius: Theme.shapeLg
        color: root.coffee ? Theme.inverted : (coffeeMa.containsMouse ? Theme.surfaceHigh : Theme.surface)
        border.width: 1
        border.color: root.coffee ? "transparent" : Theme.outline

        Behavior on color { ColorAnimation { duration: Theme.durShort } }

        MouseArea {
            id: coffeeMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.coffee = !root.coffee;
                if (root.coffee) root.coffeeStart();
                else root.coffeeStop();
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
                    NumberAnimation { duration: Theme.durShort; easing.type: Easing.Bezier; easing.bezierCurve: Theme.emphasized }
                }
            }
        }
    }

    // ── Componente de Botón de Acción Cuadrado / Redondeado (44x44) ──
    component ActionButton: Rectangle {
        id: ab
        property string icon: ""
        property bool danger: false
        property bool activeState: false
        signal activated

        width: 44
        height: 44
        radius: Theme.shapeLg
        color: abMa.containsMouse ? Theme.surfaceHigh : Theme.surface
        border.width: 1
        border.color: Theme.outline

        scale: abMa.pressed ? 0.94 : (abMa.containsMouse ? 1.04 : 1.0)
        Behavior on scale { NumberAnimation { duration: Theme.durShort } }
        Behavior on color { ColorAnimation { duration: Theme.durShort } }

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
            cursorShape: Qt.PointingHandCursor
            onClicked: ab.activated()
        }
    }

    // ── 2. Botón Bloquear Pantalla ──
    ActionButton {
        icon: "lock"
        onActivated: root.requestLock()
    }

    // ── 3. Botón Notificaciones ──
    ActionButton {
        icon: (Notifs.all?.length ?? 0) > 0 ? "notifications_active" : (Notifs.muted ? "notifications_off" : "notifications")
        activeState: (Notifs.all?.length ?? 0) > 0
        onActivated: root.requestNotifs()
    }

    // ── 4. Botón Menú de Apagado / Power ──
    ActionButton {
        icon: "power_settings_new"
        danger: true
        onActivated: root.requestPower()
    }
}
