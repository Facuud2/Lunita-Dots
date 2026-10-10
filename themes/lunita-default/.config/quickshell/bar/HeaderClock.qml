import QtQuick
import "."

Item {
    id: root
    height: 38

    signal requestCalendar

    // ── 1. Reloj en formato NDOT (Hora + Segundos) ──
    Row {
        id: clockRow
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        spacing: 4

        Timer {
            id: panelClock
            property date now: new Date()
            interval: 1000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: now = new Date()
        }

        Text {
            id: horaTxt
            anchors.bottom: parent.bottom
            text: Qt.formatDateTime(panelClock.now, Cfg.fmtHora)
            color: Theme.fg
            font.family: Theme.fontDots
            font.pixelSize: 38
            font.weight: Font.Bold
        }

        Text {
            id: segTxt
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 3
            text: Qt.formatDateTime(panelClock.now, "ss")
            color: Theme.fgDim
            font.family: Theme.fontDots
            font.pixelSize: 20
            font.weight: Font.Bold
        }
    }

    // ── 2. Fecha / Calendario a la derecha ──
    Rectangle {
        id: dateCard
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: dateCol.implicitWidth + 20
        height: 38
        radius: 12
        color: dateMa.containsMouse ? Theme.surfaceHigh : "transparent"

        Behavior on color {
            ColorAnimation { duration: Theme.durShort }
        }

        Column {
            id: dateCol
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                anchors.right: parent.right
                text: Cfg.locale.toString(panelClock.now, "dddd, d MMMM").toUpperCase()
                color: Theme.fgDim
                font.family: Theme.fontUi
                font.pixelSize: 11
                font.weight: Font.Medium
                font.letterSpacing: 1.2
            }

            Text {
                anchors.right: parent.right
                text: "CALENDARIO"
                color: Theme.fgDim
                font.family: Theme.fontUi
                font.pixelSize: 10
                font.letterSpacing: 1.2
            }
        }

        MouseArea {
            id: dateMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.requestCalendar()
        }
    }
}
