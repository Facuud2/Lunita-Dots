import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell

Item {
    id: root
    required property var barState

    visible: barState.activePopup === "sound"
    x: Math.max(10, parent.width - width - 12)
    y: 4
    width: 290
    implicitHeight: mainCol.implicitHeight + 24
    height: implicitHeight
    z: 10

    opacity: visible ? 1 : 0
    scale: visible ? 1 : 0.96
    Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
    Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

    Rectangle {
        anchors.fill: parent
        radius: 14
        color: barState.popupBgColor
        border.color: barState.popupBorderColor
        border.width: 1

        Behavior on color { ColorAnimation { duration: 200 } }
        Behavior on border.color { ColorAnimation { duration: 200 } }

        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: 15
            color: "transparent"
            border.color: Qt.rgba(0, 0, 0, barState.isDarkTheme ? 0.4 : 0.12)
            border.width: 1
            z: -1
        }
    }

    component SIcon: Item {
        id: sIconRoot
        property string source: ""
        property color iconColor: barState.popupTextColor
        property real iconWidth: 14
        property real iconHeight: 14

        implicitWidth: iconWidth
        implicitHeight: iconHeight

        Image {
            id: rawSvg
            anchors.fill: parent
            source: sIconRoot.source
            sourceSize.width: Math.round(sIconRoot.iconWidth * 2)
            sourceSize.height: Math.round(sIconRoot.iconHeight * 2)
            visible: false
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
        }

        ColorOverlay {
            anchors.fill: rawSvg
            source: rawSvg
            color: sIconRoot.iconColor
            Behavior on color { ColorAnimation { duration: 200 } }
        }
    }

    ColumnLayout {
        id: mainCol
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 12
        spacing: 10

        // ── 1. Volume Header & Mute Button ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "Sonido"
                color: barState.popupTextColor
                font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                font.pixelSize: 13
                font.weight: Font.DemiBold
                Behavior on color { ColorAnimation { duration: 200 } }
            }

            Item { Layout.fillWidth: true }

            Text {
                text: barState.isMuted ? "Silenciado" : (barState.volumePercent + "%")
                color: barState.popupTextDim
                font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                font.pixelSize: 11
                Behavior on color { ColorAnimation { duration: 200 } }
            }

            Rectangle {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                radius: 12
                color: muteMouse.containsMouse 
                    ? (barState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.08)) 
                    : (barState.isMuted ? "#FF3B30" : "transparent")
                Behavior on color { ColorAnimation { duration: 150 } }

                SIcon {
                    anchors.centerIn: parent
                    iconWidth: 13
                    iconHeight: 13
                    source: barState.isMuted ? "../assets/volume-muted.svg" : "../assets/volume.svg"
                    iconColor: barState.isMuted ? "#FFFFFF" : barState.popupTextColor
                }

                MouseArea {
                    id: muteMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: barState.toggleMute()
                }
            }
        }

        // ── 2. Master Volume Slider ──
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            radius: 10
            color: barState.sliderTrackColor
            clip: true

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: Math.max(28, parent.width * ((barState.isMuted ? 0 : barState.volumePercent) / 100))
                radius: 10
                color: barState.sliderFillColor
                Behavior on color { ColorAnimation { duration: 200 } }
            }

            SIcon {
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                iconWidth: 14
                iconHeight: 14
                source: barState.isMuted ? "../assets/volume-muted.svg" : "../assets/volume.svg"
                iconColor: ((barState.volumePercent > 12) && !barState.isMuted) ? barState.sliderIconCovered : barState.sliderIconUncovered
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onPositionChanged: mouse => updateVol(mouse.x)
                onClicked: mouse => updateVol(mouse.x)

                function updateVol(mX) {
                    var ratio = Math.max(0, Math.min(1, mX / parent.width));
                    var newVal = Math.round(ratio * 100);
                    barState.setVolume(newVal);
                }
            }
        }

        // ── Separator ──
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: barState.popupSeparatorColor
            Behavior on color { ColorAnimation { duration: 200 } }
        }

        // ── 3. Output Sinks Section ("Salida") ──
        Text {
            text: "Salida"
            color: barState.popupTextDim
            font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
            font.pixelSize: 11
            font.weight: Font.Medium
            Behavior on color { ColorAnimation { duration: 200 } }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Repeater {
                model: barState.audioSinks
                delegate: Rectangle {
                    id: sinkRow
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    radius: 8
                    color: modelData.isDefault
                        ? (barState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.08))
                        : (sinkMouse.containsMouse ? (barState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(0, 0, 0, 0.04)) : "transparent")
                    Behavior on color { ColorAnimation { duration: 120 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8

                        SIcon {
                            iconWidth: 14
                            iconHeight: 14
                            source: modelData.type === "headphones"
                                ? "../assets/bluetooth.svg"
                                : (modelData.type === "hdmi" ? "../assets/brightness.svg" : "../assets/volume.svg")
                            iconColor: modelData.isDefault ? "#007AFF" : barState.popupTextColor
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.name
                            color: barState.popupTextColor
                            font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                            font.pixelSize: 12
                            font.weight: modelData.isDefault ? Font.DemiBold : Font.Normal
                            elide: Text.ElideRight
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        // Checkmark if default
                        Text {
                            visible: modelData.isDefault
                            text: "✓"
                            color: "#007AFF"
                            font.pixelSize: 13
                            font.bold: true
                        }
                    }

                    MouseArea {
                        id: sinkMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            barState.setAudioSink(modelData.id);
                        }
                    }
                }
            }
        }

        // ── Separator ──
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: barState.popupSeparatorColor
            Behavior on color { ColorAnimation { duration: 200 } }
        }

        // ── 4. Sound Settings Link ──
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 28
            radius: 6
            color: settingsMouse.containsMouse ? (barState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(0, 0, 0, 0.04)) : "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8

                Text {
                    text: "Ajustes de Sonido..."
                    color: barState.popupTextColor
                    font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                    font.pixelSize: 11
                    Behavior on color { ColorAnimation { duration: 200 } }
                }
            }

            MouseArea {
                id: settingsMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    barState.closePopups();
                    barState.runSilent("pavucontrol || systemsettings kcm_pulseaudio");
                }
            }
        }
    }
}
