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
    property var clipboardList: []
    property bool isSearching: false

    property bool isDarkTheme: true
    Process {
        id: themeMonitor
        running: true
        command: ["bash", "-c", "if [ -f $HOME/.config/lunita/color_scheme ]; then cat $HOME/.config/lunita/color_scheme; else gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || echo 'prefer-dark'; fi"]
        stdout: SplitParser {
            onRead: data => {
                var str = data.trim().toLowerCase();
                root.isDarkTheme = str.indexOf("light") === -1;
            }
        }
    }

    // ── Nothing OS / Lunita Default Styling Tokens ──
    readonly property color panelBgColor: "#0B0B0B"
    readonly property color panelInnerSheen: Qt.rgba(1, 1, 1, 0.05)
    readonly property color panelBorderColor: "#1A1A1A"
    readonly property color panelShadowColor: Qt.rgba(0, 0, 0, 0.85)

    readonly property color textColor: "#FFFFFF"
    readonly property color textDimColor: Qt.rgba(1, 1, 1, 0.60)
    readonly property color dividerColor: "#1A1A1A"

    // Row highlights
    readonly property color itemHoverBg: "#1E1E1E"
    readonly property color selectedBgColor: "#FFFFFF"
    readonly property color selectedBorderColor: "transparent"
    readonly property color selectedTextColor: "#000000"
    readonly property color selectedSubColor: Qt.rgba(0, 0, 0, 0.70)

    // Action button badge
    readonly property color copyBtnBg: "#242424"

    // Menu styling
    readonly property color menuBgColor: "#161616"
    readonly property color menuBorderColor: "#1A1A1A"

    // Current selected item helper
    readonly property var currentItem: (clipboardList && clipboardList.length > selectedIndex && selectedIndex >= 0) ? clipboardList[selectedIndex] : null

    function getScriptPath() {
        return Quickshell.env("HOME") + "/.config/quickshell/clipboard/scripts/clipboard_manager.py";
    }


    // ── Debounce Timer for Search / Refresh ──
    Timer {
        id: searchDebounce
        interval: 25
        repeat: false
        onTriggered: {
            listProc.running = false;
            listProc.command = ["python3", root.getScriptPath(), "list", root.searchQuery];
            listProc.running = true;
        }
    }

    Timer {
        id: refreshAfterActionTimer
        interval: 120
        repeat: false
        onTriggered: {
            listProc.running = false;
            listProc.command = ["python3", root.getScriptPath(), "list", root.searchQuery];
            listProc.running = true;
        }
    }

    // ── Process to Fetch Clipboard List ──
    Process {
        id: listProc
        stdout: SplitParser {
            onRead: text => {
                try {
                    var parsed = JSON.parse(text);
                    if (parsed && parsed.items !== undefined) {
                        root.clipboardList = parsed.items;
                        if (root.selectedIndex >= parsed.items.length) {
                            root.selectedIndex = 0;
                        }
                    }
                } catch(e) {}
            }
        }
    }

    onSearchQueryChanged: {
        selectedIndex = 0;
        searchDebounce.restart();
    }

    // ── Navigation & Actions ──
    function moveSelectionDown() {
        if (!clipboardList || clipboardList.length === 0) return;
        if (selectedIndex < clipboardList.length - 1) {
            selectedIndex++;
        } else {
            selectedIndex = 0;
        }
    }

    function moveSelectionUp() {
        if (!clipboardList || clipboardList.length === 0) return;
        if (selectedIndex > 0) {
            selectedIndex--;
        } else {
            selectedIndex = clipboardList.length - 1;
        }
    }

    function selectIndex(idx) {
        if (idx >= 0 && idx < clipboardList.length) {
            selectedIndex = idx;
        }
    }

    function activateCurrentItem() {
        var it = currentItem;
        if (!it) return;
        closeClipboard();
        Quickshell.execDetached(["python3", getScriptPath(), "paste", it.id]);
    }

    function copyItem(itemId) {
        if (!itemId) {
            var it = currentItem;
            if (it) itemId = it.id;
        }
        if (!itemId) return;
        Quickshell.execDetached(["python3", getScriptPath(), "copy", itemId]);
        Quickshell.execDetached(["bash", "-c", "notify-send -a 'Portapapeles' -i edit-copy 'Portapapeles' 'Copiado al portapapeles'"]);
        closeClipboard();
    }

    function deleteCurrentItem() {
        var it = currentItem;
        if (!it) return;
        deleteItem(it.id);
    }

    function deleteItem(itemId) {
        if (!itemId) return;
        Quickshell.execDetached(["python3", getScriptPath(), "delete", itemId]);
        var updated = [];
        for (var i = 0; i < clipboardList.length; i++) {
            if (clipboardList[i].id !== itemId) {
                updated.push(clipboardList[i]);
            }
        }
        clipboardList = updated;
        if (selectedIndex >= clipboardList.length) {
            selectedIndex = Math.max(0, clipboardList.length - 1);
        }
        refreshAfterActionTimer.restart();
    }

    function clearAll() {
        Quickshell.execDetached(["python3", getScriptPath(), "clear"]);
        clipboardList = [];
        selectedIndex = 0;
        Quickshell.execDetached(["bash", "-c", "notify-send -a 'Portapapeles' 'Portapapeles' 'Historial limpiado completamente'"]);
        closeClipboard();
    }

    function openClipboard() {
        root.searchQuery = "";
        root.selectedIndex = 0;
        root.isOpen = true;
        root.windowVisible = true;
        searchDebounce.restart();
    }

    function closeClipboard() {
        root.isOpen = false;
        root.windowVisible = false;
        root.searchQuery = "";
    }

    function toggleClipboard() {
        if (root.isOpen) {
            closeClipboard();
        } else {
            openClipboard();
        }
    }

    Component.onCompleted: {
        searchDebounce.restart();
    }
}
