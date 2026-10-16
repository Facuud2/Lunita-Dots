import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    // ── Visibility & Search State ──
    property bool isOpen: false
    property bool windowVisible: false
    property bool pendingOpen: false
    property string searchQuery: ""
    property int selectedIndex: 0
    property var clipboardList: []

    // ── Cursor & Active Window Tracking (Lunita-Default behavior) ──
    property int cardWidth: 460
    property int cardHeight: 480
    property int panelX: 120
    property int panelY: 100
    property string targetScreenName: ""
    property string lastFocusedAddress: ""
    property string lastFocusedClass: ""

    // ── Tipografías e Iconos Nothing OS / Lunita-Default ──
    readonly property FontLoader cargaNumeros: FontLoader {
        source: "fonts/ndot-47-inspired-by-nothing.otf"
    }
    readonly property FontLoader cargaUi: FontLoader {
        source: "fonts/SpaceGrotesk.ttf"
    }
    readonly property FontLoader cargaIconos: FontLoader {
        source: "fonts/MaterialSymbolsRounded.ttf"
    }

    readonly property string fontDots: cargaNumeros.name || "NDOT 47 (inspired by NOTHING)"
    readonly property string fontUi: cargaUi.name || "Space Grotesk"
    readonly property string fontIcons: cargaIconos.name || "Material Symbols Rounded"

    // ── Nothing OS / Lunita-Default Vivid Styling Tokens ──
    readonly property color panelBgColor: Qt.rgba(14 / 255, 15 / 255, 20 / 255, 0.97)
    readonly property color panelBorderColor: Qt.rgba(1.0, 0.22, 0.26, 0.42)
    readonly property color panelInnerBorderColor: Qt.rgba(1, 1, 1, 0.14)
    readonly property color backdropColor: "transparent"

    readonly property color accentRed: "#FF2430"
    readonly property color accentRedBright: "#FF4752"
    readonly property color textColor: "#FFFFFF"
    readonly property color textDimColor: Qt.rgba(1, 1, 1, 0.85)
    readonly property color textFaintColor: Qt.rgba(1, 1, 1, 0.62)
    readonly property color dividerColor: Qt.rgba(1, 1, 1, 0.14)

    // Header & Search tokens (Vivid)
    readonly property color titlePillBg: Qt.rgba(1.0, 0.14, 0.19, 0.22)
    readonly property color titlePillBorder: Qt.rgba(1.0, 0.25, 0.30, 0.55)
    readonly property color infoBadgeBg: Qt.rgba(1, 1, 1, 0.12)
    readonly property color infoBadgeBorder: Qt.rgba(1, 1, 1, 0.20)
    readonly property color headerBtnBg: Qt.rgba(1, 1, 1, 0.10)
    readonly property color headerBtnBorder: Qt.rgba(1, 1, 1, 0.18)
    readonly property color headerBtnHoverBg: Qt.rgba(1, 1, 1, 0.24)
    readonly property color headerBtnHoverBorder: Qt.rgba(1, 1, 1, 0.38)
    readonly property color clearBtnHoverBg: Qt.rgba(1.0, 0.14, 0.19, 0.35)
    readonly property color clearBtnHoverBorder: Qt.rgba(1.0, 0.25, 0.30, 0.65)

    readonly property color searchBgColor: Qt.rgba(26 / 255, 28 / 255, 36 / 255, 0.95)
    readonly property color searchBorderColor: Qt.rgba(1, 1, 1, 0.18)

    // Row highlights (Vivid)
    readonly property color rowBgColor: Qt.rgba(1, 1, 1, 0.06)
    readonly property color rowBorderColor: Qt.rgba(1, 1, 1, 0.09)
    readonly property color itemHoverBg: Qt.rgba(1, 1, 1, 0.13)
    readonly property color selectedBgColor: Qt.rgba(1.0, 0.14, 0.19, 0.20)
    readonly property color selectedBorderColor: Qt.rgba(1.0, 0.25, 0.30, 0.70)

    // Vivid Type Badges (Image, Code, Link, Text)
    readonly property color badgeImageBg: Qt.rgba(0.76, 0.24, 1.0, 0.28)
    readonly property color badgeImageFg: "#E580FF"
    readonly property color badgeImageBorder: Qt.rgba(0.85, 0.40, 1.0, 0.55)

    readonly property color badgeCodeBg: Qt.rgba(0.0, 0.72, 1.0, 0.28)
    readonly property color badgeCodeFg: "#38D0FF"
    readonly property color badgeCodeBorder: Qt.rgba(0.20, 0.80, 1.0, 0.55)

    readonly property color badgeLinkBg: Qt.rgba(0.0, 0.90, 0.46, 0.26)
    readonly property color badgeLinkFg: "#19F08A"
    readonly property color badgeLinkBorder: Qt.rgba(0.15, 0.95, 0.55, 0.55)

    readonly property color badgeTextBg: Qt.rgba(1.0, 0.20, 0.25, 0.25)
    readonly property color badgeTextFg: "#FF5C66"
    readonly property color badgeTextBorder: Qt.rgba(1.0, 0.32, 0.36, 0.52)

    // Row action buttons
    readonly property color actionBtnBg: Qt.rgba(1, 1, 1, 0.09)
    readonly property color actionBtnBorder: Qt.rgba(1, 1, 1, 0.16)
    readonly property color copyBtnHoverBg: Qt.rgba(0.0, 0.72, 1.0, 0.30)
    readonly property color copyBtnHoverBorder: Qt.rgba(0.20, 0.80, 1.0, 0.65)
    readonly property color delBtnHoverBg: Qt.rgba(1.0, 0.14, 0.19, 0.34)
    readonly property color delBtnHoverBorder: Qt.rgba(1.0, 0.25, 0.30, 0.65)

    // Footer key pills
    readonly property color keyPillBg: Qt.rgba(1, 1, 1, 0.12)
    readonly property color keyPillBorder: Qt.rgba(1, 1, 1, 0.22)

    // Current selected item helper
    readonly property var currentItem: (clipboardList && clipboardList.length > selectedIndex && selectedIndex >= 0) ? clipboardList[selectedIndex] : null

    function getScriptPath() {
        var localUrl = Qt.resolvedUrl("scripts/clipboard_manager.py").toString();
        if (localUrl.indexOf("file://") === 0) {
            return localUrl.substring(7);
        }
        return Quickshell.env("HOME") + "/.config/quickshell/clipboard/scripts/clipboard_manager.py";
    }

    // ── Capture Cursor Position & Focused Window BEFORE showing window ──
    Process {
        id: contextProbeProc
        command: [
            "python3",
            "-c",
            "import json, subprocess\n" +
            "res = {'x': 120, 'y': 100, 'addr': '', 'cls': '', 'mon': ''}\n" +
            "try:\n" +
            "    w = json.loads(subprocess.check_output(['hyprctl', 'activewindow', '-j'], text=True))\n" +
            "    res['addr'] = w.get('address', '') or ''\n" +
            "    res['cls'] = w.get('class', '') or w.get('initialClass', '') or ''\n" +
            "except Exception: pass\n" +
            "try:\n" +
            "    c = json.loads(subprocess.check_output(['hyprctl', 'cursorpos', '-j'], text=True))\n" +
            "    m_list = json.loads(subprocess.check_output(['hyprctl', 'monitors', '-j'], text=True))\n" +
            "    cx, cy = int(c.get('x', 960)), int(c.get('y', 540))\n" +
            "    mon = next((m for m in m_list if m['x'] <= cx < m['x'] + m['width'] and m['y'] <= cy < m['y'] + m['height']), None)\n" +
            "    if not mon and m_list:\n" +
            "        mon = next((m for m in m_list if m.get('focused')), m_list[0])\n" +
            "    if mon:\n" +
            "        res['mon'] = mon.get('name', '')\n" +
            "        mw, mh = int(mon.get('width', 1920)), int(mon.get('height', 1080))\n" +
            "        rx, ry = cx - int(mon.get('x', 0)), cy - int(mon.get('y', 0))\n" +
            "        cw, ch, pad = 460, 480, 16\n" +
            "        px = max(pad, rx - cw) if (rx + cw + pad > mw) else max(pad, rx)\n" +
            "        py = max(pad, ry - ch) if (ry + ch + pad > mh) else max(pad, ry)\n" +
            "        res['x'], res['y'] = px, py\n" +
            "except Exception: pass\n" +
            "print(json.dumps(res))"
        ]
        stdout: SplitParser {
            onRead: line => {
                try {
                    var data = JSON.parse(line);
                    if (typeof data.x === "number") root.panelX = data.x;
                    if (typeof data.y === "number") root.panelY = data.y;
                    if (data.mon) root.targetScreenName = data.mon;
                    root.lastFocusedAddress = data.addr || "";
                    root.lastFocusedClass = data.cls || "";
                } catch (e) {}
                if (root.pendingOpen) {
                    root.pendingOpen = false;
                    root.isOpen = true;
                    root.windowVisible = true;
                }
            }
        }
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
                } catch (e) {}
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
        pasteItem(it.id);
    }

    function pasteItem(itemId) {
        if (!itemId) return;
        var addr = root.lastFocusedAddress;
        var cls = root.lastFocusedClass;
        closeClipboard();
        Quickshell.execDetached(["python3", getScriptPath(), "paste", itemId, addr, cls]);
    }

    function copyItem(itemId) {
        if (!itemId) {
            var it = currentItem;
            if (it) itemId = it.id;
        }
        if (!itemId) return;
        pasteItem(itemId);
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
        searchQuery = "";
    }

    Timer {
        id: closeSurfaceTimer
        interval: 35
        repeat: false
        onTriggered: {
            if (!root.isOpen && !root.pendingOpen) {
                root.windowVisible = false;
            }
        }
    }

    function openClipboard() {
        closeSurfaceTimer.stop();
        root.isOpen = false;
        root.searchQuery = "";
        root.selectedIndex = 0;
        root.pendingOpen = true;
        contextProbeProc.running = false;
        contextProbeProc.running = true;
        searchDebounce.restart();
    }

    function closeClipboard() {
        root.pendingOpen = false;
        root.isOpen = false;
        root.searchQuery = "";
        closeSurfaceTimer.restart();
    }

    function toggleClipboard() {
        if (root.isOpen || root.pendingOpen) {
            closeClipboard();
        } else {
            openClipboard();
        }
    }

    Component.onCompleted: {
        searchDebounce.restart();
    }
}
