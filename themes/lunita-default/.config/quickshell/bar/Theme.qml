import "."
import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

QtObject {
    id: root

    property var matugenColors: ({
    })
    property var colorWatcher

    colorWatcher: FileView {
        id: colorWatcher

        path: Quickshell.env("HOME") + "/.config/quickshell/colors.json"
        watchChanges: true
        onLoaded: root.updateFromTokens()
        onFileChanged: colorWatcher.reload()
        onTextChanged: root.updateFromTokens()
    }

    // ── Nothing OS Strict Monochrome + Matugen Dynamic Palette ──
    readonly property color bg: matugenColors.surface || "#0B0B0B"
    readonly property color surface: matugenColors.surface_container || "#161616"
    readonly property color surfaceAlt: matugenColors.surface_container_high || "#1A1A1A"
    readonly property color surfaceHigh: matugenColors.surface_container_highest || "#242424"
    readonly property color surfaceTop: matugenColors.surface_container_highest || "#2A2A2A"
    readonly property color inverted: matugenColors.primary || "#FFFFFF"
    readonly property color invertedFg: matugenColors.on_primary || "#000000"
    readonly property color fg: matugenColors.on_surface || "#FFFFFF"
    readonly property color fgDim: matugenColors.on_surface_variant || Qt.rgba(1, 1, 1, 0.6)
    readonly property color fgFaint: matugenColors.outline || Qt.rgba(1, 1, 1, 0.3)
    readonly property color outline: matugenColors.outline_variant || "#1A1A1A"
    readonly property color alert: matugenColors.error || "#D71921"
    readonly property color accent: matugenColors.primary || "#FFFFFF"
    // aliases para compatibilidad con Nothing Island
    readonly property color primary: matugenColors.primary || fg
    readonly property color primaryFg: matugenColors.on_primary || invertedFg
    readonly property color secondary: matugenColors.secondary || fgDim
    readonly property color tertiary: matugenColors.tertiary || fgDim
    readonly property color error: alert
    readonly property color containerLowest: bg
    readonly property color containerLow: surface
    readonly property color container: surface
    readonly property color containerHigh: surfaceAlt
    readonly property color containerHighest: surfaceHigh
    readonly property color primaryContainer: matugenColors.primary_container || surfaceAlt
    readonly property color primaryContainerFg: matugenColors.on_primary_container || fg
    readonly property color onSurface: fg
    readonly property color fgVariant: fgDim
    readonly property color fgMuted: fgFaint
    readonly property color outlineVariant: outline
    // ── formas Nothing OS ──
    readonly property int shapeXs: 6
    readonly property int shapeSm: 10
    readonly property int shapeMd: 14
    readonly property int shapeLg: 18
    readonly property int shapeXl: 26
    readonly property int shapePill: 9999
    // ── tipografía y tamaños ──
    readonly property int displayLarge: 40
    readonly property int displaySmall: 22
    readonly property int titleMedium: 16
    readonly property int titleSmall: 14
    readonly property int bodyMedium: 13
    readonly property int bodySmall: 12
    readonly property int labelMedium: 11
    readonly property int labelSmall: 10
    readonly property real labelSpacing: 1.2
    // ── fuentes Nothing OS ──
    readonly property FontLoader
    cargaNumeros: FontLoader {
        source: "fonts/ndot-47-inspired-by-nothing.otf"
    }

    readonly property FontLoader
    cargaUi: FontLoader {
        source: "fonts/SpaceGrotesk.ttf"
    }

    readonly property FontLoader
    cargaIconos: FontLoader {
        source: "fonts/MaterialSymbolsRounded.ttf"
    }

    readonly property string font: Cfg.fuenteUi || cargaUi.name || "Space Grotesk"
    readonly property string fontDots: Cfg.fuenteNumeros || cargaNumeros.name || "NDOT 47 (inspired by NOTHING)"
    readonly property string fontIcons: cargaIconos.name || "Material Symbols Rounded"
    readonly property string fontDisplay: fontDots
    readonly property string fontUi: font
    readonly property string fontIcon: fontIcons
    // ── movimiento ──
    readonly property var emphasized: [0.2, 0, 0, 1, 1, 1]
    readonly property var emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
    readonly property var standard: [0.2, 0, 0, 1, 1, 1]
    readonly property int durShort: 180
    readonly property int durMedium: 280
    readonly property int durLong: 380
    readonly property real stateHover: 0.1
    readonly property real statePressed: 0.16
    // ── medidas de la isla ──
    readonly property int collapsedHeight: 38
    readonly property int expandedHeight: 502
    readonly property int collapsedWidth: 490
    readonly property int expandedWidth: 580
    readonly property int notifStrip: 62
    readonly property int expandedRadius: shapeXl
    readonly property int topGap: 8

    function updateFromTokens() {
        try {
            let txt = colorWatcher.text();
            if (txt && txt.trim().length > 0)
                root.matugenColors = JSON.parse(txt);

        } catch (e) {
            console.warn("Error parsing colors.json in bar Theme:", e);
        }
    }

    function mezcla(a, b, t) {
        return Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, 1);
    }

    function brillo(c) {
        return 0.299 * c.r + 0.587 * c.g + 0.114 * c.b;
    }

    Component.onCompleted: {
        root.updateFromTokens();
    }
}
