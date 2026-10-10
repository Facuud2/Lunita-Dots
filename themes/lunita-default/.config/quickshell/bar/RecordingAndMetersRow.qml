import QtQuick
import "."

Item {
    id: root
    height: 104

    // ── 1. Tarjeta de Grabación de Pantalla (Izquierda) ──
    Rectangle {
        id: recCard
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 176
        radius: Theme.shapeLg
        color: Recorder.recording ? Qt.rgba(0.84, 0.10, 0.13, 0.15) : Theme.surface
        border.width: 1
        border.color: Recorder.recording ? Theme.alert : Theme.outline

        Behavior on color { ColorAnimation { duration: Theme.durShort } }
        Behavior on border.color { ColorAnimation { duration: Theme.durShort } }

        // Acción principal: botón de iniciar/detener
        MouseArea {
            id: recMainBtn
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: recDivider.left
            anchors.margins: 4
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Recorder.toggle()

            Row {
                anchors.centerIn: parent
                spacing: 8

                // Insignia circular con punto/icono de grabación
                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: Theme.surfaceHigh
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        anchors.centerIn: parent
                        text: Recorder.recording ? "stop" : "fiber_manual_record"
                        color: Theme.alert
                        font.family: Theme.fontIcons
                        font.pixelSize: 16
                    }
                }

                // Título y tiempo
                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 1

                    Text {
                        text: "GRABACIÓN"
                        color: Theme.fgDim
                        font.family: Theme.fontUi
                        font.pixelSize: 10
                        font.letterSpacing: 1.2
                        font.weight: Font.Medium
                    }

                    Text {
                        text: Recorder.recording ? Recorder.elapsedText : "00:00"
                        color: Recorder.recording ? Theme.fg : Theme.fgDim
                        font.family: Theme.fontDots
                        font.pixelSize: 14
                        font.weight: Font.Bold
                    }
                }
            }
        }

        // Divisor vertical sutil
        Rectangle {
            id: recDivider
            anchors.right: recToggles.left
            anchors.rightMargin: 4
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.topMargin: 12
            anchors.bottomMargin: 12
            width: 1
            color: Theme.outline
        }

        // Conmutadores de audio y micrófono
        Column {
            id: recToggles
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            // Conmutador de Sonido del Sistema
            Rectangle {
                width: 28
                height: 28
                radius: 14
                color: Recorder.systemAudio ? (Recorder.recording ? Qt.rgba(0.84, 0.10, 0.13, 0.3) : Qt.rgba(1, 1, 1, 0.22)) : Theme.surfaceHigh
                border.width: Recorder.recording && Recorder.systemAudio ? 1 : 0
                border.color: Theme.alert

                Text {
                    anchors.centerIn: parent
                    text: Recorder.systemAudio ? "volume_up" : "volume_off"
                    color: Recorder.recording && Recorder.systemAudio ? Theme.alert : (Recorder.systemAudio ? Theme.fg : Theme.fgFaint)
                    font.family: Theme.fontIcons
                    font.pixelSize: 15
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Recorder.systemAudio = !Recorder.systemAudio
                }
            }

            // Conmutador de Micrófono
            Rectangle {
                width: 28
                height: 28
                radius: 14
                color: Recorder.microphone ? (Recorder.recording ? Qt.rgba(0.84, 0.10, 0.13, 0.3) : Qt.rgba(1, 1, 1, 0.22)) : Theme.surfaceHigh
                border.width: Recorder.recording && Recorder.microphone ? 1 : 0
                border.color: Theme.alert

                Text {
                    anchors.centerIn: parent
                    text: Recorder.microphone ? "mic" : "mic_off"
                    color: Recorder.recording && Recorder.microphone ? Theme.alert : (Recorder.microphone ? Theme.fg : Theme.fgFaint)
                    font.family: Theme.fontIcons
                    font.pixelSize: 15
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Recorder.microphone = !Recorder.microphone
                }
            }
        }
    }

    // ── 2. Tarjeta de Métricas de Hardware (CPU, RAM, GPU) ──
    Rectangle {
        id: metersCard
        anchors.left: recCard.right
        anchors.leftMargin: 8
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        radius: Theme.shapeLg
        color: Theme.surface
        border.width: 1
        border.color: Theme.outline

        Column {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            // CPU Row
            Row {
                width: parent.width
                height: 22
                spacing: 8

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "memory"
                    color: Theme.fgDim
                    font.family: Theme.fontIcons
                    font.pixelSize: 16
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 28
                    text: "CPU"
                    color: Theme.fgDim
                    font.family: Theme.fontUi
                    font.pixelSize: 10
                    font.weight: Font.Medium
                    font.letterSpacing: 1.2
                }

                Rectangle {
                    id: cpuTrack
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 24 - 36 - 44 - 38
                    height: 6
                    radius: 3
                    color: Theme.surfaceHigh

                    Rectangle {
                        width: Math.max(4, cpuTrack.width * Math.min(1.0, SysInfo.cpu / 100))
                        height: parent.height
                        radius: 3
                        color: SysInfo.cpu > 80 ? Theme.alert : Theme.fg

                        Behavior on width { NumberAnimation { duration: Theme.durLong } }
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 36
                    horizontalAlignment: Text.AlignRight
                    text: Math.round(SysInfo.cpu) + "%"
                    color: Theme.fgDim
                    font.family: Theme.fontDots
                    font.pixelSize: 12
                    font.weight: Font.Bold
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    visible: SysInfo.cpuTemp >= 0

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "local_fire_department"
                        color: Theme.alert
                        font.family: Theme.fontIcons
                        font.pixelSize: 14
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: SysInfo.cpuTemp + "°"
                        color: SysInfo.cpuTemp > 80 ? Theme.alert : Theme.fgDim
                        font.family: Theme.fontDots
                        font.pixelSize: 11
                    }
                }
            }

            // RAM Row
            Row {
                width: parent.width
                height: 22
                spacing: 8

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "developer_board"
                    color: Theme.fgDim
                    font.family: Theme.fontIcons
                    font.pixelSize: 16
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 28
                    text: "RAM"
                    color: Theme.fgDim
                    font.family: Theme.fontUi
                    font.pixelSize: 10
                    font.weight: Font.Medium
                    font.letterSpacing: 1.2
                }

                Rectangle {
                    id: ramTrack
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 24 - 36 - 44 - 38
                    height: 6
                    radius: 3
                    color: Theme.surfaceHigh

                    Rectangle {
                        width: Math.max(4, ramTrack.width * Math.min(1.0, SysInfo.mem / 100))
                        height: parent.height
                        radius: 3
                        color: SysInfo.mem > 85 ? Theme.alert : Theme.fg

                        Behavior on width { NumberAnimation { duration: Theme.durLong } }
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 36
                    horizontalAlignment: Text.AlignRight
                    text: Math.round(SysInfo.mem) + "%"
                    color: Theme.fgDim
                    font.family: Theme.fontDots
                    font.pixelSize: 12
                    font.weight: Font.Bold
                }
            }

            // GPU Row
            Row {
                width: parent.width
                height: 22
                spacing: 8

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "videogame_asset"
                    color: Theme.fgDim
                    font.family: Theme.fontIcons
                    font.pixelSize: 16
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 28
                    text: "GPU"
                    color: Theme.fgDim
                    font.family: Theme.fontUi
                    font.pixelSize: 10
                    font.weight: Font.Medium
                    font.letterSpacing: 1.2
                }

                Rectangle {
                    id: gpuTrack
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 24 - 36 - 44 - 38
                    height: 6
                    radius: 3
                    color: Theme.surfaceHigh

                    Rectangle {
                        width: Math.max(4, gpuTrack.width * Math.min(1.0, (SysInfo.gpuAvailable ? SysInfo.gpu : 0) / 100))
                        height: parent.height
                        radius: 3
                        color: SysInfo.gpu > 80 ? Theme.alert : Theme.fg

                        Behavior on width { NumberAnimation { duration: Theme.durLong } }
                    }
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 36
                    horizontalAlignment: Text.AlignRight
                    text: (SysInfo.gpuAvailable ? Math.round(SysInfo.gpu) : 0) + "%"
                    color: Theme.fgDim
                    font.family: Theme.fontDots
                    font.pixelSize: 12
                    font.weight: Font.Bold
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    visible: SysInfo.gpuAvailable && SysInfo.gpuTemp >= 0

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "local_fire_department"
                        color: Theme.alert
                        font.family: Theme.fontIcons
                        font.pixelSize: 14
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: SysInfo.gpuTemp + "°"
                        color: SysInfo.gpuTemp > 80 ? Theme.alert : Theme.fgDim
                        font.family: Theme.fontDots
                        font.pixelSize: 11
                    }
                }
            }
        }
    }
}
