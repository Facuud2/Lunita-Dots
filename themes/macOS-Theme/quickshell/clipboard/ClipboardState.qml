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

    // ── Theme Color Tokens Matching Reference Image Exactly ──
    // Translucent vibrant frosted cyan / aqua glass sampled from reference
    readonly property color panelBgColor: Qt.rgba(0.42, 0.80, 0.92, 0.62)
    readonly property color panelInnerSheen: Qt.rgba(1, 1, 1, 0.45)
    readonly property color panelBorderColor: Qt.rgba(1, 1, 1, 0.35)
    readonly property color panelShadowColor: Qt.rgba(0, 0, 0, 0.25)

    // Deep teal/navy readable text sampled from reference
    readonly property color textColor: "#053B55"
    readonly property color textDimColor: "#206888"
    readonly property color dividerColor: Qt.rgba(5, 59, 85, 0.12)

    // Row highlights
    readonly property color itemHoverBg: Qt.rgba(255, 255, 255, 0.16)
    readonly property color selectedBgColor: Qt.rgba(255, 255, 255, 0.28)
    readonly property color selectedBorderColor: Qt.rgba(255, 255, 255, 0.45)
    readonly property color selectedTextColor: "#022738"
    readonly property color selectedSubColor: "#134B62"

    // Action button badge
    readonly property color copyBtnBg: Qt.rgba(5, 59, 85, 0.35)

    // Menu styling
    readonly property color menuBgColor: Qt.rgba(0.85, 0.96, 0.99, 0.96)
    readonly property color menuBorderColor: Qt.rgba(5, 59, 85, 0.18)

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
