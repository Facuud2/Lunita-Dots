import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    // ── Visibility & Search State ──
    property bool isOpen: false
    property bool windowVisible: false
    property string searchQuery: ""
    property int selectedIndex: 0
    property var resultsList: []
    property bool isSearching: false

    // ── Theme State (macOS Light & Dark Mode) ──
    property bool isDarkTheme: true

    // Dynamic Theme Color Tokens
    readonly property color panelBgColor: isDarkTheme ? Qt.rgba(30/255, 30/255, 30/255, 0.65) : Qt.rgba(1, 1, 1, 0.70)
    readonly property color panelInnerSheen: isDarkTheme ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(1, 1, 1, 0.60)
    readonly property color panelBorderColor: isDarkTheme ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(1, 1, 1, 0.10)
    readonly property color panelShadowColor: isDarkTheme ? Qt.rgba(0, 0, 0, 0.70) : Qt.rgba(0, 0, 0, 0.28)

    readonly property color searchInputBg: isDarkTheme ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(0, 0, 0, 0.04)
    readonly property color searchInputText: isDarkTheme ? "#FFFFFF" : "#1D1D1F"
    readonly property color searchPlaceholderText: isDarkTheme ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.35)

    readonly property color textColor: isDarkTheme ? "#FFFFFF" : "#1D1D1F"
    readonly property color textDimColor: isDarkTheme ? Qt.rgba(1, 1, 1, 0.55) : Qt.rgba(0, 0, 0, 0.50)
    readonly property color categoryHeaderColor: isDarkTheme ? Qt.rgba(1, 1, 1, 0.42) : Qt.rgba(0, 0, 0, 0.42)
    readonly property color dividerColor: isDarkTheme ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.08)

    readonly property color itemHoverBg: isDarkTheme ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.05)
    readonly property color selectedBgColor: isDarkTheme ? "#0A84FF" : "#007AFF"
    readonly property color selectedTextColor: "#FFFFFF"
    readonly property color selectedSubColor: Qt.rgba(1, 1, 1, 0.82)

    readonly property color previewBgColor: isDarkTheme ? Qt.rgba(0.08, 0.09, 0.11, 0.45) : Qt.rgba(0, 0, 0, 0.03)
    readonly property color cardBgColor: isDarkTheme ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(0, 0, 0, 0.04)
    readonly property color cardBorderColor: isDarkTheme ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(0, 0, 0, 0.08)

    // Current selected item helper
    readonly property var currentItem: (resultsList && resultsList.length > selectedIndex && selectedIndex >= 0) ? resultsList[selectedIndex] : null

    // ── Animation Close Timer ──
    Timer {
        id: closeTimer
        interval: 200
        repeat: false
        onTriggered: {
            if (!root.isOpen) {
                root.windowVisible = false;
            }
        }
    }

    // ── Search Debounce Timer ──
    Timer {
        id: searchDebounce
        interval: 35
        repeat: false
        onTriggered: {
            searchProc.running = false;
            var scriptPath = Quickshell.env("HOME") + "/.config/quickshell/spotlight/scripts/spotlight_search.py";
            // Fallback to local repo path if not yet deployed to ~/.config
            searchProc.command = ["python3", scriptPath, root.searchQuery];
            searchProc.running = true;
        }
    }

    // ── Python Search Execution Process ──
    Process {
        id: searchProc
        stdout: SplitParser {
            onRead: text => {
                try {
                    var parsed = JSON.parse(text);
                    if (parsed && parsed.results !== undefined) {
                        root.resultsList = parsed.results;
                        if (root.selectedIndex >= parsed.results.length) {
                            root.selectedIndex = 0;
                        }
                    }
                } catch(e) {}
            }
        }
    }

    // ── History & Theme State Init ──
    Process {
        id: themeInitProc
        running: true
        command: ["bash", "-c", "if [ -f $HOME/.config/lunita/color_scheme ]; then cat $HOME/.config/lunita/color_scheme; else gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || echo 'prefer-dark'; fi"]
        stdout: SplitParser {
            onRead: data => {
                var str = data.trim().toLowerCase();
                root.isDarkTheme = str.indexOf("light") === -1;
            }
        }
    }

    // Trigger search whenever query changes
    onSearchQueryChanged: {
        selectedIndex = 0;
        searchDebounce.restart();
    }

    // ── Navigation & Actions ──
    function moveSelectionDown() {
        if (!resultsList || resultsList.length === 0) return;
        if (selectedIndex < resultsList.length - 1) {
            selectedIndex++;
        } else {
            selectedIndex = 0; // Wrap around
        }
    }

    function moveSelectionUp() {
        if (!resultsList || resultsList.length === 0) return;
        if (selectedIndex > 0) {
            selectedIndex--;
        } else {
            selectedIndex = resultsList.length - 1; // Wrap around
        }
    }

    function selectIndex(idx) {
        if (idx >= 0 && idx < resultsList.length) {
            selectedIndex = idx;
        }
    }

    function activateCurrentItem() {
        var it = currentItem;
        if (!it) return;
        
        if (it.action) {
            Quickshell.execDetached(["bash", "-c", it.action]);
        }
        
        if (it.type === "app" && it.metadata && it.metadata.path) {
            recordRecent(it.id.replace("app-", ""));
        }
        
        closeSpotlight();
    }

    function revealCurrentItem() {
        var it = currentItem;
        if (!it) return;
        
        if (it.revealAction) {
            Quickshell.execDetached(["bash", "-c", it.revealAction]);
            closeSpotlight();
        } else if (it.metadata && it.metadata.path) {
            Quickshell.execDetached(["bash", "-c", "dolphin --select '" + it.metadata.path + "'"]);
            closeSpotlight();
        }
    }

    function copyCurrentItem() {
        var it = currentItem;
        if (!it) return;

        var textToCopy = "";
        if (it.type === "calc" && it.metadata && it.metadata.result) {
            textToCopy = it.metadata.result;
        } else if (it.metadata && it.metadata.path) {
            textToCopy = it.metadata.path;
        } else if (it.subtitle) {
            textToCopy = it.subtitle;
        }

        if (textToCopy) {
            Quickshell.execDetached(["bash", "-c", "wl-copy '" + textToCopy + "' 2>/dev/null || xclip -selection clipboard <<< '" + textToCopy + "'; notify-send 'Spotlight' 'Copiado al portapapeles'"]);
            closeSpotlight();
        }
    }

    function recordRecent(appId) {
        var script = "python3 -c 'import os, json; p = os.path.expanduser(\"~/.config/lunita/spotlight-history.json\"); os.makedirs(os.path.dirname(p), exist_ok=True); data = [];\ntry:\n    with open(p, \"r\") as f: data = json.load(f)\nexcept: pass\ndata = [x for x in data if x != \"" + appId + "\"]\ndata.insert(0, \"" + appId + "\")\nwith open(p, \"w\") as f: json.dump(data[:20], f)'";
        Quickshell.execDetached(["bash", "-c", script]);
    }

    // ── Open / Close / Toggle ──
    function openSpotlight() {
        themeInitProc.running = true;
        closeTimer.stop();
        root.searchQuery = "";
        root.selectedIndex = 0;
        root.windowVisible = true;
        root.isOpen = true;
        searchDebounce.restart();
    }

    function closeSpotlight() {
        root.isOpen = false;
        root.searchQuery = "";
        closeTimer.restart();
    }

    function toggleSpotlight() {
        if (root.isOpen) {
            root.closeSpotlight();
        } else {
            root.openSpotlight();
        }
    }

    Component.onCompleted: {
        searchDebounce.restart();
    }
}
