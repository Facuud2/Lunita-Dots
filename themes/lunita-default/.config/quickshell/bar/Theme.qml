pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "."

QtObject {
    id: root

    property var colorWatcher: FileView {
        path: Quickshell.env("HOME") + "/.config/quickshell/colors.json"
        onLoaded: root.updateFromTokens()
        onFileChanged: root.updateFromTokens()
    }

    function updateFromTokens() {
        // Reserved for dynamic matugen colors
    }

    // ── Nothing OS Strict Monochrome Palette ──
    readonly property color bg: "#0B0B0B"
    readonly property color surface: "#161616"
    readonly property color surfaceAlt: "#1A1A1A"
    readonly property color surfaceHigh: "#242424"
    readonly property color surfaceTop: "#2A2A2A"

    readonly property color inverted: "#FFFFFF"
    readonly property color invertedFg: "#000000"

    readonly property color fg: "#FFFFFF"
    readonly property color fgDim: Qt.rgba(1, 1, 1, 0.60)
    readonly property color fgFaint: Qt.rgba(1, 1, 1, 0.30)
    readonly property color outline: "#1A1A1A"

    readonly property color alert: "#D71921"
    readonly property color accent: "#FFFFFF"

    function mezcla(a, b, t) {
        return Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, 1);
    }

    function brillo(c) {
        return 0.299 * c.r + 0.587 * c.g + 0.114 * c.b;
    }

    // aliases para compatibilidad con Nothing Island
    readonly property color primary: fg
    readonly property color primaryFg: invertedFg
    readonly property color secondary: fgDim
    readonly property color tertiary: fgDim
    readonly property color error: alert

    readonly property color containerLowest: bg
    readonly property color containerLow: surface
    readonly property color container: surface
    readonly property color containerHigh: surfaceAlt
    readonly property color containerHighest: surfaceHigh
    readonly property color primaryContainer: surfaceAlt
    readonly property color primaryContainerFg: fg

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
    readonly property FontLoader cargaNumeros: FontLoader {
        source: "fonts/ndot-47-inspired-by-nothing.otf"
    }
    readonly property FontLoader cargaUi: FontLoader {
        source: "fonts/SpaceGrotesk.ttf"
    }
    readonly property FontLoader cargaIconos: FontLoader {
        source: "fonts/MaterialSymbolsRounded.ttf"
    }

    readonly property string font: Cfg.fuenteUi || cargaUi.name || "Space Grotesk"
    readonly property string fontDots: Cfg.fuenteNumeros || cargaNumeros.name || "NDOT 47 (inspired by NOTHING)"
    readonly property string fontIcons: cargaIconos.name || "Material Symbols Rounded"

    readonly property string fontDisplay: fontDots
    readonly property string fontUi: font
    readonly property string fontIcon: fontIcons

    // ── movimiento ──
    readonly property var emphasized: [0.2, 0.0, 0.0, 1.0, 1.0, 1.0]
    readonly property var emphasizedDecel: [0.05, 0.7, 0.1, 1.0, 1.0, 1.0]
    readonly property var standard: [0.2, 0.0, 0.0, 1.0, 1.0, 1.0]

    readonly property int durShort: 180
    readonly property int durMedium: 280
    readonly property int durLong: 380

    readonly property real stateHover: 0.10
    readonly property real statePressed: 0.16

    // ── medidas de la isla ──
    readonly property int collapsedHeight: 38
    readonly property int expandedHeight: 502
    readonly property int collapsedWidth: 490
    readonly property int expandedWidth: 580
    readonly property int notifStrip: 62
    readonly property int expandedRadius: shapeXl
    readonly property int topGap: 8
}
