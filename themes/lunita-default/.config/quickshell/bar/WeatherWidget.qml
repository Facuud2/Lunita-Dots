import QtQuick
import "."

Rectangle {
    id: root

    implicitWidth: contentRow.implicitWidth + 14
    implicitHeight: 24
    radius: 12
    color: widgetMa.containsMouse ? Theme.surfaceHigh : Theme.surfaceAlt
    border.width: 1
    border.color: widgetMa.containsMouse ? Theme.fgDim : Theme.outline

    Behavior on color { ColorAnimation { duration: Theme.durShort } }
    Behavior on border.color { ColorAnimation { duration: Theme.durShort } }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 5

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: (Weather.ready && Weather.icon) ? Weather.icon : "sunny"
            color: Theme.accent
            font.family: Theme.fontIcons
            font.pixelSize: 14
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: (Weather.ready && Weather.temp && Weather.temp !== "--") ? Weather.temp : "--°"
            color: Theme.fg
            font.family: Theme.fontDots
            font.pixelSize: 12
            font.weight: Font.Bold
        }
    }

    MouseArea {
        id: widgetMa
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Weather.fetch()
    }
}
