import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root

    required property var barState
    signal closeRequested()

    color: root.barState.themeSurface
    radius: root.barState.themeCardRadius
    border.color: root.barState.themeBorderSpecular
    border.width: 1
    clip: true

    // Vertical Fader Strip Component
    component MixerStrip: Rectangle {
        id: stripRoot
        property string iconGlyph: "󰕾"
        property string appName: "App"
        property string subTitle: ""
        property int volumeValue: 100
        property bool isMuted: false
        property color accentColor: root.barState.themeAccent
        signal volumeChangedByUser(int newVal)
        signal muteToggled()

        width: 104
        Layout.fillHeight: true
        radius: 14
        color: stripHov.hovered ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(1, 1, 1, 0.06)
        border.color: stripHov.hovered ? root.barState.themeBorderSpecular : Qt.rgba(1, 1, 1, 0.12)
        border.width: 1

        HoverHandler { id: stripHov }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 6

            // App / Source Icon
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 32
                height: 32
                radius: 16
                color: stripRoot.isMuted ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(stripRoot.accentColor.r, stripRoot.accentColor.g, stripRoot.accentColor.b, 0.25)
                border.color: stripRoot.isMuted ? Qt.rgba(1, 1, 1, 0.20) : stripRoot.accentColor
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: stripRoot.iconGlyph
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 15
                    color: stripRoot.isMuted ? Qt.rgba(1, 1, 1, 0.40) : stripRoot.accentColor
                }
            }

            // Name & Subtitle
            Text {
                Layout.fillWidth: true
                text: stripRoot.appName
                font.family: root.barState.themeFontInterface
                font.pixelSize: 11
                font.weight: Font.DemiBold
                color: "#FFFFFF"
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: stripRoot.subTitle
                font.family: root.barState.themeFontInterface
                font.pixelSize: 9
                color: Qt.rgba(1, 1, 1, 0.55)
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                visible: stripRoot.subTitle !== ""
            }

            // Vertical Track Container
            Item {
                id: vTrackContainer
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Background Track Line (4px)
                Rectangle {
                    id: vBgTrack
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 4
                    radius: 2
                    color: Qt.rgba(1, 1, 1, 0.18)

                    // Active Fill from bottom upwards
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 4
                        height: parent.height * Math.min(1.0, Math.max(0.0, stripRoot.volumeValue / 100.0))
                        radius: 2
                        color: stripRoot.isMuted ? Qt.rgba(1, 1, 1, 0.35) : stripRoot.accentColor
                    }
                }

                // Circular White Thumb Knob (14x14)
                Rectangle {
                    id: vThumbKnob
                    width: 14
                    height: 14
                    radius: 7
                    color: "#FFFFFF"
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: Math.max(0, Math.min(vTrackContainer.height - height, vTrackContainer.height * (1.0 - (stripRoot.volumeValue / 100.0)) - (height / 2)))

                    border.color: Qt.rgba(0, 0, 0, 0.25)
                    border.width: 1
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    function updateVolume(mouse) {
                        var relY = Math.max(0, Math.min(vTrackContainer.height, mouse.y));
                        var pct = Math.round((1.0 - (relY / vTrackContainer.height)) * 100);
                        stripRoot.volumeChangedByUser(Math.max(0, Math.min(100, pct)));
                    }

                    onPressed: mouse => updateVolume(mouse)
                    onPositionChanged: mouse => {
                        if (pressed) updateVolume(mouse);
                    }
                }
            }

            // Percentage Tag
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: stripRoot.volumeValue + "%"
                font.family: root.barState.themeFontInterface
                font.pixelSize: 10
                font.weight: Font.Medium
                color: root.barState.themeOnSurfaceDim
            }

            // Mute Button Pill
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 70
                height: 24
                radius: 6
                color: stripRoot.isMuted ? "#E81123" : (muteHov.hovered ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.10))

                HoverHandler { id: muteHov }

                Text {
                    anchors.centerIn: parent
                    text: stripRoot.isMuted ? "Silenciado" : "Silenciar"
                    font.family: root.barState.themeFontInterface
                    font.pixelSize: 9
                    color: "#FFFFFF"
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: stripRoot.muteToggled()
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        // ── Header: Back button, Title & PipeWire Status ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // Back Button
            Rectangle {
                width: 76
                height: 30
                radius: 8
                color: backHover.hovered ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.08)
                border.color: root.barState.themeBorder
                border.width: 1

                HoverHandler { id: backHover }

                Row {
                    anchors.centerIn: parent
                    spacing: 4
                    Text {
                        text: "󰁍"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 13
                        color: root.barState.themeOnSurface
                    }
                    Text {
                        text: "Volver"
                        font.family: root.barState.themeFontInterface
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        color: root.barState.themeOnSurface
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.closeRequested()
                }
            }

            Text {
                text: "Mezclador de Volumen (PipeWire)"
                font.family: root.barState.themeFontInterface
                font.pixelSize: 15
                font.weight: Font.Bold
                color: "#FFFFFF"
            }

            Item { Layout.fillWidth: true }

            // Audio Server Tag
            Rectangle {
                width: 86
                height: 26
                radius: 6
                color: Qt.rgba(1, 1, 1, 0.08)
                border.color: root.barState.themeBorder
                border.width: 1

                Row {
                    anchors.centerIn: parent
                    spacing: 5
                    Rectangle {
                        width: 6
                        height: 6
                        radius: 3
                        color: "#107C41"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "PipeWire"
                        font.family: root.barState.themeFontInterface
                        font.pixelSize: 10
                        font.weight: Font.Medium
                        color: root.barState.themeOnSurface
                    }
                }
            }
        }

        // ── Console Mixing Strips Container ──
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: stripsRow.implicitWidth
            contentHeight: height
            clip: true

            RowLayout {
                id: stripsRow
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                spacing: 10

                // 1. Master Output Strip
                MixerStrip {
                    iconGlyph: root.barState.isMuted ? "󰝟" : "󰕾"
                    appName: "Master"
                    subTitle: "Salida Principal"
                    volumeValue: root.barState.volumePercent
                    isMuted: root.barState.isMuted
                    accentColor: root.barState.themeAccent
                    onVolumeChangedByUser: newVal => root.barState.setVolume(newVal)
                    onMuteToggled: root.barState.toggleMute()
                }

                // 2. Microphone Input Strip
                MixerStrip {
                    iconGlyph: root.barState.micMuted ? "󰍭" : "󰍬"
                    appName: "Micrófono"
                    subTitle: "Entrada"
                    volumeValue: root.barState.micPercent
                    isMuted: root.barState.micMuted
                    accentColor: root.barState.themeAccent
                    onVolumeChangedByUser: newVal => root.barState.setMicVolume(newVal)
                    onMuteToggled: root.barState.toggleMicMute()
                }

                // Vertical Divider
                Rectangle {
                    Layout.fillHeight: true
                    width: 1
                    color: Qt.rgba(1, 1, 1, 0.15)
                }

                // 3. Dynamic Application Streams
                Repeater {
                    model: root.barState.audioStreams

                    delegate: MixerStrip {
                        required property var modelData
                        iconGlyph: modelData.icon || "󰕾"
                        appName: modelData.name || "App"
                        subTitle: modelData.title || ""
                        volumeValue: modelData.volume || 100
                        isMuted: !!modelData.muted
                        accentColor: root.barState.themeAccent
                        onVolumeChangedByUser: newVal => root.barState.setStreamVolume(modelData.id, newVal)
                        onMuteToggled: root.barState.toggleStreamMute(modelData.id)
                    }
                }

                // Fallback indicator when no streams exist
                Item {
                    visible: root.barState.audioStreams.length === 0
                    Layout.fillHeight: true
                    width: 220

                    Column {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "󰕾"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 24
                            color: Qt.rgba(1, 1, 1, 0.35)
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "No hay apps emitiendo audio"
                            font.family: root.barState.themeFontInterface
                            font.pixelSize: 11
                            color: Qt.rgba(1, 1, 1, 0.50)
                        }
                    }
                }
            }
        }
    }
}
