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
    z: 5 // Debajo de los widgets (z: 10+) pero visible como guía

    Behavior on opacity {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    // ── 1. Matriz de Celdas Guía (Pantalla Completa) ─────────────────────
    Repeater {
        model: root.cols * root.rows

        Item {
            property int cellCol: index % root.cols
            property int cellRow: Math.floor(index / root.cols)

            x: root.marginLeft + cellCol * (root.cellSize + root.cellGap)
            y: root.marginTop + cellRow * (root.cellSize + root.cellGap)
            width: root.cellSize
            height: root.cellSize

            // Recuadro Squircle de la celda
            Rectangle {
                anchors.fill: parent
                radius: root.isNothing ? 24 : 22
                color: root.isNothing ? Qt.rgba(1, 1, 1, 0.012) : Qt.rgba(255, 255, 255, 0.02)
                border.color: root.isNothing ? Qt.rgba(1, 1, 1, 0.07) : Qt.rgba(255, 255, 255, 0.08)
                border.width: 1

                // Punto central sutil estilo retícula Ryoku / Nothing
                Rectangle {
                    anchors.centerIn: parent
                    width: 3
                    height: 3
                    radius: 1.5
                    color: root.isNothing ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(255, 255, 255, 0.14)
                }
            }
        }
    }

    // ── 2. Ghost Slot: Silueta Proyectada de Destino Magnético ───────────
    Rectangle {
        id: ghostSlot

        visible: root.isDragging && root.activeDragCol >= 0 && root.activeDragRow >= 0

        x: root.marginLeft + root.activeDragCol * (root.cellSize + root.cellGap)
        y: root.marginTop + root.activeDragRow * (root.cellSize + root.cellGap)
        width: root.activeDragColSpan * root.cellSize + (root.activeDragColSpan - 1) * root.cellGap
        height: root.activeDragRowSpan * root.cellSize + (root.activeDragRowSpan - 1) * root.cellGap
        radius: root.isNothing ? 24 : 22

        color: root.isNothing
            ? Qt.rgba(1, 1, 1, 0.10)
            : Qt.rgba(0.0, 0.48, 1.0, 0.16)

        border.color: root.isNothing
            ? (root.canvas && root.canvas.widgetsState && root.canvas.widgetsState.skin ? root.canvas.widgetsState.skin.signal : "#FFFFFF")
            : "#007AFF"
        border.width: root.isNothing ? 1.5 : 2

        Behavior on x {
            NumberAnimation {
                duration: 160
                easing.type: Easing.OutQuad
            }
        }

        Behavior on y {
            NumberAnimation {
                duration: 160
                easing.type: Easing.OutQuad
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: 160
                easing.type: Easing.OutQuad
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 160
                easing.type: Easing.OutQuad
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: 140 }
        }

        // Cruz de enfoque central de destino
        Item {
            anchors.centerIn: parent
            width: 16
            height: 16

            Rectangle {
                anchors.centerIn: parent
                width: 16
                height: 2
                radius: 1
                color: ghostSlot.border.color
                opacity: 0.6
            }

            Rectangle {
                anchors.centerIn: parent
                width: 2
                height: 16
                radius: 1
                color: ghostSlot.border.color
                opacity: 0.6
            }
        }
    }
}
