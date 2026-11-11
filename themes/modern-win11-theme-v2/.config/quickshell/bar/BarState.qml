import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Item {
    id: root

    // ==========================================
    // 0. ASTRAEUS THEME TOKENS & LOOK ENGINE
    // ==========================================
    property string astraeusLook: "dark" // "dark" | "glass" | "starfall" | "light" | "custom"

    // Primary & Accent Colors
    property color themeAccent: {
        if (root.astraeusLook === "starfall") return "#9F8CFF";
        if (root.astraeusLook === "glass") return "#60CDFF";
        if (root.astraeusLook === "light") return "#0078D4";
        return "#0078D4";
    }
    property color themeAccentHover: {
        if (root.astraeusLook === "starfall") return "#B588F7";
        if (root.astraeusLook === "glass") return "#7BD7FF";
        return "#4CC2FF";
    }
    property color themeAccentActive: {
        if (root.astraeusLook === "starfall") return "#7B2CBF";
        if (root.astraeusLook === "glass") return "#0091FF";
        return "#005A9E";
    }
    property color themeAccentGlow: {
        if (root.astraeusLook === "starfall") return Qt.rgba(0.62, 0.55, 1.0, 0.35);
        if (root.astraeusLook === "glass") return Qt.rgba(0.38, 0.80, 1.0, 0.30);
        return Qt.rgba(0.0, 0.47, 0.83, 0.28);
    }
    property color themeOnAccent: "#FFFFFF"

    // Surfaces & Containers
    property color themeSurface: {
        if (root.astraeusLook === "light") return Qt.rgba(0.95, 0.95, 0.97, 0.82);
        if (root.astraeusLook === "glass") return Qt.rgba(0.08, 0.08, 0.12, 0.65);
        if (root.astraeusLook === "starfall") return Qt.rgba(0.04, 0.05, 0.09, 0.85);
        return Qt.rgba(0.07, 0.07, 0.10, 0.78);
    }
    property color themeSurfaceContainer: {
        if (root.astraeusLook === "light") return Qt.rgba(1, 1, 1, 0.65);
        if (root.astraeusLook === "glass") return Qt.rgba(1, 1, 1, 0.09);
        if (root.astraeusLook === "starfall") return Qt.rgba(0.08, 0.09, 0.14, 0.74);
        return Qt.rgba(1, 1, 1, 0.07);
    }
    property color themeSurfaceContainerHigh: {
        if (root.astraeusLook === "light") return Qt.rgba(1, 1, 1, 0.90);
        if (root.astraeusLook === "glass") return Qt.rgba(1, 1, 1, 0.16);
        if (root.astraeusLook === "starfall") return Qt.rgba(0.12, 0.13, 0.20, 0.85);
        return Qt.rgba(1, 1, 1, 0.12);
    }

    // Typography & Ink Tokens
    property color themeOnSurface: {
        if (root.astraeusLook === "light") return "#1C1D22";
        if (root.astraeusLook === "glass") return "#FFFFFF";
        if (root.astraeusLook === "starfall") return "#F0EFFF";
        return "#F4F4F6";
    }
    property color themeOnSurfaceDim: {
        if (root.astraeusLook === "light") return "#5C5F6D";
        if (root.astraeusLook === "glass") return Qt.rgba(1, 1, 1, 0.82);
        if (root.astraeusLook === "starfall") return "#9D9BC2";
        return "#A0A5B5";
    }
    property color themeOnSurfaceLow: {
        if (root.astraeusLook === "light") return "#9CA3AF";
        if (root.astraeusLook === "glass") return Qt.rgba(1, 1, 1, 0.55);
        if (root.astraeusLook === "starfall") return "#6B6894";
        return "#707588";
    }

    // Outlines, Borders & Hairlines
    property color themeBorder: {
        if (root.astraeusLook === "light") return Qt.rgba(0, 0, 0, 0.08);
        if (root.astraeusLook === "glass") return Qt.rgba(1, 1, 1, 0.14);
        if (root.astraeusLook === "starfall") return Qt.rgba(0.62, 0.55, 1.0, 0.15);
        return Qt.rgba(1, 1, 1, 0.08);
    }
    property color themeBorderSpecular: {
        if (root.astraeusLook === "light") return Qt.rgba(1, 1, 1, 0.45);
        if (root.astraeusLook === "glass") return Qt.rgba(1, 1, 1, 0.38);
        if (root.astraeusLook === "starfall") return Qt.rgba(1, 1, 1, 0.20);
        return Qt.rgba(1, 1, 1, 0.16);
    }
    property color themeHairlineTop: {
        if (root.astraeusLook === "light") return Qt.rgba(1, 1, 1, 0.60);
        if (root.astraeusLook === "glass") return Qt.rgba(1, 1, 1, 0.38);
        if (root.astraeusLook === "starfall") return Qt.rgba(1, 1, 1, 0.18);
        return Qt.rgba(1, 1, 1, 0.14);
    }
    property color themeHairlineBot: {
        if (root.astraeusLook === "light") return Qt.rgba(0, 0, 0, 0.04);
        if (root.astraeusLook === "glass") return Qt.rgba(1, 1, 1, 0.08);
        if (root.astraeusLook === "starfall") return Qt.rgba(1, 1, 1, 0.04);
        return Qt.rgba(1, 1, 1, 0.03);
    }
    property color themeTrack: {
        if (root.astraeusLook === "light") return Qt.rgba(0, 0, 0, 0.08);
        if (root.astraeusLook === "glass") return Qt.rgba(1, 1, 1, 0.20);
        if (root.astraeusLook === "starfall") return Qt.rgba(0.62, 0.55, 1.0, 0.12);
        return Qt.rgba(1, 1, 1, 0.16);
    }

    // Geometry & Radii
    property real themeCardRadius: 14
    property real themeControlRadius: 8
    property real themePillRadius: 9999
    property real themePanelRadius: 18

    // Fonts
    property string themeFontInterface: "Segoe UI Variable Text, Segoe UI, Inter, Sans-Serif"
    property string themeFontDisplay: "Segoe UI Variable Display, Segoe UI"

    function setAstraeusLook(newLook) {
        if (newLook === "dark" || newLook === "glass" || newLook === "starfall" || newLook === "light" || newLook === "custom") {
            root.astraeusLook = newLook;
        }
    }

    // ==========================================
    // 0B. WINDOW & FULLSCREEN TRACKING
    // ==========================================
    property string activeWindowTitle: ""
    property string activeWindowClass: ""
    property int isWindowFullscreen: 0
    property bool isWindowFloating: false

    Timer {
        id: hyprActiveTimer
        interval: 800
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!hyprActiveProc.running) {
                hyprActiveProc.running = true;
            }
        }
    }

    Process {
        id: hyprActiveProc
        command: [Quickshell.env("HOME") + "/.config/quickshell/bar/scripts/activewindow.sh"]
        stdout: SplitParser {
            onRead: data => {
                var str = data.trim();
                if (!str || str === "{}" || str === "") {
                    root.activeWindowTitle = "";
                    root.activeWindowClass = "";
                    root.isWindowFloating = false;
                    root.isWindowFullscreen = 0;
                    return;
                }
                try {
                    var parsed = JSON.parse(str);
                    root.activeWindowTitle = parsed.title || "";
                    root.activeWindowClass = parsed.class || "";
                    root.isWindowFloating = !!parsed.floating;
                    root.isWindowFullscreen = parsed.fullscreen || 0;
                } catch(e) {}
            }
        }
    }

    // ==========================================
    // 0C. ASTRAEUS DYNAMIC ISLAND & LYRICS STATE
    // ==========================================
    property string islandStateMode: "notch" // "notch" | "music_pill" | "long_pill" | "dashboard"
    property bool forceLongPill: false
    property string currentLyricLine: ""
    property bool lyricsActive: false

    // ==========================================
    // 1. DATE & TIME
    // ==========================================
    property string timeStr: "03:31 p. m."
    property string dateStr: "3 de octubre"
    property string monthName: "Octubre"
    property int currentYear: 2026
    property int currentMonth: 10 // 1-indexed
    property int currentDay: 3

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date();
            var hours = now.getHours();
            var minutes = now.getMinutes();
            var ampm = hours >= 12 ? "p. m." : "a. m.";
            var h12 = hours % 12;
            if (h12 === 0) h12 = 12;
            var hStr = (h12 < 10 ? "0" : "") + h12;
            var mStr = (minutes < 10 ? "0" : "") + minutes;
            root.timeStr = hStr + ":" + mStr + " " + ampm;

            root.currentYear = now.getFullYear();
            root.currentMonth = now.getMonth() + 1;
            root.currentDay = now.getDate();

            var months = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
                          "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"];
            root.monthName = months[now.getMonth()];
            root.dateStr = now.getDate() + " de " + root.monthName.toLowerCase();
        }
    }

    // ==========================================
    // 2. AUDIO & VOLUME (PipeWire / wpctl)
    // ==========================================
    property int volumePercent: 75
    property bool isMuted: false
    property string activeAudioSink: "Altavoces principales"
    property bool volumeInitialized: false
    signal requestShowSoundFeedback(string targetScreen)

    function triggerSoundFeedback() {
        var target = (Hyprland.focusedMonitor && Hyprland.focusedMonitor.name) ? Hyprland.focusedMonitor.name : "";
        root.requestShowSoundFeedback(target);
    }

    Process {
        id: volumeListenerProc
        command: ["python3", "-u", Quickshell.env("HOME") + "/.config/quickshell/bar/scripts/volume_listener.py"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                var str = data.trim();
                if (!str || str.length === 0) return;
                try {
                    var parsed = JSON.parse(str);
                    if (parsed.volume !== undefined) {
                        var prevVol = root.volumePercent;
                        var prevMuted = root.isMuted;
                        var newVol = Math.min(100, Math.max(0, parsed.volume));
                        var newMuted = !!parsed.muted;
                        root.volumePercent = newVol;
                        root.isMuted = newMuted;
                        if (parsed.sink) root.activeAudioSink = parsed.sink;

                        if (root.volumeInitialized) {
                            if (prevVol !== newVol || prevMuted !== newMuted) {
                                root.triggerSoundFeedback();
                            }
                        } else {
                            root.volumeInitialized = true;
                        }
                    }
                } catch(e) {}
            }
        }
        onExited: {
            listenerRespawnTimer.restart();
        }
    }

    Timer {
        id: listenerRespawnTimer
        interval: 1000
        repeat: false
        onTriggered: {
            volumeListenerProc.running = true;
        }
    }

    property var audioSinks: [
        { name: "Altavoces (Audio integrado)", id: "@DEFAULT_AUDIO_SINK@" },
        { name: "Auriculares / Headset", id: "headphones" },
        { name: "Audio Digital HDMI", id: "hdmi" }
    ]

    Timer {
        id: volumeTimer
        interval: 4000
        running: true
        repeat: true
        triggeredOnStart: false
        onTriggered: {
            volumeProc.running = true;
        }
    }

    Process {
        id: volumeProc
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null || echo 'Volume: 0.75'"]
        stdout: SplitParser {
            onRead: data => {
                var line = data.trim();
                if (line.indexOf("[MUTED]") !== -1) {
                    root.isMuted = true;
                } else {
                    root.isMuted = false;
                }
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

    function setVolume(pct) {
        var clamped = Math.max(0, Math.min(100, Math.round(pct)));
        root.volumePercent = clamped;
        Quickshell.execDetached(["bash", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + (clamped / 100).toFixed(2) + " 2>/dev/null || pactl set-sink-volume @DEFAULT_SINK@ " + clamped + "% 2>/dev/null"]);
    }

    function toggleMute() {
        root.isMuted = !root.isMuted;
        Quickshell.execDetached(["bash", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle 2>/dev/null || pactl set-sink-mute @DEFAULT_SINK@ toggle 2>/dev/null"]);
    }

    // Microphone Volume & Mute Controls
    property int micPercent: 100
    property bool micMuted: false

    function setMicVolume(pct) {
        var clamped = Math.max(0, Math.min(100, Math.round(pct)));
        root.micPercent = clamped;
        Quickshell.execDetached(["bash", "-c", "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ " + (clamped / 100).toFixed(2) + " 2>/dev/null || true"]);
    }

    function toggleMicMute() {
        root.micMuted = !root.micMuted;
        Quickshell.execDetached(["bash", "-c", "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle 2>/dev/null || true"]);
    }

    // ==========================================
    // 3. BRIGHTNESS (brightnessctl / fallback)
    // ==========================================
    property int brightnessPercent: 80
    property bool nightLightEnabled: false

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
        command: ["bash", "-c", "brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%' || echo '80'"]
        stdout: SplitParser {
            onRead: data => {
                var num = parseInt(data.trim());
                if (!isNaN(num) && num >= 0 && num <= 100) {
                    root.brightnessPercent = num;
                }
            }
        }
    }

    function setBrightness(pct) {
        var clamped = Math.max(5, Math.min(100, Math.round(pct)));
        root.brightnessPercent = clamped;
        Quickshell.execDetached(["bash", "-c", "brightnessctl s " + clamped + "% 2>/dev/null || true"]);
    }

    function toggleNightLight() {
        root.nightLightEnabled = !root.nightLightEnabled;
        if (root.nightLightEnabled) {
            Quickshell.execDetached(["bash", "-c", "hyprshade on blue-light-filter 2>/dev/null || gammastep -O 4500 -b 0.9 2>/dev/null || true"]);
        } else {
            Quickshell.execDetached(["bash", "-c", "hyprshade off 2>/dev/null || pkill gammastep 2>/dev/null || true"]);
        }
    }

    // ==========================================
    // 4. MPRIS / MUSIC PLAYER
    // ==========================================
    property bool mprisAvailable: false
    property bool mprisPlaying: false
    property bool mprisActive: false
    property string mprisTitle: ""
    property string mprisArtist: ""
    property string mprisArtUrl: ""
    property double mprisPosition: 0.0
    property double mprisLength: 100.0
    property string mprisPositionStr: "0:00"
    property string mprisRemainingStr: "-0:00"

    // Astraeus MPRIS Compatibility Aliases
    property alias mprisTrackTitle: root.mprisTitle
    property alias mprisTrackArtist: root.mprisArtist
    property alias mprisPlaybackPosition: root.mprisPosition
    property alias mprisTrackLength: root.mprisLength
    readonly property string mprisPlaybackStatus: root.mprisPlaying ? "Playing" : "Paused"

    function togglePlay() {
        root.playPause();
    }

    // 6 seconds pause timeout (iOS Dynamic Island standard): automatically dismiss CAVA and media cover if inactive
    Timer {
        id: pauseTimeoutTimer
        interval: 6000 // 6,000 ms = 6 seconds
        repeat: false
        onTriggered: {
            if (!root.mprisPlaying) {
                root.mprisActive = false;
            }
        }
    }

    Process {
        id: mediaHelperProc
        command: ["python3", "-u", Quickshell.env("HOME") + "/.config/quickshell/bar/scripts/media_helper.py"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                var str = data.trim();
                if (!str) return;
                try {
                    var obj = JSON.parse(str);
                    if (!obj.available) {
                        root.mprisAvailable = false;
                        root.mprisPlaying = false;
                        root.mprisActive = false;
                        pauseTimeoutTimer.stop();
                        root.mprisTitle = "";
                        root.mprisArtist = "";
                        root.mprisArtUrl = "";
                        return;
                    }

                    root.mprisAvailable = true;
                    root.mprisTitle = obj.title || "";
                    root.mprisArtist = obj.artist || "";
                    root.mprisArtUrl = obj.art_url || "";
                    root.mprisPosition = obj.position || 0.0;
                    root.mprisLength = Math.max(1.0, obj.length || 100.0);
                    root.mprisPositionStr = obj.position_str || "0:00";
                    root.mprisRemainingStr = obj.remaining_str || "-0:00";

                    var nextPlaying = !!obj.playing;
                    var wasPlaying = root.mprisPlaying;
                    root.mprisPlaying = nextPlaying;

                    if (nextPlaying) {
                        pauseTimeoutTimer.stop();
                        root.mprisActive = true;
                        if (!cavaProc.running) {
                            cavaProc.running = true;
                        }
                    } else {
                        if (cavaProc.running) {
                            cavaProc.running = false;
                            root.cavaBars = [];
                        }
                        if (wasPlaying && !nextPlaying) {
                            pauseTimeoutTimer.restart();
                        } else if (!pauseTimeoutTimer.running && !root.mprisActive) {
                            // Expired
                        } else if (!pauseTimeoutTimer.running && root.mprisActive) {
                            pauseTimeoutTimer.restart();
                        }
                    }
                } catch (e) {}
            }
        }
    }

    function playPause() {
        root.mprisPlaying = !root.mprisPlaying;
        if (root.mprisPlaying) {
            pauseTimeoutTimer.stop();
            root.mprisActive = true;
        } else {
            pauseTimeoutTimer.restart();
        }
        Quickshell.execDetached(["python3", Quickshell.env("HOME") + "/.config/quickshell/bar/scripts/media_helper.py", "play-pause"]);
    }

    function nextTrack() {
        pauseTimeoutTimer.stop();
        root.mprisActive = true;
        Quickshell.execDetached(["python3", Quickshell.env("HOME") + "/.config/quickshell/bar/scripts/media_helper.py", "next"]);
    }

    function previousTrack() {
        pauseTimeoutTimer.stop();
        root.mprisActive = true;
        Quickshell.execDetached(["python3", Quickshell.env("HOME") + "/.config/quickshell/bar/scripts/media_helper.py", "previous"]);
    }

    function seekPosition(ratio) {
        if (root.mprisLength > 0) {
            var targetSec = ratio * root.mprisLength;
            root.mprisPosition = targetSec;

            // Instant visual feedback for timestamps
            var pMin = Math.floor(targetSec / 60);
            var pSec = Math.floor(targetSec % 60);
            root.mprisPositionStr = pMin + ":" + (pSec < 10 ? "0" : "") + pSec;
            var rem = Math.max(0, root.mprisLength - targetSec);
            var rMin = Math.floor(rem / 60);
            var rSec = Math.floor(rem % 60);
            root.mprisRemainingStr = "-" + rMin + ":" + (rSec < 10 ? "0" : "") + rSec;

            Quickshell.execDetached(["python3", Quickshell.env("HOME") + "/.config/quickshell/bar/scripts/media_helper.py", "seek", targetSec.toFixed(1)]);
        }
    }

    // ==========================================
    // 4B. CAVA REAL-TIME AUDIO VISUALIZER
    // ==========================================
    property var cavaBars: []

    Process {
        id: cavaProc
        command: ["bash", "-c", "exec $HOME/.config/quickshell/bar/scripts/cava.sh"]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                var raw = data.trim();
                if (!raw) return;
                var parts = raw.split(";");
                var vals = [];
                for (var i = 0; i < parts.length; i++) {
                    var p = parts[i].trim();
                    if (p !== "") {
                        vals.push(Math.min(100, Math.max(0, parseInt(p) || 0)));
                    }
                }
                if (vals.length >= 10) {
                    root.cavaBars = vals;
                }
            }
        }
    }

    onMprisPlayingChanged: {
        if (root.mprisPlaying) {
            cavaProc.running = true;
        } else {
            cavaProc.running = false;
            root.cavaBars = [];
        }
    }

    // ==========================================
    // 5. WEATHER & BATTERY
    // ==========================================
    property string weatherTemp: "28°C"
    property string weatherDesc: "Soleado"
    property int batteryPercent: 100
    property bool isBatteryCharging: false
    property bool hasBattery: true

    Timer {
        id: weatherTimer
        interval: 300000 // 5 minutes
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            weatherProc.running = true;
        }
    }

    Process {
        id: weatherProc
        command: ["bash", "-c", "curl -s --max-time 3 'wttr.in/?format=%t' 2>/dev/null | tr -d '+' || echo '28°C'"]
        stdout: SplitParser {
            onRead: data => {
                var t = data.trim();
                if (t && t.length > 0 && t.indexOf("<") === -1) {
                    root.weatherTemp = t;
                }
            }
        }
    }

    Timer {
        id: batteryTimer
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            batteryProc.running = true;
        }
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
                }
            }
        }
    }

    // ==========================================
    // 6. TOGGLES & QUICK SETTINGS (WI-FI & BLUETOOTH)
    // ==========================================
    property bool wifiConnected: false
    property bool wifiEnabled: true
    property string wifiSsid: "Wi-Fi"
    property var wifiNetworks: []
    property bool wifiScanning: false

    property bool bluetoothConnected: false
    property bool bluetoothEnabled: true
    property string bluetoothConnectedDevice: ""
    property var bluetoothDevices: []
    property bool bluetoothScanning: false

    property bool dndActive: false

    Timer {
        id: netTimer
        interval: 3500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            netProc.running = true;
            btProc.running = true;
        }
    }

    Process {
        id: netProc
        command: ["python3", Quickshell.env("HOME") + "/.config/quickshell/bar/scripts/network.py"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    var parsed = JSON.parse(data.trim());
                    if (parsed.wifi) {
                        root.wifiEnabled = !!parsed.wifi.enabled;
                        root.wifiConnected = !!parsed.wifi.connected;
                        root.wifiSsid = parsed.wifi.name || "Wi-Fi";
                        root.wifiNetworks = parsed.wifi.networks || [];
                    }
                } catch(e) {}
            }
        }
    }

    Process {
        id: btProc
        command: ["python3", Quickshell.env("HOME") + "/.config/quickshell/bar/scripts/bluetooth.py"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    var parsed = JSON.parse(data.trim());
                    root.bluetoothEnabled = !!parsed.powered;
                    root.bluetoothConnected = !!parsed.connectedDevice;
                    root.bluetoothConnectedDevice = parsed.connectedDevice || "";
                    root.bluetoothDevices = parsed.devices || [];
                } catch(e) {}
            }
        }
    }

    function toggleWifi() {
        var next = !root.wifiEnabled;
        root.wifiEnabled = next;
        Quickshell.execDetached(["bash", "-c", next ? "nmcli radio wifi on" : "nmcli radio wifi off"]);
        netProc.running = true;
    }

    function rescanWifi() {
        Quickshell.execDetached(["bash", "-c", "nmcli dev wifi rescan 2>/dev/null || true"]);
        wifiRescanTimer.restart();
    }

    Timer {
        id: wifiRescanTimer
        interval: 1200
        onTriggered: netProc.running = true
    }

    function connectWifi(ssid) {
        Quickshell.execDetached(["bash", "-c", "nmcli device wifi connect \"" + ssid + "\" 2>/dev/null || true"]);
        wifiRescanTimer.restart();
    }

    function toggleBluetooth() {
        var next = !root.bluetoothEnabled;
        root.bluetoothEnabled = next;
        Quickshell.execDetached(["bash", "-c", next ? "bluetoothctl power on" : "bluetoothctl power off"]);
        btProc.running = true;
    }

    function connectBluetooth(mac) {
        Quickshell.execDetached(["bash", "-c", "bluetoothctl connect " + mac + " 2>/dev/null || true"]);
        btRescanTimer.restart();
    }

    function disconnectBluetooth(mac) {
        Quickshell.execDetached(["bash", "-c", "bluetoothctl disconnect " + mac + " 2>/dev/null || true"]);
        btRescanTimer.restart();
    }

    Timer {
        id: btRescanTimer
        interval: 1000
        onTriggered: btProc.running = true
    }

    function toggleDnd() {
        root.dndActive = !root.dndActive;
    }

    function triggerScreenshot() {
        Quickshell.execDetached(["bash", "-c", "hyprshot -m region 2>/dev/null || grimblast copy area 2>/dev/null || grim -g \"$(slurp)\" - | wl-copy 2>/dev/null || true"]);
    }

    // Recording (wf-recorder) State & Methods
    property bool isRecording: false

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
        command: ["bash", "-c", "pgrep -x wf-recorder >/dev/null && echo 'yes' || echo 'no'"]
        stdout: SplitParser {
            onRead: data => {
                root.isRecording = (data.trim() === "yes");
            }
        }
    }

    function toggleRecording(mode) {
        var m = mode || "area";
        var home = Quickshell.env("HOME");
        if (root.isRecording) {
            Quickshell.execDetached(["bash", "-c", home + "/.config/hypr/scripts/record.sh stop"]);
        } else {
            Quickshell.execDetached(["bash", "-c", home + "/.config/hypr/scripts/record.sh " + m]);
        }
        recordProc.running = true;
    }

    function openLauncher() {
        Quickshell.execDetached(["bash", "-c", "lunita-launcher 2>/dev/null || rofi -show drun 2>/dev/null || true"]);
    }

    function reloadInterface() {
        Quickshell.execDetached(["bash", "-c", "lunita-theme apply modern-win11-theme 2>/dev/null || quickshell kill && lunita-quickshell &"]);
    }

    // ==========================================
    // 7. FOCUS / POMODORO TIMER
    // ==========================================
    property bool timerRunning: false
    property int timerRemainingSecs: 300 // 5 minutes default
    property int timerInitialSecs: 300
    property string timerDisplay: "05:00"

    function updateTimerDisplay() {
        var m = Math.floor(root.timerRemainingSecs / 60);
        var s = root.timerRemainingSecs % 60;
        root.timerDisplay = (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s;
    }

    Timer {
        id: pomodoroCountdown
        interval: 1000
        repeat: true
        running: root.timerRunning
        onTriggered: {
            if (root.timerRemainingSecs > 0) {
                root.timerRemainingSecs -= 1;
                root.updateTimerDisplay();
            } else {
                root.timerRunning = false;
                Quickshell.execDetached(["bash", "-c", "notify-send 'Pomodoro completado' '¡El tiempo de enfoque ha terminado!' -i clock 2>/dev/null || true"]);
            }
        }
    }

    function toggleTimer() {
        root.timerRunning = !root.timerRunning;
    }

    function resetTimer() {
        root.timerRunning = false;
        root.timerRemainingSecs = root.timerInitialSecs;
        root.updateTimerDisplay();
    }

    function setTimerPreset(mins) {
        root.timerRunning = false;
        root.timerInitialSecs = mins * 60;
        root.timerRemainingSecs = mins * 60;
        root.updateTimerDisplay();
    }

    // ==========================================
    // 7B. TELEMETRY & SPARKLINE HISTORIES
    // ==========================================
    property int cpuPercent: 0
    property var cpuHistory: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    property int ramPercent: 0
    property string ramUsed: ""
    property var ramHistory: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    property string netDownRate: "0 KB/s"
    property var netHistory: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

    property alias bluetoothDeviceName: root.bluetoothConnectedDevice

    Timer {
        id: telemetryTimer
        interval: 1500
        repeat: true
        running: root.activePopup === "dashboard"
        triggeredOnStart: true
        onTriggered: {
            telemetrySysProc.running = true;
            telemetryNetProc.running = true;
        }
    }

    Process {
        id: telemetrySysProc
        command: [Quickshell.env("HOME") + "/.config/quickshell/widgets/scripts/sys_provider.py"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    var obj = JSON.parse(data.trim());
                    if (obj.cpu !== undefined) {
                        root.cpuPercent = Math.round(obj.cpu);
                        var ch = root.cpuHistory.slice();
                        ch.push(root.cpuPercent);
                        if (ch.length > 12) ch.shift();
                        root.cpuHistory = ch;
                    }
                    if (obj.ram !== undefined) {
                        root.ramPercent = Math.round(obj.ram);
                        root.ramUsed = obj.ram_used || (root.ramPercent + "%");
                        var rh = root.ramHistory.slice();
                        rh.push(root.ramPercent);
                        if (rh.length > 12) rh.shift();
                        root.ramHistory = rh;
                    }
                } catch (e) {}
            }
        }
    }

    Process {
        id: telemetryNetProc
        command: [Quickshell.env("HOME") + "/.config/quickshell/widgets/scripts/net_provider.py"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    var obj = JSON.parse(data.trim());
                    if (obj.down_val !== undefined && obj.down_unit !== undefined) {
                        root.netDownRate = obj.down_val + " " + obj.down_unit;
                        var val = parseFloat(obj.down_kb) || 0.0;
                        var nh = root.netHistory.slice();
                        nh.push(val);
                        if (nh.length > 12) nh.shift();
                        root.netHistory = nh;
                    }
                } catch (e) {}
            }
        }
    }

    // ==========================================
    // 8. POPUPS & OVERLAYS MANAGEMENT
    // ==========================================
    property string activePopup: "" // "" | "media" | "calendar" | "controlcenter"

    function openPopup(name) {
        if (root.activePopup === name) {
            root.activePopup = "";
        } else {
            root.activePopup = name;
        }
    }

    function closePopups() {
        root.activePopup = "";
    }

    // ==========================================
    // 9. EDGE SIDE PANELS (SOUND & BRIGHTNESS)
    // ==========================================
    signal requestCloseEdgePanels()
    signal requestToggleSound(string targetScreen)
    signal requestToggleBrightness(string targetScreen)

    function closeEdgePanels() {
        root.requestCloseEdgePanels();
    }

    function toggleSound(targetScreen) {
        root.requestToggleSound(targetScreen || "");
    }

    function toggleBrightness(targetScreen) {
        root.requestToggleBrightness(targetScreen || "");
    }

    Connections {
        target: Hyprland
        function onFocusedMonitorChanged() {
            root.closeEdgePanels();
            if (!hyprActiveProc.running) hyprActiveProc.running = true;
        }
        function onFocusedWorkspaceChanged() {
            root.closeEdgePanels();
            if (!hyprActiveProc.running) hyprActiveProc.running = true;
        }
    }
}
