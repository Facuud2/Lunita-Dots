import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Item {
    id: root

    // ==========================================
    // 1. START BUTTON
    // ==========================================
    property var startApp: ({
        id: "start",
        name: "Inicio",
        icon: "win11-start.svg",
        cmd: "lunita-launcher || rofi -show drun",
        matchClasses: [],
        isStart: true,
        hasBadge: false
    })

    // ==========================================
    // 2. PINNED APPS PERSISTENCE & LISTMODELS
    // ==========================================
    readonly property string pinnedConfigPath: Quickshell.env("HOME") + "/.config/lunita/dock-win11-pinned.json"
    property var defaultPinnedList: [
        {
            id: "dolphin",
            name: "Explorador de archivos",
            icon: "win11-explorer.svg",
            cmd: "dolphin",
            matchClasses: ["dolphin", "org.kde.dolphin", "nautilus", "thunar"]
        },
        {
            id: "store",
            name: "Microsoft Store",
            icon: "win11-store.svg",
            cmd: "plasma-discover || pamac-manager",
            matchClasses: ["discover", "plasma-discover", "pamac-manager", "gnome-software"]
        },
        {
            id: "zen",
            name: "Zen Browser",
            icon: "image://icon/zen-browser",
            cmd: "zen-browser || zen",
            matchClasses: ["zen", "zen-browser"]
        },
        {
            id: "terminal",
            name: "Terminal",
            icon: "win11-terminal.svg",
            cmd: "kitty",
            matchClasses: ["kitty", "alacritty", "foot", "wezterm", "terminal"]
        }
    ]

    property var pinnedArray: []
    ListModel { id: pinnedAppsModel }
    property alias pinnedAppsModel: pinnedAppsModel

    // Running Unpinned Apps
    ListModel { id: unpinnedAppsModel }
    property alias unpinnedAppsModel: unpinnedAppsModel
    property alias openAppsModel: unpinnedAppsModel

    property var hyprClients: []
    property var openApps: []
    property string activeWindowAddress: ""
    property string activeWindowClass: ""

    // Context Menu State
    property bool contextMenuVisible: false
    property var contextMenuApp: null
    property real contextMenuX: 0
    property string contextMenuScreen: ""

    function openContextMenu(appObj, posX, screenName) {
        root.contextMenuApp = appObj;
        root.contextMenuX = posX;
        root.contextMenuScreen = screenName || "";
        root.contextMenuVisible = true;
    }

    function closeContextMenu() {
        root.contextMenuVisible = false;
        root.contextMenuApp = null;
        root.contextMenuScreen = "";
    }

    function focusAddress(addr, wsId) {
        if (!addr || addr === "") return;

        // Find workspace if not provided
        if (!wsId) {
            for (var i = 0; i < root.hyprClients.length; i++) {
                var cl = root.hyprClients[i];
                if (cl.address === addr) {
                    if (cl.workspace) wsId = cl.workspace.id || cl.workspace.name;
                    break;
                }
            }
        }

        var cmds = [];
        if (wsId) {
            cmds.push("hyprctl dispatch 'hl.dsp.focus({ workspace = " + wsId + " })' 2>/dev/null || hyprctl dispatch workspace " + wsId + " 2>/dev/null");
        }
        cmds.push("hyprctl dispatch 'hl.dsp.focus({ window = \"address:" + addr + "\" })' 2>/dev/null || hyprctl dispatch focuswindow address:" + addr + " 2>/dev/null");

        Quickshell.execDetached(["bash", "-c", cmds.join(" ; ")]);
    }

    // ── Persistence: Load Pinned Apps ──
    property bool isSelfSaving: false

    Timer {
        id: saveDebounceTimer
        interval: 1000
        repeat: false
        onTriggered: root.isSelfSaving = false
    }

    Process {
        id: initPinnedLoader
        command: ["bash", "-c", "cat ~/.config/lunita/dock-win11-pinned.json 2>/dev/null | tr '\\n' ' ' || echo '[]'"]
        running: true
        stdout: SplitParser {
            onRead: text => {
                root.parsePinnedJson(text);
            }
        }
    }

    FileView {
        id: pinnedConfigFile
        path: root.pinnedConfigPath
        watchChanges: true
        onLoaded: {
            root.parsePinnedJson(pinnedConfigFile.text());
        }
        onFileChanged: {
            if (!root.isSelfSaving) {
                root.parsePinnedJson(pinnedConfigFile.text());
            }
        }
    }

    function parsePinnedJson(raw) {
        if (!raw || raw.trim().length === 0) {
            if (root.pinnedArray.length === 0) {
                root.pinnedArray = root.defaultPinnedList;
                root.syncPinnedModel();
                root.savePinnedApps();
            }
            return;
        }
        try {
            var parsed = JSON.parse(raw);
            if (Array.isArray(parsed) && parsed.length > 0) {
                root.pinnedArray = parsed;
                root.syncPinnedModel();
                root.refreshClients();
            } else if (root.pinnedArray.length === 0) {
                root.pinnedArray = root.defaultPinnedList;
                root.syncPinnedModel();
                root.savePinnedApps();
            }
        } catch (e) {
            if (root.pinnedArray.length === 0) {
                root.pinnedArray = root.defaultPinnedList;
                root.syncPinnedModel();
            }
        }
    }

    function syncPinnedModel() {
        // 1. Remove deleted pinned apps
        for (var i = pinnedAppsModel.count - 1; i >= 0; i--) {
            var id = pinnedAppsModel.get(i).id;
            var found = false;
            for (var j = 0; j < root.pinnedArray.length; j++) {
                if (root.pinnedArray[j].id === id) { found = true; break; }
            }
            if (!found) pinnedAppsModel.remove(i);
        }

        // 2. Add, update, or reposition pinned items in place
        for (var k = 0; k < root.pinnedArray.length; k++) {
            var p = root.pinnedArray[k];
            var existing = -1;
            for (var m = 0; m < pinnedAppsModel.count; m++) {
                if (pinnedAppsModel.get(m).id === p.id) { existing = m; break; }
            }
            var mClasses = p.matchClasses || [p.id];
            if (existing !== -1) {
                if (existing !== k) {
                    pinnedAppsModel.move(existing, k, 1);
                }
                pinnedAppsModel.setProperty(k, "name", p.name || p.id);
                pinnedAppsModel.setProperty(k, "cmd", p.cmd || p.id);
                pinnedAppsModel.setProperty(k, "icon", p.icon || root.resolveAppIcon(p.id));
                pinnedAppsModel.setProperty(k, "matchClassesJson", JSON.stringify(mClasses));
            } else {
                pinnedAppsModel.insert(k, {
                    id: p.id,
                    clazz: p.id,
                    name: p.name || p.id,
                    title: p.name || p.id,
                    icon: p.icon || root.resolveAppIcon(p.id),
                    cmd: p.cmd || p.id,
                    matchClassesJson: JSON.stringify(mClasses),
                    isPinned: true,
                    isStart: false,
                    isRunning: false,
                    isFocused: false,
                    address: "",
                    windowsJson: "[]",
                    hasBadge: (p.id === "obs"),
                    isClosing: false
                });
            }
        }
    }

    function savePinnedApps() {
        if (!root.pinnedArray || root.pinnedArray.length === 0) return;
        root.isSelfSaving = true;
        saveDebounceTimer.restart();
        var jsonStr = JSON.stringify(root.pinnedArray, null, 2);
        var escaped = jsonStr.replace(/'/g, "'\\''");
        var cmd = "mkdir -p ~/.config/lunita && printf '%s\\n' '" + escaped + "' > ~/.config/lunita/dock-win11-pinned.json.tmp && mv -f ~/.config/lunita/dock-win11-pinned.json.tmp ~/.config/lunita/dock-win11-pinned.json";
        Quickshell.execDetached(["bash", "-c", cmd]);
    }

    function isPinned(appId) {
        if (!appId) return false;
        for (var i = 0; i < root.pinnedArray.length; i++) {
            if (root.pinnedArray[i].id === appId) return true;
        }
        return false;
    }

    function pinApp(appObj) {
        if (!appObj || !appObj.id) return;
        if (root.isPinned(appObj.id)) return;
        var mClasses = appObj.matchClasses || [appObj.id];
        var p = {
            id: appObj.id,
            name: appObj.name || appObj.title || appObj.id,
            icon: appObj.icon || root.resolveAppIcon(appObj.id),
            cmd: appObj.cmd || appObj.id,
            matchClasses: mClasses
        };
        root.pinnedArray.push(p);
        root.syncPinnedModel();
        root.savePinnedApps();
        root.refreshClients();
    }

    function unpinApp(appId) {
        if (!appId) return;
        var filtered = [];
        for (var i = 0; i < root.pinnedArray.length; i++) {
            if (root.pinnedArray[i].id !== appId) filtered.push(root.pinnedArray[i]);
        }
        root.pinnedArray = filtered;
        root.syncPinnedModel();
        root.savePinnedApps();
        root.refreshClients();
    }

    // ── Reordering & Moving Apps (Pinned & Unpinned) ──
    function getPinnedIndex(appId) {
        if (!appId) return -1;
        for (var i = 0; i < root.pinnedArray.length; i++) {
            if (root.pinnedArray[i].id === appId) return i;
        }
        return -1;
    }

    function getUnpinnedIndex(appId) {
        if (!appId) return -1;
        for (var i = 0; i < unpinnedAppsModel.count; i++) {
            if (unpinnedAppsModel.get(i).id === appId) return i;
        }
        return -1;
    }

    function reorderPinnedApp(sourceIdx, targetIdx) {
        if (sourceIdx === targetIdx || sourceIdx < 0 || targetIdx < 0 ||
            sourceIdx >= root.pinnedArray.length || targetIdx >= root.pinnedArray.length) return;
        var copy = root.pinnedArray.slice();
        var item = copy.splice(sourceIdx, 1)[0];
        copy.splice(targetIdx, 0, item);
        root.pinnedArray = copy;
        pinnedAppsModel.move(sourceIdx, targetIdx, 1);
        root.savePinnedApps();
    }

    function movePinnedApp(appId, steps) {
        var idx = root.getPinnedIndex(appId);
        if (idx === -1) return;
        var targetIdx = Math.max(0, Math.min(root.pinnedArray.length - 1, idx + steps));
        if (targetIdx !== idx) {
            root.reorderPinnedApp(idx, targetIdx);
        }
    }

    function reorderUnpinnedApp(sourceIdx, targetIdx) {
        if (sourceIdx === targetIdx || sourceIdx < 0 || targetIdx < 0 ||
            sourceIdx >= unpinnedAppsModel.count || targetIdx >= unpinnedAppsModel.count) return;
        unpinnedAppsModel.move(sourceIdx, targetIdx, 1);
    }

    function moveUnpinnedApp(appId, steps) {
        var idx = root.getUnpinnedIndex(appId);
        if (idx === -1) return;
        var targetIdx = Math.max(0, Math.min(unpinnedAppsModel.count - 1, idx + steps));
        if (targetIdx !== idx) {
            root.reorderUnpinnedApp(idx, targetIdx);
        }
    }

    function moveApp(appRef, steps) {
        if (!appRef) return;
        var id = (typeof appRef === "string") ? appRef : (appRef.id || appRef.clazz || "");
        if (!id || id === "start") return;
        if (root.isPinned(id)) {
            root.movePinnedApp(id, steps);
        } else {
            root.moveUnpinnedApp(id, steps);
        }
    }

    function canMoveLeft(appRef) {
        if (!appRef) return false;
        var id = (typeof appRef === "string") ? appRef : (appRef.id || appRef.clazz || "");
        if (!id || id === "start") return false;
        if (root.isPinned(id)) {
            return root.getPinnedIndex(id) > 0;
        } else {
            return root.getUnpinnedIndex(id) > 0;
        }
    }

    function canMoveRight(appRef) {
        if (!appRef) return false;
        var id = (typeof appRef === "string") ? appRef : (appRef.id || appRef.clazz || "");
        if (!id || id === "start") return false;
        if (root.isPinned(id)) {
            var pIdx = root.getPinnedIndex(id);
            return pIdx >= 0 && pIdx < root.pinnedArray.length - 1;
        } else {
            var uIdx = root.getUnpinnedIndex(id);
            return uIdx >= 0 && uIdx < unpinnedAppsModel.count - 1;
        }
    }

    // ── Live Drag & Drop Preview (Neighbors shift aside smoothly) ──
    property string draggingAppId: ""
    property int draggingSteps: 0
    property bool dragJustCommitted: false

    function setDragPreview(appId, steps) {
        root.dragJustCommitted = false;
        root.draggingAppId = appId;
        root.draggingSteps = steps;
    }

    function clearDragPreview() {
        root.draggingAppId = "";
        root.draggingSteps = 0;
    }

    function commitDrag(appId, steps) {
        if (steps !== 0 && appId) {
            root.dragJustCommitted = true;
            root.moveApp(appId, steps);
            Qt.callLater(function() {
                root.dragJustCommitted = false;
            });
        }
        root.draggingAppId = "";
        root.draggingSteps = 0;
    }

    function getNeighborShift(appId) {
        if (!root.draggingAppId || root.draggingAppId === "" || root.draggingAppId === appId) return 0;
        if (root.draggingSteps === 0) return 0;

        var dragIsPinned = root.isPinned(root.draggingAppId);
        var myIsPinned = root.isPinned(appId);
        if (dragIsPinned !== myIsPinned) return 0;

        if (dragIsPinned) {
            var dragIdx = root.getPinnedIndex(root.draggingAppId);
            var myIdx = root.getPinnedIndex(appId);
            if (dragIdx < 0 || myIdx < 0) return 0;

            if (root.draggingSteps > 0) {
                if (myIdx > dragIdx && myIdx <= dragIdx + root.draggingSteps) {
                    return -48;
                }
            } else if (root.draggingSteps < 0) {
                if (myIdx < dragIdx && myIdx >= dragIdx + root.draggingSteps) {
                    return 48;
                }
            }
        } else {
            var dragUIdx = root.getUnpinnedIndex(root.draggingAppId);
            var myUIdx = root.getUnpinnedIndex(appId);
            if (dragUIdx < 0 || myUIdx < 0) return 0;

            if (root.draggingSteps > 0) {
                if (myUIdx > dragUIdx && myUIdx <= dragUIdx + root.draggingSteps) {
                    return -48;
                }
            } else if (root.draggingSteps < 0) {
                if (myUIdx < dragUIdx && myUIdx >= dragUIdx + root.draggingSteps) {
                    return 48;
                }
            }
        }

        return 0;
    }

    // ── Ignored Clients & Hyprland Process Sync ──
    readonly property var ignoredClasses: [
        "quickshell",
        "rofi",
        "wlogout",
        "hyprlock",
        "waybar",
        "eww",
        "polkit-kde-authentication-agent-1",
        "polkit-gnome-authentication-agent-1",
        "blueman-applet",
        "nm-applet",
        "pinentry-qt",
        "pinentry-gtk-2",
        "gcr-prompter",
        "flameshot"
    ]

    function isClientIgnored(c) {
        if (!c) return true;
        if (c.hidden) return true;
        if (c.size && (c.size[0] <= 1 || c.size[1] <= 1)) return true;
        var cls = (c["class"] || "").toLowerCase();
        var icls = (c["initialClass"] || "").toLowerCase();
        if (!cls && !icls) return true;
        for (var i = 0; i < root.ignoredClasses.length; i++) {
            var ign = root.ignoredClasses[i].toLowerCase();
            if (cls === ign || icls === ign) return true;
        }
        if (cls.endsWith("-applet") || icls.endsWith("-applet") ||
            cls.endsWith("-tray") || icls.endsWith("-tray") ||
            cls.endsWith("-daemon") || icls.endsWith("-daemon")) {
            return true;
        }
        return false;
    }

    function refreshClients() {
        if (!clientProc.running) {
            clientProc.running = true;
        }
        if (!activeWindowProc.running) {
            activeWindowProc.running = true;
        }
    }

    Connections {
        target: Hyprland

        function onActiveToplevelChanged() {
            root.refreshClients();
        }

        function onRawEvent(event) {
            if (!event) return;
            var ev = event.name;
            if (ev === "openwindow" || ev === "closewindow" || ev === "movewindow" || 
                ev === "activewindow" || ev === "activewindowv2" || ev === "focusedmon" ||
                ev === "changefloatingmode") {
                root.refreshClients();
            }
        }
    }

    // Fallback sync timer
    Timer {
        id: clientTracker
        interval: 1200
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshClients()
    }

    Process {
        id: clientProc
        command: ["bash", "-c", "hyprctl -j clients 2>/dev/null | tr -d '\\n' || echo '[]'"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    var parsed = JSON.parse(data);
                    if (Array.isArray(parsed)) {
                        root.hyprClients = parsed;
                        root.updateRunningApps();
                    }
                } catch (e) {}
            }
        }
    }

    Process {
        id: activeWindowProc
        command: ["bash", "-c", "hyprctl -j activewindow 2>/dev/null | tr -d '\\n' || echo '{}'"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    var parsed = JSON.parse(data);
                    root.activeWindowAddress = parsed.address || "";
                    root.activeWindowClass = (parsed["class"] || "").toLowerCase();
                    root.updateRunningApps();
                } catch (e) {}
            }
        }
    }

    function resolveAppIcon(cls) {
        if (!cls) return "appstore.svg";
        cls = cls.toLowerCase();
        // Preserved Windows icons requested by user
        if (cls === "dolphin" || cls === "org.kde.dolphin" || cls === "nautilus" || cls === "thunar")
            return "win11-explorer.svg";
        if (cls === "kitty" || cls === "alacritty" || cls === "foot" || cls === "wezterm" || cls.indexOf("terminal") !== -1)
            return "win11-terminal.svg";
        if (cls === "discover" || cls === "plasma-discover" || cls === "pamac-manager")
            return "win11-store.svg";

        // Native icons for applications
        if (cls === "zen" || cls === "zen-browser")
            return "image://icon/zen-browser";
        if (cls === "antigravity")
            return "image://icon/antigravity";
        if (cls === "microsoft-edge" || cls === "microsoft-edge-stable" || cls === "msedge")
            return "win11-edge.svg";

        return "image://icon/" + cls;
    }

    function updateRunningApps() {
        if (!root.hyprClients || !Array.isArray(root.hyprClients)) return;

        // 1. Update running status of all PINNED apps
        for (var p = 0; p < pinnedAppsModel.count; p++) {
            var pItem = pinnedAppsModel.get(p);
            var mClasses = [];
            try {
                mClasses = JSON.parse(pItem.matchClassesJson);
            } catch(e) {
                mClasses = [pItem.id];
            }

            var matchingClients = [];
            for (var cIdx = 0; cIdx < root.hyprClients.length; cIdx++) {
                var cl = root.hyprClients[cIdx];
                if (root.isClientIgnored(cl)) continue;
                var clClass = (cl["class"] || "").toLowerCase();
                var clInitClass = (cl["initialClass"] || "").toLowerCase();
                var isMatch = false;
                for (var m = 0; m < mClasses.length; m++) {
                    var targetClass = mClasses[m].toLowerCase();
                    if (clClass.indexOf(targetClass) !== -1 || clInitClass.indexOf(targetClass) !== -1) {
                        isMatch = true;
                        break;
                    }
                }
                if (isMatch) {
                    matchingClients.push({
                        address: cl["address"],
                        title: cl["title"] || clClass,
                        workspace: cl["workspace"] ? cl["workspace"]["id"] : 1
                    });
                }
            }

            var isRunning = matchingClients.length > 0;
            var isFocused = false;
            var firstAddr = "";
            if (isRunning) {
                firstAddr = matchingClients[0].address;
                for (var f = 0; f < matchingClients.length; f++) {
                    if (matchingClients[f].address === root.activeWindowAddress) {
                        isFocused = true;
                        firstAddr = matchingClients[f].address;
                        break;
                    }
                }
            }

            pinnedAppsModel.setProperty(p, "isRunning", isRunning);
            pinnedAppsModel.setProperty(p, "isFocused", isFocused);
            pinnedAppsModel.setProperty(p, "address", firstAddr);
            pinnedAppsModel.setProperty(p, "windowsJson", JSON.stringify(matchingClients));
        }

        // 2. Group UNPINNED running clients
        var unpinnedList = [];
        var seenClasses = {};

        for (var i = 0; i < root.hyprClients.length; i++) {
            var client = root.hyprClients[i];
            if (root.isClientIgnored(client)) continue;

            var cls = (client["class"] || "").toLowerCase();
            var icls = (client["initialClass"] || "").toLowerCase();
            var title = client["title"] || "";
            if (!cls && !icls) continue;

            // Check if claimed by any pinned app
            var claimedByPinned = false;
            for (var pi = 0; pi < root.pinnedArray.length; pi++) {
                var pinObj = root.pinnedArray[pi];
                var pinClasses = pinObj.matchClasses || [pinObj.id];
                for (var pm = 0; pm < pinClasses.length; pm++) {
                    var targetM = pinClasses[pm].toLowerCase();
                    if (cls.indexOf(targetM) !== -1 || icls.indexOf(targetM) !== -1) {
                        claimedByPinned = true;
                        break;
                    }
                }
                if (claimedByPinned) break;
            }

            if (claimedByPinned) continue; // Managed under pinnedAppsModel

            var appKey = cls || icls;
            if (seenClasses[appKey]) {
                seenClasses[appKey].windows.push({
                    address: client["address"],
                    title: title.length > 0 ? title : appKey,
                    workspace: client["workspace"] ? client["workspace"]["id"] : 1
                });
            } else {
                var appItem = {
                    id: appKey,
                    clazz: appKey,
                    name: title.length > 0 ? title : (client["initialTitle"] || appKey),
                    title: title.length > 0 ? title : appKey,
                    icon: root.resolveAppIcon(appKey),
                    cmd: appKey,
                    matchClasses: [appKey],
                    address: client["address"],
                    isPinned: false,
                    isStart: false,
                    isRunning: true,
                    isFocused: (client["address"] === root.activeWindowAddress),
                    hasBadge: (appKey === "obs"),
                    windows: [{
                        address: client["address"],
                        title: title.length > 0 ? title : appKey,
                        workspace: client["workspace"] ? client["workspace"]["id"] : 1
                    }]
                };
                seenClasses[appKey] = appItem;
                unpinnedList.push(appItem);
            }
        }

        // 3. Mark missing unpinned apps as closing
        for (var u = unpinnedAppsModel.count - 1; u >= 0; u--) {
            var existingItem = unpinnedAppsModel.get(u);
            var stillOpen = false;
            for (var ul = 0; ul < unpinnedList.length; ul++) {
                if (unpinnedList[ul].id === existingItem.id) {
                    stillOpen = true;
                    break;
                }
            }
            if (!stillOpen) {
                unpinnedAppsModel.setProperty(u, "isClosing", true);
            }
        }

        // 4. Update or append apps in unpinnedAppsModel
        for (var k = 0; k < unpinnedList.length; k++) {
            var targetApp = unpinnedList[k];
            var existIdx = -1;
            for (var m = 0; m < unpinnedAppsModel.count; m++) {
                if (unpinnedAppsModel.get(m).id === targetApp.id) {
                    existIdx = m;
                    break;
                }
            }

            if (existIdx !== -1) {
                unpinnedAppsModel.setProperty(existIdx, "isClosing", false);
                unpinnedAppsModel.setProperty(existIdx, "name", targetApp.name);
                unpinnedAppsModel.setProperty(existIdx, "title", targetApp.title);
                unpinnedAppsModel.setProperty(existIdx, "address", targetApp.address);
                unpinnedAppsModel.setProperty(existIdx, "windowsJson", JSON.stringify(targetApp.windows));
                var isFoc = targetApp.windows.some(function(w) { return w.address === root.activeWindowAddress; });
                unpinnedAppsModel.setProperty(existIdx, "isFocused", isFoc);
            } else {
                unpinnedAppsModel.append({
                    id: targetApp.id,
                    clazz: targetApp.clazz,
                    name: targetApp.name,
                    title: targetApp.title,
                    icon: targetApp.icon,
                    cmd: targetApp.cmd,
                    matchClassesJson: JSON.stringify(targetApp.matchClasses),
                    address: targetApp.address,
                    isPinned: false,
                    isStart: false,
                    isRunning: true,
                    isFocused: (targetApp.address === root.activeWindowAddress),
                    hasBadge: targetApp.hasBadge,
                    windowsJson: JSON.stringify(targetApp.windows),
                    isClosing: false
                });
            }
        }

        root.openApps = unpinnedList;
    }

    function finalizeAppRemoval(appId) {
        for (var i = unpinnedAppsModel.count - 1; i >= 0; i--) {
            if (unpinnedAppsModel.get(i).id === appId && unpinnedAppsModel.get(i).isClosing) {
                unpinnedAppsModel.remove(i);
                break;
            }
        }
    }

    // Safety watchdog for any item stuck in closing
    Timer {
        interval: 800
        repeat: true
        running: true
        onTriggered: {
            for (var i = unpinnedAppsModel.count - 1; i >= 0; i--) {
                if (unpinnedAppsModel.get(i).isClosing) {
                    unpinnedAppsModel.remove(i);
                }
            }
        }
    }

    function isAppRunning(item) {
        if (!item || item.isStart) return false;
        if (item.isRunning !== undefined) return !!item.isRunning;
        return false;
    }

    function isAppFocused(item) {
        if (!item || item.isStart) return false;
        if (item.isFocused !== undefined) return !!item.isFocused;
        return false;
    }

    function launchApp(item) {
        if (!item) return;
        if (item.isStart) {
            Quickshell.execDetached(["bash", "-c", "lunita-launcher 2>/dev/null || rofi -show drun 2>/dev/null || true"]);
            return;
        }

        // If running, switch to its workspace & monitor, then focus window
        if (item.isRunning) {
            var targetAddr = item.address;
            var targetWs = null;

            if (item.windowsJson) {
                try {
                    var wins = JSON.parse(item.windowsJson);
                    if (wins.length > 0) {
                        targetAddr = wins[0].address;
                        targetWs = wins[0].workspace;
                    }
                } catch(e) {}
            }

            if (!targetWs && targetAddr) {
                for (var i = 0; i < root.hyprClients.length; i++) {
                    if (root.hyprClients[i].address === targetAddr) {
                        if (root.hyprClients[i].workspace) {
                            targetWs = root.hyprClients[i].workspace.id || root.hyprClients[i].workspace.name;
                        }
                        break;
                    }
                }
            }

            // If already focused on screen, minimize it
            if (item.isFocused && targetAddr && targetAddr === root.activeWindowAddress) {
                Quickshell.execDetached(["bash", "-c", "hyprctl dispatch movetoworkspacesilent special:minimized,address:" + targetAddr]);
                return;
            }

            if (targetAddr) {
                root.focusAddress(targetAddr, targetWs);
                return;
            }
        }

        // If not running, launch application command
        if (item.cmd && item.cmd !== "") {
            Quickshell.execDetached(["bash", "-c", item.cmd + " &"]);
        }
    }

    // ==========================================
    // 3. SYSTEM TRAY: DATE & TIME
    // ==========================================
    property string timeStr: "15:43"
    property string dateFullStr: "Domingo, 4 de octubre"

    Timer {
        id: timeTimer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date();
            var hours = now.getHours();
            var minutes = now.getMinutes();
            var hStr = (hours < 10 ? "0" : "") + hours;
            var mStr = (minutes < 10 ? "0" : "") + minutes;
            root.timeStr = hStr + ":" + mStr;

            var days = ["Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"];
            var months = ["enero", "febrero", "marzo", "abril", "mayo", "junio",
                          "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"];
            root.dateFullStr = days[now.getDay()] + ", " + now.getDate() + " de " + months[now.getMonth()] + " de " + now.getFullYear();
        }
    }

    // ==========================================
    // 4. SYSTEM TRAY: AUDIO & VOLUME
    // ==========================================
    property int volumePercent: 75
    property bool isVolumeMuted: false

    Timer {
        id: volumeTimer
        interval: 1500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: volumeProc.running = true
    }

    Process {
        id: volumeProc
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || echo 'Volume: 0.75'"]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim();
                root.isVolumeMuted = (line.indexOf("[MUTED]") !== -1);
                var match = line.match(/([0-9]+(?:\.[0-9]+)?)/);
                if (match) {
                    var val = parseFloat(match[1]);
                    if (val <= 1.5) {
                        root.volumePercent = Math.min(100, Math.round(val * 100));
                    } else {
                        root.volumePercent = Math.min(100, Math.round(val));
                    }
                }
            }
        }
    }

    function toggleVolumeMute() {
        root.isVolumeMuted = !root.isVolumeMuted;
        Quickshell.execDetached(["bash", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle 2>/dev/null || pactl set-sink-mute @DEFAULT_SINK@ toggle 2>/dev/null"]);
    }

    function changeVolume(delta) {
        var next = Math.max(0, Math.min(100, root.volumePercent + delta));
        root.volumePercent = next;
        Quickshell.execDetached(["bash", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + (next / 100).toFixed(2) + " 2>/dev/null"]);
    }

    function openVolumeFlyout(screenName) {
        root.toggleAudioFlyout(screenName);
    }

    // ==========================================
    // 5. SYSTEM TRAY: MICROPHONE
    // ==========================================
    property bool micMuted: false

    Timer {
        id: micTimer
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: micProc.running = true
    }

    Process {
        id: micProc
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null || echo 'Volume: 0.50'"]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim();
                root.micMuted = (line.indexOf("[MUTED]") !== -1);
            }
        }
    }

    function toggleMic() {
        root.micMuted = !root.micMuted;
        Quickshell.execDetached(["bash", "-c", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle 2>/dev/null"]);
    }

    // ==========================================
    // 6. SYSTEM TRAY: KEYBOARD LAYOUT
    // ==========================================
    property string keyboardLayout: "ESP"

    Timer {
        id: kbdTimer
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: kbdProc.running = true
    }

    Process {
        id: kbdProc
        command: ["bash", "-c", "hyprctl devices -j 2>/dev/null | tr -d '\\n' || echo '{}'"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    var parsed = JSON.parse(data);
                    if (parsed && Array.isArray(parsed.keyboards)) {
                        for (var i = 0; i < parsed.keyboards.length; i++) {
                            var k = parsed.keyboards[i];
                            var km = (k.active_keymap || "").toLowerCase();
                            var lay = (k.layout || "").toLowerCase();
                            if (km.indexOf("spanish") !== -1 || km.indexOf("español") !== -1 || lay === "es") {
                                root.keyboardLayout = "ESP";
                                return;
                            } else if (km.indexOf("english") !== -1 || lay === "us") {
                                root.keyboardLayout = "ENG";
                                return;
                            }
                        }
                    }
                } catch(e) {}
            }
        }
    }

    function cycleKeyboardLayout() {
        Quickshell.execDetached(["bash", "-c", "hyprctl switchxkblayout all next 2>/dev/null"]);
        kbdTimer.restart();
    }

    // ==========================================
    // 7. SYSTEM TRAY: WI-FI & NETWORK
    // ==========================================
    property bool wifiConnected: true
    property string wifiSsid: "Wi-Fi"

    Timer {
        id: wifiTimer
        interval: 4000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: wifiProc.running = true
    }

    Process {
        id: wifiProc
        command: ["bash", "-c", "nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2 || ip route get 1.1.1.1 2>/dev/null | awk '{print $5}' || echo 'Online'"]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim();
                if (line && line.length > 0) {
                    root.wifiConnected = true;
                    root.wifiSsid = line;
                } else {
                    root.wifiConnected = false;
                    root.wifiSsid = "Desconectado";
                }
            }
        }
    }

    function openNetwork() {
        Quickshell.execDetached(["bash", "-c", "nm-connection-editor || kitty -e nmtui &"]);
    }

    // ==========================================
    // 8. SYSTEM TRAY: BATTERY / POWER
    // ==========================================
    property bool hasBattery: false
    property int batteryPercent: 100
    property bool batteryCharging: false

    Timer {
        id: batteryTimer
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: batteryProc.running = true
    }

    Process {
        id: batteryProc
        command: ["bash", "-c", "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1 || echo '100'"]
        stdout: SplitParser {
            onRead: data => {
                var cap = parseInt(data.trim());
                if (!isNaN(cap)) {
                    root.batteryPercent = cap;
                    root.hasBattery = true;
                } else {
                    root.hasBattery = false;
                    root.batteryPercent = 100;
                }
            }
        }
    }

    Process {
        id: batStatusProc
        command: ["bash", "-c", "cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n1 || echo 'Full'"]
        stdout: SplitParser {
            onRead: data => {
                var st = data.trim().toLowerCase();
                root.batteryCharging = (st === "charging");
            }
        }
    }

    // ==========================================
    // 9. GENERAL POPUP ACTIONS & FLYOUTS
    // ==========================================
    property string activeFlyout: "" // "" | "audio" | "calendar"
    property string flyoutScreen: ""
    property bool flyoutOpen: false
    property bool flyoutVisible: false

    Timer {
        id: flyoutCloseTimer
        interval: 180
        repeat: false
        onTriggered: {
            if (!root.flyoutOpen) {
                root.flyoutVisible = false;
                root.activeFlyout = "";
                root.flyoutScreen = "";
                root.audioSinksExpanded = false;
            }
        }
    }

    function toggleAudioFlyout(screenName) {
        if (root.flyoutOpen && root.activeFlyout === "audio" && (root.flyoutScreen === screenName || !screenName)) {
            root.closeFlyouts();
        } else {
            flyoutCloseTimer.stop();
            root.activeFlyout = "audio";
            root.flyoutScreen = screenName || "";
            root.flyoutVisible = true;
            root.flyoutOpen = true;
            root.refreshAudioSinks();
            root.refreshMpris();
        }
    }

    function toggleCalendarFlyout(screenName) {
        if (root.flyoutOpen && root.activeFlyout === "calendar" && (root.flyoutScreen === screenName || !screenName)) {
            root.closeFlyouts();
        } else {
            flyoutCloseTimer.stop();
            root.activeFlyout = "calendar";
            root.flyoutScreen = screenName || "";
            root.flyoutVisible = true;
            root.flyoutOpen = true;
            root.refreshNotifications();
        }
    }

    function closeFlyouts() {
        if (!root.flyoutOpen && !root.flyoutVisible) return;
        root.flyoutOpen = false;
        flyoutCloseTimer.restart();
    }

    function openCalendar(screenName) {
        root.toggleCalendarFlyout(screenName);
    }

    function openLauncher() {
        Quickshell.execDetached(["bash", "-c", "lunita-launcher 2>/dev/null || rofi -show drun 2>/dev/null || true"]);
    }

    // ==========================================
    // 10. MPRIS MEDIA CONTROLLER
    // ==========================================
    property bool mprisAvailable: false
    property bool mprisPlaying: false
    property string mprisPlayerName: "Spotify"
    property string mprisTitle: "Lil Mama (with Trevor Daniel)"
    property string mprisArtist: "Miles Wesley"
    property string mprisArtUrl: ""
    property real mprisPosition: 0
    property real mprisLength: 100

    Timer {
        id: mprisTimer
        interval: 1200
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!mprisProc.running) mprisProc.running = true;
        }
    }

    Process {
        id: mprisProc
        command: ["bash", "-c", "playerctl metadata --format '{{playerName}}:::{{title}}:::{{artist}}:::{{mpris:artUrl}}:::{{status}}:::{{position}}:::{{mpris:length}}' 2>/dev/null || echo ''"]
        stdout: SplitParser {
            onRead: data => {
                var str = data.trim();
                if (!str || str.indexOf(":::") === -1) {
                    root.mprisAvailable = false;
                    root.mprisPlaying = false;
                    return;
                }
                var parts = str.split(":::");
                if (!parts[1] && !parts[2]) {
                    root.mprisAvailable = false;
                    root.mprisPlaying = false;
                    return;
                }
                root.mprisAvailable = true;
                var rawPlayer = parts[0] ? parts[0].trim() : "spotify";
                root.mprisPlayerName = rawPlayer.charAt(0).toUpperCase() + rawPlayer.slice(1);
                root.mprisTitle = parts[1] || "Lil Mama (with Trevor Daniel)";
                root.mprisArtist = parts[2] || "Miles Wesley";
                root.mprisArtUrl = parts[3] || "";
                root.mprisPlaying = (parts[4] && parts[4].toLowerCase() === "playing");
                if (parts[5]) root.mprisPosition = parseFloat(parts[5]) / 1000000.0;
                if (parts[6]) root.mprisLength = parseFloat(parts[6]) / 1000000.0;
            }
        }
    }

    function refreshMpris() {
        if (!mprisProc.running) mprisProc.running = true;
    }

    function playPause() {
        root.mprisPlaying = !root.mprisPlaying;
        Quickshell.execDetached(["bash", "-c", "playerctl play-pause 2>/dev/null || true"]);
    }

    function nextTrack() {
        Quickshell.execDetached(["bash", "-c", "playerctl next 2>/dev/null || true"]);
    }

    function previousTrack() {
        Quickshell.execDetached(["bash", "-c", "playerctl previous 2>/dev/null || true"]);
    }

    // ==========================================
    // 11. BRIGHTNESS CONTROLLER
    // ==========================================
    property int brightnessPercent: 80

    Timer {
        id: brightnessTimer
        interval: 3500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!brightnessProc.running) brightnessProc.running = true;
        }
    }

    Process {
        id: brightnessProc
        command: ["bash", "-c", "brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%' || echo '80'"]
        stdout: SplitParser {
            onRead: data => {
                var num = parseInt(data.trim());
                if (!isNaN(num)) root.brightnessPercent = num;
            }
        }
    }

    function setBrightness(val) {
        var clamped = Math.max(5, Math.min(100, Math.round(val)));
        root.brightnessPercent = clamped;
        Quickshell.execDetached(["bash", "-c", "brightnessctl s " + clamped + "% 2>/dev/null || true"]);
    }

    // ==========================================
    // 12. AUDIO SINKS (FUENTES DE REPRODUCCIÓN)
    // ==========================================
    property var audioSinks: []
    property bool audioSinksExpanded: false

    function toggleAudioSinksExpanded() {
        root.audioSinksExpanded = !root.audioSinksExpanded;
        if (root.audioSinksExpanded) {
            root.refreshAudioSinks();
        }
    }

    function refreshAudioSinks() {
        if (!sinksProc.running) sinksProc.running = true;
    }

    Process {
        id: sinksProc
        command: ["python3", (Quickshell.env("HOME") || "") + "/.config/quickshell/dock/scripts/audio_sinks.py"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    var parsed = JSON.parse(data.trim());
                    if (Array.isArray(parsed)) {
                        root.audioSinks = parsed;
                    }
                } catch(e) {}
            }
        }
    }

    function setAudioSink(sinkId) {
        Quickshell.execDetached(["python3", (Quickshell.env("HOME") || "") + "/.config/quickshell/dock/scripts/audio_sinks.py", "set", String(sinkId)]);
        var current = root.audioSinks.slice();
        for (var i = 0; i < current.length; i++) {
            current[i].active = (current[i].id === sinkId);
        }
        root.audioSinks = current;
    }

    // ==========================================
    // 13. BLUETOOTH STATUS & CONTROLLER
    // ==========================================
    property bool bluetoothEnabled: true
    property string bluetoothDeviceName: ""

    Timer {
        id: btTimer
        interval: 4000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!btProc.running) btProc.running = true;
        }
    }

    Process {
        id: btProc
        command: ["bash", "-c", "bluetoothctl show 2>/dev/null | grep 'Powered: yes' >/dev/null && echo 'on' || echo 'off'"]
        stdout: SplitParser {
            onRead: data => {
                root.bluetoothEnabled = (data.trim() === "on");
            }
        }
    }

    function toggleBluetooth() {
        var next = !root.bluetoothEnabled;
        root.bluetoothEnabled = next;
        Quickshell.execDetached(["bash", "-c", next ? "bluetoothctl power on" : "bluetoothctl power off"]);
    }

    // ==========================================
    // 14. NOTIFICATIONS CACHE & MANAGER
    // ==========================================
    property var notificationsList: []

    FileView {
        id: notifsCacheFile
        path: "/tmp/notifications_cache.json"
        watchChanges: true
        onLoaded: {
            root.parseNotificationsJson(notifsCacheFile.text());
        }
        onFileChanged: {
            root.parseNotificationsJson(notifsCacheFile.text());
        }
    }

    function parseNotificationsJson(raw) {
        if (!raw || raw.trim().length === 0) return;
        try {
            var list = JSON.parse(raw.trim());
            if (Array.isArray(list)) {
                root.notificationsList = list;
            }
        } catch(e) {}
    }

    Timer {
        id: notifsFallbackTimer
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!notifsProc.running) notifsProc.running = true;
        }
    }

    Process {
        id: notifsProc
        command: ["bash", "-c", "jq -c . /tmp/notifications_cache.json 2>/dev/null || tr -d '\\n' < /tmp/notifications_cache.json 2>/dev/null || echo '[]'"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                root.parseNotificationsJson(data);
            }
        }
    }

    function refreshNotifications() {
        if (!notifsProc.running) notifsProc.running = true;
    }

    function clearAllNotifications() {
        root.notificationsList = [];
        Quickshell.execDetached(["bash", "-c", "printf '[]\\n' > /tmp/notifications_cache.json.tmp && mv -f /tmp/notifications_cache.json.tmp /tmp/notifications_cache.json; quickshell ipc -c notifications call notifications clear 2>/dev/null || true"]);
    }

    function dismissNotification(id) {
        var current = root.notificationsList.slice();
        var next = [];
        for (var i = 0; i < current.length; i++) {
            if (current[i].id !== id) next.push(current[i]);
        }
        root.notificationsList = next;
        var jsonStr = JSON.stringify(next);
        var escaped = jsonStr.replace(/'/g, "'\\''");
        Quickshell.execDetached(["bash", "-c", "printf '%s\\n' '" + escaped + "' > /tmp/notifications_cache.json.tmp && mv -f /tmp/notifications_cache.json.tmp /tmp/notifications_cache.json; quickshell ipc -c notifications call notifications dismiss '" + id + "' 2>/dev/null || true"]);
    }

    function invokeNotification(id, actionIndex) {
        dismissNotification(id);
        Quickshell.execDetached(["bash", "-c", "quickshell ipc -c notifications call notifications invoke '" + id + "' '" + (actionIndex || 0) + "' 2>/dev/null"]);
    }

    // ==========================================
    // 15. CALENDAR NAVIGATION & FOCUS / POMODORO
    // ==========================================
    property int displayedYear: 2026
    property int displayedMonth: 9 // 0-indexed (9 = Octubre)
    property int currentYear: 2026
    property int currentMonth: 9
    property int currentDay: 1
    property int selectedDay: 1

    property int focusMinutes: 30
    property bool focusActive: false
    property int focusSecondsRemaining: 1800

    Timer {
        id: focusTimer
        interval: 1000
        running: root.focusActive
        repeat: true
        onTriggered: {
            if (root.focusSecondsRemaining > 0) {
                root.focusSecondsRemaining -= 1;
            } else {
                root.focusActive = false;
                Quickshell.execDetached(["bash", "-c", "notify-send 'Concentración' '¡Sesión de concentración completada!' 2>/dev/null || true"]);
            }
        }
    }

    function adjustFocus(delta) {
        if (root.focusActive) return;
        var next = root.focusMinutes + delta;
        if (next < 5) next = 5;
        if (next > 120) next = 120;
        root.focusMinutes = next;
        root.focusSecondsRemaining = next * 60;
    }

    function toggleFocus() {
        if (!root.focusActive) {
            root.focusSecondsRemaining = root.focusMinutes * 60;
            root.focusActive = true;
        } else {
            root.focusActive = false;
        }
    }

    function prevMonth() {
        if (root.displayedMonth === 0) {
            root.displayedMonth = 11;
            root.displayedYear -= 1;
        } else {
            root.displayedMonth -= 1;
        }
    }

    function nextMonth() {
        if (root.displayedMonth === 11) {
            root.displayedMonth = 0;
            root.displayedYear += 1;
        } else {
            root.displayedMonth += 1;
        }
    }

    function resetToToday() {
        var now = new Date();
        root.displayedYear = now.getFullYear();
        root.displayedMonth = now.getMonth();
        root.selectedDay = now.getDate();
    }

    // ==========================================
    // 16. SYSTEM TRAY ICON RESOLVER
    // ==========================================
    readonly property string trayResolverScriptPath: Qt.resolvedUrl("scripts/tray_resolver.py").toString().replace("file://", "")
    property var trayIconsMap: ({})

    Process {
        id: trayResolverProc
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                var line = data.trim();
                if (!line || line.indexOf("|") === -1) return;
                var parts = line.split("|");
                if (parts.length >= 2) {
                    var raw = parts[0];
                    var resolved = parts.slice(1).join("|").trim();
                    if (resolved !== "") {
                        var mapCopy = Object.assign({}, root.trayIconsMap);
                        mapCopy[raw] = resolved;
                        root.trayIconsMap = mapCopy;
                    }
                }
            }
        }
    }

    function resolveTrayIcons(items) {
        if (!items || items.length === 0) return;
        var args = ["python3", root.trayResolverScriptPath, "--batch"];
        var hasArgs = false;
        for (var i = 0; i < items.length; i++) {
            var item = items[i];
            if (item && item.icon) {
                var iconStr = item.icon.toString();
                if (iconStr !== "") {
                    args.push(iconStr);
                    hasArgs = true;
                }
            }
        }
        if (hasArgs) {
            trayResolverProc.command = args;
            trayResolverProc.running = false;
            trayResolverProc.running = true;
        }
    }
}
