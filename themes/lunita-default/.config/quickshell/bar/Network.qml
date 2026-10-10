import QtQuick
import "."

Row {
    id: root
    spacing: 4

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: !Net.connected ? Icons.wifiOff : Net.isWifi ? Icons.wifi : Icons.ethernet
        color: Net.connected ? Theme.fg : Theme.error
        font.family: Theme.fontIcon
        font.pixelSize: 18
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        visible: Net.isWifi
        text: Net.signal_
        color: Theme.fgDim
        font.family: Theme.fontUi
        font.pixelSize: 11
    }
}
