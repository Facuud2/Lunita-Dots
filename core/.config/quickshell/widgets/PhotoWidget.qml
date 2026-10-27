import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    property var widgetsState
    readonly property bool isSmall: root.width <= 220
    readonly property bool isMedium: root.width > 220 && root.height <= 240
    readonly property bool isLarge: root.width > 220 && root.height > 240
    readonly property bool nothing: root.widgetsState && root.widgetsState.skin && root.widgetsState.skin.isNothing
    readonly property var skin: root.widgetsState ? root.widgetsState.skin : null
    readonly property bool fluent: root.skin ? root.skin.isFluent : (root.widgetsState && root.widgetsState.activeThemeId === "modern-win11-theme")
    readonly property real cardRadius: root.nothing ? root.skin.radiusCard : (root.fluent ? root.skin.radiusCard : (root.widgetsState ? root.widgetsState.cardRadius : 22))
    readonly property string currentPhotoPath: {
        if (root.widgetsState && root.widgetsState.photoPath)
            return root.widgetsState.photoPath;

        return "";
    }
    readonly property string prevPhotoPath: {
        if (root.widgetsState && root.widgetsState.photoPrevPath)
            return root.widgetsState.photoPrevPath;

        return "";
    }
    readonly property string nextPhotoPath: {
        if (root.widgetsState && root.widgetsState.photoNextPath)
            return root.widgetsState.photoNextPath;

        return "";
    }
    // Ruta actualmente proyectada en la tarjeta frontal
    property string displayCurrentPath: root.currentPhotoPath
    readonly property bool hasPhotos: root.currentPhotoPath !== ""
    // Índice activo para los dos puntos de paginación verticales
    readonly property int photoIndex: root.widgetsState ? root.widgetsState.photoIndex : 1
    readonly property int activeDot: (root.photoIndex % 2 === 1) ? 0 : 1
    // ── Propiedades de Navegación Smart Stack (iOS) ──────────────────────
    property real stackOffsetY: 0
    property bool isStackAnimating: false
    property int pendingDirection: 0 // 1: next, -1: prev, 0: ninguno
    property real lastWheelTime: 0

    function slideToNext() {
        if (stackSlideAnim.running || !root.widgetsState)
            return ;

        root.isStackAnimating = true;
        root.pendingDirection = 1;
        stackSlideAnim.from = root.stackOffsetY;
        stackSlideAnim.to = -cardContainer.height;
        stackSlideAnim.restart();
    }

    function slideToPrev() {
        if (stackSlideAnim.running || !root.widgetsState)
            return ;

        root.isStackAnimating = true;
        root.pendingDirection = -1;
        stackSlideAnim.from = root.stackOffsetY;
        stackSlideAnim.to = cardContainer.height;
        stackSlideAnim.restart();
    }

    function snapStackBack() {
        if (stackSlideAnim.running)
            return ;

        root.pendingDirection = 0;
        stackSlideAnim.from = root.stackOffsetY;
        stackSlideAnim.to = 0;
        stackSlideAnim.restart();
    }

    onCurrentPhotoPathChanged: {
        if (!root.isStackAnimating && root.currentPhotoPath !== "")
            root.displayCurrentPath = root.currentPhotoPath;

    }

    // Animación de deslizamiento vertical con físicas estilo resorte iOS
    NumberAnimation {
        id: stackSlideAnim

        target: root
        property: "stackOffsetY"
        duration: 250
        easing.type: Easing.OutCubic
        onFinished: {
            if (root.pendingDirection === 1) {
                if (root.nextPhotoPath !== "")
                    root.displayCurrentPath = root.nextPhotoPath;

                root.stackOffsetY = 0;
                root.isStackAnimating = false;
                root.pendingDirection = 0;
                if (root.widgetsState)
                    root.widgetsState.nextPhoto();

            } else if (root.pendingDirection === -1) {
                if (root.prevPhotoPath !== "")
                    root.displayCurrentPath = root.prevPhotoPath;

                root.stackOffsetY = 0;
                root.isStackAnimating = false;
                root.pendingDirection = 0;
                if (root.widgetsState)
                    root.widgetsState.prevPhoto();

            } else {
                root.stackOffsetY = 0;
                root.isStackAnimating = false;
                root.pendingDirection = 0;
            }
        }
    }

    // ── Tarjeta Contenedora Principal ─────────────────────────────────────
    Rectangle {
        // ═══════════════════════════════════════════════════════════════════
        // ── 3. Capas Smart Stack: Previa, Siguiente y Actual ──────────────
        // ═══════════════════════════════════════════════════════════════════

        id: cardContainer

        anchors.fill: parent
        radius: root.cardRadius
        color: root.nothing ? root.skin.card : (root.fluent ? root.skin.card : "#1C1C1E")
        clip: true
        border.color: root.nothing ? root.skin.cardBorder : (root.fluent ? root.skin.cardBorder : Qt.rgba(255, 255, 255, 0.18))
        border.width: root.nothing ? 0 : 1
        scale: clickArea.pressed ? 0.985 : 1

        // Chip identificador Windows 11 Photos
        Rectangle {
            visible: root.fluent
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: 10
            height: 22
            width: photoChipRow.implicitWidth + 14
            radius: root.skin ? root.skin.radiusControl : 6
            color: Qt.rgba(0, 0, 0, 0.5)
            border.color: Qt.rgba(255, 255, 255, 0.15)
            border.width: 1
            z: 25

            RowLayout {
                id: photoChipRow

                anchors.centerIn: parent
                spacing: 5

                Text {
                    text: "󰄄"
                    font.family: "Symbols Nerd Font"
                    font.pixelSize: 11
                    color: root.skin ? root.skin.accent : "#0078D4"
                }

                Text {
                    text: "Fotos"
                    font.family: root.skin ? root.skin.fontText : "Segoe UI Variable Text"
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    color: "#FFFFFF"
                }

            }

        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 1. Gesto de Arrastre Vertical (DragHandler Smart Stack) ───────
        // ═══════════════════════════════════════════════════════════════════
        DragHandler {
            id: dragHandler

            target: null
            xAxis.enabled: false
            yAxis.enabled: true
            enabled: !root.isStackAnimating && (!root.widgetsState || !root.widgetsState.isEditing)
            onActiveChanged: {
                if (!active) {
                    if (root.stackOffsetY < -35)
                        root.slideToNext();
                    else if (root.stackOffsetY > 35)
                        root.slideToPrev();
                    else
                        root.snapStackBack();
                }
            }
            onTranslationChanged: {
                if (active && !root.isStackAnimating)
                    root.stackOffsetY = Math.max(-cardContainer.height, Math.min(cardContainer.height, translation.y));

            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 2. Gesto con Rueda del Ratón / Touchpad (WheelHandler) ─────────
        // ═══════════════════════════════════════════════════════════════════
        WheelHandler {
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            enabled: !root.isStackAnimating && (!root.widgetsState || !root.widgetsState.isEditing)
            onWheel: (event) => {
                var now = Date.now();
                if (now - root.lastWheelTime > 260 && !root.isStackAnimating) {
                    root.lastWheelTime = now;
                    if (event.angleDelta.y < 0)
                        root.slideToNext();
                    else if (event.angleDelta.y > 0)
                        root.slideToPrev();
                }
            }
        }

        // Foto Previa (Arriba: entra hacia abajo al arrastrar o navegar atrás)
        PhotoCardItem {
            id: prevCard

            imagePath: root.prevPhotoPath
            cardY: -cardContainer.height + root.stackOffsetY
            cardScale: 0.92 + 0.08 * Math.min(1, Math.max(0, root.stackOffsetY / Math.max(1, cardContainer.height)))
            cardOpacity: 0.45 + 0.55 * Math.min(1, Math.max(0, root.stackOffsetY / Math.max(1, cardContainer.height)))
            visible: (root.stackOffsetY > 0 || (root.isStackAnimating && root.pendingDirection === -1)) && root.prevPhotoPath !== ""
        }

        // Foto Siguiente (Abajo: entra hacia arriba al arrastrar o navegar adelante)
        PhotoCardItem {
            id: nextCard

            imagePath: root.nextPhotoPath
            cardY: cardContainer.height + root.stackOffsetY
            cardScale: 0.92 + 0.08 * Math.min(1, Math.max(0, -root.stackOffsetY / Math.max(1, cardContainer.height)))
            cardOpacity: 0.45 + 0.55 * Math.min(1, Math.max(0, -root.stackOffsetY / Math.max(1, cardContainer.height)))
            visible: (root.stackOffsetY < 0 || (root.isStackAnimating && root.pendingDirection === 1)) && root.nextPhotoPath !== ""
        }

        // Foto Actual
        PhotoCardItem {
            id: currentCard

            imagePath: root.displayCurrentPath !== "" ? root.displayCurrentPath : root.currentPhotoPath
            cardY: root.stackOffsetY
            cardScale: 1 - 0.08 * Math.min(1, Math.abs(root.stackOffsetY) / Math.max(1, cardContainer.height))
            cardOpacity: 1 - 0.45 * Math.min(1, Math.abs(root.stackOffsetY) / Math.max(1, cardContainer.height))
            visible: root.hasPhotos
        }

        // Estado vacío si no hay imágenes
        Item {
            anchors.fill: parent
            visible: !root.hasPhotos

            Column {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "󰄄"
                    font.family: "CaskaydiaCove Nerd Font"
                    font.pixelSize: 32
                    color: root.nothing ? root.skin.inkDim : Qt.rgba(1, 1, 1, 0.45)
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Sin Fotos"
                    font.family: root.nothing ? root.skin.fontFigure : "SF Pro Display"
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    color: root.nothing ? root.skin.inkDim : Qt.rgba(1, 1, 1, 0.55)
                }

            }

        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 4. Interacción Nativa (Clic rápido: Avanzar, Clic derecho: Abrir)
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
                    if (!root.isStackAnimating && Math.abs(root.stackOffsetY) < 5)
                        root.slideToNext();

                } else if (mouse.button === Qt.RightButton) {
                    var targetPath = root.displayCurrentPath !== "" ? root.displayCurrentPath : root.currentPhotoPath;
                    if (targetPath)
                        Quickshell.execDetached(["xdg-open", targetPath]);

                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 5. Indicador Vertical de Paginación (2 Puntos Smart Stack) ────
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
                color: root.nothing ? (root.activeDot === 0 ? root.skin.signal : root.skin.dotOff) : (root.fluent ? (root.activeDot === 0 ? root.skin.accent : root.skin.dotOff) : (root.activeDot === 0 ? "#FFFFFF" : Qt.rgba(255, 255, 255, 0.45)))
                border.color: (root.nothing || root.fluent) ? "transparent" : Qt.rgba(0, 0, 0, 0.3)
                border.width: (root.nothing || root.fluent) ? 0 : 0.5
                scale: root.activeDot === 0 ? 1.25 : 1

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!root.isStackAnimating && root.activeDot !== 0)
                            root.slideToPrev();

                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }

                }

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }

                }

            }

            // Punto Inferior (Dot 1)
            Rectangle {
                width: 5.5
                height: 5.5
                radius: 2.75
                color: root.nothing ? (root.activeDot === 1 ? root.skin.signal : root.skin.dotOff) : (root.fluent ? (root.activeDot === 1 ? root.skin.accent : root.skin.dotOff) : (root.activeDot === 1 ? "#FFFFFF" : Qt.rgba(255, 255, 255, 0.45)))
                border.color: (root.nothing || root.fluent) ? "transparent" : Qt.rgba(0, 0, 0, 0.3)
                border.width: (root.nothing || root.fluent) ? 0 : 0.5
                scale: root.activeDot === 1 ? 1.25 : 1

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!root.isStackAnimating && root.activeDot !== 1)
                            root.slideToNext();

                    }
                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutCubic
                    }

                }

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }

                }

            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }

        }

    }

    // ── Componente Reutilizable: Tarjeta de Foto con Squircle ─────────────
    component PhotoCardItem: Item {
        id: cardItem

        property string imagePath: ""
        property real cardY: 0
        property real cardScale: 1
        property real cardOpacity: 1

        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height
        y: cardY
        scale: cardScale
        opacity: cardOpacity
        transformOrigin: Item.Center

        Rectangle {
            anchors.fill: parent
            radius: root.cardRadius
            clip: true
            color: root.nothing ? root.skin.card : (root.fluent ? root.skin.card : "#1C1C1E")

            Image {
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                smooth: true
                cache: true
                source: cardItem.imagePath !== "" ? ("file://" + cardItem.imagePath) : ""
            }

            // Borde squircle sutil
            Rectangle {
                anchors.fill: parent
                radius: root.cardRadius
                color: "transparent"
                border.color: root.nothing ? root.skin.cardBorder : (root.fluent ? root.skin.cardBorder : Qt.rgba(255, 255, 255, 0.14))
                border.width: root.nothing ? 0 : 1
            }

        }

    }

}
