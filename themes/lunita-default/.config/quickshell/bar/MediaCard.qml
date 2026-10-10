import QtQuick
import Quickshell
import Quickshell.Io
import "."

Item {
    id: root

    readonly property bool active: MprisPlayer.active
    readonly property bool isPlaying: MprisPlayer.isPlaying
    readonly property string artUrl: MprisPlayer.artUrl
    readonly property real length: MprisPlayer.length
    readonly property real position: MprisPlayer.position
    readonly property real progress: MprisPlayer.progress

    property var cavaBars: []
    readonly property string cavaScript: Qt.resolvedUrl("scripts/cava.sh").toString().replace("file://", "")

    // Proceso CAVA a 60 FPS reactivo a PipeWire
    property var cavaProc: Process {
        id: cavaProcess
        command: ["bash", "-c", "exec " + root.cavaScript]
        running: root.active && root.isPlaying
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const raw = data.trim();
                if (!raw) return;
                const parts = raw.split(";");
                const vals = [];
                for (let i = 0; i < parts.length; i++) {
                    const p = parts[i].trim();
                    if (p !== "") {
                        vals.push(Math.min(100, Math.max(0, parseInt(p) || 0)));
                    }
                }
                if (vals.length >= 16) {
                    root.cavaBars = vals;
                }
            }
        }
    }

    onIsPlayingChanged: {
        if (!isPlaying) {
            root.cavaBars = [];
        }
    }

    // Timer de oscilación orgánica para cuando no hay picos extremos
    property real animPhase: 0
    Timer {
        interval: 50
        running: root.active && root.isPlaying
        repeat: true
        onTriggered: root.animPhase = (root.animPhase + 0.12) % (Math.PI * 2)
    }

    function fmt(seconds) {
        if (!seconds || seconds <= 0 || isNaN(seconds)) return "0:00";
        const sec = Math.floor(seconds);
        const h = Math.floor(sec / 3600);
        const m = Math.floor((sec % 3600) / 60);
        const s = sec % 60;
        const sStr = (s < 10 ? "0" : "") + s;
        if (h > 0) {
            const mStr = (m < 10 ? "0" : "") + m;
            return h + ":" + mStr + ":" + sStr;
        }
        return m + ":" + sStr;
    }

    implicitHeight: 124

    Rectangle {
        id: card
        anchors.fill: parent
        radius: Theme.shapeLg
        color: Theme.surface
        border.width: 1
        border.color: Theme.outline
        clip: true

        // ── 1. Fila Superior: Carátula + Título/Artista + Controles ──
        Item {
            id: topRow
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 12
            height: 46

            // Carátula del Álbum (46x46 redondeada con micro-escala reactiva)
            Rectangle {
                id: artBox
                width: 46
                height: 46
                radius: Theme.shapeSm
                color: Theme.surfaceHigh
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                clip: true
                scale: root.isPlaying ? 1.02 : 1.0
                Behavior on scale { NumberAnimation { duration: Theme.durMedium; easing.type: Easing.Bezier; easing.bezierCurve: Theme.emphasized } }

                Image {
                    id: artImg
                    anchors.fill: parent
                    source: root.artUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: status === Image.Ready && source !== ""
                }

                Text {
                    anchors.centerIn: parent
                    visible: !artImg.visible
                    text: "music_note"
                    color: Theme.fgDim
                    font.family: Theme.fontIcons
                    font.pixelSize: 24
                }
            }

            // Título y Artista
            Column {
                anchors.left: artBox.right
                anchors.leftMargin: 12
                anchors.right: transportControls.left
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    width: parent.width
                    text: root.active && MprisPlayer.title ? MprisPlayer.title : "Sin reproducción"
                    color: Theme.fg
                    font.family: Theme.fontUi
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: root.active && MprisPlayer.artist ? MprisPlayer.artist : "Desconocido"
                    color: Theme.fgDim
                    font.family: Theme.fontUi
                    font.pixelSize: 11
                    elide: Text.ElideRight
                }
            }

            // Botones de Transporte con micro-feedback reactivo
            Row {
                id: transportControls
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                // Anterior (|<)
                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: prevMa.containsMouse ? Theme.surfaceHigh : "transparent"
                    scale: prevMa.pressed ? 0.90 : (prevMa.containsMouse ? 1.08 : 1.0)
                    Behavior on scale { NumberAnimation { duration: 100 } }
                    Behavior on color { ColorAnimation { duration: Theme.durShort } }

                    Text {
                        anchors.centerIn: parent
                        text: "skip_previous"
                        color: Theme.fg
                        font.family: Theme.fontIcons
                        font.pixelSize: 18
                    }

                    MouseArea {
                        id: prevMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: MprisPlayer.previous()
                    }
                }

                // Play / Pause Circular Blanco Nothing (reactivo al clic)
                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: Theme.inverted
                    scale: playMa.pressed ? 0.90 : (playMa.containsMouse ? 1.08 : 1.0)

                    Behavior on scale { NumberAnimation { duration: 100 } }

                    Text {
                        anchors.centerIn: parent
                        text: root.isPlaying ? "pause" : "play_arrow"
                        color: Theme.invertedFg
                        font.family: Theme.fontIcons
                        font.pixelSize: 22
                    }

                    MouseArea {
                        id: playMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: MprisPlayer.playPause()
                    }
                }

                // Siguiente (>|)
                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: nextMa.containsMouse ? Theme.surfaceHigh : "transparent"
                    scale: nextMa.pressed ? 0.90 : (nextMa.containsMouse ? 1.08 : 1.0)
                    Behavior on scale { NumberAnimation { duration: 100 } }
                    Behavior on color { ColorAnimation { duration: Theme.durShort } }

                    Text {
                        anchors.centerIn: parent
                        text: "skip_next"
                        color: Theme.fg
                        font.family: Theme.fontIcons
                        font.pixelSize: 18
                    }

                    MouseArea {
                        id: nextMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: MprisPlayer.next()
                    }
                }
            }
        }

        // ── 2. Reproductor CAVA Ultra-Reactivo y Línea de Tiempo Marcada ──
        Item {
            id: waveBox
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            anchors.top: topRow.bottom
            anchors.topMargin: 8
            height: 30

            readonly property int barCount: 64
            readonly property real minBarHeight: 3.5
            readonly property real maxBarHeight: 28.0

            // Patrón de onda sonoro armónico característico de la pista
            readonly property var pattern: {
                const title = (MprisPlayer.title || "Nothing") + (MprisPlayer.artist || "");
                let seed = 0;
                for (let i = 0; i < title.length; i++)
                    seed = (seed * 31 + title.charCodeAt(i)) & 0x7fffffff;
                if (seed === 0) seed = 12345;

                const out = [];
                for (let b = 0; b < barCount; b++) {
                    seed = (seed * 1103515245 + 12345) & 0x7fffffff;
                    const r = (seed >>> 8) / 0x7fffff;
                    const env = Math.sin(Math.PI * (b + 0.5) / barCount);
                    out.push(0.18 + 0.82 * r * (0.42 + 0.58 * env));
                }
                return out;
            }

            MouseArea {
                id: seekMouse
                anchors.fill: parent
                anchors.topMargin: -8
                anchors.bottomMargin: -8
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                function seek(mx) {
                    if (root.length > 0) {
                        const ratio = Math.max(0.0, Math.min(1.0, mx / waveBox.width));
                        MprisPlayer.setPosition(Math.round(ratio * root.length));
                    }
                }

                onPressed: mouse => seek(mouse.x)
                onPositionChanged: mouse => {
                    if (pressed) seek(mouse.x);
                }
            }

            Repeater {
                model: waveBox.barCount

                Rectangle {
                    id: barItem
                    property real barSlotWidth: waveBox.width / waveBox.barCount
                    property real itemWidth: Math.max(2.8, Math.min(5.2, barSlotWidth - 2.8))
                    property real ratio: index / Math.max(1, waveBox.barCount - 1)

                    x: index * barSlotWidth + (barSlotWidth - itemWidth) / 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: itemWidth
                    radius: itemWidth / 2

                    // Altura acústica viva: modula con el espectro CAVA en tiempo real
                    property real patVal: (waveBox.pattern && index < waveBox.pattern.length) ? waveBox.pattern[index] : 0.4
                    property real cavaVal: (root.cavaBars && index < root.cavaBars.length) ? root.cavaBars[index] : 0

                    // Efecto hover interactivo: amplía la barra cerca del cursor
                    property bool hoveredNear: seekMouse.containsMouse && Math.abs((seekMouse.mouseX / waveBox.width) - ratio) < 0.04

                    height: {
                        const baseH = Math.max(waveBox.minBarHeight, patVal * 16.0);
                        let h = baseH;

                        if (root.isPlaying) {
                            if (cavaVal > 0) {
                                // Reacción dinámica contundente y acentuada con CAVA directo
                                const norm = Math.min(1.0, cavaVal / 60.0);
                                const punch = Math.pow(norm, 0.7);
                                h = Math.min(waveBox.maxBarHeight, Math.max(waveBox.minBarHeight, 3.5 + punch * (waveBox.maxBarHeight - 3.5)));
                            } else {
                                // Oscilación orgánica viva cuando el espectro está en silencio momentáneo
                                const waveOsc = Math.sin(root.animPhase + index * 0.28) * 3.5;
                                h = Math.max(waveBox.minBarHeight, baseH + waveOsc);
                            }
                        }

                        if (hoveredNear) {
                            h = Math.min(waveBox.maxBarHeight, h + 3.0);
                        }

                        return h;
                    }

                    Behavior on height {
                        NumberAnimation {
                            duration: 20
                            easing.type: Easing.Linear
                        }
                    }

                    // Línea de tiempo reactiva:
                    // Blanco brillante (#FFFFFF) para lo reproducido
                    // Hover scrub reactivo intermedio
                    // Gris oscuro definido (#262626) para la silueta pendiente
                    color: {
                        if (ratio <= root.progress) {
                            return "#FFFFFF";
                        }
                        if (seekMouse.containsMouse && ratio <= (seekMouse.mouseX / waveBox.width)) {
                            return Qt.rgba(1, 1, 1, 0.55);
                        }
                        return "#262626";
                    }

                    Behavior on color {
                        ColorAnimation { duration: 60 }
                    }
                }
            }
        }

        // ── 3. Marcas de Tiempo en NDOT 47 ──
        Item {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            anchors.top: waveBox.bottom
            anchors.topMargin: 2
            height: 16

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: root.fmt(root.position)
                color: Theme.fgDim
                font.family: Theme.fontDots
                font.pixelSize: 12
                font.weight: Font.Bold
            }

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: root.active && root.length > 0 ? root.fmt(root.length) : "0:00"
                color: Theme.fgDim
                font.family: Theme.fontDots
                font.pixelSize: 12
                font.weight: Font.Bold
            }
        }
    }
}
