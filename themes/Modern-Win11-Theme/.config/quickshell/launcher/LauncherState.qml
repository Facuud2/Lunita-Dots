import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    // ── Launcher Visibility & View Modes ──
    property bool isOpen: false
    property bool windowVisible: false
    property string searchQuery: ""
    property string activeViewMode: "standard" // "standard" | "detail" | "all_apps"
    property var activeCategoryDetail: null
    property bool isPinnedExpanded: true
    property string categoryViewType: "folders" // "folders" | "list"
    property bool powerMenuOpen: false

    Timer {
        id: closeTimer
        interval: 220
        repeat: false
        onTriggered: {
            if (!root.isOpen) {
                root.windowVisible = false;
                root.powerMenuOpen = false;
            }
        }
    }

    // ── User Information ──
    property string userName: "Antony A. Benites"
    property string userAvatar: ""

    Process {
        id: userInfoProcess
        running: true
        command: ["bash", "-c", "NAME=$(getent passwd $USER | cut -d ':' -f 5 | cut -d ',' -f 1); [ -n \"$NAME\" ] && echo \"$NAME\" || echo \"$USER\""]
        stdout: SplitParser {
            onRead: data => {
                let val = data.trim();
                if (val.length > 0) {
                    root.userName = val;
                }
            }
        }
    }

    Process {
        id: userAvatarProcess
        running: true
        command: ["bash", "-c", "if [ -f $HOME/.face ]; then echo \"file://$HOME/.face\"; elif [ -f $HOME/.config/hypr/avatar.jpg ]; then echo \"file://$HOME/.config/hypr/avatar.jpg\"; elif [ -f /mnt/Desarrollo/Lunita-Dots/core/hypr/avatar.jpg ]; then echo \"file:///mnt/Desarrollo/Lunita-Dots/core/hypr/avatar.jpg\"; else echo \"\"; fi"]
        stdout: SplitParser {
            onRead: data => {
                let val = data.trim();
                root.userAvatar = val;
            }
        }
    }

    // ── Pure Transparent Acrylic Tokens (True Frosted Glass, No Heavy White Tints, No Harsh Borders) ──
    // Highly transparent base allows Hyprland's layer blur to project pure desktop backdrop blur
    readonly property color panelBgColor: Qt.rgba(20/255, 20/255, 24/255, 0.22)
    readonly property color panelBorderColor: Qt.rgba(255, 255, 255, 0.06)
    readonly property color panelShadowColor: Qt.rgba(0, 0, 0, 0.35)

    // Windows 11 Typography & Accents on Transparent Acrylic
    readonly property color headerTitleColor: "#FFFFFF"
    readonly property color headerSubColor: Qt.rgba(1, 1, 1, 0.65)

    readonly property color accentColor: "#4CC2FF"
    readonly property color accentHover: "#60CDFF"

    readonly property color appTitleColor: "#FFFFFF"
    readonly property color appHoverBg: Qt.rgba(255, 255, 255, 0.08)
    readonly property color appHoverBorder: Qt.rgba(255, 255, 255, 0.12)
    readonly property color appActiveBg: Qt.rgba(255, 255, 255, 0.14)

    readonly property color folderCardBg: Qt.rgba(255, 255, 255, 0.04)
    readonly property color folderCardBorder: Qt.rgba(255, 255, 255, 0.06)
    readonly property color folderCardHover: Qt.rgba(255, 255, 255, 0.09)

    readonly property color footerBg: Qt.rgba(15/255, 15/255, 18/255, 0.20)
    readonly property color dividerColor: Qt.rgba(255, 255, 255, 0.06)

    readonly property color searchBgColor: Qt.rgba(255, 255, 255, 0.07)
    readonly property color searchBorderColor: Qt.rgba(255, 255, 255, 0.08)
    readonly property color searchTextColor: "#FFFFFF"
    readonly property color searchPlaceholderColor: Qt.rgba(1, 1, 1, 0.60)

    // ── Application Datasets ──
    property var allAppsList: []
    property var pinnedAppsList: []
    property var folderCategories: []

    // ── Python Scanner Process ──
    Process {
        id: appScanner
        command: ["python3", Qt.resolvedUrl("scripts/app_scanner.py").toString().replace("file://", "")]
        stdout: SplitParser {
            onRead: function(text) {
                try {
                    let parsed = JSON.parse(text);
                    if (Array.isArray(parsed) && parsed.length > 0) {
                        root.allAppsList = parsed;
                        root.buildPinnedAndFolders(parsed);
                    }
                } catch (e) {}
            }
        }
    }

    // ── Build Windows 11 Reference Layout with 100% Real Installed Apps (3 Rows x 6 Columns = 18 apps) ──
    function buildPinnedAndFolders(apps) {
        if (!apps || apps.length === 0) return;

        // Priority list of real desktop IDs installed on the user system
        let preferredPinnedIds = [
            "zen.desktop",
            "com.microsoft.VSCode.desktop",
            "antigravity.desktop",
            "org.vinegarhq.Sober.desktop",
            "kitty.desktop",
            "org.kde.dolphin.desktop",
            "vesktop.desktop",
            "org.prismlauncher.PrismLauncher.desktop",
            "firefox.desktop",
            "org.kde.gwenview.desktop",
            "mpv.desktop",
            "nvim.desktop",
            "org.pulseaudio.pavucontrol.desktop",
            "nwg-displays.desktop",
            "blueman-manager.desktop",
            "ai.elementlabs.lmstudio.desktop",
            "timeshift-gtk.desktop",
            "lunita-widgets-manager.desktop",
            // Priority fallbacks if any above are uninstalled:
            "lunita-theme-selector.desktop",
            "com.ysuraj.Tokri.desktop",
            "thunar.desktop",
            "proton.vpn.app.gtk.desktop",
            "re.fossplant.songrec.desktop",
            "cmake-gui.desktop",
            "btop.desktop",
            "ventoy.desktop",
            "wayscriber.desktop",
            "vim.desktop"
        ];

        let pinned = [];
        let usedIds = new Set();

        // 1. Add apps from preferred priority list
        for (let i = 0; i < preferredPinnedIds.length; i++) {
            let pid = preferredPinnedIds[i];
            let found = apps.find(function(a) { return a.id === pid; });
            if (found && !usedIds.has(found.id)) {
                usedIds.add(found.id);
                pinned.push(found);
                if (pinned.length >= 18) break;
            }
        }

        // 2. Fill remaining slots up to 18 with any other installed apps
        if (pinned.length < 18) {
            for (let i = 0; i < apps.length; i++) {
                let a = apps[i];
                if (!usedIds.has(a.id)) {
                    usedIds.add(a.id);
                    pinned.push(a);
                    if (pinned.length >= 18) break;
                }
            }
        }

        root.pinnedAppsList = pinned;

        // ── Build 3 Folder Cards for "Todo" Section with Real Installed Apps ──
        // Category 1: Creatividad & Medios
        let catCreativity = apps.filter(function(a) {
            let s = (a.category + " " + a.name + " " + a.id).toLowerCase();
            return s.includes("medios") || s.includes("creativ") || s.includes("graphic") || s.includes("gwenview") || s.includes("mpv") || s.includes("songrec") || s.includes("video") || s.includes("photo") || s.includes("wayscriber") || s.includes("sober") || s.includes("roblox");
        });
        if (catCreativity.length === 0) catCreativity = apps.slice(0, 4);

        // Category 2: Desarrollo & Herramientas
        let catDev = apps.filter(function(a) {
            let s = (a.category + " " + a.name + " " + a.id).toLowerCase();
            return s.includes("desarrollo") || s.includes("terminal") || s.includes("code") || s.includes("antigravity") || s.includes("kitty") || s.includes("nvim") || s.includes("vim") || s.includes("cmake");
        });
        if (catDev.length === 0) catDev = apps.slice(4, 8);

        // Category 3: Internet & Red
        let catNet = apps.filter(function(a) {
            let s = (a.category + " " + a.name + " " + a.id).toLowerCase();
            return s.includes("internet") || s.includes("red") || s.includes("browser") || s.includes("zen") || s.includes("firefox") || s.includes("vesktop") || s.includes("discord") || s.includes("vpn");
        });
        if (catNet.length === 0) catNet = apps.slice(8, 12);

        root.folderCategories = [
            {
                id: "creativity",
                title: "Creatividad & Medios",
                apps: catCreativity,
                previewApps: catCreativity.slice(0, 4)
            },
            {
                id: "development",
                title: "Desarrollo & Herramientas",
                apps: catDev,
                previewApps: catDev.slice(0, 4)
            },
            {
                id: "internet",
                title: "Internet & Red",
                apps: catNet,
                previewApps: catNet.slice(0, 4)
            }
        ];
    }

    // ── Search & Filter Logic ──
    function getFilteredApps() {
        let q = root.searchQuery.trim().toLowerCase();
        if (!q) return root.allAppsList;
        return root.allAppsList.filter(function(a) {
            return (a.displayName || "").toLowerCase().includes(q) ||
                   (a.name || "").toLowerCase().includes(q) ||
                   (a.executable || "").toLowerCase().includes(q) ||
                   (a.description || "").toLowerCase().includes(q) ||
                   (a.category || "").toLowerCase().includes(q);
        });
    }

    // ── App Launch Execution ──
    function launchApp(app) {
        if (!app) return;
        if (app.executable || app.id) {
            let cmd = "gtk-launch " + app.id + " 2>/dev/null || " + (app.executable ? app.executable : "") + " &";
            Quickshell.execDetached(["bash", "-c", cmd]);
        }
        root.closeLauncher();
    }

    // ── Navigation & View Controls ──
    function openLauncher() {
        closeTimer.stop();
        appScanner.running = true;
        root.searchQuery = "";
        root.activeViewMode = "standard";
        root.activeCategoryDetail = null;
        root.powerMenuOpen = false;
        root.windowVisible = true;
        root.isOpen = true;
    }

    function closeLauncher() {
        root.isOpen = false;
        root.searchQuery = "";
        root.activeCategoryDetail = null;
        root.powerMenuOpen = false;
        closeTimer.restart();
    }

    function toggleLauncher() {
        if (root.isOpen) {
            root.closeLauncher();
        } else {
            root.openLauncher();
        }
    }

    function togglePinnedExpanded() {
        root.isPinnedExpanded = !root.isPinnedExpanded;
    }

    function toggleAllApps() {
        if (root.activeViewMode === "all_apps") {
            root.activeViewMode = "standard";
        } else {
            root.activeViewMode = "all_apps";
        }
    }

    function openCategoryFolder(categoryObj) {
        root.activeCategoryDetail = categoryObj;
        root.activeViewMode = "detail";
    }

    function backToStandard() {
        root.activeCategoryDetail = null;
        root.activeViewMode = "standard";
    }

    // ── Power Actions ──
    function powerAction(action) {
        root.closeLauncher();
        if (action === "shutdown") {
            Quickshell.execDetached(["bash", "-c", "systemctl poweroff"]);
        } else if (action === "reboot") {
            Quickshell.execDetached(["bash", "-c", "systemctl reboot"]);
        } else if (action === "suspend") {
            Quickshell.execDetached(["bash", "-c", "systemctl suspend"]);
        } else if (action === "lock") {
            Quickshell.execDetached(["bash", "-c", "command -v smart_lock.sh >/dev/null 2>&1 && smart_lock.sh || hyprlock"]);
        } else if (action === "logout") {
            Quickshell.execDetached(["bash", "-c", "hyprctl dispatch exit"]);
        } else if (action === "wlogout") {
            Quickshell.execDetached(["bash", "-c", "wlogout"]);
        }
    }

    Component.onCompleted: {
        appScanner.running = true;
    }
}
