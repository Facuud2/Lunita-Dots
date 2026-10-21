import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    // ── OSD Properties ──
    property int volume: 50
    property bool muted: false
    property string sinkName: "Altavoces"
    property bool isHeadphones: false
    property string osdType: "volume" // "volume" | "brightness"

    // ── Visibility & Animation States ──
    property bool isVisible: false
    property real cardOpacity: 0.0
    property real cardScale: 0.92
    property bool isFirstBoot: true

    // ── 16 Segments Calculation ──
    readonly property int totalSegments: 16
    readonly property int activeSegments: muted ? 0 : Math.min(16, Math.max(0, Math.round((volume / 100.0) * totalSegments)))

    // Dynamic icon selection based on sound levels and device
    readonly property string iconSource: {
        if (osdType === "brightness") {
            return "assets/sun-max.svg";
        }
        if (muted) {
            return "assets/speaker-slash.svg";
        }
        if (isHeadphones) {
            return "assets/headphones.svg";
        }
        if (volume === 0) {
            return "assets/speaker-wave-0.svg";
        }
        if (volume <= 33) {
            return "assets/speaker-wave-1.svg";
        }
        if (volume <= 66) {
            return "assets/speaker-wave-2.svg";
        }
        return "assets/speaker-wave-3.svg";
    }

    Process {
        id: brightnessProc
        command: ["bash", "-c", "command -v brightnessctl >/dev/null 2>&1 && brightnessctl -m | cut -d, -f4 | tr -d '%' || echo 50"]
        stdout: SplitParser {
            onRead: data => {
                let v = parseInt(data.trim());
                if (!isNaN(v)) {
                    root.volume = Math.max(0, Math.min(100, v));
                    root.muted = false;
                }
            }
        }
    }

    function show(type) {
        if (type) root.osdType = type;
        if (root.osdType === "brightness") {
            brightnessProc.running = true;
        }
        
        // Cancelar timer de ocultamiento si el usuario sigue rotando la rueda del teclado
        hideTimer.stop();
        unmapTimer.stop();

        root.isVisible = true;
        root.cardOpacity = 1.0;
        root.cardScale = 1.0;

        // Iniciar timer de permanencia (1.5 segundos estilo macOS)
        hideTimer.restart();
    }

    function hideImmediately() {
        hideTimer.stop();
        unmapTimer.stop();
        root.cardOpacity = 0.0;
        root.cardScale = 0.92;
        root.isVisible = false;
    }

    Timer {
        id: hideTimer
        interval: 1500
        repeat: false
        onTriggered: {
            root.cardOpacity = 0.0;
            root.cardScale = 0.94;
            unmapTimer.restart();
        }
    }

    Timer {
        id: unmapTimer
        interval: 220
        repeat: false
        onTriggered: {
            root.isVisible = false;
        }
    }

    // ── Listener en tiempo real de eventos PipeWire / WirePlumber ──
    Process {
        id: listenerProc
        command: ["python3", "-u", Quickshell.env("HOME") + "/.config/quickshell/osd/scripts/osd_listener.py"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                var str = data.trim();
                if (!str || str.length === 0) return;
                try {
                    var parsed = JSON.parse(str);
                    if (parsed.type === "volume") {
                        var prevVol = root.volume;
                        var prevMuted = root.muted;
                        var newVol = typeof parsed.volume === "number" ? parsed.volume : prevVol;
                        var newMuted = typeof parsed.muted === "boolean" ? parsed.muted : prevMuted;
                        
                        root.volume = newVol;
                        root.muted = newMuted;
                        root.sinkName = parsed.sink || root.sinkName;
                        root.isHeadphones = !!parsed.isHeadphones;
                        root.osdType = "volume";

                        // Si es el primer reporte de arranque, solo sincronizar estado sin mostrar el OSD
                        if (root.isFirstBoot) {
                            root.isFirstBoot = false;
                            return;
                        }

                        // Mostrar el OSD ÚNICAMENTE si el volumen o mute cambiaron realmente
                        if (prevVol !== newVol || prevMuted !== newMuted) {
                            root.show("volume");
                        }
                    }
                } catch(e) {}
            }
        }
    }
}
