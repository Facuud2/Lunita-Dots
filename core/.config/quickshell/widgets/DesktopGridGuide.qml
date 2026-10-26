import QtQuick

Item {
    id: root

    property var canvas: null
    property real cellSize: 170
    property real cellGap: 14
    property int cols: 10
    property int rows: 5
    property real marginLeft: 47
    property real marginTop: 87

    property int activeDragCol: -1
    property int activeDragRow: -1
    property int activeDragColSpan: 1
    property int activeDragRowSpan: 1
    property bool isDragging: false
    property bool isNothing: canvas && canvas.widgetsState && canvas.widgetsState.skin && canvas.widgetsState.skin.isNothing

    anchors.fill: parent
    opacity: (canvas && canvas.isEditing) ? 1.0 : 0.0
    visible: opacity > 0.001
    z: 5 // Debajo de los widgets (z: 10+) pero visible como silueta magnética

    Behavior on opacity {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    // ── Ghost Slot: Silueta Proyectada de Destino Magnético (iOS / Nothing style) ──
    Rectangle {
        id: ghostSlot

        visible: opacity > 0.001
        opacity: (root.isDragging && root.activeDragCol >= 0 && root.activeDragRow >= 0) ? 1.0 : 0.0

        x: (root.activeDragCol >= 0) ? (root.marginLeft + root.activeDragCol * (root.cellSize + root.cellGap)) : 0
        y: (root.activeDragRow >= 0) ? (root.marginTop + root.activeDragRow * (root.cellSize + root.cellGap)) : 0
        width: root.activeDragColSpan * root.cellSize + (root.activeDragColSpan - 1) * root.cellGap
        height: root.activeDragRowSpan * root.cellSize + (root.activeDragRowSpan - 1) * root.cellGap
        radius: root.isNothing ? 24 : 22

        color: root.isNothing
            ? Qt.rgba(1, 1, 1, 0.07)
            : Qt.rgba(255, 255, 255, 0.09)

        border.color: root.isNothing
            ? Qt.rgba(1, 1, 1, 0.22)
            : Qt.rgba(255, 255, 255, 0.28)
        border.width: 1.5

        // Las animaciones de posición sólo se habilitan cuando el ghostSlot ya es visible
        // previniendo que vuele desde la esquina (0, 0) o (-1, -1) al iniciar el arrastre
        Behavior on x {
            enabled: root.isDragging && ghostSlot.opacity > 0.05
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        Behavior on y {
            enabled: root.isDragging && ghostSlot.opacity > 0.05
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }
        }
    }
}
