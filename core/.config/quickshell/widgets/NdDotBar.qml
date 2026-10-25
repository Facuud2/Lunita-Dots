import QtQuick

// NdDotBar — Barra de progreso horizontal hecha de puntos.
Item {
    id: bar

    property real value: 0          // 0.0 – 1.0
    property real dotSize: 4
    property real spacing: 3
    property color onColor: "#F5F5F5"
    property color offColor: "#2C2C2C"

    readonly property int count: Math.max(1, Math.floor((width + spacing) / (dotSize + spacing)))
    readonly property int lit: Math.round(Math.max(0, Math.min(1, value)) * count)

    implicitHeight: dotSize

    Row {
        anchors.verticalCenter: parent.verticalCenter
        spacing: bar.spacing

        Repeater {
            model: bar.count

            Rectangle {
                required property int index

                width: bar.dotSize
                height: bar.dotSize
                radius: bar.dotSize / 2
                color: index < bar.lit ? bar.onColor : bar.offColor
            }
        }
    }
}
