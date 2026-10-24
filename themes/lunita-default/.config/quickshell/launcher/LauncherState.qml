import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property bool isOpen: false
    property string activeTab: "apps" // "apps" | "links"
    property bool searchMode: false
    property string searchQuery: ""
    property int selectedIndex: 0
    property int searchSelectedIndex: 0
    // Animación de deslizamiento fluido de izquierda a derecha y opacidad
    property real visualXOffset: -80
    property real visualOpacity: 0
    // Información del sistema para los indicadores estilo Rofi / BSPWM Rice
    property string defaultBrowser: "zen-browser"
    property string ramUsageStr: ""
    // ── Detección del Navegador y Memoria RAM ──
    property var sysInfoProc

    sysInfoProc: Process {
        id: sysProc

        command: ["bash", "-c", "echo $(xdg-settings get default-web-browser 2>/dev/null | sed 's/.desktop//') '|' $(free -h | awk '/Mem:/ {print $3 \"/\" $2}')"]
        running: false

        stdout: SplitParser {
            onRead: (data) => {
                if (data && data.trim()) {
                    let parts = data.trim().split("|");
                    if (parts.length >= 2) {
                        let b = parts[0].trim();
                        root.defaultBrowser = b ? b : "zen-browser";
                        root.ramUsageStr = parts[1].trim();
                    }
                }
            }
        }

    }

    // ── Colores Dinámicos extraídos de Matugen (~/.config/quickshell/colors.json) ──
    property var matugenColors: ({
    })
    // Colores reactivos a Matugen
    readonly property color panelBg: matugenColors.surface || "#131318"
    readonly property color panelBorder: matugenColors.primary || "#c0c1ff"
    readonly property color cellBg: matugenColors.surface_container || "#1f1f25"
    readonly property color cellHoverBg: matugenColors.surface_container_high || "#2a292f"
    readonly property color cellSelectedBg: matugenColors.primary || "#c0c1ff"
    readonly property color cellBorder: matugenColors.outline_variant || Qt.rgba(1, 1, 1, 0.08)
    readonly property color accentColor: matugenColors.primary || "#c0c1ff"
    readonly property color accentFg: matugenColors.on_primary || "#292a60"
    readonly property color fgColor: matugenColors.on_surface || "#e4e1e9"
    readonly property color fgDimColor: matugenColors.on_surface_variant || "#c8c5d0"
    readonly property color fgFaintColor: matugenColors.outline || Qt.rgba(189 / 255, 189 / 255, 189 / 255, 0.35)
    // ── Tipografías e Iconos auténticos (Feather & Symbols Nerd Font & Comfortaa) ──
    readonly property FontLoader
    cargaFeather: FontLoader {
        source: "fonts/feather.ttf"
    }

    readonly property FontLoader
    cargaSymbols: FontLoader {
        source: "fonts/SymbolsNerdFont.ttf"
    }

    readonly property FontLoader
    cargaComfortaa: FontLoader {
        source: "fonts/Comfortaa.ttf"
    }

    readonly property FontLoader
    cargaUi: FontLoader {
        source: "fonts/SpaceGrotesk.ttf"
    }

    readonly property string fontFeather: cargaFeather.name || "feather"
    readonly property string fontSymbols: cargaSymbols.name || "Symbols Nerd Font"
    readonly property string fontComfortaa: cargaComfortaa.name || "Comfortaa"
    readonly property string fontUi: cargaUi.name || "Space Grotesk"
    // ── Aplicaciones Instaladas ──
    property var installedApps: []
    property var scanProc

    scanProc: Process {
        id: appsProc

        command: ["python3", Quickshell.env("HOME") + "/.config/quickshell/launcher/scripts/apps.py"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                try {
                    let parsed = JSON.parse(data || "[]");
                    if (Array.isArray(parsed) && parsed.length > 0)
                        root.installedApps = parsed;

                } catch (e) {
                }
            }
        }

    }

    // Filtro de aplicaciones en tiempo real
    readonly property var filteredApps: {
        const q = root.searchQuery.trim().toLowerCase();
        if (q === "")
            return root.installedApps.slice(0, 50);

        const scored = [];
        for (var i = 0; i < root.installedApps.length; i++) {
            const app = root.installedApps[i];
            const name = (app.name || "").toLowerCase();
            const generic = (app.generic || "").toLowerCase();
            let score = -1;
            if (name.startsWith(q))
                score = 100 - name.length;
            else if (name.indexOf(q) !== -1)
                score = 50 - name.indexOf(q);
            else if (generic.indexOf(q) !== -1)
                score = 20;
            if (score >= 0)
                scored.push({
                    "app": app,
                    "score": score
                });

        }
        scored.sort((a, b) => {
            if (b.score !== a.score)
                return b.score - a.score;

            return (a.app.name || "").localeCompare(b.app.name || "");
        });
        return scored.slice(0, 50).map((s) => {
            return s.app;
        });
    }

    function loadColors() {
        try {
            let txt = colorsWatcher.text();
            if (txt && txt.trim().length > 0)
                root.matugenColors = JSON.parse(txt);

        } catch (e) {
            console.warn("Error parsing colors.json:", e);
        }
    }

    function loadAppsJson() {
        try {
            let txt = appsJsonFile.text();
            if (txt && txt.trim().length > 0) {
                let parsed = JSON.parse(txt);
                if (Array.isArray(parsed) && parsed.length > 0)
                    root.installedApps = parsed;

            }
        } catch (e) {
        }
    }

    // ── Acciones y Control de Flujo ──────────────────────────────────────────
    function toggleLauncher() {
        if (isOpen)
            closeLauncher();
        else
            openLauncher();
    }

    function openLauncher() {
        colorsWatcher.reload();
        root.loadColors();
        root.loadAppsJson();
        scanProc.running = true;
        sysProc.running = true;
        searchMode = false;
        searchQuery = "";
        selectedIndex = 0;
        searchSelectedIndex = 0;
        isOpen = true;
        visualXOffset = -80;
        visualOpacity = 0;
        openSlideAnim.restart();
    }

    function closeLauncher() {
        if (!isOpen)
            return ;

        closeSlideAnim.restart();
    }

    function switchTab(tab) {
        if (activeTab !== tab) {
            activeTab = tab;
            selectedIndex = 0;
        }
    }

    function openSearch(initialText) {
        searchMode = true;
        searchQuery = initialText || "";
        searchSelectedIndex = 0;
    }

    function closeSearch() {
        searchMode = false;
        searchQuery = "";
        selectedIndex = 0;
    }

    function quote(s) {
        return "'" + String(s).replace(/'/g, "'\\''") + "'";
    }

    function launchSelectedApp(app) {
        if (!app)
            return ;

        var cmd = "gio launch " + quote(app.path) + " 2>/dev/null || gtk-launch " + quote(app.name) + " 2>/dev/null &";
        Quickshell.execDetached(["bash", "-c", cmd]);
        closeLauncher();
    }

    function launchCommand(cmd) {
        if (!cmd)
            return ;

        Quickshell.execDetached(["bash", "-c", cmd + " &"]);
        closeLauncher();
    }

    Component.onCompleted: {
        root.loadColors();
    }
    onSearchQueryChanged: {
        searchSelectedIndex = 0;
    }
    FileView {
        id: colorsWatcher

        path: Quickshell.env("HOME") + "/.config/quickshell/colors.json"
        watchChanges: true
        onLoaded: root.loadColors()
        onFileChanged: colorsWatcher.reload()
        onTextChanged: root.loadColors()
    }

    FileView {
        id: appsJsonFile

        path: Quickshell.env("HOME") + "/.cache/quickshell_launcher_apps.json"
        watchChanges: true
        onLoaded: root.loadAppsJson()
        onFileChanged: root.loadAppsJson()
    }

    // ── Animación Fluida de Izquierda a Derecha (Slide In / Slide Out) ──
    SequentialAnimation {
        id: openSlideAnim

        PauseAnimation {
            duration: 15
        }

        ParallelAnimation {
            NumberAnimation {
                target: root
                property: "visualXOffset"
                from: -80
                to: 0
                duration: 250
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                target: root
                property: "visualOpacity"
                from: 0
                to: 1
                duration: 200
                easing.type: Easing.OutCubic
            }

        }

    }

    ParallelAnimation {
        id: closeSlideAnim

        onFinished: {
            root.isOpen = false;
            root.searchMode = false;
            root.searchQuery = "";
        }

        NumberAnimation {
            target: root
            property: "visualXOffset"
            to: -80
            duration: 180
            easing.type: Easing.InCubic
        }

        NumberAnimation {
            target: root
            property: "visualOpacity"
            to: 0
            duration: 150
            easing.type: Easing.InQuad
        }

    }

}
