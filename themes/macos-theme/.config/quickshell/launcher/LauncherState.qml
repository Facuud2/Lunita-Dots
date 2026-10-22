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
    // ── Scanned Apps & Categorized Datasets ──
    property var allAppsList: []
    property var categoriesList: []
    property var recentAppsList: []
    // ── Dark/Light Theme Awareness ──
    property bool isDarkTheme: true
    // Dynamic Theme Tokens
    readonly property color panelBgColor: isDarkTheme ? Qt.rgba(30 / 255, 30 / 255, 30 / 255, 0.65) : Qt.rgba(1, 1, 1, 0.7)
    readonly property color panelInnerSheen: isDarkTheme ? Qt.rgba(1, 1, 1, 0.06) : Qt.rgba(1, 1, 1, 0.45)
    readonly property color panelBorderColor: isDarkTheme ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(1, 1, 1, 0.1)
    readonly property color panelShadowColor: isDarkTheme ? Qt.rgba(0, 0, 0, 0.6) : Qt.rgba(0, 0, 0, 0.25)
    readonly property color headerTitleColor: isDarkTheme ? "#FFFFFF" : "#1D1D1F"
    readonly property color headerSubColor: isDarkTheme ? Qt.rgba(1, 1, 1, 0.55) : Qt.rgba(0, 0, 0, 0.5)
    readonly property color categoryHeaderColor: isDarkTheme ? "#E5E5EA" : "#1D1D1F"
    readonly property color categoryActionColor: isDarkTheme ? "#0A84FF" : "#007AFF"
    readonly property color categoryActionHover: isDarkTheme ? "#409CFF" : "#0062CC"
    readonly property color appTitleColor: isDarkTheme ? "#F2F2F7" : "#1D1D1F"
    readonly property color appHoverBg: isDarkTheme ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.07)
    readonly property color appActiveBg: isDarkTheme ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(0, 0, 0, 0.14)
    readonly property color dividerColor: isDarkTheme ? Qt.rgba(1, 1, 1, 0.09) : Qt.rgba(0, 0, 0, 0.08)
    readonly property color searchBgColor: isDarkTheme ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(0, 0, 0, 0.06)
    readonly property color searchBorderColor: isDarkTheme ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(0, 0, 0, 0.1)
    readonly property color searchTextColor: isDarkTheme ? "#FFFFFF" : "#1D1D1F"
    readonly property color searchPlaceholderColor: isDarkTheme ? Qt.rgba(1, 1, 1, 0.45) : Qt.rgba(0, 0, 0, 0.4)
    // ── History & Favorites Persistence ──
    readonly property string historyFilePath: Quickshell.env("HOME") + "/.config/lunita/launcher-history.json"

    // ── Build Structured Categories ──
    function buildCategories(apps) {
        let catOrder = [{
            "id": "suggestions",
            "name": "Suggestions",
            "showMoreAction": "Show More"
        }, {
            "id": "productivity",
            "name": "Productivity",
            "showMoreAction": "Show All"
        }, {
            "id": "creativity",
            "name": "Creativity",
            "showMoreAction": "Show All"
        }, {
            "id": "information",
            "name": "Information & Reading",
            "showMoreAction": "Show All"
        }, {
            "id": "development",
            "name": "Development",
            "showMoreAction": "Show All"
        }, {
            "id": "system",
            "name": "System & Utilities",
            "showMoreAction": "Show All"
        }, {
            "id": "entertainment",
            "name": "Entertainment & Media",
            "showMoreAction": "Show All"
        }];
        let catMap = {
            "Productivity": [],
            "Creativity": [],
            "Information & Reading": [],
            "Development": [],
            "System & Utilities": [],
            "Entertainment & Media": []
        };
        for (let i = 0; i < apps.length; i++) {
            let a = apps[i];
            let c = a.category || "System & Utilities";
            if (catMap[c])
                catMap[c].push(a);
            else
                catMap["System & Utilities"].push(a);
        }
        // Suggestions: take top curated / most accessed apps
        let suggestions = [];
        let curatedSuggestions = ["zen", "firefox", "antigravity", "code", "kitty", "dolphin", "spotify", "discord", "vesktop", "neovim", "htop", "songrec"];
        for (let k = 0; k < curatedSuggestions.length; k++) {
            let match = apps.find(function(a) {
                let s = (a.id + " " + a.executable + " " + a.name).toLowerCase();
                return s.includes(curatedSuggestions[k]);
            });
            if (match && !suggestions.includes(match))
                suggestions.push(match);

        }
        // Fill up to 5 suggestions
        for (let i = 0; i < apps.length && suggestions.length < 5; i++) {
            if (!suggestions.includes(apps[i]))
                suggestions.push(apps[i]);

        }
        let result = [];
        for (let i = 0; i < catOrder.length; i++) {
            let meta = catOrder[i];
            let list = [];
            if (meta.id === "suggestions")
                list = suggestions;
            else
                list = catMap[meta.name] || [];
            if (list.length > 0)
                result.push({
                    "id": meta.id,
                    "name": meta.name,
                    "displayName": meta.name,
                    "actionText": meta.showMoreAction,
                    "allApps": list,
                    "previewApps": list.slice(0, 5)
                });

        }
        root.categoriesList = result;
    }

    // ── Search & Filter Logic ──
    function getFilteredApps() {
        let q = root.searchQuery.trim().toLowerCase();
        if (!q)
            return root.allAppsList;

        return root.allAppsList.filter(function(a) {
            return (a.displayName || "").toLowerCase().includes(q) || (a.name || "").toLowerCase().includes(q) || (a.executable || "").toLowerCase().includes(q) || (a.description || "").toLowerCase().includes(q) || (a.category || "").toLowerCase().includes(q);
        });
    }

    // ── App Launch & History ──
    function launchApp(app) {
        if (!app)
            return ;

        let escapedId = (app.id || "").replace(/'/g, "'\\''");
        let envPrefix = "if [ -z \"${DISPLAY:-}\" ]; then " + "disp=\"$(systemctl --user show-environment 2>/dev/null | sed -n 's/^DISPLAY=//p' | head -n 1 || true)\"; " + "if [ -z \"$disp\" ]; then " + "for s in /tmp/.X11-unix/X*[0-9]; do if [ -S \"$s\" ] && [ -O \"$s\" ]; then disp=\":${s##*X}\"; break; fi; done; " + "fi; " + "[ -n \"$disp\" ] && export DISPLAY=\"$disp\"; " + "fi; ";
        let cmd = envPrefix + "(gtk-launch '" + escapedId + "' 2>/dev/null || " + app.executable + ") &";
        Quickshell.execDetached(["bash", "-c", cmd]);
        root.recordRecent(app.id);
        root.closeLauncher();
    }

    function recordRecent(appId) {
        let cmd = "python3 -c 'import os, json; p = os.path.expanduser(\"~/.config/lunita/launcher-history.json\"); os.makedirs(os.path.dirname(p), exist_ok=True); data = [];\ntry:\n    with open(p, \"r\") as f: data = json.load(f)\nexcept: pass\ndata = [x for x in data if x != \"" + appId + "\"]\ndata.insert(0, \"" + appId + "\")\nwith open(p, \"w\") as f: json.dump(data[:20], f)'";
        Quickshell.execDetached(["bash", "-c", cmd]);
    }

    // ── Navigation & View Controls ──
    function openLauncher() {
        closeTimer.stop();
        appScanner.running = true;
        root.searchQuery = "";
        root.activeViewMode = "categorized";
        root.activeCategoryDetail = null;
        root.windowVisible = true;
        root.isOpen = true;
    }

    function closeLauncher() {
        root.isOpen = false;
        root.searchQuery = "";
        root.activeCategoryDetail = null;
        closeTimer.restart();
    }

    function toggleLauncher() {
        if (root.isOpen)
            root.closeLauncher();
        else
            root.openLauncher();
    }

    function showCategoryDetail(catObj) {
        root.activeCategoryDetail = catObj;
        root.activeViewMode = "detail";
    }

    function backToCategories() {
        root.activeCategoryDetail = null;
        root.activeViewMode = "categorized";
    }

    function toggleAllApps() {
        if (root.activeViewMode === "all")
            root.activeViewMode = "categorized";
        else
            root.activeViewMode = "all";
    }

    Component.onCompleted: {
        appScanner.running = true;
    }

    Timer {
        id: closeTimer

        interval: 240
        repeat: false
        onTriggered: {
            if (!root.isOpen)
                root.windowVisible = false;

        }
    }

    Process {
        id: themeMonitor

        running: true
        command: ["bash", "-c", "if [ -f $HOME/.config/lunita/color_scheme ]; then cat $HOME/.config/lunita/color_scheme; else gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || echo 'prefer-dark'; fi"]

        stdout: SplitParser {
            onRead: (data) => {
                var str = data.trim().toLowerCase();
                root.isDarkTheme = str.indexOf("light") === -1;
            }
        }

    }

    // ── Python Scanner Process ──
    Process {
        id: appScanner

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

def resolve_icon(icon_str, app_id, exec_cmd):
    if not icon_str:
        icon_str = app_id.replace(\".desktop\", \"\")
    if icon_str.startswith(\"/\") and os.path.exists(icon_str):
        return \"file://\" + icon_str
    candidates = [icon_str, icon_str.lower(), app_id.replace(\".desktop\", \"\")]
    lower = (app_id + \" \" + icon_str).lower()
    if \"zen\" in lower:
        candidates.insert(0, \"zen-browser\")
    if \"antigravity\" in lower:
        candidates.insert(0, \"antigravity\")
    if \"code\" in lower or \"vscode\" in lower:
        candidates.insert(0, \"vscode\")
        candidates.insert(1, \"code\")
    if \"dolphin\" in lower:
        candidates.insert(0, \"org.kde.dolphin\")
    if gtk_theme is not None:
        for cand in candidates:
            try:
                info = gtk_theme.lookup_icon(cand, 48, 0)
                if info:
                    fn = info.get_filename()
                    if fn and os.path.exists(fn):
                        return \"file://\" + fn
            except Exception:
                pass
    for ext in [\"\", \".svg\", \".png\", \".xpm\"]:
        for cand in candidates:
            p = f\"/usr/share/pixmaps/{cand}{ext}\"
            if os.path.exists(p):
                return f\"file://{p}\"
    return \"assets/icons/launchpad.svg\"

def categorize(cats_str, name, exec_cmd, desc, desktop_id):
    c = (cats_str + \" \" + name + \" \" + exec_cmd + \" \" + desc + \" \" + desktop_id).lower()
    if any(k in c for k in [\"antigravity\", \"development\", \"ide\", \"debugger\", \"programming\", \"code\", \"terminal\", \"editor\", \"texteditor\", \"neovim\", \"nvim\", \"vim\", \"git\", \"compiler\", \"database\", \"kitty\", \"cmake\", \"studio\", \"vscodium\"]):
        return \"Development\"
    if any(k in c for k in [\"office\", \"spreadsheet\", \"wordprocessor\", \"presentation\", \"email\", \"mail\", \"contact\", \"todo\", \"calendar\", \"notes\", \"organizer\", \"reminder\", \"weylus\", \"task\", \"libreoffice\", \"thunderbird\", \"obsidian\", \"kate\", \"notepadqq\"]):
        return \"Productivity\"
    if any(k in c for k in [\"graphics\", \"rastergraphics\", \"vectorgraphics\", \"2dgraphics\", \"3dgraphics\", \"video\", \"audiovideoediting\", \"publishing\", \"recorder\", \"blender\", \"gimp\", \"inkscape\", \"krita\", \"paint\", \"draw\", \"wayscriber\", \"songrec\", \"capture\", \"gwenview\", \"loupe\", \"kamoso\", \"cheese\", \"v4l2\", \"hp scan\", \"scan\"]):
        return \"Creativity\"
    if any(k in c for k in [\"audiovideo\", \"audio\", \"music\", \"player\", \"multimedia\", \"game\", \"entertainment\", \"media\", \"spotify\", \"mpv\", \"vlc\", \"steam\", \"prism\", \"cider\", \"amberol\", \"celluloid\", \"bedrock\", \"volume control\", \"pavucontrol\"]):
        return \"Entertainment & Media\"
    if any(k in c for k in [\"network\", \"webbrowser\", \"browser\", \"news\", \"feed\", \"maps\", \"weather\", \"reader\", \"viewer\", \"document\", \"book\", \"zen\", \"firefox\", \"chrome\", \"discord\", \"vesktop\", \"telegram\", \"whatsapp\", \"signal\", \"cartes\", \"globe\", \"vpn\", \"proton\"]):
        return \"Information & Reading\"
    return \"System & Utilities\"

paths = glob.glob(\"/usr/share/applications/*.desktop\") + glob.glob(os.path.expanduser(\"~/.local/share/applications/*.desktop\"))
apps = []
seen = set()
ignored_apps = [\"kitty URL Launcher\", \"Xwayland\", \"Hardware Locality lstopo\", \"Print Settings\", \"Avahi SSH Server Browser\", \"Avahi VNC Server Browser\", \"xgpsspeed\"]

for p in paths:
    try:
        with open(p, \"r\", encoding=\"utf-8\", errors=\"ignore\") as f: lines = f.readlines()
        name, icon, exec_cmd, desc, cats_str = \"\", \"\", \"\", \"\", \"\"
        nodisplay = False
        for l in lines:
            l = l.strip()
            if l.startswith(\"Name=\") and not name: name = l[5:]
            elif l.startswith(\"Icon=\") and not icon: icon = l[5:]
            elif l.startswith(\"Exec=\") and not exec_cmd: exec_cmd = l[5:]
            elif l.startswith(\"Comment=\") and not desc: desc = l[8:]
            elif l.startswith(\"Categories=\") and not cats_str: cats_str = l[11:]
            elif l == \"NoDisplay=true\": nodisplay = True
        if nodisplay or not name or not exec_cmd or name in ignored_apps: continue
        desktop_id = os.path.basename(p)
        if desktop_id in seen: continue
        seen.add(desktop_id)
        clean_exec = exec_cmd.split(\"%\")[0].strip()
        cat = categorize(cats_str, name, clean_exec, desc, desktop_id)
        icon_res = resolve_icon(icon, desktop_id, clean_exec)
        apps.append({\"id\": desktop_id, \"name\": name, \"displayName\": name, \"description\": desc, \"executable\": clean_exec, \"iconName\": icon, \"resolvedIcon\": icon_res, \"category\": cat, \"desktopPath\": p})
    except Exception:
        pass

apps.sort(key=lambda x: x[\"displayName\"].lower())
print(json.dumps(apps))
'"]

        stdout: SplitParser {
            onRead: function(text) {
                try {
                    let parsed = JSON.parse(text);
                    if (Array.isArray(parsed) && parsed.length > 0) {
                        root.allAppsList = parsed;
                        root.buildCategories(parsed);
                    }
                } catch (e) {
                }
            }
        }

    }

}
