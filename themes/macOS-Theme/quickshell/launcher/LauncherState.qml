import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    // ── Launcher Visibility & View Modes ──
    property bool isOpen: false
    property bool windowVisible: false
    property string searchQuery: ""
    property string activeViewMode: "categorized" // "categorized" | "detail" | "all"
    property var activeCategoryDetail: null

    Timer {
        id: closeTimer
        interval: 220
        repeat: false
        onTriggered: {
            if (!root.isOpen) {
                root.windowVisible = false
            }
        }
    }

    // ── Scanned Apps & Categorized Datasets ──
    property var allAppsList: []
    property var categoriesList: []
    property var recentAppsList: []

    // ── Dark/Light Theme Awareness ──
    property bool isDarkTheme: false

    // Dynamic Theme Tokens
    readonly property color panelBgColor: isDarkTheme ? Qt.rgba(0.12, 0.13, 0.16, 0.88) : Qt.rgba(0.94, 0.96, 0.99, 0.88)
    readonly property color panelInnerSheen: isDarkTheme ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(1, 1, 1, 0.45)
    readonly property color panelBorderColor: isDarkTheme ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.65)
    readonly property color panelShadowColor: isDarkTheme ? Qt.rgba(0, 0, 0, 0.60) : Qt.rgba(0, 0, 0, 0.25)

    readonly property color headerTitleColor: isDarkTheme ? "#FFFFFF" : "#1D1D1F"
    readonly property color headerSubColor: isDarkTheme ? Qt.rgba(1, 1, 1, 0.55) : Qt.rgba(0, 0, 0, 0.50)
    
    readonly property color categoryHeaderColor: isDarkTheme ? "#E5E5EA" : "#1D1D1F"
    readonly property color categoryActionColor: isDarkTheme ? "#0A84FF" : "#007AFF"
    readonly property color categoryActionHover: isDarkTheme ? "#409CFF" : "#0062CC"
    
    readonly property color appTitleColor: isDarkTheme ? "#F2F2F7" : "#1D1D1F"
    readonly property color appHoverBg: isDarkTheme ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.07)
    readonly property color appActiveBg: isDarkTheme ? Qt.rgba(1, 1, 1, 0.20) : Qt.rgba(0, 0, 0, 0.14)
    
    readonly property color dividerColor: isDarkTheme ? Qt.rgba(1, 1, 1, 0.09) : Qt.rgba(0, 0, 0, 0.08)
    
    readonly property color searchBgColor: isDarkTheme ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(0, 0, 0, 0.06)
    readonly property color searchBorderColor: isDarkTheme ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(0, 0, 0, 0.10)
    readonly property color searchTextColor: isDarkTheme ? "#FFFFFF" : "#1D1D1F"
    readonly property color searchPlaceholderColor: isDarkTheme ? Qt.rgba(1, 1, 1, 0.45) : Qt.rgba(0, 0, 0, 0.40)

    // ── History & Favorites Persistence ──
    readonly property string historyFilePath: Quickshell.env("HOME") + "/.config/lunita/launcher-history.json"

    // ── Python Scanner Process ──
    Process {
        id: appScanner
        command: ["bash", "-c", "python3 -c '\nimport os, glob, json\n\ndef resolve_icon(icon_str, app_id, exec_cmd):\n    id_lower = (app_id + \" \" + exec_cmd + \" \" + icon_str).lower()\n    if any(k in id_lower for k in [\"zen\", \"firefox\", \"safari\", \"chrome\", \"chromium\", \"brave\"]): return \"assets/icons/safari.svg\"\n    if any(k in id_lower for k in [\"antigravity\", \"cursor\", \"vscodium\", \"vscode\", \"code\"]): return \"assets/icons/code.svg\"\n    if any(k in id_lower for k in [\"kitty\", \"alacritty\", \"foot\", \"wezterm\", \"terminal\"]): return \"assets/icons/terminal.svg\"\n    if any(k in id_lower for k in [\"dolphin\", \"nautilus\", \"thunar\", \"finder\"]): return \"assets/icons/finder.svg\"\n    if any(k in id_lower for k in [\"spotify\", \"music\", \"cider\", \"amberol\"]): return \"assets/icons/music.svg\"\n    if any(k in id_lower for k in [\"discord\", \"vesktop\", \"telegram\", \"messages\", \"whatsapp\"]): return \"assets/icons/messages.svg\"\n    if any(k in id_lower for k in [\"gwenview\", \"loupe\", \"photos\", \"eog\"]): return \"assets/icons/photos.svg\"\n    if any(k in id_lower for k in [\"settings\", \"systemsettings\", \"control-center\", \"pavucontrol\", \"displays\", \"bluetooth\"]): return \"assets/icons/settings.svg\"\n    if any(k in id_lower for k in [\"rofi\", \"shortcuts\", \"launcher\"]): return \"assets/icons/shortcuts.svg\"\n    if any(k in id_lower for k in [\"thunderbird\", \"mail\"]): return \"assets/icons/mail.svg\"\n    if any(k in id_lower for k in [\"obsidian\", \"notes\", \"notepadqq\", \"kate\"]): return \"assets/icons/notes.svg\"\n    if any(k in id_lower for k in [\"calendar\", \"korganizer\"]): return \"assets/icons/calendar.svg\"\n    if any(k in id_lower for k in [\"reminders\"]): return \"assets/icons/reminders.svg\"\n    if any(k in id_lower for k in [\"keychain\", \"keepassxc\", \"bitwarden\", \"seahorse\"]): return \"assets/icons/keychain.svg\"\n    if any(k in id_lower for k in [\"appstore\", \"discover\", \"pamac\", \"prism\"]): return \"assets/icons/appstore.svg\"\n    if not icon_str: return \"image://icon/application-x-executable\"\n    if icon_str.startswith(\"/\"):\n        return \"file://\" + icon_str if os.path.exists(icon_str) else \"image://icon/application-x-executable\"\n    for ext in [\"\", \".png\", \".svg\", \".xpm\"]:\n        p = f\"/usr/share/pixmaps/{icon_str}{ext}\"\n        if os.path.exists(p):\n            return f\"file://{p}\"\n    return \"image://icon/\" + icon_str\n\ndef categorize(cats_str, name, exec_cmd, desc, desktop_id):\n    c = (cats_str + \" \" + name + \" \" + exec_cmd + \" \" + desc + \" \" + desktop_id).lower()\n    if any(k in c for k in [\"antigravity\", \"development\", \"ide\", \"debugger\", \"programming\", \"code\", \"terminal\", \"editor\", \"texteditor\", \"neovim\", \"nvim\", \"vim\", \"git\", \"compiler\", \"database\", \"kitty\", \"cmake\", \"studio\", \"vscodium\"]):\n        return \"Development\"\n    if any(k in c for k in [\"office\", \"spreadsheet\", \"wordprocessor\", \"presentation\", \"email\", \"mail\", \"contact\", \"todo\", \"calendar\", \"notes\", \"organizer\", \"reminder\", \"weylus\", \"task\", \"libreoffice\", \"thunderbird\", \"obsidian\", \"kate\", \"notepadqq\"]):\n        return \"Productivity\"\n    if any(k in c for k in [\"graphics\", \"rastergraphics\", \"vectorgraphics\", \"2dgraphics\", \"3dgraphics\", \"video\", \"audiovideoediting\", \"publishing\", \"recorder\", \"blender\", \"gimp\", \"inkscape\", \"krita\", \"paint\", \"draw\", \"wayscriber\", \"songrec\", \"capture\", \"gwenview\", \"loupe\", \"kamoso\", \"cheese\", \"v4l2\", \"hp scan\", \"scan\"]):\n        return \"Creativity\"\n    if any(k in c for k in [\"audiovideo\", \"audio\", \"music\", \"player\", \"multimedia\", \"game\", \"entertainment\", \"media\", \"spotify\", \"mpv\", \"vlc\", \"steam\", \"prism\", \"cider\", \"amberol\", \"celluloid\", \"bedrock\", \"volume control\", \"pavucontrol\"]):\n        return \"Entertainment & Media\"\n    if any(k in c for k in [\"network\", \"webbrowser\", \"browser\", \"news\", \"feed\", \"maps\", \"weather\", \"reader\", \"viewer\", \"document\", \"book\", \"zen\", \"firefox\", \"chrome\", \"discord\", \"vesktop\", \"telegram\", \"whatsapp\", \"signal\", \"cartes\", \"globe\", \"vpn\", \"proton\"]):\n        return \"Information & Reading\"\n    return \"System & Utilities\"\n\npaths = glob.glob(\"/usr/share/applications/*.desktop\") + glob.glob(os.path.expanduser(\"~/.local/share/applications/*.desktop\"))\napps = []\nseen = set()\nignored_apps = [\"kitty URL Launcher\", \"Xwayland\", \"Hardware Locality lstopo\", \"Print Settings\", \"Avahi SSH Server Browser\", \"Avahi VNC Server Browser\", \"xgpsspeed\"]\n\nfor p in paths:\n    try:\n        with open(p, \"r\", encoding=\"utf-8\", errors=\"ignore\") as f: lines = f.readlines()\n        name, icon, exec_cmd, desc, cats_str = \"\", \"\", \"\", \"\", \"\"\n        nodisplay = False\n        for l in lines:\n            l = l.strip()\n            if l.startswith(\"Name=\") and not name: name = l[5:]\n            elif l.startswith(\"Icon=\") and not icon: icon = l[5:]\n            elif l.startswith(\"Exec=\") and not exec_cmd: exec_cmd = l[5:]\n            elif l.startswith(\"Comment=\") and not desc: desc = l[8:]\n            elif l.startswith(\"Categories=\") and not cats_str: cats_str = l[11:]\n            elif l == \"NoDisplay=true\": nodisplay = True\n        if nodisplay or not name or not exec_cmd or name in ignored_apps: continue\n        desktop_id = os.path.basename(p)\n        if desktop_id in seen: continue\n        seen.add(desktop_id)\n        clean_exec = exec_cmd.split(\"%\")[0].strip()\n        cat = categorize(cats_str, name, clean_exec, desc, desktop_id)\n        icon_res = resolve_icon(icon, desktop_id, clean_exec)\n        apps.append({\"id\": desktop_id, \"name\": name, \"displayName\": name, \"description\": desc, \"executable\": clean_exec, \"iconName\": icon, \"resolvedIcon\": icon_res, \"category\": cat, \"desktopPath\": p})\n    except Exception:\n        pass\n\napps.sort(key=lambda x: x[\"displayName\"].lower())\nprint(json.dumps(apps))\n'"]
        stdout: SplitParser {
            onRead: function(text) {
                try {
                    let parsed = JSON.parse(text)
                    if (Array.isArray(parsed) && parsed.length > 0) {
                        root.allAppsList = parsed
                        root.buildCategories(parsed)
                    }
                } catch (e) {}
            }
        }
    }

    // ── Build Structured Categories ──
    function buildCategories(apps) {
        let catOrder = [
            { id: "suggestions", name: "Suggestions", showMoreAction: "Show More" },
            { id: "productivity", name: "Productivity", showMoreAction: "Show All" },
            { id: "creativity", name: "Creativity", showMoreAction: "Show All" },
            { id: "information", name: "Information & Reading", showMoreAction: "Show All" },
            { id: "development", name: "Development", showMoreAction: "Show All" },
            { id: "system", name: "System & Utilities", showMoreAction: "Show All" },
            { id: "entertainment", name: "Entertainment & Media", showMoreAction: "Show All" }
        ]

        let catMap = {
            "Productivity": [],
            "Creativity": [],
            "Information & Reading": [],
            "Development": [],
            "System & Utilities": [],
            "Entertainment & Media": []
        }

        for (let i = 0; i < apps.length; i++) {
            let a = apps[i]
            let c = a.category || "System & Utilities"
            if (catMap[c]) {
                catMap[c].push(a)
            } else {
                catMap["System & Utilities"].push(a)
            }
        }

        // Suggestions: take top curated / most accessed apps
        let suggestions = []
        let curatedSuggestions = ["zen", "firefox", "antigravity", "code", "kitty", "dolphin", "spotify", "discord", "vesktop", "neovim", "htop", "songrec"]
        for (let k = 0; k < curatedSuggestions.length; k++) {
            let match = apps.find(function(a) {
                let s = (a.id + " " + a.executable + " " + a.name).toLowerCase()
                return s.includes(curatedSuggestions[k])
            })
            if (match && !suggestions.includes(match)) {
                suggestions.push(match)
            }
        }
        // Fill up to 5 suggestions
        for (let i = 0; i < apps.length && suggestions.length < 5; i++) {
            if (!suggestions.includes(apps[i])) {
                suggestions.push(apps[i])
            }
        }

        let result = []
        for (let i = 0; i < catOrder.length; i++) {
            let meta = catOrder[i]
            let list = []
            if (meta.id === "suggestions") {
                list = suggestions
            } else {
                list = catMap[meta.name] || []
            }

            if (list.length > 0) {
                result.push({
                    id: meta.id,
                    name: meta.name,
                    displayName: meta.name,
                    actionText: meta.showMoreAction,
                    allApps: list,
                    previewApps: list.slice(0, 5)
                })
            }
        }

        root.categoriesList = result
    }

    // ── Search & Filter Logic ──
    function getFilteredApps() {
        let q = root.searchQuery.trim().toLowerCase()
        if (!q) return root.allAppsList
        return root.allAppsList.filter(function(a) {
            return (a.displayName || "").toLowerCase().includes(q) ||
                   (a.name || "").toLowerCase().includes(q) ||
                   (a.executable || "").toLowerCase().includes(q) ||
                   (a.description || "").toLowerCase().includes(q) ||
                   (a.category || "").toLowerCase().includes(q)
        })
    }

    // ── App Launch & History ──
    function launchApp(app) {
        if (!app) return
        let cmd = "gtk-launch " + app.id + " 2>/dev/null || " + app.executable + " &"
        Quickshell.execDetached(["bash", "-c", cmd])
        root.recordRecent(app.id)
        root.closeLauncher()
    }

    function recordRecent(appId) {
        let cmd = "python3 -c 'import os, json; p = os.path.expanduser(\"~/.config/lunita/launcher-history.json\"); os.makedirs(os.path.dirname(p), exist_ok=True); data = [];\ntry:\n    with open(p, \"r\") as f: data = json.load(f)\nexcept: pass\ndata = [x for x in data if x != \"" + appId + "\"]\ndata.insert(0, \"" + appId + "\")\nwith open(p, \"w\") as f: json.dump(data[:20], f)'"
        Quickshell.execDetached(["bash", "-c", cmd])
    }

    // ── Navigation & View Controls ──
    function openLauncher() {
        closeTimer.stop()
        appScanner.running = true
        root.searchQuery = ""
        root.activeViewMode = "categorized"
        root.activeCategoryDetail = null
        root.windowVisible = true
        root.isOpen = true
    }

    function closeLauncher() {
        root.isOpen = false
        root.searchQuery = ""
        root.activeCategoryDetail = null
        closeTimer.restart()
    }

    function toggleLauncher() {
        if (root.isOpen) {
            root.closeLauncher()
        } else {
            root.openLauncher()
        }
    }

    function showCategoryDetail(catObj) {
        root.activeCategoryDetail = catObj
        root.activeViewMode = "detail"
    }

    function backToCategories() {
        root.activeCategoryDetail = null
        root.activeViewMode = "categorized"
    }

    function toggleAllApps() {
        if (root.activeViewMode === "all") {
            root.activeViewMode = "categorized"
        } else {
            root.activeViewMode = "all"
        }
    }

    Component.onCompleted: {
        appScanner.running = true
    }
}
