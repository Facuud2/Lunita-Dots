import QtQuick

// NdDotRing — Anillo de progreso hecho de puntos (lenguaje Glyph de Nothing).
// Los puntos encendidos usan `onColor`; el resto queda en `offColor`.
Item {
    id: ring

    property real value: 0          // 0.0 – 1.0
    property int dots: 36
    property real dotSize: 4
    property color onColor: "#F5F5F5"
    property color offColor: "#2C2C2C"
    property real startAngle: -90   // grados, 12 en punto

    implicitWidth: 64
    implicitHeight: 64

    onValueChanged: canvas.requestPaint()
    onOnColorChanged: canvas.requestPaint()
    onOffColorChanged: canvas.requestPaint()
    onDotsChanged: canvas.requestPaint()
    onWidthChanged: canvas.requestPaint()
    onHeightChanged: canvas.requestPaint()

    Canvas {
        id: canvas

        anchors.fill: parent
        antialiasing: true
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            var cx = width / 2;
            var cy = height / 2;
            var r = Math.min(width, height) / 2 - ring.dotSize / 2 - 0.5;
            var lit = Math.round(Math.max(0, Math.min(1, ring.value)) * ring.dots);
            for (var i = 0; i < ring.dots; i++) {
                var a = (ring.startAngle + (360 / ring.dots) * i) * Math.PI / 180;
                ctx.beginPath();
                ctx.arc(cx + r * Math.cos(a), cy + r * Math.sin(a), ring.dotSize / 2, 0, 2 * Math.PI);
                ctx.fillStyle = i < lit ? ring.onColor : ring.offColor;
                ctx.fill();
            }
        }
    }
}
