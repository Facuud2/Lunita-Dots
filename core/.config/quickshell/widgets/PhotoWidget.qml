import Qt5Compat.GraphicalEffects
import QtQuick
import Quickshell

Item {
    id: root

    property var widgetsState

    readonly property bool isSmall: root.width <= 220
    readonly property bool isMedium: root.width > 220 && root.height <= 240
    readonly property bool isLarge: root.width > 220 && root.height > 240

    readonly property bool nothing: root.widgetsState && root.widgetsState.skin && root.widgetsState.skin.isNothing
    readonly property var skin: root.widgetsState ? root.widgetsState.skin : null

    readonly property real cardRadius: root.nothing ? root.skin.radiusCard : (root.widgetsState ? root.widgetsState.cardRadius : 22)
    readonly property string currentPhotoPath: {
        if (root.widgetsState && root.widgetsState.photoPath)
            return root.widgetsState.photoPath;
        return "";
    }

    // Índice activo para los dos puntos de paginación verticales (exactos a la imagen)
    readonly property int photoIndex: root.widgetsState ? root.widgetsState.photoIndex : 1
    readonly property int activeDot: (root.photoIndex % 2 === 1) ? 0 : 1

    // ── Tarjeta Contenedora Principal ─────────────────────────────────────
    Rectangle {
        id: cardContainer

        anchors.fill: parent
        radius: root.cardRadius
        color: root.nothing ? root.skin.card : "#1C1C1E"
        clip: true
        border.color: root.nothing ? root.skin.cardBorder : Qt.rgba(255, 255, 255, 0.18)
        border.width: root.nothing ? 0 : 1

        // ═══════════════════════════════════════════════════════════════════
        // ── 1. Capa Fotográfica Full-Bleed con Máscara Squircle (iOS) ─────
        // ═══════════════════════════════════════════════════════════════════
        Item {
            id: maskedContent

            anchors.fill: parent
            layer.enabled: true

            property bool usingA: true

            // Imagen Primaria (A)
            Image {
                id: imgA

                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                smooth: true
                cache: true
                opacity: 1
                source: root.currentPhotoPath !== "" ? ("file://" + root.currentPhotoPath) : ""
            }

            // Imagen Secundaria (B) para Transición Suave CrossFade
            Image {
                id: imgB

                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                smooth: true
                cache: true
                opacity: 0
                source: ""
            }

            // Escuchar cambios de ruta de foto en widgetsState
            Connections {
                function onPhotoPathChanged() {
                    var newPath = root.currentPhotoPath;
                    if (!newPath)
                        return ;

                    var fileUrl = "file://" + newPath;
                    if (maskedContent.usingA) {
                        imgB.source = fileUrl;
                        crossfadeToB.restart();
                        maskedContent.usingA = false;
                    } else {
                        imgA.source = fileUrl;
                        crossfadeToA.restart();
                        maskedContent.usingA = true;
                    }
                }

                target: root.widgetsState
            }

            // Animación de Transición A -> B
            ParallelAnimation {
                id: crossfadeToB

                NumberAnimation {
                    target: imgA
                    property: "opacity"
                    to: 0
                    duration: 450
                    easing.type: Easing.InOutQuad
                }

                NumberAnimation {
                    target: imgB
                    property: "opacity"
                    to: 1
                    duration: 450
                    easing.type: Easing.InOutQuad
                }
            }

            // Animación de Transición B -> A
            ParallelAnimation {
                id: crossfadeToA

                NumberAnimation {
                    target: imgB
                    property: "opacity"
                    to: 0
                    duration: 450
                    easing.type: Easing.InOutQuad
                }

                NumberAnimation {
                    target: imgA
                    property: "opacity"
                    to: 1
                    duration: 450
                    easing.type: Easing.InOutQuad
                }
            }

            // Máscara precisa con radio de curvatura idéntico a la referencia
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: cardContainer.width
                    height: cardContainer.height
                    radius: root.cardRadius
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 2. Indicador Vertical de Paginación (2 Puntos Exactos a Ref) ──
        // ═══════════════════════════════════════════════════════════════════
        Column {
            id: paginationDots

            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6
            z: 20

            // Punto Superior (Dot 0)
            Rectangle {
                width: 5.5
                height: 5.5
                radius: 2.75
                color: root.nothing
                    ? (root.activeDot === 0 ? root.skin.signal : root.skin.dotOff)
                    : (root.activeDot === 0 ? "#FFFFFF" : Qt.rgba(255, 255, 255, 0.45))
                border.color: root.nothing ? "transparent" : Qt.rgba(0, 0, 0, 0.30)
                border.width: root.nothing ? 0 : 0.5

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.activeDot !== 0 && root.widgetsState)
                            root.widgetsState.prevPhoto();
                    }
                }
            }

            // Punto Inferior (Dot 1)
            Rectangle {
                width: 5.5
                height: 5.5
                radius: 2.75
                color: root.nothing
                    ? (root.activeDot === 1 ? root.skin.signal : root.skin.dotOff)
                    : (root.activeDot === 1 ? "#FFFFFF" : Qt.rgba(255, 255, 255, 0.45))
                border.color: root.nothing ? "transparent" : Qt.rgba(0, 0, 0, 0.30)
                border.width: root.nothing ? 0 : 0.5

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.activeDot !== 1 && root.widgetsState)
                            root.widgetsState.nextPhoto();
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 3. Interacción Nativa (Clic: Avanzar, Rueda: Navegar) ─────────
        // ═══════════════════════════════════════════════════════════════════
        MouseArea {
            id: clickArea

            anchors.fill: parent
            z: 10
            enabled: !root.widgetsState || !root.widgetsState.isEditing
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    if (root.widgetsState)
                        root.widgetsState.nextPhoto();
                } else if (mouse.button === Qt.RightButton) {
                    if (root.currentPhotoPath)
                        Quickshell.execDetached(["xdg-open", root.currentPhotoPath]);
                }
            }

            onWheel: (wheel) => {
                if (wheel.angleDelta.y > 0) {
                    if (root.widgetsState)
                        root.widgetsState.prevPhoto();
                } else if (wheel.angleDelta.y < 0) {
                    if (root.widgetsState)
                        root.widgetsState.nextPhoto();
                }
            }
        }
    }
}
