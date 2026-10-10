import QtQuick
import "."

Item {
    id: root

    readonly property bool active: MprisPlayer.active
    readonly property bool isPlaying: MprisPlayer.isPlaying
    readonly property string artUrl: MprisPlayer.artUrl

    // Propiedad que permanece activa mientras reproduce o hasta que expire el timer tras pausar
    property bool shouldShow: isPlaying

    Timer {
        id: pauseGraceTimer
        interval: 3500 // 3.5 segundos de gracia tras pausar
        running: false
        repeat: false
        onTriggered: {
            if (!root.isPlaying) {
                root.shouldShow = false;
            }
        }
    }

    onIsPlayingChanged: {
        if (isPlaying) {
            pauseGraceTimer.stop();
            shouldShow = true;
        } else {
            // Si el medio está pausado o detenido
            if (active) {
                pauseGraceTimer.restart();
            } else {
                pauseGraceTimer.stop();
                shouldShow = false;
            }
        }
    }

    onActiveChanged: {
        if (!active) {
            pauseGraceTimer.stop();
            shouldShow = false;
        } else if (isPlaying) {
            shouldShow = true;
        }
    }

    implicitWidth: row.implicitWidth
    implicitHeight: 28

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        // Carátula redonda (avatar de música)
        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: 24
            height: 24

            Rectangle {
                id: artMask
                anchors.fill: parent
                radius: width / 2
                color: Theme.surfaceHigh
                clip: true

                Image {
                    id: coverImg
                    anchors.fill: parent
                    source: root.artUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: status === Image.Ready && source !== ""
                }

                Text {
                    anchors.centerIn: parent
                    visible: !coverImg.visible
                    text: "album"
                    color: Theme.fgDim
                    font.family: Theme.fontIcons
                    font.pixelSize: 16
                }
            }

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "transparent"
                border.width: 1
                border.color: Theme.outline
            }
        }

        // Controles de medios compactos Nothing: |<  ||  >|
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            // Anterior (|<)
            Rectangle {
                width: 22
                height: 22
                radius: width / 2
                color: prevMa.containsMouse ? Theme.surfaceHigh : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "skip_previous"
                    color: Theme.fg
                    font.family: Theme.fontIcons
                    font.pixelSize: 16
                }

                MouseArea {
                    id: prevMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: MprisPlayer.previous()
                }
            }

            // Reproducir / Pausa (|| o |>)
            Rectangle {
                width: 22
                height: 22
                radius: width / 2
                color: playMa.containsMouse ? Theme.surfaceHigh : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: root.isPlaying ? "pause" : "play_arrow"
                    color: Theme.fg
                    font.family: Theme.fontIcons
                    font.pixelSize: 17
                }

                MouseArea {
                    id: playMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: MprisPlayer.playPause()
                }
            }

            // Siguiente (>|)
            Rectangle {
                width: 22
                height: 22
                radius: width / 2
                color: nextMa.containsMouse ? Theme.surfaceHigh : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "skip_next"
                    color: Theme.fg
                    font.family: Theme.fontIcons
                    font.pixelSize: 16
                }

                MouseArea {
                    id: nextMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: MprisPlayer.next()
                }
            }
        }
    }
}
