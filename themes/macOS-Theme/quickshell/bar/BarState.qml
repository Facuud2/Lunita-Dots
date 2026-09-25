import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Item {
    id: root

    // ── Active Window Tracking ──
    property string activeAppName: "Finder"
    property string activeWindowTitle: ""
    property string activeWindowClass: ""
    property bool isWindowFloating: false
    property int isWindowFullscreen: 0

    // ── Date & Time Tracking ──
    property string timeStr: ""
    property string dateStr: ""
    property string fullDateStr: ""

    // ── Audio & Volume ──
    property int volumePercent: 75
    property bool isMuted: false
    property string activeAudioSink: ""
    property var audioSinks: []

    // ── Brightness ──
    property int brightnessPercent: 80

    // ── Battery ──
    property int batteryPercent: 100
    property bool isCharging: false
    property bool hasBattery: false

    // ── Network (Ethernet & Wi-Fi) ──
    property bool networkConnected: true
    property string activeNetworkType: "ethernet" // "ethernet" | "wifi" | "none"
    property string networkName: "Ethernet"
    property string networkDevice: ""
    property string networkIp: ""
    property bool isEthernet: activeNetworkType === "ethernet"
    property bool isWifi: activeNetworkType === "wifi"

    // Ethernet specific
    property bool ethernetHasDevice: true
    property bool ethernetEnabled: true
    property bool ethernetConnected: true
    property string ethernetDevice: "enp9s0"
    property string ethernetName: "Conexión cableada"
    property string ethernetIp: ""

    // Wi-Fi specific
    property bool wifiHasDevice: true
    property bool wifiEnabled: false
    property bool wifiConnected: false
    property string wifiDevice: "wlan0"
    property string wifiName: "Wi-Fi"
    property string wifiIp: ""
    property int wifiStrength: 0
    property var wifiNetworks: []

    // ── Bluetooth ──
    property bool bluetoothEnabled: true
    property string bluetoothConnectedDevice: ""
    property var bluetoothDevices: []

    // ── DND / Night Light ──
    property bool dndEnabled: false
    property bool nightLightEnabled: false

    // ── Screen Recording ──
    property bool isRecording: false

    // ── MPRIS Music ──
    property string mprisTitle: ""
    property string mprisArtist: ""
    property string mprisArtUrl: ""
    property bool mprisPlaying: false
    property bool mprisAvailable: false

    // ── Theme State (macOS Light & Dark Mode) ──
    property bool isDarkTheme: true

    // Dynamic Theme Color Tokens
    readonly property color barBgColor: isDarkTheme ? Qt.rgba(0.08, 0.08, 0.10, 0.75) : Qt.rgba(0.96, 0.96, 0.98, 0.82)
    readonly property color barDividerColor: isDarkTheme ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12)
    readonly property color barTextColor: isDarkTheme ? "#FFFFFF" : "#1D1D1F"
    readonly property color barTextDimColor: isDarkTheme ? Qt.rgba(1, 1, 1, 0.70) : Qt.rgba(0.11, 0.11, 0.12, 0.70)
    readonly property color barHoverColor: isDarkTheme ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(0, 0, 0, 0.08)
    readonly property color barActiveHoverColor: isDarkTheme ? Qt.rgba(1, 1, 1, 0.22) : Qt.rgba(0, 0, 0, 0.15)
    readonly property color iconColor: isDarkTheme ? "#FFFFFF" : "#1D1D1F"

    readonly property color popupBgColor: isDarkTheme ? Qt.rgba(0.12, 0.12, 0.16, 0.98) : Qt.rgba(0.96, 0.96, 0.98, 0.98)
    readonly property color popupBorderColor: isDarkTheme ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(0, 0, 0, 0.14)
    readonly property color popupCardBg: isDarkTheme ? Qt.rgba(0.18, 0.18, 0.22, 0.60) : Qt.rgba(0, 0, 0, 0.05)
    readonly property color popupCardBorder: isDarkTheme ? Qt.rgba(1, 1, 1, 0.08) : Qt.rgba(0, 0, 0, 0.08)
    readonly property color popupTextColor: isDarkTheme ? "#FFFFFF" : "#1D1D1F"
    readonly property color popupTextDim: isDarkTheme ? Qt.rgba(1, 1, 1, 0.55) : Qt.rgba(0.11, 0.11, 0.12, 0.55)
    readonly property color popupSeparatorColor: isDarkTheme ? Qt.rgba(1, 1, 1, 0.10) : Qt.rgba(0, 0, 0, 0.10)

    readonly property color sliderTrackColor: isDarkTheme ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.10)
    readonly property color sliderFillColor: isDarkTheme ? "#FFFFFF" : "#007AFF"
    readonly property color sliderIconCovered: isDarkTheme ? "#1D1D1F" : "#FFFFFF"
    readonly property color sliderIconUncovered: isDarkTheme ? "#FFFFFF" : "#1D1D1F"

    function toggleThemeMode() {
        isDarkTheme = !isDarkTheme;
        var scheme = isDarkTheme ? "prefer-dark" : "prefer-light";
        var gtkTheme = isDarkTheme ? "Adwaita-dark" : "Adwaita";
        var cmd = "gsettings set org.gnome.desktop.interface color-scheme '" + scheme + "' 2>/dev/null; " +
                  "gsettings set org.gnome.desktop.interface gtk-theme '" + gtkTheme + "' 2>/dev/null; " +
                  "mkdir -p $HOME/.config/lunita && echo '" + (isDarkTheme ? "dark" : "light") + "' > $HOME/.config/lunita/color_scheme";
        Quickshell.execDetached(["bash", "-c", cmd]);
    }

    // Process to initialize theme mode from gsettings / state file
    Process {
        id: themeInitProc
        running: true
        command: ["bash", "-c", "if [ -f $HOME/.config/lunita/color_scheme ]; then cat $HOME/.config/lunita/color_scheme; else gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || echo 'prefer-dark'; fi"]
        stdout: SplitParser {
            onRead: data => {
                var str = data.trim().toLowerCase();
                if (str.indexOf("light") !== -1) {
                    root.isDarkTheme = false;
                } else {
                    root.isDarkTheme = true;
                }
            }
        }
    }

    // ── Active Popup State ──
    property string activePopup: "" // "apple", "appmenu", "bluetooth", "controlcenter", "calendar"
    property real popupX: 0
    property real popupY: 28
    property string activeMenuTitle: ""
    property var activeScreen: null

    function togglePopup(name, xPos, yPos, targetScreen) {
        var screenMatches = (targetScreen === undefined || activeScreen === null || activeScreen === targetScreen || (activeScreen && targetScreen && activeScreen.name === targetScreen.name));
        if (activePopup === name && screenMatches) {
            activePopup = "";
            activeScreen = null;
        } else {
            popupX = xPos !== undefined ? xPos : 0;
            popupY = yPos !== undefined ? yPos : 28;
            activeScreen = targetScreen !== undefined ? targetScreen : null;
            activePopup = name;
        }
    }

    function openAppMenu(name, xPos, yPos, targetScreen) {
        var screenMatches = (targetScreen === undefined || activeScreen === null || activeScreen === targetScreen || (activeScreen && targetScreen && activeScreen.name === targetScreen.name));
        if (activePopup === "appmenu" && activeMenuTitle === name && screenMatches) {
            activePopup = "";
            activeMenuTitle = "";
            activeScreen = null;
        } else {
            activeMenuTitle = name;
            popupX = xPos;
            popupY = yPos !== undefined ? yPos : 28;
            activeScreen = targetScreen !== undefined ? targetScreen : null;
            activePopup = "appmenu";
        }
    }

    function closePopups() {
        activePopup = "";
        activeMenuTitle = "";
        activeScreen = null;
    }

    // ── 1. Clock & Date Timer ──
    Timer {
        id: clockTimer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date();
            var days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
            var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
            
            var dayName = days[now.getDay()];
            var monthName = months[now.getMonth()];
            var dayNum = now.getDate();
            
            var hours = now.getHours();
            var minutes = now.getMinutes();
            var ampm = hours >= 12 ? "PM" : "AM";
            var displayHours = hours % 12;
            if (displayHours === 0) displayHours = 12;
            var displayMinutes = minutes < 10 ? "0" + minutes : minutes;
            
            root.dateStr = dayName + " " + monthName + " " + dayNum;
            root.timeStr = displayHours + ":" + displayMinutes + " " + ampm;
            root.fullDateStr = root.dateStr + "  " + root.timeStr;
        }
    }

    // ── 2. Hyprland Active Window Tracker ──
    Timer {
        id: hyprTimer
        interval: 250
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            hyprActiveProc.running = true;
        }
    }

    Process {
        id: hyprActiveProc
        command: [Quickshell.env("HOME") + "/.config/quickshell/bar/scripts/activewindow.sh"]
        stdout: SplitParser {
            onRead: data => {
                var str = data.trim();
                if (!str || str === "{}" || str === "") {
                    root.activeAppName = "Finder";
                    root.activeWindowTitle = "";
                    root.activeWindowClass = "";
                    root.isWindowFloating = false;
                    root.isWindowFullscreen = 0;
                    return;
                }
                try {
                    var parsed = JSON.parse(str);
                    var cls = parsed.class || parsed.initialClass || "";
                    if (!cls) {
                        root.activeAppName = "Finder";
                        root.activeWindowTitle = "";
                        root.activeWindowClass = "";
                        return;
                    }
                    root.activeWindowClass = cls;
                    root.activeWindowTitle = parsed.title || "";
                    root.isWindowFloating = !!parsed.floating;
                    root.isWindowFullscreen = parsed.fullscreen || 0;
                    root.activeAppName = formatAppName(cls, parsed.initialTitle || parsed.title);
                } catch(e) {}
            }
        }
    }

    function formatAppName(cls, title) {
        if (!cls) return "Finder";
        var c = cls.toLowerCase();
        if (c.indexOf("dolphin") !== -1 || c.indexOf("nautilus") !== -1 || c.indexOf("thunar") !== -1) return "Finder";
        if (c.indexOf("kitty") !== -1) return "Kitty";
        if (c.indexOf("ghostty") !== -1) return "Ghostty";
        if (c.indexOf("foot") !== -1 || c.indexOf("alacritty") !== -1 || c.indexOf("wezterm") !== -1) return "Terminal";
        if (c.indexOf("zen") !== -1) return "Zen Browser";
        if (c.indexOf("firefox") !== -1) return "Firefox";
        if (c.indexOf("chrome") !== -1) return "Google Chrome";
        if (c.indexOf("chromium") !== -1) return "Chromium";
        if (c.indexOf("brave") !== -1) return "Brave";
        if (c.indexOf("code") !== -1 || c.indexOf("vscodium") !== -1) return "Visual Studio Code";
        if (c.indexOf("spotify") !== -1) return "Spotify";
        if (c.indexOf("discord") !== -1 || c.indexOf("vesktop") !== -1) return "Discord";
        if (c.indexOf("telegram") !== -1) return "Telegram";
        if (c.indexOf("minecraft") !== -1) return "Minecraft";
        if (c.indexOf("prism") !== -1) return "Prism Launcher";
        if (c.indexOf("settings") !== -1 || c.indexOf("nwg-look") !== -1 || c.indexOf("pavucontrol") !== -1) return "System Settings";
        if (c.indexOf("obs") !== -1) return "OBS Studio";
        if (c.indexOf("neovim") !== -1 || c.indexOf("nvim") !== -1) return "Neovim";
        if (c.indexOf("antigravity") !== -1) return "Antigravity";
        
        // Clean reverse domain notation (e.g. org.prismlauncher.PrismLauncher -> Prism Launcher)
        var name = cls;
        if (name.indexOf(".") !== -1) {
            var parts = name.split(".");
            name = parts[parts.length - 1];
        }
        name = name.replace(/([a-z])([A-Z])/g, "$1 $2");

        if (title && title.length > 0 && title.length < 25 && title.indexOf("/") === -1 && title.indexOf("—") === -1) {
            return title;
        }
        return name.charAt(0).toUpperCase() + name.slice(1);
    }

    // ── 3. Volume & Audio Control (audio.py) ──
    Timer {
        id: audioTimer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            audioQueryProc.running = true;
        }
    }

    Process {
        id: audioQueryProc
        command: ["python3", Quickshell.env("HOME") + "/.config/quickshell/bar/scripts/audio.py"]
        stdout: SplitParser {
            onRead: data => {
                var str = data.trim();
                if (!str || str.length === 0) return;
                try {
                    var parsed = JSON.parse(str);
                    if (typeof parsed.volume === "number") root.volumePercent = parsed.volume;
                    if (typeof parsed.muted === "boolean") root.isMuted = parsed.muted;
                    if (parsed.activeSink) root.activeAudioSink = parsed.activeSink;
                    if (Array.isArray(parsed.sinks)) root.audioSinks = parsed.sinks;
                } catch(e) {}
            }
        }
    }

    function setVolume(pct) {
        var clamped = Math.max(0, Math.min(100, pct));
        root.volumePercent = clamped;
        Quickshell.execDetached(["python3", Quickshell.env("HOME") + "/.config/quickshell/bar/scripts/audio.py", "set-vol", clamped.toString()]);
    }

    function toggleMute() {
        root.isMuted = !root.isMuted;
        Quickshell.execDetached(["python3", Quickshell.env("HOME") + "/.config/quickshell/bar/scripts/audio.py", "toggle-mute"]);
    }

    function setAudioSink(sinkId) {
        Quickshell.execDetached(["python3", Quickshell.env("HOME") + "/.config/quickshell/bar/scripts/audio.py", "set-sink", sinkId.toString()]);
        audioQueryProc.running = true;
    }

    // ── 4. Brightness Control ──
    Timer {
        id: brightnessTimer
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            brightnessProc.running = true;
        }
    }

    Process {
        id: brightnessProc
        command: ["bash", "-c", "brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%'"]
        stdout: SplitParser {
            onRead: data => {
                var num = parseInt(data.trim());
                if (!isNaN(num)) {
                    root.brightnessPercent = num;
                }
            }
        }
    }

    function setBrightness(pct) {
        var clamped = Math.max(5, Math.min(100, pct));
        root.brightnessPercent = clamped;
        Quickshell.execDetached(["bash", "-c", "brightnessctl s " + clamped + "%"]);
    }

    // ── 5. Battery Tracking ──
    Timer {
        id: batteryTimer
        interval: 4000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            batteryProc.running = true;
        }
    }

    Process {
        id: batteryProc
        command: ["bash", "-c", "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1; cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n 1"]
        stdout: SplitParser {
            onRead: data => {
                var lines = data.trim().split("\n");
                if (lines.length >= 1 && lines[0] !== "") {
                    var cap = parseInt(lines[0]);
                    if (!isNaN(cap)) {
                        root.hasBattery = true;
                        root.batteryPercent = cap;
                        if (lines.length >= 2) {
                            root.isCharging = (lines[1].trim() === "Charging");
                        }
                    }
                }
            }
        }
    }

    // ── 6. Network (Ethernet & Wi-Fi) Tracking ──
    Timer {
        id: netTimer
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            netProc.running = true;
        }
    }

    Process {
        id: netProc
        command: [Quickshell.env("HOME") + "/.config/quickshell/bar/scripts/network.py"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    var parsed = JSON.parse(data.trim());
                    root.networkConnected = !!parsed.connected;
                    root.activeNetworkType = parsed.activeType || "none";
                    root.networkName = parsed.activeName || "Desconectado";
                    root.networkIp = parsed.activeIp || "";

                    if (parsed.ethernet) {
                        root.ethernetHasDevice = !!parsed.ethernet.hasDevice;
                        root.ethernetEnabled = !!parsed.ethernet.enabled;
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
                        root.wifiName = parsed.wifi.name || "Wi-Fi";
                        root.wifiIp = parsed.wifi.ip || "";
                        root.wifiStrength = parsed.wifi.signal || 0;
                        root.wifiNetworks = parsed.wifi.networks || [];
                    }
                } catch(e) {}
            }
        }
    }

    function toggleWifi() {
        var next = !root.wifiEnabled;
        root.wifiEnabled = next;
        Quickshell.execDetached(["bash", "-c", next ? "nmcli radio wifi on" : "nmcli radio wifi off"]);
        netTimer.restart();
    }

    function toggleEthernet() {
        var next = !root.ethernetConnected;
        root.ethernetConnected = next;
        var dev = root.ethernetDevice || "enp9s0";
        if (next) {
            Quickshell.execDetached(["bash", "-c", "nmcli device connect " + dev + " || nmcli connection up \"" + root.ethernetName + "\""]);
        } else {
            Quickshell.execDetached(["bash", "-c", "nmcli device disconnect " + dev]);
        }
        netTimer.restart();
    }

    function connectWifi(ssid) {
        if (!ssid) return;
        Quickshell.execDetached(["bash", "-c", "nmcli connection up \"" + ssid + "\" || nmcli dev wifi connect \"" + ssid + "\" || nm-connection-editor"]);
        netTimer.restart();
    }

    function rescanWifi() {
        Quickshell.execDetached(["bash", "-c", "nmcli dev wifi rescan"]);
        netTimer.restart();
    }

    function runSilent(cmd) {
        if (cmd) {
            Quickshell.execDetached(["bash", "-c", cmd]);
        }
    }

    // ── Tray Icons Cache ──
    property var trayIconsMap: ({})

    function resolveTrayIcons(iconsList) {
        if (!iconsList || iconsList.length === 0) return;
        var cmd = ["python3", Quickshell.env("HOME") + "/.config/quickshell/bar/scripts/tray_resolver.py"].concat(iconsList);
        trayResolveProc.command = cmd;
        trayResolveProc.running = true;
    }

    Process {
        id: trayResolveProc
        stdout: SplitParser {
            onRead: data => {
                try {
                    var map = JSON.parse(data.trim());
                    var current = Object.assign({}, root.trayIconsMap);
                    for (var k in map) {
                        current[k] = map[k];
                    }
                    root.trayIconsMap = current;
                } catch(e) {}
            }
        }
    }

    // ── 7. Bluetooth Tracking (1:1 with AGS implementation) ──
    Timer {
        id: btTimer
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            btProc.running = true;
        }
    }

    Process {
        id: btProc
        command: [Quickshell.env("HOME") + "/.config/quickshell/bar/scripts/bluetooth.py"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    var parsed = JSON.parse(data.trim());
                    root.bluetoothEnabled = !!parsed.powered;
                    root.bluetoothConnectedDevice = parsed.connectedDevice || "";
                    root.bluetoothDevices = parsed.devices || [];
                } catch(e) {}
            }
        }
    }

    function toggleBluetooth() {
        var next = !root.bluetoothEnabled;
        root.bluetoothEnabled = next;
        if (next) {
            Quickshell.execDetached(["bash", "-c", "rfkill unblock bluetooth 2>/dev/null; bluetoothctl power on"]);
        } else {
            Quickshell.execDetached(["bash", "-c", "bluetoothctl power off"]);
        }
        btTimer.restart();
    }

    function connectBluetoothDevice(mac, isConnected) {
        if (isConnected) {
            Quickshell.execDetached(["bash", "-c", "bluetoothctl disconnect " + mac]);
        } else {
            Quickshell.execDetached(["bash", "-c", "bluetoothctl connect " + mac]);
        }
        btTimer.restart();
    }

    function rescanBluetooth() {
        Quickshell.execDetached(["bash", "-c", "bluetoothctl --timeout 5 scan on"]);
        btTimer.restart();
    }

    function openBluetoothSettings() {
        closePopups();
        Quickshell.execDetached(["bash", "-c", "blueman-manager || rofi-bluetooth || hyprctl dispatch exec blueman-manager"]);
    }

    // ── 8. Screen Recording & Camera Tracking ──
    Timer {
        id: recordTimer
        interval: 1500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            recordProc.running = true;
        }
    }

    Process {
        id: recordProc
        command: ["bash", "-c", "pidof wf-recorder gpu-screen-recorder obs >/dev/null && echo 'yes' || echo 'no'"]
        stdout: SplitParser {
            onRead: data => {
                root.isRecording = (data.trim() === "yes");
            }
        }
    }

    function toggleRecording() {
        var home = Quickshell.env("HOME") || "/home/facuud2";
        Quickshell.execDetached(["bash", "-c", home + "/.config/hypr/scripts/record.sh area"]);
    }

    // ── 9. MPRIS Media Tracking ──
    Timer {
        id: mprisTimer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            mprisProc.running = true;
        }
    }

    Process {
        id: mprisProc
        command: ["bash", "-c", "playerctl metadata --format '{{title}}:::{{artist}}:::{{mpris:artUrl}}:::{{status}}' 2>/dev/null || echo ''"]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim();
                if (!line) {
                    root.mprisAvailable = false;
                    root.mprisPlaying = false;
                    return;
                }
                var parts = line.split(":::");
                if (parts.length >= 4) {
                    root.mprisAvailable = true;
                    root.mprisTitle = parts[0] || "Unknown Track";
                    root.mprisArtist = parts[1] || "Unknown Artist";
                    root.mprisArtUrl = parts[2] || "";
                    root.mprisPlaying = (parts[3].toLowerCase() === "playing");
                }
            }
        }
    }

    function mediaPlayPause() {
        Quickshell.execDetached(["bash", "-c", "playerctl play-pause"]);
    }
    function mediaNext() {
        Quickshell.execDetached(["bash", "-c", "playerctl next"]);
    }
    function mediaPrevious() {
        Quickshell.execDetached(["bash", "-c", "playerctl previous"]);
    }

    // ── System & Window Dispatch Actions ──
    function launchCommand(cmd) {
        closePopups();
        if (cmd) {
            Quickshell.execDetached(["bash", "-c", cmd]);
        }
    }

    function lockScreen() {
        closePopups();
        var home = Quickshell.env("HOME") || "/home/facuud2";
        Quickshell.execDetached(["bash", "-c", home + "/.config/hypr/scripts/smart_lock.sh classic || hyprlock"]);
    }

    function openSpotlight() {
        closePopups();
        Quickshell.execDetached(["bash", "-c", "rofi -show drun"]);
    }
}
