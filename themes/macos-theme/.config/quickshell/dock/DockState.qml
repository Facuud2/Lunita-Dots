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

    // ── Active Context Menu State ──
    property bool contextMenuVisible: false
    property var contextMenuApp: null
    property var contextMenuRunning: null
    property bool contextMenuIsTrash: false
    property bool contextMenuIsFolder: false
    property real contextMenuX: 0
    property real contextMenuY: 0

    // ── Add App Modal State ──
    property bool addModalVisible: false
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
            id: "safari",
            name: "Safari",
            iconFile: "safari.svg",
            fallbackIcon: "web-browser",
            cmd: "zen-browser || firefox || google-chrome-stable",
            matchClasses: ["zen", "zen-alpha", "zen-browser", "firefox", "google-chrome", "chromium", "brave-browser"]
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
            iconFile: "code.svg",
            fallbackIcon: "text-editor",
            cmd: "antigravity || code || vscodium",
            matchClasses: ["antigravity", "code", "Code", "vscodium", "neovim", "cursor"]
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

    readonly property var rightStackApps: [
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
                root.pinnedList = []
                root.pinnedList = parsed
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
                        root.updateRunningUnpinned(parsed)
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
            clientsProc.running = true
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
            Quickshell.execDetached(["bash", "-c", pinned.cmd + " &"])
        }
    }

    function launchNew(cmd) {
        Quickshell.execDetached(["bash", "-c", cmd + " &"])
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

    // ── Scan System Installed Desktop Applications ──
    Process {
        id: scanProc
        command: ["bash", "-c", "python3 -c '
import os, glob, json

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
        
        apps.append({
            \"id\": desktop_id,
            \"name\": name,
            \"displayName\": name,
            \"description\": desc,
            \"executable\": clean_exec,
            \"iconName\": icon or \"application-x-executable\",
            \"cmd\": f\"gtk-launch {desktop_id}\",
            \"matchClasses\": [desktop_id.replace(\".desktop\", \"\").lower(), clean_exec.lower(), name.lower()]
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

    // ── Context Menu Trigger ──
    function openContextMenu(appObj, runningObj, isTrash, isFolder, posX, posY) {
        root.contextMenuApp = appObj
        root.contextMenuRunning = runningObj
        root.contextMenuIsTrash = isTrash
        root.contextMenuIsFolder = isFolder
        root.contextMenuX = posX
        root.contextMenuY = posY
        root.contextMenuVisible = true
    }

    function closeContextMenu() {
        root.contextMenuVisible = false
    }

    // ── Modal Actions ──
    function openAddModal() {
        root.scanInstalledApps()
        root.addModalQuery = ""
        root.addModalVisible = true
    }

    function closeAddModal() {
        root.addModalVisible = false
        root.addModalQuery = ""
    }

    Component.onCompleted: {
        initFileLoader.running = true
        root.updateTrashCount()
        root.scanInstalledApps()
    }
}
