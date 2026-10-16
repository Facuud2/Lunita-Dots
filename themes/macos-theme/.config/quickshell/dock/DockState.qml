import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Item {
    id: root

    // ── Reactive Properties & Lists ──
    property var pinnedList: []
    property var runningList: []
    property int trashCount: 0
    property var hyprClients: []

    // ── Active Context Menu State (Per-Monitor Isolated) ──
    property bool contextMenuVisible: false
    property string contextMenuScreen: ""
    property var contextMenuApp: null
    property var contextMenuRunning: null
    property bool contextMenuIsTrash: false
    property bool contextMenuIsFolder: false
    property real contextMenuX: 0
    property real contextMenuY: 0

    // ── Live Drag & Reorder State ──
    property bool isDraggingItem: false
    property string dragSection: ""
    property int dragSourceIndex: -1
    property int dragTargetIndex: -1
    property var runningOrderKeys: []

    // ── Add App Modal State (Per-Monitor Isolated) ──
    property bool addModalVisible: false
    property string addModalScreen: ""
    property string addModalQuery: ""
    property var installedAppsList: []

    // ── Default Applications Fallback ──
    readonly property var defaultPinned: [
        {
            id: "finder",
            name: "Finder",
            iconFile: "finder.svg",
            fallbackIcon: "system-file-manager",
            cmd: "dolphin",
            matchClasses: ["dolphin", "org.kde.dolphin", "nautilus", "thunar"]
        },
        {
            id: "launchpad",
            name: "Launchpad",
            iconFile: "launchpad.svg",
            fallbackIcon: "view-app-grid-symbolic",
            cmd: "lunita-launcher",
            matchClasses: []
        },
        {
            id: "zen",
            name: "Zen Browser",
            fallbackIcon: "zen-browser",
            cmd: "zen-browser || gtk-launch zen.desktop || gtk-launch zen",
            matchClasses: ["zen", "zen-alpha", "zen-browser"]
        },
        {
            id: "messages",
            name: "Mensajes",
            iconFile: "messages.svg",
            fallbackIcon: "chat",
            cmd: "telegram-desktop || discord || vesktop",
            matchClasses: ["telegram", "telegram-desktop", "discord", "vesktop"]
        },
        {
            id: "mail",
            name: "Mail",
            iconFile: "mail.svg",
            fallbackIcon: "mail-client",
            cmd: "thunderbird || zen-browser https://mail.google.com",
            matchClasses: ["thunderbird"]
        },
        {
            id: "maps",
            name: "Mapas",
            iconFile: "maps.svg",
            fallbackIcon: "maps",
            cmd: "zen-browser https://maps.google.com",
            matchClasses: []
        },
        {
            id: "photos",
            name: "Fotos",
            iconFile: "photos.svg",
            fallbackIcon: "image-viewer",
            cmd: "gwenview || loupe || eog",
            matchClasses: ["gwenview", "loupe", "eog"]
        },
        {
            id: "facetime",
            name: "FaceTime",
            iconFile: "facetime.svg",
            fallbackIcon: "camera-video",
            cmd: "weylus || cheese || kamoso",
            matchClasses: ["weylus", "cheese"]
        },
        {
            id: "phone",
            name: "Teléfono",
            iconFile: "phone.svg",
            fallbackIcon: "call-start",
            cmd: "whatsapp-for-linux || zen-browser https://web.whatsapp.com",
            matchClasses: ["whatsapp", "whatsapp-for-linux"]
        },
        {
            id: "calendar",
            name: "Calendario",
            iconFile: "calendar.svg",
            fallbackIcon: "x-office-calendar",
            cmd: "gnome-calendar || korganizer || zen-browser https://calendar.google.com",
            matchClasses: ["gnome-calendar", "korganizer"]
        },
        {
            id: "contacts",
            name: "Contactos",
            iconFile: "contacts.svg",
            fallbackIcon: "x-office-address-book",
            cmd: "gnome-contacts || zen-browser https://contacts.google.com",
            matchClasses: ["gnome-contacts"]
        },
        {
            id: "reminders",
            name: "Recordatorios",
            iconFile: "reminders.svg",
            fallbackIcon: "checkbox",
            cmd: "zen-browser https://keep.google.com",
            matchClasses: []
        },
        {
            id: "notes",
            name: "Notas",
            iconFile: "notes.svg",
            fallbackIcon: "accessories-text-editor",
            cmd: "obsidian || notepadqq || kate",
            matchClasses: ["obsidian", "notepadqq", "kate"]
        },
        {
            id: "appletv",
            name: "TV",
            iconFile: "appletv.svg",
            fallbackIcon: "video-player",
            cmd: "mpv || vlc || celluloid",
            matchClasses: ["mpv", "vlc", "celluloid"]
        },
        {
            id: "music",
            name: "Música",
            iconFile: "music.svg",
            fallbackIcon: "multimedia-audio-player",
            cmd: "spotify || cider || amberol",
            matchClasses: ["spotify", "Spotify", "cider", "apple-music", "amberol"]
        },
        {
            id: "code",
            name: "Visual Studio Code",
            fallbackIcon: "vscode",
            cmd: "code || vscodium",
            matchClasses: ["code", "Code", "vscodium"]
        },
        {
            id: "antigravity",
            name: "Antigravity",
            fallbackIcon: "antigravity",
            cmd: "antigravity",
            matchClasses: ["antigravity"]
        },
        {
            id: "appstore",
            name: "App Store",
            iconFile: "appstore.svg",
            fallbackIcon: "software-store",
            cmd: "discover || gnome-software || pamac-manager || rofi -show drun",
            matchClasses: ["discover", "gnome-software", "pamac-manager"]
        },
        {
            id: "terminal",
            name: "Terminal",
            iconFile: "terminal.svg",
            fallbackIcon: "utilities-terminal",
            cmd: "kitty",
            matchClasses: ["kitty", "alacritty", "foot", "org.gnome.Terminal", "wezterm"]
        },
        {
            id: "settings",
            name: "Ajustes del Sistema",
            iconFile: "settings.svg",
            fallbackIcon: "preferences-system",
            cmd: "systemsettings || gnome-control-center",
            matchClasses: ["systemsettings", "gnome-control-center", "pavucontrol", "lxappearance"]
        }
    ]

    property var rightStackApps: [
        {
            id: "shortcuts",
            name: "Atajos",
            iconFile: "shortcuts.svg",
            fallbackIcon: "system-run",
            cmd: "rofi -show drun",
            matchClasses: []
        },
        {
            id: "keychain",
            name: "Contraseñas y Llaveros",
            iconFile: "keychain.svg",
            fallbackIcon: "dialog-password",
            cmd: "keepassxc || seahorse || bitwarden",
            matchClasses: ["keepassxc", "seahorse", "bitwarden"]
        }
    ]

    // ── Persistence: Load Pinned Apps ──
    readonly property string configFilePath: Quickshell.env("HOME") + "/.config/lunita/dock-pinned.json"
    property bool isSelfSaving: false
    property bool hasLoadedFromDisk: false

    Timer {
        id: saveTimer
        interval: 1200
        repeat: false
        onTriggered: root.isSelfSaving = false
    }

    Timer {
        id: ensureTimer
        interval: 600
        running: true
        repeat: false
        onTriggered: root.ensureInitialPinned()
    }

    // Instant initial load via Process
    Process {
        id: initFileLoader
        command: ["bash", "-c", "cat ~/.config/lunita/dock-pinned.json 2>/dev/null | tr '\\n' ' ' || echo ''"]
        stdout: SplitParser {
            onRead: function(text) {
                root.parseAndApplyPinned(text)
            }
        }
    }

    FileView {
        id: configFile
        path: root.configFilePath
        watchChanges: true
        onLoaded: {
            root.parseAndApplyPinned(configFile.text())
        }
        onFileChanged: {
            if (!root.isSelfSaving) {
                root.parseAndApplyPinned(configFile.text())
            }
        }
    }

    function parseAndApplyPinned(raw) {
        if (!raw || raw.trim().length === 0) return
        try {
            const parsed = JSON.parse(raw)
            if (Array.isArray(parsed) && parsed.length > 0) {
                root.hasLoadedFromDisk = true
                let cleaned = parsed.map(function(item) {
                    if (!item) return item
                    let itemId = (item.id || "").toLowerCase()
                    let itemName = (item.name || "").toLowerCase()
                    let itemCmd = (item.cmd || "").toLowerCase()

                    // Corrección específica para Zen Browser
                    if (itemId === "zen" || itemName.includes("zen") || itemCmd.includes("zen")) {
                        item.fallbackIcon = "zen-browser"
                        item.cmd = "zen-browser || gtk-launch zen.desktop || gtk-launch zen"
                        delete item.iconFile
                        item.matchClasses = ["zen", "zen-alpha", "zen-browser"]
                    }

                    // Corrección específica para Visual Studio Code
                    if (itemId === "code" || itemName.includes("visual studio code")) {
                        item.fallbackIcon = "vscode"
                        delete item.iconFile
                        if (Array.isArray(item.matchClasses)) {
                            item.matchClasses = item.matchClasses.filter(function(c) { return c.toLowerCase() !== "antigravity" })
                        }
                        if (item.cmd && item.cmd.includes("antigravity")) {
                            item.cmd = "code || vscodium"
                        }
                    }

                    // Corrección específica para Antigravity
                    if (itemId === "antigravity" || itemName.includes("antigravity")) {
                        item.fallbackIcon = "antigravity"
                        delete item.iconFile
                        item.cmd = "antigravity"
                        item.matchClasses = ["antigravity"]
                    }

                    // Sanear gtk-launch general (evitar encerrar pipes || o && en comillas)
                    if (item.cmd) {
                        let c = item.cmd.trim()
                        if (c.startsWith("gtk-launch ") && !c.includes("'") && !c.includes('"') && !c.includes("||") && !c.includes("&&") && !c.includes(";")) {
                            let arg = c.substring(11).trim()
                            if (arg.includes(" ")) {
                                item.cmd = "gtk-launch \"" + arg + "\""
                            }
                        }
                    }
                    return item
                })
                root.pinnedList = []
                root.pinnedList = cleaned
            }
        } catch (e) {
            console.warn("[DockState] Falló lectura de dock-pinned.json:", e)
        }
    }

    function ensureInitialPinned() {
        if (!root.hasLoadedFromDisk && (!root.pinnedList || root.pinnedList.length === 0)) {
            root.pinnedList = []
            root.pinnedList = root.defaultPinned
            root.savePinnedApps()
        }
    }

    function savePinnedApps() {
        if (!root.pinnedList || root.pinnedList.length === 0) return
        root.isSelfSaving = true
        root.hasLoadedFromDisk = true
        saveTimer.restart()
        const jsonStr = JSON.stringify(root.pinnedList, null, 2)
        const escaped = jsonStr.replace(/'/g, "'\\''")
        const cmd = "mkdir -p ~/.config/lunita && printf '%s\\n' '" + escaped + "' > ~/.config/lunita/dock-pinned.json.tmp && mv -f ~/.config/lunita/dock-pinned.json.tmp ~/.config/lunita/dock-pinned.json"
        Quickshell.execDetached(["bash", "-c", cmd])
    }

    // ── Pin / Unpin / Reorder ──
    function pinApp(appObj) {
        if (!appObj || !appObj.id) return
        for (let i = 0; i < root.pinnedList.length; i++) {
            if (root.pinnedList[i].id === appObj.id) return
        }
        let copy = root.pinnedList.slice()
        copy.push(appObj)
        root.pinnedList = []
        root.pinnedList = copy
        root.savePinnedApps()
    }

    function unpinApp(appId) {
        if (!appId) return
        let copy = root.pinnedList.filter(function(p) { return p.id !== appId })
        root.pinnedList = []
        root.pinnedList = copy
        root.savePinnedApps()
    }

    function isPinned(appId) {
        if (!appId) return false
        for (let i = 0; i < root.pinnedList.length; i++) {
            if (root.pinnedList[i].id === appId) return true
        }
        return false
    }

    function getPinnedIndex(appId) {
        if (!appId) return -1
        for (let i = 0; i < root.pinnedList.length; i++) {
            if (root.pinnedList[i].id === appId) return i
        }
        return -1
    }

    function reorderPinnedApp(sourceIdx, targetIdx) {
        if (sourceIdx === targetIdx || sourceIdx < 0 || targetIdx < 0 ||
            sourceIdx >= root.pinnedList.length || targetIdx >= root.pinnedList.length) return
        let copy = root.pinnedList.slice()
        let item = copy.splice(sourceIdx, 1)[0]
        copy.splice(targetIdx, 0, item)
        root.pinnedList = []
        root.pinnedList = copy
        root.savePinnedApps()
    }

    function movePinnedApp(appId, direction) {
        let idx = root.getPinnedIndex(appId)
        if (idx === -1) return
        let targetIdx = idx + direction
        if (targetIdx >= 0 && targetIdx < root.pinnedList.length) {
            root.reorderPinnedApp(idx, targetIdx)
        }
    }

    // ── Live Drag & Drop Reordering Engine ──
    function getSectionCount(section) {
        if (section === "main") {
            return root.pinnedList.length + root.runningList.length
        }
        if (section === "right") {
            return root.rightStackApps.length
        }
        return 0
    }

    function startDrag(section, sourceIdx) {
        root.closeContextMenu()
        root.dragSection = section
        root.dragSourceIndex = sourceIdx
        root.dragTargetIndex = sourceIdx
        root.isDraggingItem = true
    }

    function updateDragTarget(targetIdx) {
        if (!root.isDraggingItem) return
        let total = root.getSectionCount(root.dragSection)
        if (total <= 0) return
        let clamped = Math.max(0, Math.min(total - 1, targetIdx))
        if (root.dragTargetIndex !== clamped) {
            root.dragTargetIndex = clamped
        }
    }

    function cancelDrag() {
        root.isDraggingItem = false
        root.dragSection = ""
        root.dragSourceIndex = -1
        root.dragTargetIndex = -1
    }

    function commitDrag() {
        if (!root.isDraggingItem) return
        let sec = root.dragSection
        let src = root.dragSourceIndex
        let dst = root.dragTargetIndex
        root.cancelDrag()

        if (src === dst || src < 0 || dst < 0) return

        if (sec === "right") {
            if (src < root.rightStackApps.length && dst < root.rightStackApps.length) {
                let copy = root.rightStackApps.slice()
                let item = copy.splice(src, 1)[0]
                copy.splice(dst, 0, item)
                root.rightStackApps = copy
            }
            return
        }

        if (sec === "main") {
            let pLen = root.pinnedList.length
            let rLen = root.runningList.length

            // Case 1: Dragging a pinned app
            if (src < pLen) {
                let targetPinnedIdx = Math.max(0, Math.min(pLen - 1, dst))
                if (src !== targetPinnedIdx) {
                    root.reorderPinnedApp(src, targetPinnedIdx)
                }
                return
            }

            // Case 2: Dragging a running unpinned app
            let rSrc = src - pLen
            if (rSrc >= 0 && rSrc < rLen) {
                let runObj = root.runningList[rSrc]
                // If dragged into the pinned apps region, pin & insert at that position
                if (dst < pLen && runObj) {
                    let runCls = (runObj.clazz || "").toLowerCase()
                    let matchedInstalled = null
                    for (let i = 0; i < root.installedAppsList.length; i++) {
                        let itm = root.installedAppsList[i]
                        if (itm.matchClasses && itm.matchClasses.indexOf(runCls) !== -1) {
                            matchedInstalled = itm
                            break
                        }
                    }
                    let newId = matchedInstalled ? matchedInstalled.id : (runObj.clazz || runObj.name || "app").toLowerCase().replace(/[^a-z0-9_-]/g, "-")
                    let newPinned = {
                        id: newId,
                        name: matchedInstalled ? matchedInstalled.displayName : (runObj.name || runObj.clazz),
                        iconPath: matchedInstalled ? matchedInstalled.iconPath : "",
                        fallbackIcon: matchedInstalled ? matchedInstalled.iconName : (runObj.icon || newId),
                        cmd: matchedInstalled ? matchedInstalled.cmd : ("gtk-launch " + runObj.clazz + " || " + runObj.clazz),
                        matchClasses: [runCls]
                    }
                    let copy = root.pinnedList.slice()
                    copy.splice(dst, 0, newPinned)
                    root.pinnedList = copy
                    root.savePinnedApps()
                    root.updateRunningUnpinned(root.hyprClients)
                } else {
                    // Reorder within runningList
                    let rDst = Math.max(0, Math.min(rLen - 1, dst - pLen))
                    if (rSrc !== rDst) {
                        let rCopy = root.runningList.slice()
                        let moved = rCopy.splice(rSrc, 1)[0]
                        rCopy.splice(rDst, 0, moved)
                        root.runningOrderKeys = rCopy.map(function(it) { return (it.clazz || "").toLowerCase() })
                        root.runningList = rCopy
                    }
                }
            }
        }
    }

    // ── Hyprland Running Clients Sync ──
    Process {
        id: clientsProc
        command: ["bash", "-c", "hyprctl clients -j 2>/dev/null | jq -c . 2>/dev/null || echo '[]'"]
        stdout: SplitParser {
            onRead: function(text) {
                try {
                    let parsed = JSON.parse(text)
                    if (Array.isArray(parsed)) {
                        root.hyprClients = parsed
                        if (!root.isDraggingItem) {
                            root.updateRunningUnpinned(parsed)
                        }
                    }
                } catch (e) {}
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!root.isDraggingItem) {
                clientsProc.running = true
            }
            root.updateTrashCount()
        }
    }

    // ── Ignored Background Daemons & Applets ──
    readonly property var ignoredClasses: [
        "macos-dock",
        "ags",
        "quickshell",
        "waybar",
        "eww",
        "hyprlock",
        "blueman-applet",
        "blueman-tray",
        "nm-applet",
        "xembedsniproxy",
        "pasystray",
        "awww-daemon",
        "swaybg",
        "hyprpaper",
        "hyprpolkitagent",
        "polkit-gnome-authentication-agent-1",
        "polkit-kde-authentication-agent-1",
        "org.kde.polkit-kde-authentication-agent-1",
        "polkit-agent",
        "gcr-prompter",
        "pinentry-qt",
        "pinentry-gtk-2",
        "pinentry-gnome3",
        "flameshot"
    ]

    function isClientIgnored(c) {
        if (!c || !c.mapped || c.hidden) return true
        if (c.size && (c.size[0] <= 1 || c.size[1] <= 1)) return true
        let cls = (c.class || "").toLowerCase()
        let icls = (c.initialClass || "").toLowerCase()

        for (let i = 0; i < root.ignoredClasses.length; i++) {
            let ign = root.ignoredClasses[i].toLowerCase()
            if (cls === ign || icls === ign) return true
        }

        if (cls.endsWith("-applet") || icls.endsWith("-applet") ||
            cls.endsWith("-tray") || icls.endsWith("-tray") ||
            cls.endsWith("-daemon") || icls.endsWith("-daemon") ||
            cls.endsWith("applet") || icls.endsWith("applet")) {
            return true
        }

        return false
    }

    function isAppRunning(pinned) {
        if (!pinned || !pinned.matchClasses || pinned.matchClasses.length === 0) return false
        for (let i = 0; i < root.hyprClients.length; i++) {
            let c = root.hyprClients[i]
            if (root.isClientIgnored(c)) continue
            let cls = (c.class || "").toLowerCase()
            let icls = (c.initialClass || "").toLowerCase()
            for (let j = 0; j < pinned.matchClasses.length; j++) {
                let m = pinned.matchClasses[j].toLowerCase()
                if (cls.includes(m) || icls.includes(m)) return true
            }
        }
        return false
    }

    function getMatchingClients(pinned) {
        let res = []
        if (!pinned || !pinned.matchClasses || pinned.matchClasses.length === 0) return res
        for (let i = 0; i < root.hyprClients.length; i++) {
            let c = root.hyprClients[i]
            if (root.isClientIgnored(c)) continue
            let cls = (c.class || "").toLowerCase()
            let icls = (c.initialClass || "").toLowerCase()
            for (let j = 0; j < pinned.matchClasses.length; j++) {
                let m = pinned.matchClasses[j].toLowerCase()
                if (cls.includes(m) || icls.includes(m)) {
                    res.push(c)
                    break
                }
            }
        }
        return res
    }

    function updateRunningUnpinned(clientList) {
        let allPinned = root.pinnedList.concat(root.rightStackApps)
        let unpinned = []
        let seenClasses = {}

        for (let i = 0; i < clientList.length; i++) {
            let c = clientList[i]
            if (root.isClientIgnored(c)) continue

            let cls = (c.class || "").toLowerCase()
            let icls = (c.initialClass || "").toLowerCase()

            let isPinnedApp = false
            for (let j = 0; j < allPinned.length; j++) {
                let p = allPinned[j]
                if (p.matchClasses) {
                    for (let k = 0; k < p.matchClasses.length; k++) {
                        let m = p.matchClasses[k].toLowerCase()
                        if (cls.includes(m) || icls.includes(m)) {
                            isPinnedApp = true
                            break
                        }
                    }
                }
                if (isPinnedApp) break
            }

            if (!isPinnedApp) {
                let key = cls || icls || c.title
                if (key && !seenClasses[key]) {
                    seenClasses[key] = true
                    unpinned.push({
                        id: "running-" + c.address,
                        name: c.title ? c.title.split(" — ")[0].slice(0, 24) : c.class,
                        clazz: c.class,
                        address: c.address,
                        icon: c.class.toLowerCase(),
                        count: 1
                    })
                }
            }
        }

        if (root.runningOrderKeys && root.runningOrderKeys.length > 0) {
            unpinned.sort(function(a, b) {
                let ka = (a.clazz || "").toLowerCase()
                let kb = (b.clazz || "").toLowerCase()
                let ia = root.runningOrderKeys.indexOf(ka)
                let ib = root.runningOrderKeys.indexOf(kb)
                if (ia === -1) ia = 9999
                if (ib === -1) ib = 9999
                return ia - ib
            })
        }

        root.runningList = unpinned
    }

    // ── Window & Action Dispatch ──
    function focusClient(c) {
        if (!c) return
        let wsCmd = ""
        if (c.workspace) {
            if (typeof c.workspace.id === "number" && c.workspace.id > 0) {
                wsCmd = "hyprctl dispatch 'hl.dsp.focus({ workspace = " + c.workspace.id + " })' 2>/dev/null || hyprctl dispatch workspace " + c.workspace.id + " 2>/dev/null; "
            } else if (c.workspace.name) {
                wsCmd = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"" + c.workspace.name + "\" })' 2>/dev/null || hyprctl dispatch workspace name:" + c.workspace.name + " 2>/dev/null; "
            }
        }
        let addr = c.address || ""
        let focusCmd = wsCmd + "hyprctl dispatch 'hl.dsp.focus({ window = \"address:" + addr + "\" })' 2>/dev/null || hyprctl dispatch focuswindow address:" + addr
        Quickshell.execDetached(["bash", "-c", focusCmd])
    }

    function focusAddress(address) {
        if (!address) return
        let found = null
        for (let i = 0; i < root.hyprClients.length; i++) {
            if (root.hyprClients[i].address === address) {
                found = root.hyprClients[i]
                break
            }
        }
        if (found) {
            root.focusClient(found)
        } else {
            let cmd = "hyprctl dispatch 'hl.dsp.focus({ window = \"address:" + address + "\" })' 2>/dev/null || hyprctl dispatch focuswindow address:" + address
            Quickshell.execDetached(["bash", "-c", cmd])
        }
    }

    function focusOrLaunch(pinned) {
        if (!pinned) return
        let matching = root.getMatchingClients(pinned)
        if (matching.length > 0) {
            root.focusClient(matching[0])
        } else {
            root.launchAppCmd(pinned.cmd)
        }
    }

    function launchNew(cmd) {
        root.launchAppCmd(cmd)
    }

    function launchAppCmd(cmd) {
        if (!cmd) return
        let envPrefix = "if [ -z \"${DISPLAY:-}\" ]; then " +
            "disp=\"$(systemctl --user show-environment 2>/dev/null | sed -n 's/^DISPLAY=//p' | head -n 1 || true)\"; " +
            "if [ -z \"$disp\" ]; then " +
            "for s in /tmp/.X11-unix/X*[0-9]; do if [ -S \"$s\" ] && [ -O \"$s\" ]; then disp=\":${s##*X}\"; break; fi; done; " +
            "fi; " +
            "[ -n \"$disp\" ] && export DISPLAY=\"$disp\"; " +
            "fi; "
        Quickshell.execDetached(["bash", "-c", envPrefix + "(" + cmd + ") &"])
    }

    function closeApp(pinned, runningAddress) {
        if (runningAddress) {
            let cmd = "hyprctl dispatch 'hl.dsp.window.close({ address = \"" + runningAddress + "\" })' 2>/dev/null || hyprctl dispatch closewindow address:" + runningAddress
            Quickshell.execDetached(["bash", "-c", cmd])
            return
        }
        if (pinned) {
            let matching = root.getMatchingClients(pinned)
            for (let i = 0; i < matching.length; i++) {
                let addr = matching[i].address
                let cmd = "hyprctl dispatch 'hl.dsp.window.close({ address = \"" + addr + "\" })' 2>/dev/null || hyprctl dispatch closewindow address:" + addr
                Quickshell.execDetached(["bash", "-c", cmd])
            }
        }
    }

    function openDownloads() {
        Quickshell.execDetached(["bash", "-c", "dolphin ~/Descargas || dolphin ~/Downloads || xdg-open ~/Downloads &"])
    }

    function openTrash() {
        Quickshell.execDetached(["bash", "-c", "dolphin trash:/// || nautilus trash:/// || xdg-open trash:/// &"])
    }

    function emptyTrash() {
        Quickshell.execDetached(["bash", "-c", "rm -rf ~/.local/share/Trash/files/* ~/.local/share/Trash/info/* 2>/dev/null || true"])
        root.updateTrashCount()
    }

    // ── Trash Counter ──
    Process {
        id: trashProc
        command: ["bash", "-c", "ls -1 ~/.local/share/Trash/files 2>/dev/null | wc -l"]
        stdout: SplitParser {
            onRead: function(text) {
                let cnt = parseInt(text.trim(), 10)
                root.trashCount = isNaN(cnt) ? 0 : cnt
            }
        }
    }

    function updateTrashCount() {
        trashProc.running = true
    }

    // ── Safe Icon Source Resolver (Never returns missing-texture image://icon/) ──
    function resolveIconSource(iconVal) {
        if (!iconVal || iconVal.length === 0) {
            return Qt.resolvedUrl("assets/icons/launchpad.svg")
        }
        if (iconVal.startsWith("file://") || iconVal.startsWith("/")) {
            return iconVal.startsWith("file://") ? iconVal : ("file://" + iconVal)
        }
        if (iconVal.startsWith("assets/icons/") || iconVal.startsWith("qrc:/")) {
            return Qt.resolvedUrl(iconVal)
        }

        let lower = iconVal.toLowerCase()
        let candidates = [iconVal, lower]
        if (lower === "zen" || lower === "zen-alpha" || lower.includes("zen-browser")) {
            candidates.unshift("zen-browser")
        } else if (lower === "antigravity" || lower.includes("antigravity")) {
            candidates.unshift("antigravity")
        } else if (lower === "code" || lower === "vscode" || lower === "visual-studio-code" || lower === "com.microsoft.vscode") {
            candidates.unshift("vscode", "code", "visual-studio-code")
        } else if (lower === "firefox" || lower.includes("firefox")) {
            candidates.unshift("firefox")
        } else if (lower === "dolphin" || lower.includes("dolphin")) {
            candidates.unshift("org.kde.dolphin", "dolphin")
        } else if (lower === "kitty" || lower.includes("kitty")) {
            candidates.unshift("kitty")
        } else if (lower === "spotify" || lower.includes("spotify")) {
            candidates.unshift("spotify")
        } else if (lower === "discord" || lower.includes("discord")) {
            candidates.unshift("discord", "vesktop")
        }

        // 1. Buscar en apps de escritorio escaneadas
        for (let c = 0; c < candidates.length; c++) {
            let cand = candidates[c]
            for (let i = 0; i < root.installedAppsList.length; i++) {
                let item = root.installedAppsList[i]
                if (item.iconPath && item.iconPath.length > 0) {
                    if (item.iconName === cand || item.id === cand || (item.displayName && item.displayName.toLowerCase() === cand) || (item.matchClasses && item.matchClasses.indexOf(cand) !== -1)) {
                        return item.iconPath
                    }
                }
            }
        }

        // 2. Probar Quickshell.iconPath con cada candidato
        for (let c = 0; c < candidates.length; c++) {
            let qsPath = Quickshell.iconPath(candidates[c], true)
            if (qsPath && qsPath.length > 0) {
                return qsPath
            }
        }

        // 3. Fallbacks exclusivos para ítems mockup de macOS si fueron explícitamente solicitados
        if (lower === "finder") return Qt.resolvedUrl("assets/icons/finder.svg")
        if (lower === "launchpad") return Qt.resolvedUrl("assets/icons/launchpad.svg")
        if (lower === "shortcuts") return Qt.resolvedUrl("assets/icons/shortcuts.svg")
        if (lower === "keychain") return Qt.resolvedUrl("assets/icons/keychain.svg")

        return Qt.resolvedUrl("assets/icons/launchpad.svg")
    }

    // ── Scan System Installed Desktop Applications ──
    Process {
        id: scanProc
        command: ["bash", "-c", "python3 -c '
import os, glob, json

gtk_theme = None
try:
    import gi
    gi.require_version(\"Gtk\", \"3.0\")
    from gi.repository import Gtk
    gtk_theme = Gtk.IconTheme.get_default()
except Exception:
    pass

def resolve_icon_path(icon_name):
    if not icon_name:
        return \"\"
    if os.path.isabs(icon_name) and os.path.isfile(icon_name):
        return \"file://\" + icon_name
    candidates = [icon_name, icon_name.lower()]
    lower = icon_name.lower()
    if lower in (\"zen\", \"zen-browser\"):
        candidates.extend([\"zen-browser\", \"zen\"])
    elif lower in (\"code\", \"vscode\", \"visual-studio-code\", \"com.microsoft.vscode\"):
        candidates.extend([\"vscode\", \"code\", \"visual-studio-code\", \"com.visualstudio.code\"])
    elif lower in (\"dolphin\", \"org.kde.dolphin\"):
        candidates.extend([\"org.kde.dolphin\", \"dolphin\"])
    elif lower in (\"antigravity\",):
        candidates.extend([\"antigravity\"])
    if gtk_theme is not None:
        for candidate in candidates:
            try:
                info = gtk_theme.lookup_icon(candidate, 48, 0)
                if info:
                    fn = info.get_filename()
                    if fn and os.path.isfile(fn):
                        return \"file://\" + fn
            except Exception:
                pass
    for ext in (\".svg\", \".png\"):
        for cand in candidates:
            p = f\"/usr/share/pixmaps/{cand}{ext}\"
            if os.path.isfile(p):
                return \"file://\" + p
    return \"\"

apps = []
paths = glob.glob(\"/usr/share/applications/*.desktop\") + glob.glob(os.path.expanduser(\"~/.local/share/applications/*.desktop\"))
seen = set()

for p in paths:
    try:
        with open(p, \"r\", encoding=\"utf-8\", errors=\"ignore\") as f:
            lines = f.readlines()
        
        name = \"\"
        icon = \"\"
        exec_cmd = \"\"
        desc = \"\"
        nodisplay = False
        
        for l in lines:
            l = l.strip()
            if l.startswith(\"Name=\") and not name:
                name = l[5:]
            elif l.startswith(\"Icon=\") and not icon:
                icon = l[5:]
            elif l.startswith(\"Exec=\") and not exec_cmd:
                exec_cmd = l[5:]
            elif l.startswith(\"Comment=\") and not desc:
                desc = l[8:]
            elif l == \"NoDisplay=true\":
                nodisplay = True
                
        if nodisplay or not name or not exec_cmd:
            continue
            
        desktop_id = os.path.basename(p)
        if desktop_id in seen:
            continue
        seen.add(desktop_id)
        
        clean_exec = exec_cmd.split(\"%\")[0].strip()
        icon_val = icon or \"application-x-executable\"
        icon_path = resolve_icon_path(icon_val)
        
        escaped_id = desktop_id.replace('\"', '\\\"')
        match_classes = list(set([desktop_id.replace(\".desktop\", \"\").lower(), clean_exec.split()[0].lower() if clean_exec else \"\", name.lower()] + ([\"steam\"] if \"steam\" in (desktop_id + clean_exec).lower() else [])))
        apps.append({
            \"id\": desktop_id,
            \"name\": name,
            \"displayName\": name,
            \"description\": desc,
            \"executable\": clean_exec,
            \"iconName\": icon_val,
            \"iconPath\": icon_path,
            \"cmd\": f'gtk-launch \"{escaped_id}\" || {clean_exec}',
            \"matchClasses\": match_classes
        })
    except Exception:
        pass

apps.sort(key=lambda x: x[\"displayName\"].lower())
print(json.dumps(apps))
'"]
        stdout: SplitParser {
            onRead: function(text) {
                try {
                    let parsed = JSON.parse(text)
                    if (Array.isArray(parsed)) {
                        root.installedAppsList = parsed
                    }
                } catch (e) {}
            }
        }
    }

    function scanInstalledApps() {
        scanProc.running = true
    }

    // ── Context Menu Trigger (Scoped to Target Monitor) ──
    function openContextMenu(appObj, runningObj, isTrash, isFolder, posX, posY, screenName) {
        root.contextMenuApp = appObj
        root.contextMenuRunning = runningObj
        root.contextMenuIsTrash = isTrash
        root.contextMenuIsFolder = isFolder
        root.contextMenuX = posX
        root.contextMenuY = posY
        root.contextMenuScreen = screenName || ""
        root.contextMenuVisible = true
    }

    function closeContextMenu() {
        root.contextMenuVisible = false
        root.contextMenuScreen = ""
    }

    // ── Modal Actions (Scoped to Target Monitor) ──
    function openAddModal(screenName) {
        root.closeContextMenu()
        root.scanInstalledApps()
        root.addModalQuery = ""
        root.addModalScreen = screenName || ""
        root.addModalVisible = true
    }

    function closeAddModal() {
        root.addModalVisible = false
        root.addModalScreen = ""
        root.addModalQuery = ""
    }

    Component.onCompleted: {
        initFileLoader.running = true
        root.updateTrashCount()
        root.scanInstalledApps()
    }
}
