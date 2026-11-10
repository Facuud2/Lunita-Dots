import QtQuick
import Quickshell

// ════════════════════════════════════════════════════════════════════════
// WidgetSkin — Capa estética intercambiable de los widgets de escritorio.
//
// Los widgets comparten TODA su lógica (providers, IPC, gestos, notas) y
// solo consultan este objeto para decidir su apariencia. Cada tema declara
// su skin en theme.json → active_tokens.json (`widgets.skin`):
//   • "nothing" → lunita-default (NothingOS: monocromo + rojo, dot-matrix)
//   • "apple"   → macOS (diseño original, valor por defecto)
//   • "fluent"  → reservado para modern-win11-theme
// ════════════════════════════════════════════════════════════════════════
QtObject {
    id: skin

    property string activeThemeId: ""
    property var widgetTokens: ({})
    property bool isDarkTheme: true

    // ── Resolución del skin activo ──
    readonly property string name: {
        if (widgetTokens && widgetTokens.skin)
            return widgetTokens.skin;
        if (activeThemeId === "lunita-default")
            return "nothing";
        if (activeThemeId === "modern-win11-theme")
            return "fluent";
        return "apple";
    }
    readonly property bool isNothing: name === "nothing"
    readonly property bool isFluent: name === "fluent"
    readonly property bool isApple: name === "apple"

    // ── Tipografías ──
    property FontLoader ndotLoader: FontLoader {
        source: isNothing ? ("file://" + Quickshell.env("HOME") + "/.config/quickshell/bar/fonts/ndot-47-inspired-by-nothing.otf") : ""
    }
    readonly property string fontFigure: {
        if (isNothing)
            return ndotLoader.status === FontLoader.Ready ? ndotLoader.name : "Doto";
        if (isFluent)
            return "Segoe UI Variable Display, Segoe UI, sans-serif";
        return "SF Pro Display, Inter, sans-serif";
    }
    readonly property string fontText: {
        if (isNothing)
            return "Space Grotesk";
        if (isFluent)
            return "Segoe UI Variable Text, Segoe UI, sans-serif";
        return "SF Pro Text, -apple-system, sans-serif";
    }

    // ── Superficies y Fondos ──
    readonly property color card: {
        if (isNothing)
            return isDarkTheme ? "#111111" : "#F2F2F2";
        if (isFluent)
            return isDarkTheme ? Qt.rgba(32 / 255, 32 / 255, 32 / 255, 0.90) : Qt.rgba(243 / 255, 243 / 255, 243 / 255, 0.90);
        return isDarkTheme ? Qt.rgba(0.12, 0.14, 0.18, 0.75) : Qt.rgba(0.98, 0.98, 1, 0.82);
    }
    readonly property color cardBorder: {
        if (isNothing)
            return "transparent";
        if (isFluent)
            return isDarkTheme ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.08);
        return isDarkTheme ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.12);
    }
    readonly property color raised: {
        if (isNothing)
            return isDarkTheme ? "#1C1C1C" : "#E4E4E4";
        if (isFluent)
            return isDarkTheme ? Qt.rgba(1, 1, 1, 0.055) : Qt.rgba(1, 1, 1, 0.65);
        return isDarkTheme ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.06);
    }
    readonly property color surface: raised
    readonly property color surfaceHover: {
        if (isNothing)
            return isDarkTheme ? "#2A2A2A" : "#DCDCDC";
        if (isFluent)
            return isDarkTheme ? Qt.rgba(1, 1, 1, 0.09) : Qt.rgba(0, 0, 0, 0.05);
        return isDarkTheme ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.08);
    }
    readonly property color surfacePressed: {
        if (isNothing)
            return isDarkTheme ? "#141414" : "#EBEBEB";
        if (isFluent)
            return isDarkTheme ? Qt.rgba(1, 1, 1, 0.035) : Qt.rgba(0, 0, 0, 0.08);
        return isDarkTheme ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(0, 0, 0, 0.12);
    }
    readonly property color ink: {
        if (isNothing)
            return isDarkTheme ? "#F5F5F5" : "#0A0A0A";
        if (isFluent)
            return isDarkTheme ? "#FFFFFF" : "#1A1A1A";
        return isDarkTheme ? "#FFFFFF" : "#1D1D1F";
    }
    readonly property color inkDim: {
        if (isNothing)
            return isDarkTheme ? "#8F8F8F" : "#5C5C5C";
        if (isFluent)
            return isDarkTheme ? "#94A3B8" : "#5C5C5C";
        return isDarkTheme ? Qt.rgba(1, 1, 1, 0.60) : Qt.rgba(0.11, 0.11, 0.12, 0.60);
    }
    readonly property color inkMuted: {
        if (isNothing)
            return isDarkTheme ? "#5A5A5A" : "#8A8A8A";
        if (isFluent)
            return isDarkTheme ? Qt.rgba(1, 1, 1, 0.44) : Qt.rgba(0, 0, 0, 0.44);
        return isDarkTheme ? Qt.rgba(1, 1, 1, 0.40) : Qt.rgba(0, 0, 0, 0.40);
    }
    readonly property color dotOff: {
        if (isNothing)
            return isDarkTheme ? "#2C2C2C" : "#CFCFCF";
        if (isFluent)
            return isDarkTheme ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(0, 0, 0, 0.10);
        return isDarkTheme ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.12);
    }

    // ── Acentos Funcionales ──
    readonly property color signal: isNothing ? "#D71921" : (isFluent ? "#0078D4" : "#007AFF")
    readonly property color accent: signal
    readonly property color accentHover: isNothing ? "#FF3B44" : (isFluent ? "#60CDFF" : "#409CFF")
    readonly property color accentActive: isNothing ? "#B5141B" : (isFluent ? "#005A9E" : "#0051A8")
    readonly property color amber: isNothing ? "#FF6B00" : (isFluent ? "#F7630C" : "#FF9F0A")
    readonly property color yellow: isNothing ? "#F5D020" : (isFluent ? "#FCE100" : "#FFD60A")
    readonly property color green: isNothing ? "#00E599" : (isFluent ? "#6CCB5F" : "#30D158")
    readonly property color cyan: isNothing ? "#00D2FF" : (isFluent ? "#00B7C3" : "#64D2FF")
    readonly property color purple: isNothing ? "#A78BFA" : (isFluent ? "#B146C2" : "#BF5AF2")
    readonly property color red: isNothing ? "#D71921" : (isFluent ? "#E81123" : "#FF453A")

    // Superficie invertida / papel de notas
    readonly property color paper: isNothing ? "#F5F5F5" : (isFluent ? (isDarkTheme ? "#252525" : "#FFF9D2") : "#FFFFFF")
    readonly property color paperInk: isNothing ? "#0A0A0A" : (isFluent ? (isDarkTheme ? "#FFFFFF" : "#1A1A1A") : "#000000")
    readonly property color paperDim: isNothing ? "#6B6B6B" : (isFluent ? (isDarkTheme ? "#94A3B8" : "#6B6B6B") : "#8E8E93")
    readonly property color paperDot: isNothing ? "#D4D4D4" : (isFluent ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.10))

    // ── Geometría ──
    readonly property int radius: isNothing ? 24 : (isFluent ? 10 : 22)
    readonly property int radiusCard: radius
    readonly property int radiusControl: isNothing ? 12 : (isFluent ? 6 : 10)
    readonly property int pad: isNothing ? 16 : (isFluent ? 14 : 16)
    readonly property int gap: 8

    // ── Escala tipográfica ──
    readonly property int sizeLabel: 12
    readonly property int sizeBody: 14
    readonly property int sizeFigureS: 34
    readonly property int sizeFigureM: 48
    readonly property int sizeFigureL: 64
}
