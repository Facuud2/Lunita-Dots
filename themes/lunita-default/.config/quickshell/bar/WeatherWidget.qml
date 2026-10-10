import QtQuick
import "."

Row {
    id: root
    spacing: 5
    anchors.verticalCenter: parent.verticalCenter

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: (Weather.ready && Weather.icon) ? Weather.icon : "sunny"
        color: Theme.fgDim
        font.family: Theme.fontIcons
        font.pixelSize: 16
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: (Weather.ready && Weather.temp && Weather.temp !== "--") ? Weather.temp : "37°"
        color: Theme.fgDim
        font.family: Theme.fontDots
        font.pixelSize: 12
    }
}
