import QtQuick

// NdDotGrid — Trama de puntos de fondo (papel punteado de Nothing).
Canvas {
    id: grid

    property real step: 14
    property real dotSize: 1.6
    property color dotColor: "#D4D4D4"

    onStepChanged: requestPaint()
    onDotColorChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d");
        ctx.reset();
        ctx.fillStyle = grid.dotColor;
        var off = grid.step / 2;
        for (var y = off; y < height; y += grid.step) {
            for (var x = off; x < width; x += grid.step) {
                ctx.beginPath();
                ctx.arc(x, y, grid.dotSize / 2, 0, 2 * Math.PI);
                ctx.fill();
            }
        }
    }
}
