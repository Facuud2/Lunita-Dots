import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell

Item {
    id: root

    required property var osdState

    implicitWidth: 260
    implicitHeight: 114

    // Escala y opacidad con transición fluida Nothing OS
    scale: osdState.cardScale
    opacity: osdState.cardOpacity

    Behavior on opacity {
        NumberAnimation {
            duration: root.opacity === 0.0 ? 160 : 100
            easing.type: root.opacity === 0.0 ? Easing.InQuad : Easing.OutQuad
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutCubic
        }
    }

    // ── Tarjeta HUD Nothing OS (Pitch Black con Borde Pixelado Característico) ──
    Rectangle {
        id: cardContainer
        anchors.fill: parent
        radius: 18
        color: osdState.cardBg
        clip: false

        // Borde gris pixelado característico del sistema Nothing (Dot-matrix gray border)
        Shape {
            id: pixelBorder
            anchors.fill: parent
            layer.enabled: true
            layer.samples: 4
            z: 3

            ShapePath {
                strokeColor: osdState.muted ? osdState.nothingRed : osdState.nothingPixelBorder
                strokeWidth: 1.5
                fillColor: "transparent"
                strokeStyle: ShapePath.DashLine
                dashPattern: [1, 1.5]
                capStyle: ShapePath.FlatCap
                joinStyle: ShapePath.RoundJoin

                startX: cardContainer.radius
                startY: 0.5
                PathLine { x: pixelBorder.width - cardContainer.radius; y: 0.5 }
                PathArc { x: pixelBorder.width - 0.5; y: cardContainer.radius; radiusX: cardContainer.radius; radiusY: cardContainer.radius; direction: PathArc.Clockwise }
                PathLine { x: pixelBorder.width - 0.5; y: pixelBorder.height - cardContainer.radius }
                PathArc { x: pixelBorder.width - cardContainer.radius; y: pixelBorder.height - 0.5; radiusX: cardContainer.radius; radiusY: cardContainer.radius; direction: PathArc.Clockwise }
                PathLine { x: cardContainer.radius; y: pixelBorder.height - 0.5 }
                PathArc { x: 0.5; y: pixelBorder.height - cardContainer.radius; radiusX: cardContainer.radius; radiusY: cardContainer.radius; direction: PathArc.Clockwise }
                PathLine { x: 0.5; y: cardContainer.radius }
                PathArc { x: cardContainer.radius; y: 0.5; radiusX: cardContainer.radius; radiusY: cardContainer.radius; direction: PathArc.Clockwise }
            }
        }

        // Sombra de profundidad sutil
        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: 19
            color: "transparent"
            border.color: Qt.rgba(0, 0, 0, 0.65)
            border.width: 1
            z: -1
            opacity: 0.5
        }

        // Contenido interno del OSD
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            // ── 1. Fila Superior: Categoría NDOT y Porcentaje NDOT ──
            RowLayout {
                Layout.fillWidth: true

                RowLayout {
                    spacing: 6

                    // Punto indicador Nothing
                    Rectangle {
                        width: 5
                        height: 5
                        radius: 2.5
                        color: osdState.muted ? osdState.nothingRed : osdState.fgPrimary
                    }

                    Text {
                        text: osdState.osdType === "brightness" ? "BRIGHTNESS" : (osdState.muted ? "MUTED" : "VOLUME")
                        font.family: osdState.fontDots
                        font.pixelSize: 11
                        font.letterSpacing: 1.1
                        color: osdState.muted ? osdState.nothingRed : osdState.fgMuted
                    }
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: osdState.muted ? "--%" : (osdState.volume + "%")
                    font.family: osdState.fontDots
                    font.pixelSize: 17
                    font.weight: Font.Bold
                    color: osdState.muted ? osdState.nothingRed : osdState.fgPrimary
                }
            }

            // ── 2. Fila Media: Icono Nothing Squircle + Dispositivo ──
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // Badge de Icono estilo Nothing OS
                Rectangle {
                    Layout.preferredWidth: 38
                    Layout.preferredHeight: 38
                    radius: 10
                    color: osdState.badgeBg
                    border.width: 1
                    border.color: osdState.badgeBorder

                    Text {
                        anchors.centerIn: parent
                        text: osdState.iconGlyph
                        font.family: osdState.fontIcons
                        font.pixelSize: 22
                        color: osdState.muted ? osdState.nothingRed : osdState.fgPrimary
                    }
                }

                // Título y Subtítulo
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1

                    Text {
                        Layout.fillWidth: true
                        text: osdState.osdType === "brightness" ? "Pantalla" : (osdState.sinkName || "Dispositivo")
                        font.family: osdState.fontUi
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        color: osdState.fgPrimary
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: {
                            if (osdState.osdType === "brightness") return "Brillo del sistema";
                            if (osdState.muted) return "Audio silenciado";
                            if (osdState.isHeadphones) return "Auriculares conectados";
                            return "Salida de audio";
                        }
                        font.family: osdState.fontUi
                        font.pixelSize: 11
                        color: osdState.fgSecondary
                        elide: Text.ElideRight
                    }
                }
            }

            // ── 3. Fila Inferior: Slider Cápsula Nothing OS ──
            Rectangle {
                id: sliderTrack
                Layout.fillWidth: true
                Layout.preferredHeight: 8
                radius: 4
                color: osdState.trackBg
                clip: true

                // Barra rellena reactiva con animación fluida
                Rectangle {
                    id: sliderFill
                    height: parent.height
                    radius: 4
                    width: osdState.muted ? 0 : Math.max(0, Math.min(sliderTrack.width, sliderTrack.width * (osdState.volume / 100.0)))
                    color: osdState.muted ? osdState.nothingRed : osdState.fgPrimary

                    Behavior on width {
                        NumberAnimation {
                            duration: 80
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }
        }
    }
}
