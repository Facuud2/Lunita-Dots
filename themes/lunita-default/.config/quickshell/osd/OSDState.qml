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

    // ── Tipografías e Iconos Nothing OS ──
    readonly property FontLoader cargaIconos: FontLoader {
        source: "fonts/MaterialSymbolsRounded.ttf"
    }
    readonly property FontLoader cargaUi: FontLoader {
        source: "fonts/SpaceGrotesk.ttf"
    }
    readonly property FontLoader cargaNumeros: FontLoader {
        source: "fonts/ndot-47-inspired-by-nothing.otf"
    }

    readonly property string fontIcons: cargaIconos.name || "Material Symbols Rounded"
    readonly property string fontUi: cargaUi.name || "Space Grotesk"
    readonly property string fontDots: cargaNumeros.name || "NDOT 47 (inspired by NOTHING)"

    // ── Colores Nothing OS ──
    readonly property color cardBg: "#121214"
    readonly property color nothingPixelBorder: "#5A5A5E"
    readonly property color nothingRed: "#D71921"
    readonly property color fgPrimary: "#FFFFFF"
    readonly property color fgSecondary: Qt.rgba(1, 1, 1, 0.70)
    readonly property color fgMuted: Qt.rgba(1, 1, 1, 0.40)
    readonly property color badgeBg: "#1E1E22"
    readonly property color badgeBorder: "#2C2C32"
    readonly property color trackBg: "#222226"

    // Dynamic icon selection based on sound levels and device
    readonly property string iconGlyph: {
        if (osdType === "brightness") {
            return "brightness_6";
        }
        if (muted) {
            return "volume_off";
        }
        if (isHeadphones) {
            return "headphones";
        }
        if (volume === 0) {
            return "volume_mute";
        }
        if (volume <= 50) {
            return "volume_down";
        }
        return "volume_up";
    }

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
