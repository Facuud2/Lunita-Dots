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
        return "apple";
    }
    readonly property bool isNothing: name === "nothing"

    // ── Tipografías Nothing ──
    // NDOT 47 viaja con la Dynamic Island de lunita-default; Doto es el
    // respaldo dot-matrix instalado en el sistema.
    property FontLoader ndotLoader: FontLoader {
        source: isNothing ? ("file://" + Quickshell.env("HOME") + "/.config/quickshell/bar/fonts/ndot-47-inspired-by-nothing.otf") : ""
    }
    readonly property string fontFigure: ndotLoader.status === FontLoader.Ready ? ndotLoader.name : "Doto"
    readonly property string fontText: "Space Grotesk"

    // ── Paleta Nothing: monocromo base + acentos cromáticos funcionales ──
    // Superficie plana opaca con relieve por tono (card → raised)
    readonly property color card: isDarkTheme ? "#111111" : "#F2F2F2"
    readonly property color cardBorder: "transparent"
    readonly property color raised: isDarkTheme ? "#1C1C1C" : "#E4E4E4"
    readonly property color surface: raised
    readonly property color ink: isDarkTheme ? "#F5F5F5" : "#0A0A0A"
    readonly property color inkDim: isDarkTheme ? "#8F8F8F" : "#5C5C5C"
    readonly property color dotOff: isDarkTheme ? "#2C2C2C" : "#CFCFCF"

    // ── Acentos Funcionales NothingOS (tonalidad Nothing vibrante y equilibrada) ──
    readonly property color signal: "#D71921"       // Rojo icónico Nothing
    readonly property color amber: "#FF6B00"        // Ámbar Nothing (calidez, advertencia, sol)
    readonly property color yellow: "#F5D020"       // Amarillo Nothing (notas, rayo)
    readonly property color green: "#00E599"        // Menta / Cyber Green Nothing (batería, git, conectado)
    readonly property color cyan: "#00D2FF"         // Azul Hielo / Cyan Nothing (red, agua, disco)
    readonly property color purple: "#A78BFA"       // Lavanda Nothing (multimedia, eventos)

    // Superficie invertida (papel de notas): blanco con tinta negra.
    readonly property color paper: "#F5F5F5"
    readonly property color paperInk: "#0A0A0A"
    readonly property color paperDim: "#6B6B6B"
    readonly property color paperDot: "#D4D4D4"

    // ── Geometría ──
    readonly property int radius: 24
    readonly property int radiusCard: radius
    readonly property int pad: 16
    readonly property int gap: 8

    // ── Escala tipográfica (tres tamaños hacen el trabajo visible) ──
    readonly property int sizeLabel: 12
    readonly property int sizeBody: 14
    readonly property int sizeFigureS: 34
    readonly property int sizeFigureM: 48
    readonly property int sizeFigureL: 64
}
