import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Item {
    id: root

    // ==========================================
    // 1. START BUTTON
    // ==========================================
    property var startApp: ({
        "id": "start",
        "name": "Inicio",
        "icon": "win11-start.svg",
        "cmd": "lunita-launcher || rofi -show drun",
        "matchClasses": [],
        "isStart": true,
        "hasBadge": false
    })
    // ==========================================
    // 2. PINNED APPS PERSISTENCE & LISTMODELS
    // ==========================================
    readonly property string pinnedConfigPath: Quickshell.env("HOME") + "/.config/lunita/dock-win11-pinned.json"
    property var defaultPinnedList: [{
        "id": "dolphin",
        "name": "Explorador de archivos",
        "icon": "win11-explorer.svg",
        "cmd": "dolphin",
        "matchClasses": ["dolphin", "org.kde.dolphin", "nautilus", "thunar"]
    }, {
        "id": "store",
        "name": "Microsoft Store",
        "icon": "win11-store.svg",
        "cmd": "plasma-discover || pamac-manager",
        "matchClasses": ["discover", "plasma-discover", "pamac-manager", "gnome-software"]
    }, {
        "id": "zen",
        "name": "Zen Browser",
        "icon": "image://icon/zen-browser",
        "cmd": "zen-browser || zen",
        "matchClasses": ["zen", "zen-browser"]
    }, {
        "id": "terminal",
        "name": "Terminal",
        "icon": "win11-terminal.svg",
        "cmd": "kitty",
        "matchClasses": ["kitty", "alacritty", "foot", "wezterm", "terminal"]
    }]
    property var pinnedArray: []
    property alias pinnedAppsModel: pinnedAppsModel
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
    // ── Persistence: Load Pinned Apps ──
    property bool isSelfSaving: false
    // ── Live Drag & Drop Preview (Neighbors shift aside smoothly) ──
    property string draggingAppId: ""
    property int draggingSteps: 0
    property bool dragJustCommitted: false
    // ── Ignored Clients & Hyprland Process Sync ──
    readonly property var ignoredClasses: ["quickshell", "rofi", "wlogout", "hyprlock", "waybar", "eww", "polkit-kde-authentication-agent-1", "polkit-gnome-authentication-agent-1", "blueman-applet", "nm-applet", "pinentry-qt", "pinentry-gtk-2", "gcr-prompter", "flameshot"]
    // ==========================================
    // UNIFIED APP ICONS RESOLVER (lunita-icon-resolver)
    // ==========================================
    property var appIconsMap: ({
    })
    // ==========================================
    // 3. SYSTEM TRAY: DATE & TIME
    // ==========================================
    property string timeStr: "15:43"
    property string dateFullStr: "Domingo, 4 de octubre"
    // ==========================================
    // 4. SYSTEM TRAY: AUDIO & VOLUME
    // ==========================================
    property int volumePercent: 75
    property bool isVolumeMuted: false
    // ==========================================
    // 5. SYSTEM TRAY: MICROPHONE
    // ==========================================
    property bool micMuted: false
    // ==========================================
    // 6. SYSTEM TRAY: KEYBOARD LAYOUT
    // ==========================================
    property string keyboardLayout: "ESP"
    // ==========================================
    // 7. SYSTEM TRAY: WI-FI & ETHERNET NETWORK
    // ==========================================
    readonly property string networkScriptPath: Qt.resolvedUrl("scripts/network_manager.py").toString().replace("file://", "")
    property bool ethernetHasDevice: false
    property bool ethernetConnected: false
    property string ethernetDevice: ""
    property string ethernetName: "Ethernet"
    property string ethernetIp: ""
    property bool wifiHasDevice: false
    property bool wifiEnabled: true
    property bool wifiConnected: true
    property string wifiDevice: ""
    property string wifiSsid: "Wi-Fi"
    property string wifiIp: ""
    property int wifiSignal: 100
    property var wifiNetworks: []
    property bool networkScanning: false
    // ==========================================
    // 8. SYSTEM TRAY: BATTERY / POWER
    // ==========================================
    property bool hasBattery: false
    property int batteryPercent: 100
    property bool batteryCharging: false
    // ==========================================
    // 9. GENERAL POPUP ACTIONS & FLYOUTS
    // ==========================================
    property string activeFlyout: ""
    // "" | "audio" | "calendar" | "network" | "bluetooth"
    property string flyoutScreen: ""
    property bool flyoutOpen: false
    property bool flyoutVisible: false
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
    // ==========================================
    // 11. BRIGHTNESS CONTROLLER
    // ==========================================
    property int brightnessPercent: 80
    // ==========================================
    // 12. AUDIO SINKS (FUENTES DE REPRODUCCIÓN)
    // ==========================================
    property var audioSinks: []
    property bool audioSinksExpanded: false
    // ==========================================
    // 13. BLUETOOTH STATUS & CONTROLLER
    // ==========================================
    readonly property string bluetoothScriptPath: Qt.resolvedUrl("scripts/bluetooth_manager.py").toString().replace("file://", "")
    property bool bluetoothHasAdapter: true
    property bool bluetoothEnabled: true
    property string bluetoothDeviceName: ""
    property var bluetoothDevices: []
    property bool bluetoothScanning: false
    property string bluetoothPendingMac: ""
    // ==========================================
    // 14. NOTIFICATIONS CACHE & MANAGER
    // ==========================================
    property var notificationsList: []
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
    // ==========================================
    // 16. SYSTEM TRAY ICON RESOLVER
    // ==========================================
    readonly property string trayResolverScriptPath: Qt.resolvedUrl("scripts/tray_resolver.py").toString().replace("file://", "")
    property var trayIconsMap: ({
    })
    // ==========================================
    // 17. DESKTOP WIDGETS EDITING & MANAGEMENT
    // ==========================================
    property bool widgetsEditing: false

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
        if (!addr || addr === "")
            return ;

        // Find workspace if not provided
        if (!wsId) {
            for (var i = 0; i < root.hyprClients.length; i++) {
                var cl = root.hyprClients[i];
                if (cl.address === addr) {
                    if (cl.workspace)
                        wsId = cl.workspace.id || cl.workspace.name;

                    break;
                }
            }
        }
        var cmds = [];
        if (wsId) {
            if (typeof wsId === "number" && wsId > 0)
                cmds.push("hyprctl dispatch workspace " + wsId + " 2>/dev/null");
            else
                cmds.push("hyprctl dispatch workspace name:" + wsId + " 2>/dev/null");
        }
        cmds.push("hyprctl dispatch focuswindow address:" + addr + " 2>/dev/null");
        Quickshell.execDetached(["bash", "-c", cmds.join(" ; ")]);
    }

    function parsePinnedJson(raw) {
        if (!raw || raw.trim().length === 0) {
            if (root.pinnedArray.length === 0) {
                root.pinnedArray = root.defaultPinnedList;
                root.syncPinnedModel();
                root.savePinnedApps();
            }
            return ;
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
                if (root.pinnedArray[j].id === id) {
                    found = true;
                    break;
                }
            }
            if (!found)
                pinnedAppsModel.remove(i);

        }
        // 2. Add, update, or reposition pinned items in place
        for (var k = 0; k < root.pinnedArray.length; k++) {
            var p = root.pinnedArray[k];
            var existing = -1;
            for (var m = 0; m < pinnedAppsModel.count; m++) {
                if (pinnedAppsModel.get(m).id === p.id) {
                    existing = m;
                    break;
                }
            }
            var mClasses = p.matchClasses || [p.id];
            if (existing !== -1) {
                if (existing !== k)
                    pinnedAppsModel.move(existing, k, 1);

                pinnedAppsModel.setProperty(k, "name", p.name || p.id);
                pinnedAppsModel.setProperty(k, "cmd", p.cmd || p.id);
                pinnedAppsModel.setProperty(k, "icon", p.icon || root.resolveAppIcon(p.id));
                pinnedAppsModel.setProperty(k, "matchClassesJson", JSON.stringify(mClasses));
            } else {
                pinnedAppsModel.insert(k, {
                    "id": p.id,
                    "clazz": p.id,
                    "name": p.name || p.id,
                    "title": p.name || p.id,
                    "icon": p.icon || root.resolveAppIcon(p.id),
                    "cmd": p.cmd || p.id,
                    "matchClassesJson": JSON.stringify(mClasses),
                    "isPinned": true,
                    "isStart": false,
                    "isRunning": false,
                    "isFocused": false,
                    "address": "",
                    "windowsJson": "[]",
                    "hasBadge": (p.id === "obs"),
                    "isClosing": false
                });
            }
        }
    }

    function savePinnedApps() {
        if (!root.pinnedArray || root.pinnedArray.length === 0)
            return ;

        root.isSelfSaving = true;
        saveDebounceTimer.restart();
        var jsonStr = JSON.stringify(root.pinnedArray, null, 2);
        var escaped = jsonStr.replace(/'/g, "'\\''");
        var cmd = "mkdir -p ~/.config/lunita && printf '%s\\n' '" + escaped + "' > ~/.config/lunita/dock-win11-pinned.json.tmp && mv -f ~/.config/lunita/dock-win11-pinned.json.tmp ~/.config/lunita/dock-win11-pinned.json";
        Quickshell.execDetached(["bash", "-c", cmd]);
    }

    function isPinned(appId) {
        if (!appId)
            return false;

        for (var i = 0; i < root.pinnedArray.length; i++) {
            if (root.pinnedArray[i].id === appId)
                return true;

        }
        return false;
    }

    function pinApp(appObj) {
        if (!appObj || !appObj.id)
            return ;

        if (root.isPinned(appObj.id))
            return ;

        var mClasses = appObj.matchClasses || [appObj.id];
        var p = {
            "id": appObj.id,
            "name": appObj.name || appObj.title || appObj.id,
            "icon": appObj.icon || root.resolveAppIcon(appObj.id),
            "cmd": appObj.cmd || appObj.id,
            "matchClasses": mClasses
        };
        root.pinnedArray.push(p);
        root.syncPinnedModel();
        root.savePinnedApps();
        root.refreshClients();
    }

    function unpinApp(appId) {
        if (!appId)
            return ;

        var filtered = [];
        for (var i = 0; i < root.pinnedArray.length; i++) {
            if (root.pinnedArray[i].id !== appId)
                filtered.push(root.pinnedArray[i]);

        }
        root.pinnedArray = filtered;
        root.syncPinnedModel();
        root.savePinnedApps();
        root.refreshClients();
    }

    // ── Reordering & Moving Apps (Pinned & Unpinned) ──
    function getPinnedIndex(appId) {
        if (!appId)
            return -1;

        for (var i = 0; i < root.pinnedArray.length; i++) {
            if (root.pinnedArray[i].id === appId)
                return i;

        }
        return -1;
    }

    function getUnpinnedIndex(appId) {
        if (!appId)
            return -1;

        for (var i = 0; i < unpinnedAppsModel.count; i++) {
            if (unpinnedAppsModel.get(i).id === appId)
                return i;

        }
        return -1;
    }

    function reorderPinnedApp(sourceIdx, targetIdx) {
        if (sourceIdx === targetIdx || sourceIdx < 0 || targetIdx < 0 || sourceIdx >= root.pinnedArray.length || targetIdx >= root.pinnedArray.length)
            return ;

        var copy = root.pinnedArray.slice();
        var item = copy.splice(sourceIdx, 1)[0];
        copy.splice(targetIdx, 0, item);
        root.pinnedArray = copy;
        pinnedAppsModel.move(sourceIdx, targetIdx, 1);
        root.savePinnedApps();
    }

    function movePinnedApp(appId, steps) {
        var idx = root.getPinnedIndex(appId);
        if (idx === -1)
            return ;

        var targetIdx = Math.max(0, Math.min(root.pinnedArray.length - 1, idx + steps));
        if (targetIdx !== idx)
            root.reorderPinnedApp(idx, targetIdx);

    }

    function reorderUnpinnedApp(sourceIdx, targetIdx) {
        if (sourceIdx === targetIdx || sourceIdx < 0 || targetIdx < 0 || sourceIdx >= unpinnedAppsModel.count || targetIdx >= unpinnedAppsModel.count)
            return ;

        unpinnedAppsModel.move(sourceIdx, targetIdx, 1);
    }

    function moveUnpinnedApp(appId, steps) {
        var idx = root.getUnpinnedIndex(appId);
        if (idx === -1)
            return ;

        var targetIdx = Math.max(0, Math.min(unpinnedAppsModel.count - 1, idx + steps));
        if (targetIdx !== idx)
            root.reorderUnpinnedApp(idx, targetIdx);

    }

    function moveApp(appRef, steps) {
        if (!appRef)
            return ;

        var id = (typeof appRef === "string") ? appRef : (appRef.id || appRef.clazz || "");
        if (!id || id === "start")
            return ;

        if (root.isPinned(id))
            root.movePinnedApp(id, steps);
        else
            root.moveUnpinnedApp(id, steps);
    }

    function canMoveLeft(appRef) {
        if (!appRef)
            return false;

        var id = (typeof appRef === "string") ? appRef : (appRef.id || appRef.clazz || "");
        if (!id || id === "start")
            return false;

        if (root.isPinned(id))
            return root.getPinnedIndex(id) > 0;
        else
            return root.getUnpinnedIndex(id) > 0;
    }

    function canMoveRight(appRef) {
        if (!appRef)
            return false;

        var id = (typeof appRef === "string") ? appRef : (appRef.id || appRef.clazz || "");
        if (!id || id === "start")
            return false;

        if (root.isPinned(id)) {
            var pIdx = root.getPinnedIndex(id);
            return pIdx >= 0 && pIdx < root.pinnedArray.length - 1;
        } else {
            var uIdx = root.getUnpinnedIndex(id);
            return uIdx >= 0 && uIdx < unpinnedAppsModel.count - 1;
        }
    }

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
        if (!root.draggingAppId || root.draggingAppId === "" || root.draggingAppId === appId)
            return 0;

        if (root.draggingSteps === 0)
            return 0;

        var dragIsPinned = root.isPinned(root.draggingAppId);
        var myIsPinned = root.isPinned(appId);
        if (dragIsPinned !== myIsPinned)
            return 0;

        if (dragIsPinned) {
            var dragIdx = root.getPinnedIndex(root.draggingAppId);
            var myIdx = root.getPinnedIndex(appId);
            if (dragIdx < 0 || myIdx < 0)
                return 0;

            if (root.draggingSteps > 0) {
                if (myIdx > dragIdx && myIdx <= dragIdx + root.draggingSteps)
                    return -48;

            } else if (root.draggingSteps < 0) {
                if (myIdx < dragIdx && myIdx >= dragIdx + root.draggingSteps)
                    return 48;

            }
        } else {
            var dragUIdx = root.getUnpinnedIndex(root.draggingAppId);
            var myUIdx = root.getUnpinnedIndex(appId);
            if (dragUIdx < 0 || myUIdx < 0)
                return 0;

            if (root.draggingSteps > 0) {
                if (myUIdx > dragUIdx && myUIdx <= dragUIdx + root.draggingSteps)
                    return -48;

            } else if (root.draggingSteps < 0) {
                if (myUIdx < dragUIdx && myUIdx >= dragUIdx + root.draggingSteps)
                    return 48;

            }
        }
        return 0;
    }

    function isClientIgnored(c) {
        if (!c)
            return true;

        if (c.hidden)
            return true;

        if (c.size && (c.size[0] <= 1 || c.size[1] <= 1))
            return true;

        var cls = (c["class"] || "").toLowerCase();
        var icls = (c["initialClass"] || "").toLowerCase();
        if (!cls && !icls)
            return true;

        for (var i = 0; i < root.ignoredClasses.length; i++) {
            var ign = root.ignoredClasses[i].toLowerCase();
            if (cls === ign || icls === ign)
                return true;

        }
        if (cls.endsWith("-applet") || icls.endsWith("-applet") || cls.endsWith("-tray") || icls.endsWith("-tray") || cls.endsWith("-daemon") || icls.endsWith("-daemon"))
            return true;

        return false;
    }

    function refreshClients() {
        if (!clientProc.running)
            clientProc.running = true;

        if (!activeWindowProc.running)
            activeWindowProc.running = true;

    }

    function resolveAppIcon(cls) {
        if (!cls)
            return Qt.resolvedUrl("assets/icons/appstore.svg");

        var low = cls.toLowerCase();
        // Preserved Windows icons requested by user
        if (low === "dolphin" || low === "org.kde.dolphin" || low === "nautilus" || low === "thunar")
            return "win11-explorer.svg";

        if (low === "kitty" || low === "alacritty" || low === "foot" || low === "wezterm" || low.indexOf("terminal") !== -1)
            return "win11-terminal.svg";

        if (low === "discover" || low === "plasma-discover" || low === "pamac-manager")
            return "win11-store.svg";

        if (low === "microsoft-edge" || low === "microsoft-edge-stable" || low === "msedge")
            return "win11-edge.svg";

        // Check unified app icons map
        if (root.appIconsMap[cls])
            return root.appIconsMap[cls];

        if (root.appIconsMap[low])
            return root.appIconsMap[low];

        // Aliases
        if (low === "zen" || low === "zen-browser") {
            if (root.appIconsMap["zen-browser"])
                return root.appIconsMap["zen-browser"];

            if (root.appIconsMap["zen"])
                return root.appIconsMap["zen"];

        }
        return Qt.resolvedUrl("assets/icons/appstore.svg");
    }

    function updateRunningApps() {
        if (!root.hyprClients || !Array.isArray(root.hyprClients))
            return ;

        // 1. Update running status of all PINNED apps
        for (var p = 0; p < pinnedAppsModel.count; p++) {
            var pItem = pinnedAppsModel.get(p);
            var mClasses = [];
            try {
                mClasses = JSON.parse(pItem.matchClassesJson);
            } catch (e) {
                mClasses = [pItem.id];
            }
            var matchingClients = [];
            for (var cIdx = 0; cIdx < root.hyprClients.length; cIdx++) {
                var cl = root.hyprClients[cIdx];
                if (root.isClientIgnored(cl))
                    continue;

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
                if (isMatch)
                    matchingClients.push({
                    "address": cl["address"],
                    "title": cl["title"] || clClass,
                    "workspace": cl["workspace"] ? cl["workspace"]["id"] : 1
                });

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
        var seenClasses = {
        };
        for (var i = 0; i < root.hyprClients.length; i++) {
            var client = root.hyprClients[i];
            if (root.isClientIgnored(client))
                continue;

            var cls = (client["class"] || "").toLowerCase();
            var icls = (client["initialClass"] || "").toLowerCase();
            var title = client["title"] || "";
            if (!cls && !icls)
                continue;

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
                if (claimedByPinned)
                    break;

            }
            if (claimedByPinned)
                continue;

            // Managed under pinnedAppsModel
            var appKey = cls || icls;
            if (seenClasses[appKey]) {
                seenClasses[appKey].windows.push({
                    "address": client["address"],
                    "title": title.length > 0 ? title : appKey,
                    "workspace": client["workspace"] ? client["workspace"]["id"] : 1
                });
            } else {
                var appItem = {
                    "id": appKey,
                    "clazz": appKey,
                    "name": title.length > 0 ? title : (client["initialTitle"] || appKey),
                    "title": title.length > 0 ? title : appKey,
                    "icon": root.resolveAppIcon(appKey),
                    "cmd": appKey,
                    "matchClasses": [appKey],
                    "address": client["address"],
                    "isPinned": false,
                    "isStart": false,
                    "isRunning": true,
                    "isFocused": (client["address"] === root.activeWindowAddress),
                    "hasBadge": (appKey === "obs"),
                    "windows": [{
                        "address": client["address"],
                        "title": title.length > 0 ? title : appKey,
                        "workspace": client["workspace"] ? client["workspace"]["id"] : 1
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
            if (!stillOpen)
                unpinnedAppsModel.setProperty(u, "isClosing", true);

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
                var isFoc = targetApp.windows.some(function(w) {
                    return w.address === root.activeWindowAddress;
                });
                unpinnedAppsModel.setProperty(existIdx, "isFocused", isFoc);
            } else {
                unpinnedAppsModel.append({
                    "id": targetApp.id,
                    "clazz": targetApp.clazz,
                    "name": targetApp.name,
                    "title": targetApp.title,
                    "icon": targetApp.icon,
                    "cmd": targetApp.cmd,
                    "matchClassesJson": JSON.stringify(targetApp.matchClasses),
                    "address": targetApp.address,
                    "isPinned": false,
                    "isStart": false,
                    "isRunning": true,
                    "isFocused": (targetApp.address === root.activeWindowAddress),
                    "hasBadge": targetApp.hasBadge,
                    "windowsJson": JSON.stringify(targetApp.windows),
                    "isClosing": false
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

    function isAppRunning(item) {
        if (!item || item.isStart)
            return false;

        if (item.isRunning !== undefined)
            return !!item.isRunning;

        return false;
    }

    function isAppFocused(item) {
        if (!item || item.isStart)
            return false;

        if (item.isFocused !== undefined)
            return !!item.isFocused;

        return false;
    }

    function launchApp(item) {
        if (!item)
            return ;

        if (item.isStart) {
            Quickshell.execDetached(["bash", "-c", "lunita-launcher 2>/dev/null || rofi -show drun 2>/dev/null || true"]);
            return ;
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
                } catch (e) {
                }
            }
            if (!targetWs && targetAddr) {
                for (var i = 0; i < root.hyprClients.length; i++) {
                    if (root.hyprClients[i].address === targetAddr) {
                        if (root.hyprClients[i].workspace)
                            targetWs = root.hyprClients[i].workspace.id || root.hyprClients[i].workspace.name;

                        break;
                    }
                }
            }
            // If already focused on screen, minimize it
            if (item.isFocused && targetAddr && targetAddr === root.activeWindowAddress) {
                Quickshell.execDetached(["bash", "-c", "hyprctl dispatch movetoworkspacesilent special:minimized,address:" + targetAddr]);
                return ;
            }
            if (targetAddr) {
                root.focusAddress(targetAddr, targetWs);
                return ;
            }
        }
        // If not running, launch application command
        if (item.cmd && item.cmd !== "")
            Quickshell.execDetached(["bash", "-c", item.cmd + " &"]);

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

    function toggleMic() {
        root.micMuted = !root.micMuted;
        Quickshell.execDetached(["bash", "-c", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle 2>/dev/null"]);
    }

    function cycleKeyboardLayout() {
        Quickshell.execDetached(["bash", "-c", "hyprctl switchxkblayout all next 2>/dev/null"]);
        kbdTimer.restart();
    }

    function parseNetworkState(raw) {
        if (!raw || raw.trim().length === 0)
            return ;

        try {
            var parsed = JSON.parse(raw.trim());
            if (parsed.ethernet) {
                root.ethernetHasDevice = !!parsed.ethernet.hasDevice;
                root.ethernetConnected = !!parsed.ethernet.connected;
                root.ethernetDevice = parsed.ethernet.device || "";
                root.ethernetName = parsed.ethernet.name || "Ethernet";
                root.ethernetIp = parsed.ethernet.ip || "";
            }
            if (parsed.wifi) {
                root.wifiHasDevice = !!parsed.wifi.hasDevice;
                root.wifiEnabled = !!parsed.wifi.enabled;
                root.wifiConnected = !!parsed.wifi.connected;
                root.wifiDevice = parsed.wifi.device || "";
                root.wifiSsid = parsed.wifi.name || (parsed.wifi.connected ? "Wi-Fi" : "Desconectado");
                root.wifiIp = parsed.wifi.ip || "";
                root.wifiSignal = parsed.wifi.signal || 0;
                if (Array.isArray(parsed.wifi.networks))
                    root.wifiNetworks = parsed.wifi.networks;

            }
        } catch (e) {
        }
    }

    function refreshNetwork() {
        if (!wifiProc.running && !networkActionProc.running)
            wifiProc.running = true;

    }

    function scanWifiNetworks() {
        if (networkActionProc.running)
            return ;

        root.networkScanning = true;
        networkActionProc.command = ["python3", root.networkScriptPath, "scan"];
        networkActionProc.running = true;
    }

    function toggleWifiRadio() {
        var nextState = !root.wifiEnabled;
        root.wifiEnabled = nextState;
        if (!nextState) {
            root.wifiConnected = false;
            root.wifiNetworks = [];
        }
        networkActionProc.command = ["python3", root.networkScriptPath, "toggle_wifi", nextState ? "on" : "off"];
        networkActionProc.running = false;
        networkActionProc.running = true;
    }

    function connectWifi(ssid, password) {
        if (!ssid)
            return ;

        root.networkScanning = true;
        var args = ["python3", root.networkScriptPath, "connect", ssid];
        if (password && password.length > 0)
            args.push(password);

        networkActionProc.command = args;
        networkActionProc.running = false;
        networkActionProc.running = true;
    }

    function disconnectWifi(ssidOrDev) {
        var target = ssidOrDev || root.wifiSsid || root.wifiDevice;
        if (!target)
            return ;

        networkActionProc.command = ["python3", root.networkScriptPath, "disconnect", target];
        networkActionProc.running = false;
        networkActionProc.running = true;
    }

    function openNetwork(screenName) {
        root.toggleNetworkFlyout(screenName);
    }

    function toggleAudioFlyout(screenName) {
        if (root.flyoutOpen && root.activeFlyout === "audio" && (root.flyoutScreen === screenName || !screenName)) {
            root.closeFlyouts();
        } else {
            flyoutCloseTimer.stop();
            root.activeFlyout = "audio";
            root.flyoutScreen = screenName || root.flyoutScreen || "";
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
            root.flyoutScreen = screenName || root.flyoutScreen || "";
            root.flyoutVisible = true;
            root.flyoutOpen = true;
            root.refreshNotifications();
        }
    }

    function toggleNetworkFlyout(screenName) {
        if (root.flyoutOpen && root.activeFlyout === "network" && (root.flyoutScreen === screenName || !screenName)) {
            root.closeFlyouts();
        } else {
            flyoutCloseTimer.stop();
            root.activeFlyout = "network";
            root.flyoutScreen = screenName || root.flyoutScreen || "";
            root.flyoutVisible = true;
            root.flyoutOpen = true;
            root.refreshNetwork();
            if (root.wifiEnabled && root.wifiNetworks.length === 0)
                root.scanWifiNetworks();

        }
    }

    function toggleBluetoothFlyout(screenName) {
        if (root.flyoutOpen && root.activeFlyout === "bluetooth" && (root.flyoutScreen === screenName || !screenName)) {
            root.closeFlyouts();
        } else {
            flyoutCloseTimer.stop();
            root.activeFlyout = "bluetooth";
            root.flyoutScreen = screenName || root.flyoutScreen || "";
            root.flyoutVisible = true;
            root.flyoutOpen = true;
            root.refreshBluetooth();
        }
    }

    function closeFlyouts() {
        if (!root.flyoutOpen && !root.flyoutVisible)
            return ;

        root.flyoutOpen = false;
        flyoutCloseTimer.restart();
    }

    function openCalendar(screenName) {
        root.toggleCalendarFlyout(screenName);
    }

    function openBluetooth(screenName) {
        root.toggleBluetoothFlyout(screenName);
    }

    function openLauncher() {
        Quickshell.execDetached(["bash", "-c", "lunita-launcher 2>/dev/null || rofi -show drun 2>/dev/null || true"]);
    }

    function refreshMpris() {
        if (!mprisProc.running)
            mprisProc.running = true;

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

    function setBrightness(val) {
        var clamped = Math.max(5, Math.min(100, Math.round(val)));
        root.brightnessPercent = clamped;
        Quickshell.execDetached(["bash", "-c", "brightnessctl s " + clamped + "% 2>/dev/null || true"]);
    }

    function toggleAudioSinksExpanded() {
        root.audioSinksExpanded = !root.audioSinksExpanded;
        if (root.audioSinksExpanded)
            root.refreshAudioSinks();

    }

    function refreshAudioSinks() {
        if (!sinksProc.running)
            sinksProc.running = true;

    }

    function setAudioSink(sinkId) {
        Quickshell.execDetached(["python3", (Quickshell.env("HOME") || "") + "/.config/quickshell/dock/scripts/audio_sinks.py", "set", String(sinkId)]);
        var current = root.audioSinks.slice();
        for (var i = 0; i < current.length; i++) {
            current[i].active = (current[i].id === sinkId);
        }
        root.audioSinks = current;
    }

    function parseBluetoothState(raw) {
        if (!raw || raw.trim().length === 0)
            return ;

        try {
            var parsed = JSON.parse(raw.trim());
            if (parsed.hasAdapter !== undefined)
                root.bluetoothHasAdapter = !!parsed.hasAdapter;

            root.bluetoothEnabled = !!parsed.powered;
            root.bluetoothDeviceName = parsed.connectedDevice || "";
            if (Array.isArray(parsed.devices))
                root.bluetoothDevices = parsed.devices;

        } catch (e) {
        }
    }

    function refreshBluetooth() {
        if (!btProc.running && !btActionProc.running)
            btProc.running = true;

    }

    function toggleBluetooth() {
        var next = !root.bluetoothEnabled;
        root.bluetoothEnabled = next;
        if (!next)
            root.bluetoothDeviceName = "";

        btActionProc.command = ["python3", root.bluetoothScriptPath, "power", next ? "on" : "off"];
        btActionProc.running = false;
        btActionProc.running = true;
    }

    function scanBluetoothDevices() {
        if (btActionProc.running)
            return ;

        root.bluetoothScanning = true;
        btActionProc.command = ["python3", root.bluetoothScriptPath, "scan"];
        btActionProc.running = true;
    }

    function connectBluetoothDevice(mac) {
        if (!mac)
            return ;

        root.bluetoothPendingMac = mac;
        btActionProc.command = ["python3", root.bluetoothScriptPath, "connect", mac];
        btActionProc.running = false;
        btActionProc.running = true;
    }

    function disconnectBluetoothDevice(mac) {
        if (!mac)
            return ;

        root.bluetoothPendingMac = mac;
        btActionProc.command = ["python3", root.bluetoothScriptPath, "disconnect", mac];
        btActionProc.running = false;
        btActionProc.running = true;
    }

    function parseNotificationsJson(raw) {
        if (!raw || raw.trim().length === 0)
            return ;

        try {
            var list = JSON.parse(raw.trim());
            if (Array.isArray(list))
                root.notificationsList = list;

        } catch (e) {
        }
    }

    function refreshNotifications() {
        if (!notifsProc.running)
            notifsProc.running = true;

    }

    function clearAllNotifications() {
        root.notificationsList = [];
        Quickshell.execDetached(["bash", "-c", "printf '[]\\n' > /tmp/notifications_cache.json.tmp && mv -f /tmp/notifications_cache.json.tmp /tmp/notifications_cache.json; quickshell ipc -c notifications call notifications clear 2>/dev/null || true"]);
    }

    function dismissNotification(id) {
        var current = root.notificationsList.slice();
        var next = [];
        for (var i = 0; i < current.length; i++) {
            if (current[i].id !== id)
                next.push(current[i]);

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

    function adjustFocus(delta) {
        if (root.focusActive)
            return ;

        var next = root.focusMinutes + delta;
        if (next < 5)
            next = 5;

        if (next > 120)
            next = 120;

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

    function resolveTrayIcons(items) {
        if (!items || items.length === 0)
            return ;

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

    function toggleWidgetsEdit() {
        Quickshell.execDetached(["lunita-widgets-toggle"]);
    }

    function openWidgetsManager() {
        Quickshell.execDetached(["lunita-widgets-manager", "--tab", "desktop"]);
    }

    ListModel {
        id: pinnedAppsModel
    }

    // Running Unpinned Apps
    ListModel {
        id: unpinnedAppsModel
    }

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
            onRead: (text) => {
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
            if (!root.isSelfSaving)
                root.parsePinnedJson(pinnedConfigFile.text());

        }
    }

    Connections {
        function onActiveToplevelChanged() {
            root.refreshClients();
        }

        function onRawEvent(event) {
            if (!event)
                return ;

            var ev = event.name;
            if (ev === "openwindow" || ev === "closewindow" || ev === "movewindow" || ev === "activewindow" || ev === "activewindowv2" || ev === "focusedmon" || ev === "changefloatingmode")
                root.refreshClients();

        }

        target: Hyprland
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
            onRead: (data) => {
                try {
                    var parsed = JSON.parse(data);
                    if (Array.isArray(parsed)) {
                        root.hyprClients = parsed;
                        root.updateRunningApps();
                    }
                } catch (e) {
                }
            }
        }

    }

    Process {
        id: activeWindowProc

        command: ["bash", "-c", "hyprctl -j activewindow 2>/dev/null | tr -d '\\n' || echo '{}'"]

        stdout: SplitParser {
            onRead: (data) => {
                try {
                    var parsed = JSON.parse(data);
                    root.activeWindowAddress = parsed.address || "";
                    root.activeWindowClass = (parsed["class"] || "").toLowerCase();
                    root.updateRunningApps();
                } catch (e) {
                }
            }
        }

    }

    Process {
        id: appIconsScannerProc

        command: ["lunita-icon-resolver", "--scan-apps"]
        running: true

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (data) => {
                var trimmed = data.trim();
                if (!trimmed)
                    return ;

                try {
                    var parsed = JSON.parse(trimmed);
                    if (parsed && typeof parsed === "object") {
                        root.appIconsMap = Object.assign({
                        }, root.appIconsMap, parsed);
                        root.updateRunningApps();
                    }
                } catch (e) {
                }
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
                if (unpinnedAppsModel.get(i).isClosing)
                    unpinnedAppsModel.remove(i);

            }
        }
    }

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
            var months = ["enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"];
            root.dateFullStr = days[now.getDay()] + ", " + now.getDate() + " de " + months[now.getMonth()] + " de " + now.getFullYear();
        }
    }

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
            onRead: (data) => {
                var line = data.trim();
                root.isVolumeMuted = (line.indexOf("[MUTED]") !== -1);
                var match = line.match(/([0-9]+(?:\.[0-9]+)?)/);
                if (match) {
                    var val = parseFloat(match[1]);
                    if (val <= 1.5)
                        root.volumePercent = Math.min(100, Math.round(val * 100));
                    else
                        root.volumePercent = Math.min(100, Math.round(val));
                }
            }
        }

    }

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
            onRead: (data) => {
                var line = data.trim();
                root.micMuted = (line.indexOf("[MUTED]") !== -1);
            }
        }

    }

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
            onRead: (data) => {
                try {
                    var parsed = JSON.parse(data);
                    if (parsed && Array.isArray(parsed.keyboards)) {
                        for (var i = 0; i < parsed.keyboards.length; i++) {
                            var k = parsed.keyboards[i];
                            var km = (k.active_keymap || "").toLowerCase();
                            var lay = (k.layout || "").toLowerCase();
                            if (km.indexOf("spanish") !== -1 || km.indexOf("español") !== -1 || lay === "es") {
                                root.keyboardLayout = "ESP";
                                return ;
                            } else if (km.indexOf("english") !== -1 || lay === "us") {
                                root.keyboardLayout = "ENG";
                                return ;
                            }
                        }
                    }
                } catch (e) {
                }
            }
        }

    }

    Timer {
        id: wifiTimer

        interval: 4500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshNetwork()
    }

    Process {
        id: wifiProc

        command: ["python3", root.networkScriptPath, "status"]

        stdout: SplitParser {
            onRead: (data) => {
                root.parseNetworkState(data);
            }
        }

    }

    Process {
        id: networkActionProc

        onExited: {
            root.networkScanning = false;
        }

        stdout: SplitParser {
            onRead: (data) => {
                root.networkScanning = false;
                root.parseNetworkState(data);
            }
        }

    }

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
            onRead: (data) => {
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
            onRead: (data) => {
                var st = data.trim().toLowerCase();
                root.batteryCharging = (st === "charging");
            }
        }

    }

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

    Timer {
        id: mprisTimer

        interval: 1200
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!mprisProc.running)
                mprisProc.running = true;

        }
    }

    Process {
        id: mprisProc

        command: ["bash", "-c", "playerctl metadata --format '{{playerName}}:::{{title}}:::{{artist}}:::{{mpris:artUrl}}:::{{status}}:::{{position}}:::{{mpris:length}}' 2>/dev/null || echo ''"]

        stdout: SplitParser {
            onRead: (data) => {
                var str = data.trim();
                if (!str || str.indexOf(":::") === -1) {
                    root.mprisAvailable = false;
                    root.mprisPlaying = false;
                    return ;
                }
                var parts = str.split(":::");
                if (!parts[1] && !parts[2]) {
                    root.mprisAvailable = false;
                    root.mprisPlaying = false;
                    return ;
                }
                root.mprisAvailable = true;
                var rawPlayer = parts[0] ? parts[0].trim() : "spotify";
                root.mprisPlayerName = rawPlayer.charAt(0).toUpperCase() + rawPlayer.slice(1);
                root.mprisTitle = parts[1] || "Lil Mama (with Trevor Daniel)";
                root.mprisArtist = parts[2] || "Miles Wesley";
                root.mprisArtUrl = parts[3] || "";
                root.mprisPlaying = (parts[4] && parts[4].toLowerCase() === "playing");
                if (parts[5])
                    root.mprisPosition = parseFloat(parts[5]) / 1e+06;

                if (parts[6])
                    root.mprisLength = parseFloat(parts[6]) / 1e+06;

            }
        }

    }

    Timer {
        id: brightnessTimer

        interval: 3500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!brightnessProc.running)
                brightnessProc.running = true;

        }
    }

    Process {
        id: brightnessProc

        command: ["bash", "-c", "brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%' || echo '80'"]

        stdout: SplitParser {
            onRead: (data) => {
                var num = parseInt(data.trim());
                if (!isNaN(num))
                    root.brightnessPercent = num;

            }
        }

    }

    Process {
        id: sinksProc

        command: ["python3", (Quickshell.env("HOME") || "") + "/.config/quickshell/dock/scripts/audio_sinks.py"]

        stdout: SplitParser {
            onRead: (data) => {
                try {
                    var parsed = JSON.parse(data.trim());
                    if (Array.isArray(parsed))
                        root.audioSinks = parsed;

                } catch (e) {
                }
            }
        }

    }

    Timer {
        id: btTimer

        interval: 4000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshBluetooth()
    }

    Process {
        id: btProc

        command: ["python3", root.bluetoothScriptPath, "status"]

        stdout: SplitParser {
            onRead: (data) => {
                root.parseBluetoothState(data);
            }
        }

    }

    Process {
        id: btActionProc

        onExited: {
            root.bluetoothScanning = false;
            root.bluetoothPendingMac = "";
        }

        stdout: SplitParser {
            onRead: (data) => {
                root.bluetoothScanning = false;
                root.bluetoothPendingMac = "";
                root.parseBluetoothState(data);
            }
        }

    }

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

    Timer {
        id: notifsFallbackTimer

        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!notifsProc.running)
                notifsProc.running = true;

        }
    }

    Process {
        id: notifsProc

        command: ["bash", "-c", "jq -c . /tmp/notifications_cache.json 2>/dev/null || tr -d '\\n' < /tmp/notifications_cache.json 2>/dev/null || echo '[]'"]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (data) => {
                root.parseNotificationsJson(data);
            }
        }

    }

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

    Process {
        id: trayResolverProc

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (data) => {
                var line = data.trim();
                if (!line || line.indexOf("|") === -1)
                    return ;

                var parts = line.split("|");
                if (parts.length >= 2) {
                    var raw = parts[0];
                    var resolved = parts.slice(1).join("|").trim();
                    if (resolved !== "") {
                        var mapCopy = Object.assign({
                        }, root.trayIconsMap);
                        mapCopy[raw] = resolved;
                        root.trayIconsMap = mapCopy;
                    }
                }
            }
        }

    }

    Timer {
        id: widgetsEditTimer

        interval: 350
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!checkWidgetsEditingProc.running)
                checkWidgetsEditingProc.running = true;

        }
    }

    Process {
        id: checkWidgetsEditingProc

        command: ["bash", "-c", "if [ -f /tmp/lunita_widgets_editing ]; then cat /tmp/lunita_widgets_editing; else echo 0; fi"]

        stdout: SplitParser {
            onRead: (data) => {
                root.widgetsEditing = (data.trim() === "1");
            }
        }

    }

}
