import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    required property var osdState

    implicitWidth: 190
    implicitHeight: 190

    // Escala y opacidad controladas por OSDState con transición fluida
    scale: osdState.cardScale
    opacity: osdState.cardOpacity

    Behavior on opacity {
        NumberAnimation {
            duration: root.opacity === 0.0 ? 180 : 100
            easing.type: root.opacity === 0.0 ? Easing.InQuad : Easing.OutQuad
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }

    // ── Tarjeta HUD de Cristal Translúcido (Squircle Limpio y Puro) ──
    Rectangle {
        id: cardContainer
        anchors.fill: parent
        radius: 26
        color: Qt.rgba(0.12, 0.12, 0.16, 0.88)
        border.color: Qt.rgba(1, 1, 1, 0.18)
        border.width: 1
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: 22
            anchors.bottomMargin: 18
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 6

            // ── A. Icono de Altavoz / Auriculares Centrado (macOS SF Symbols) ──
            Item {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 64
                Layout.preferredHeight: 64

                Image {
                    id: osdIcon
                    anchors.centerIn: parent
                    width: 58
                    height: 58
                    source: osdState.iconSource
                    sourceSize.width: 116
                    sourceSize.height: 116
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                }
            }

            // ── B. Nombre de Dispositivo / Estado ──
            Text {
                Layout.alignment: Qt.AlignHCenter
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                text: {
                    if (osdState.osdType === "brightness") return "Brillo";
                    if (osdState.muted) return "Silenciado";
                    return osdState.sinkName || "Volumen";
                }
                font.family: "SF Pro Display, -apple-system, Roboto, Ubuntu, sans-serif"
                font.pixelSize: 11
                font.weight: Font.Medium
                color: Qt.rgba(1, 1, 1, 0.70)
            }

            Item { Layout.fillHeight: true }

            // ── C. Matriz de 16 Segmentos Clásicos de macOS ──
            Row {
                Layout.alignment: Qt.AlignHCenter
                spacing: 3

                Repeater {
                    model: osdState.totalSegments // 16 segmentos

                    Rectangle {
                        required property int index

                        width: 7.2
                        height: 6.5
                        radius: 1.5

                        // Segmento activo vs inactivo
                        readonly property bool isActive: index < osdState.activeSegments

                        color: isActive 
                            ? Qt.rgba(1, 1, 1, 0.96) 
                            : Qt.rgba(0, 0, 0, 0.40)

                        border.width: 1
                        border.color: isActive 
                            ? Qt.rgba(1, 1, 1, 1.0) 
                            : Qt.rgba(1, 1, 1, 0.10)

                        // Transición instantánea y táctil al girar la rueda del teclado
                        Behavior on color {
                            ColorAnimation { duration: 40 }
                        }
                    }
                }
            }
        }
    }
}
