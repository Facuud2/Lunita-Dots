import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Item {
    id: root

    // ── Edit Mode State ──
    property bool isEditing: false
    // ── Theme State (Synced with Lunita Color Scheme & Theme Tokens) ──
    property bool isDarkTheme: true
    property var activeTokens: ({
    })
    property var matugenColors: ({
    })
    readonly property string activeThemeId: activeTokens && activeTokens.theme_id ? activeTokens.theme_id : "macos-theme"
    readonly property var widgetTokens: activeTokens && activeTokens.widgets ? activeTokens.widgets : ({
    })
    readonly property int cardRadius: {
        if (widgetTokens && widgetTokens.card_radius !== undefined)
            return widgetTokens.card_radius;

        if (activeThemeId === "modern-win11-theme")
            return 10;

        if (activeThemeId === "lunita-default")
            return 16;

        return 22;
    }
    readonly property color cardBg: {
        if (activeThemeId === "lunita-default" && matugenColors && matugenColors.surface) {
            let c = Qt.color(matugenColors.surface);
            return Qt.rgba(c.r, c.g, c.b, 0.9);
        }
        if (widgetTokens && widgetTokens.card_bg)
            return widgetTokens.card_bg;

        if (activeThemeId === "modern-win11-theme")
            return isDarkTheme ? Qt.rgba(32 / 255, 32 / 255, 32 / 255, 0.88) : Qt.rgba(243 / 255, 243 / 255, 243 / 255, 0.88);

        if (activeThemeId === "lunita-default")
            return isDarkTheme ? Qt.rgba(20 / 255, 20 / 255, 22 / 255, 0.92) : Qt.rgba(244 / 255, 244 / 255, 246 / 255, 0.92);

        return isDarkTheme ? Qt.rgba(0.12, 0.14, 0.18, 0.75) : Qt.rgba(0.98, 0.98, 1, 0.82);
    }
    readonly property color cardBorder: {
        if (activeThemeId === "lunita-default" && matugenColors && matugenColors.outline_variant) {
            let c = Qt.color(matugenColors.outline_variant);
            return Qt.rgba(c.r, c.g, c.b, 0.35);
        }
        if (widgetTokens && widgetTokens.card_border)
            return widgetTokens.card_border;

        if (activeThemeId === "modern-win11-theme")
            return isDarkTheme ? Qt.rgba(255, 255, 255, 0.08) : Qt.rgba(0, 0, 0, 0.08);

        if (activeThemeId === "lunita-default")
            return isDarkTheme ? Qt.rgba(255, 255, 255, 0.14) : Qt.rgba(0, 0, 0, 0.12);

        return isDarkTheme ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(0, 0, 0, 0.12);
    }
    readonly property color textColor: {
        if (activeThemeId === "lunita-default" && matugenColors && matugenColors.on_surface)
            return matugenColors.on_surface;

        if (activeTokens && activeTokens.on_surface)
            return activeTokens.on_surface;

        return isDarkTheme ? "#FFFFFF" : "#1D1D1F";
    }
    readonly property color textDim: {
        if (activeThemeId === "lunita-default" && matugenColors && matugenColors.on_surface_variant)
            return matugenColors.on_surface_variant;

        if (activeTokens && activeTokens.on_surface_dim)
            return activeTokens.on_surface_dim;

        return isDarkTheme ? Qt.rgba(1, 1, 1, 0.6) : Qt.rgba(0.11, 0.11, 0.12, 0.6);
    }
    readonly property color accentColor: {
        if (activeThemeId === "lunita-default" && matugenColors && matugenColors.primary)
            return matugenColors.primary;

        if (activeTokens && activeTokens.accent)
            return activeTokens.accent;

        if (activeThemeId === "modern-win11-theme")
            return "#0078D4";

        return "#007AFF";
    }
    readonly property color accentBlue: accentColor
    readonly property color accentGreen: "#30D158"
    readonly property color accentOrange: "#FF9F0A"
    readonly property color accentRed: activeThemeId === "lunita-default" ? (matugenColors && matugenColors.error ? matugenColors.error : "#D71921") : "#FF453A"
    readonly property string fontUi: {
        if (activeTokens && activeTokens.typography && activeTokens.typography.interface)
            return activeTokens.typography.interface;

        if (activeThemeId === "modern-win11-theme")
            return "Segoe UI Variable Text, Segoe UI, sans-serif";

        if (activeThemeId === "lunita-default")
            return "Space Grotesk, sans-serif";

        return "SF Pro Display, Inter, -apple-system, sans-serif";
    }
    readonly property string fontDisplay: {
        if (activeTokens && activeTokens.typography && activeTokens.typography.display)
            return activeTokens.typography.display;

        if (activeThemeId === "modern-win11-theme")
            return "Segoe UI Variable Display, Segoe UI, sans-serif";

        if (activeThemeId === "lunita-default")
            return "NDOT 47 (inspired by NOTHING), Space Grotesk, sans-serif";

        return "SF Pro Display, Inter, -apple-system, sans-serif";
    }
    // ── System Statistics ──
    property int cpuPercent: 15
    property int ramPercent: 25
    property string ramUsed: "4.2 GB"
    property string ramTotal: "16.0 GB"
    property int gpuPercent: 0
    property int vramPercent: 0
    property string vramUsed: "0.0 GB"
    property string vramTotal: "0.0 GB"
    property int diskPercent: 30
    property string diskUsed: "270 GB"
    property string diskTotal: "930 GB"
    // ── Network Statistics ──
    property string netDownVal: "0"
    property string netDownUnit: "KB/s"
    property string netUpVal: "0"
    property string netUpUnit: "KB/s"
    property string netStatus: "UP"
    property string netInterface: "Ethernet"
    property string netIp: "192.168.1.100"
    property var netHistory: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    // ── Photo / Memories Data ──
    property string photoPath: ""
    property string photoRawPath: ""
    property string photoTitle: "Recuerdos"
    property string photoCategory: "Destacados"
    property int photoIndex: 1
    property int photoTotal: 1
    // ── Calendar Data ──
    property string calMonthName: "SEPTIEMBRE"
    property string calYear: "2026"
    property int calMonthNum: 9
    property string calToday: "29"
    property string calWeekday: "MARTES"
    property var calWeekdays: ["M", "T", "W", "T", "F", "S", "S"]
    property var calWeeks: []
    property var calEvents: ({
    })
    property string calSelectedDay: "29"
    property string calSelectedDateStr: "2026-09-29"
    property var calSelectedEvents: []
    property bool calExpanded: false
    property var savedCalBeforeExpansion: null
    // ── Clock & Weather Data ──
    property string clockTime: "9:41"
    property string clockCity: "BUENOS AIRES"
    property string clockDay: "28"
    property string clockWeekday: "LUN"
    property string weatherTemp: "--°C"
    property string weatherIcon: "󰖐"
    property string weatherDesc: "Cargando..."
    property string weatherHumidity: "--%"
    property string weatherWind: "-- km/h"
    property var weatherHourly: []
    property var weatherDaily: []
    property bool clockExpanded: false
    property var savedBeforeExpansion: null
    // ── 8. Battery / Ecosystem Devices Data ──
    property var batteryDevices: []
    property string batteryLastSync: ""
    // ── 9. Git & CI/CD Activity Data ──
    property string gitUser: "Facuud2"
    property string gitCiStatus: "success"
    property string gitCiMessage: "Pipelines OK"
    property string gitCiRepo: "Comitas-App"
    property var gitLatestCommit: ({
        "repo": "Lunita-Dots",
        "hash": "adf8df3",
        "message": "Cargando...",
        "author": "Facuud2",
        "relative_time": ""
    })
    property var gitHeatmap: []
    property var gitRecentCommits: []
    property string gitUpdatedAt: ""
    // ── 10. Health & Activity Tracker (macOS Health-Style) ──
    property int healthCalories: 0
    property int healthCaloriesGoal: 600
    property int healthExercise: 0
    property int healthExerciseGoal: 30
    property int healthSteps: 0
    property int healthStepsGoal: 10000
    property real healthWater: 0
    property real healthWaterGoal: 2.5
    property var healthHistory: []
    property int habitDay: 14
    property int habitTotalDays: 75
    property int habitStreak: 14
    property int habitCompletedCount: 0
    property int habitTotalTasks: 5
    property int habitPercent: 0
    property string habitDate: ""
    property var habitTasks: []
    // ── 11. Timetable UNaB Data ──
    property string ttUniversity: "UNaB"
    property string ttCareer: "Tecnicatura en Programación"
    property string ttSubject: "Cargando..."
    property string ttCode: ""
    property string ttRoom: ""
    property string ttProfessor: ""
    property string ttStart: ""
    property string ttEnd: ""
    property string ttStatusLabel: "Cargando..."
    property string ttTimeLeftStr: ""
    property bool ttIsActive: false
    property bool ttIsFinishingSoon: false
    property int ttProgressPct: 0
    property var ttSchedule: []
    property var ttTasks: []
    property string ttNotes: ""
    // ── 12. Media Player Data (playerctl + PIL dominant palette) ──
    property string mediaStatus: "Stopped"
    property bool mediaIsPlaying: false
    property string mediaTitle: "Sin reproducción"
    property string mediaArtist: "Ningún reproductor activo"
    property string mediaAlbum: ""
    property string mediaArtUrl: ""
    property int mediaPosition: 0
    property int mediaLength: 0
    property string mediaPositionStr: "0:00"
    property string mediaLengthStr: "0:00"
    property real mediaProgress: 0
    property color mediaDominantColor: "#0A84FF"
    property bool mediaExpanded: false
    property var savedMediaBeforeExpansion: null
    // ── Configuration Paths ──
    readonly property string configDir: Quickshell.env("HOME") + "/.config/lunita"
    readonly property string layoutFile: configDir + "/widgets_layout_qml.json"
    readonly property string screensLayoutFile: configDir + "/widgets_layout_screens.json"
    readonly property string scriptsDir: resolveScriptsDir()
    property var screensLayout: ({
    })
    // Legacy fallback property
    property var widgetsList: getScreenWidgets("HDMI-A-1")
    property var clockExpandedScreens: ({
    })
    property var savedClockScreens: ({
    })
    property var calExpandedScreens: ({
    })
    property var savedCalScreens: ({
    })
    property var mediaExpandedScreens: ({
    })
    property var savedMediaScreens: ({
    })
    // ── 4. Photo Memories Tracker (~/Imagenes/* recursive) ──
    property int photoDirection: 1
    // ── 7. Weather Info ──
    property bool isCustomLocation: false

    signal screenLayoutChanged(string targetScreen)

    function loadActiveTokens() {
        try {
            let txt = tokensWatcher.text();
            if (txt && txt.trim().length > 0) {
                root.activeTokens = JSON.parse(txt);
                if (root.activeTokens.is_dark !== undefined)
                    root.isDarkTheme = !!root.activeTokens.is_dark;

            }
        } catch (e) {
            console.warn("Error parsing active_tokens.json in widgets:", e);
        }
    }

    function loadMatugenColors() {
        try {
            let txt = matugenWatcher.text();
            if (txt && txt.trim().length > 0)
                root.matugenColors = JSON.parse(txt);

        } catch (e) {
        }
    }

    function resolveScriptsDir() {
        var localUrl = Qt.resolvedUrl("scripts").toString();
        if (localUrl.indexOf("file://") === 0)
            return localUrl.substring(7);

        return Quickshell.env("HOME") + "/.config/quickshell/widgets/scripts";
    }

    // ── Layout Persistence ──
    function defaultScreenWidgets(name) {
        if (name === "HDMI-A-1")
            return [{
            "id": "clk",
            "type": "clock",
            "x": 600,
            "y": 240,
            "size": "small",
            "width": 170,
            "height": 170
        }, {
            "id": "cal",
            "type": "calendar",
            "x": 1704,
            "y": 50,
            "size": "small",
            "width": 170,
            "height": 170
        }];
        else if (name === "DP-1")
            return [{
            "id": "med",
            "type": "media",
            "x": 1500,
            "y": 50,
            "size": "medium",
            "width": 354,
            "height": 170
        }, {
            "id": "sys",
            "type": "resources",
            "x": 1520,
            "y": 240,
            "size": "small",
            "width": 170,
            "height": 170
        }];
        else
            return [{
            "id": "clk",
            "type": "clock",
            "x": 1520,
            "y": 50,
            "size": "small",
            "width": 170,
            "height": 170
        }, {
            "id": "cal",
            "type": "calendar",
            "x": 1704,
            "y": 50,
            "size": "small",
            "width": 170,
            "height": 170
        }, {
            "id": "bat",
            "type": "battery",
            "x": 1520,
            "y": 234,
            "size": "medium",
            "width": 354,
            "height": 170
        }];
    }

    function defaultWidgets() {
        return defaultScreenWidgets("HDMI-A-1");
    }

    function getScreenWidgets(screenName) {
        var s = screenName || "HDMI-A-1";
        if (root.screensLayout && root.screensLayout[s] && Array.isArray(root.screensLayout[s]))
            return root.screensLayout[s];

        return defaultScreenWidgets(s);
    }

    function setScreenWidgets(screenName, list) {
        var s = screenName || "HDMI-A-1";
        var copy = Object.assign({
        }, root.screensLayout);
        copy[s] = list;
        root.screensLayout = copy;
        root.widgetsList = getScreenWidgets("HDMI-A-1");
        root.screenLayoutChanged(s);
        saveScreensLayout();
    }

    function loadScreensLayout() {
        loadScreensLayoutProc.running = true;
    }

    function saveScreensLayout() {
        var jsonStr = JSON.stringify(root.screensLayout);
        var cmd = "mkdir -p " + root.configDir + " && echo '" + jsonStr.replace(/'/g, "'\\''") + "' > " + root.screensLayoutFile;
        Quickshell.execDetached(["bash", "-c", cmd]);
    }

    // Support both updateWidgetPosition(screenName, id, x, y) and updateWidgetPosition(id, x, y)
    function updateWidgetPosition(arg1, arg2, arg3, arg4) {
        var sName = (arg4 !== undefined) ? arg1 : "HDMI-A-1";
        var id = (arg4 !== undefined) ? arg2 : arg1;
        var newX = (arg4 !== undefined) ? arg3 : arg2;
        var newY = (arg4 !== undefined) ? arg4 : arg3;
        var list = getScreenWidgets(sName).slice();
        for (var i = 0; i < list.length; i++) {
            if (list[i].id === id) {
                list[i].x = Math.round(newX);
                list[i].y = Math.round(newY);
                break;
            }
        }
        setScreenWidgets(sName, list);
    }

    // Support both updateWidgetSize(screenName, id, w, h, s) and updateWidgetSize(id, w, h, s)
    function updateWidgetSize(arg1, arg2, arg3, arg4, arg5) {
        var sName = (arg5 !== undefined) ? arg1 : "HDMI-A-1";
        var id = (arg5 !== undefined) ? arg2 : arg1;
        var newWidth = (arg5 !== undefined) ? arg3 : arg2;
        var newHeight = (arg5 !== undefined) ? arg4 : arg3;
        var newSize = (arg5 !== undefined) ? arg5 : arg4;
        var list = getScreenWidgets(sName).slice();
        for (var i = 0; i < list.length; i++) {
            if (list[i].id === id) {
                list[i].width = Math.round(newWidth);
                list[i].height = Math.round(newHeight);
                if (newSize)
                    list[i].size = newSize;

                break;
            }
        }
        setScreenWidgets(sName, list);
    }

    // Support both removeWidget(screenName, id) and removeWidget(id)
    function removeWidget(arg1, arg2) {
        var sName = (arg2 !== undefined) ? arg1 : "HDMI-A-1";
        var id = (arg2 !== undefined) ? arg2 : arg1;
        var list = getScreenWidgets(sName).filter((w) => {
            return w.id !== id;
        });
        setScreenWidgets(sName, list);
    }

    // Support both addWidget(screenName, type) and addWidget(type)
    function addWidget(arg1, arg2) {
        var sName = (arg2 !== undefined) ? arg1 : "HDMI-A-1";
        var type = (arg2 !== undefined) ? arg2 : arg1;
        var defSizes = {
            "calendar": {
                "size": "small",
                "w": 170,
                "h": 170
            },
            "network": {
                "size": "small",
                "w": 170,
                "h": 170
            },
            "resources": {
                "size": "small",
                "w": 170,
                "h": 170
            },
            "clock": {
                "size": "small",
                "w": 170,
                "h": 170
            },
            "photos": {
                "size": "medium",
                "w": 354,
                "h": 176
            },
            "battery": {
                "size": "small",
                "w": 170,
                "h": 170
            },
            "git": {
                "size": "small",
                "w": 170,
                "h": 170
            },
            "habits": {
                "size": "small",
                "w": 170,
                "h": 170
            },
            "timetable": {
                "size": "small",
                "w": 170,
                "h": 170
            },
            "media": {
                "size": "medium",
                "w": 354,
                "h": 170
            }
        };
        var s = defSizes[type] || {
            "size": "small",
            "w": 170,
            "h": 170
        };
        var newId = type + "_" + Math.floor(Math.random() * 1000);
        var list = getScreenWidgets(sName).slice();
        var newX = 1520;
        var newY = 50 + (list.length * 90);
        if (newY > 700)
            newY = 50;

        list.push({
            "id": newId,
            "type": type,
            "x": newX,
            "y": newY,
            "size": s.size,
            "width": s.w,
            "height": s.h
        });
        setScreenWidgets(sName, list);
    }

    function resetLayout(screenName) {
        var sName = screenName || "HDMI-A-1";
        var list = defaultScreenWidgets(sName);
        setScreenWidgets(sName, list);
        resetHealthData();
    }

    function toggleClockExpanded(screenName) {
        var s = screenName;
        if (!s) {
            for (var k in root.screensLayout) {
                var arr = root.screensLayout[k];
                if (arr && arr.some((w) => {
                    return w.type === "clock" || w.id === "clk";
                })) {
                    s = k;
                    break;
                }
            }
        }
        if (!s)
            s = "HDMI-A-1";

        var list = getScreenWidgets(s).slice();
        var clkIdx = -1;
        for (var i = 0; i < list.length; i++) {
            if (list[i].type === "clock" || list[i].id === "clk") {
                clkIdx = i;
                break;
            }
        }
        if (clkIdx === -1)
            return ;

        var isExpanded = clockExpandedScreens[s] || false;
        var newExp = Object.assign({
        }, clockExpandedScreens);
        var newSaved = Object.assign({
        }, savedClockScreens);
        if (!isExpanded) {
            newSaved[s] = JSON.parse(JSON.stringify(list));
            var clk = Object.assign({
            }, list[clkIdx]);
            var targetClkX = clk.x - 184;
            var targetClkY = clk.y;
            var expandShift = 184;
            for (var j = 0; j < list.length; j++) {
                if (j === clkIdx)
                    continue;

                var w = Object.assign({
                }, list[j]);
                if (Math.abs(w.y - targetClkY) < 60 && w.x <= clk.x) {
                    w.x -= expandShift;
                    list[j] = w;
                }
            }
            clk.x = targetClkX;
            clk.width = 354;
            clk.size = "medium";
            list[clkIdx] = clk;
            newExp[s] = true;
        } else {
            if (newSaved[s]) {
                list = newSaved[s];
                delete newSaved[s];
            } else {
                var clkItem = Object.assign({
                }, list[clkIdx]);
                clkItem.x += 184;
                clkItem.width = 170;
                clkItem.size = "small";
                list[clkIdx] = clkItem;
                for (var m = 0; m < list.length; m++) {
                    if (m === clkIdx)
                        continue;

                    var ow = Object.assign({
                    }, list[m]);
                    if (Math.abs(ow.y - clkItem.y) < 60 && ow.x < clkItem.x) {
                        ow.x += 184;
                        list[m] = ow;
                    }
                }
            }
            newExp[s] = false;
        }
        clockExpandedScreens = newExp;
        savedClockScreens = newSaved;
        var copy = Object.assign({
        }, root.screensLayout);
        copy[s] = list;
        root.screensLayout = copy;
        root.widgetsList = getScreenWidgets("HDMI-A-1");
        root.screenLayoutChanged(s);
    }

    function selectCalendarDay(dayNumber) {
        if (!dayNumber || dayNumber === "")
            return ;

        var dayInt = parseInt(dayNumber);
        if (isNaN(dayInt) || dayInt < 1 || dayInt > 31)
            return ;

        root.calSelectedDay = dayNumber.toString();
        var y = root.calYear || "2026";
        var m = (root.calMonthNum && root.calMonthNum < 10) ? "0" + root.calMonthNum : (root.calMonthNum ? root.calMonthNum.toString() : "09");
        var d = dayInt < 10 ? "0" + dayInt : dayInt.toString();
        var dateStr = y + "-" + m + "-" + d;
        root.calSelectedDateStr = dateStr;
        if (root.calEvents && root.calEvents[dateStr])
            root.calSelectedEvents = root.calEvents[dateStr];
        else
            root.calSelectedEvents = [];
    }

    function addCalendarEvent(dateStr, timeStr, titleStr, category, color, shape) {
        calProc.command = ["python3", root.scriptsDir + "/calendar_provider.py", "add", dateStr, timeStr, titleStr, category || "General", color || "#0A84FF", shape || "circle"];
        calProc.running = true;
    }

    function deleteCalendarEvent(dateStr, eventId) {
        if (!dateStr || !eventId)
            return ;

        var curEvs = root.calSelectedEvents ? root.calSelectedEvents.slice() : [];
        root.calSelectedEvents = curEvs.filter(function(e) {
            return e.id !== eventId;
        });
        if (root.calEvents && root.calEvents[dateStr]) {
            var allEvs = Object.assign({
            }, root.calEvents);
            allEvs[dateStr] = allEvs[dateStr].filter(function(e) {
                return e.id !== eventId;
            });
            root.calEvents = allEvs;
        }
        calProc.command = ["python3", root.scriptsDir + "/calendar_provider.py", "delete", dateStr, eventId];
        calProc.running = true;
    }

    function toggleCalendarExpansion(screenName) {
        var s = screenName;
        if (!s) {
            for (var k in root.screensLayout) {
                var arr = root.screensLayout[k];
                if (arr && arr.some((w) => {
                    return w.type === "calendar" || w.id === "cal";
                })) {
                    s = k;
                    break;
                }
            }
        }
        if (!s)
            s = "HDMI-A-1";

        var list = getScreenWidgets(s).slice();
        var calIdx = -1;
        for (var i = 0; i < list.length; i++) {
            if (list[i].type === "calendar" || list[i].id === "cal") {
                calIdx = i;
                break;
            }
        }
        if (calIdx === -1)
            return ;

        var isExpanded = calExpandedScreens[s] || false;
        var newExp = Object.assign({
        }, calExpandedScreens);
        var newSaved = Object.assign({
        }, savedCalScreens);
        if (!isExpanded) {
            newSaved[s] = JSON.parse(JSON.stringify(list));
            var cal = Object.assign({
            }, list[calIdx]);
            var expandShift = 184;
            for (var j = 0; j < list.length; j++) {
                if (j === calIdx)
                    continue;

                var w = Object.assign({
                }, list[j]);
                if (Math.abs(w.y - cal.y) < 60) {
                    if (w.x >= cal.x && w.x < cal.x + 354) {
                        w.x -= expandShift;
                        list[j] = w;
                    }
                }
            }
            cal.width = 354;
            cal.size = "medium";
            list[calIdx] = cal;
            newExp[s] = true;
        } else {
            if (newSaved[s]) {
                list = newSaved[s];
                delete newSaved[s];
            } else {
                var calItem = Object.assign({
                }, list[calIdx]);
                calItem.width = 170;
                calItem.size = "small";
                list[calIdx] = calItem;
            }
            newExp[s] = false;
        }
        calExpandedScreens = newExp;
        savedCalScreens = newSaved;
        root.calExpanded = newExp["HDMI-A-1"] || false;
        var copy = Object.assign({
        }, root.screensLayout);
        copy[s] = list;
        root.screensLayout = copy;
        root.widgetsList = getScreenWidgets("HDMI-A-1");
        root.screenLayoutChanged(s);
    }

    function toggleMediaExpanded(screenName) {
        toggleMediaExpansion(screenName);
    }

    function toggleMediaExpansion(screenName) {
        var s = screenName;
        if (!s) {
            for (var k in root.screensLayout) {
                var arr = root.screensLayout[k];
                if (arr && arr.some((w) => {
                    return w.type === "media" || w.id === "med" || (w.id && w.id.indexOf("media") !== -1);
                })) {
                    s = k;
                    break;
                }
            }
        }
        if (!s)
            s = "DP-1";

        var list = getScreenWidgets(s).slice();
        var medIdx = -1;
        for (var i = 0; i < list.length; i++) {
            if (list[i].type === "media" || list[i].id === "med" || (list[i].id && list[i].id.indexOf("media") !== -1)) {
                medIdx = i;
                break;
            }
        }
        if (medIdx === -1)
            return ;

        var isExpanded = mediaExpandedScreens[s] || false;
        var newExp = Object.assign({
        }, mediaExpandedScreens);
        var newSaved = Object.assign({
        }, savedMediaScreens);
        if (!isExpanded) {
            newSaved[s] = JSON.parse(JSON.stringify(list));
            var med = Object.assign({
            }, list[medIdx]);
            var expandShift = 184;
            for (var j = 0; j < list.length; j++) {
                if (j === medIdx)
                    continue;

                var w = Object.assign({
                }, list[j]);
                if (Math.abs(w.y - med.y) < 60) {
                    if (w.x >= med.x && w.x < med.x + 354) {
                        w.x -= expandShift;
                        list[j] = w;
                    }
                }
            }
            med.width = 354;
            med.size = "medium";
            list[medIdx] = med;
            newExp[s] = true;
        } else {
            if (newSaved[s]) {
                list = newSaved[s];
                delete newSaved[s];
            } else {
                var medItem = Object.assign({
                }, list[medIdx]);
                medItem.width = 170;
                medItem.size = "small";
                list[medIdx] = medItem;
            }
            newExp[s] = false;
        }
        mediaExpandedScreens = newExp;
        savedMediaScreens = newSaved;
        root.mediaExpanded = newExp["DP-1"] || false;
        var copy = Object.assign({
        }, root.screensLayout);
        copy[s] = list;
        root.screensLayout = copy;
        root.widgetsList = getScreenWidgets("HDMI-A-1");
        root.screenLayoutChanged(s);
    }

    function toggleEdit() {
        root.isEditing = !root.isEditing;
    }

    function refreshAllData() {
        sysProc.running = true;
        netProc.running = true;
        photoProc.running = true;
        calProc.running = true;
        weatherProc.running = true;
        batProc.running = true;
        gitProc.running = true;
        habitProc.running = true;
        ttProc.running = true;
        mediaProc.running = true;
    }

    function nextPhoto() {
        photoTimer.restart();
        photoProc.command = ["python3", root.scriptsDir + "/photo_provider.py", "next"];
        photoProc.running = true;
    }

    function prevPhoto() {
        photoTimer.restart();
        photoProc.command = ["python3", root.scriptsDir + "/photo_provider.py", "prev"];
        photoProc.running = true;
    }

    function setWeatherLocation(loc) {
        if (loc && loc.trim() !== "")
            weatherProc.command = ["python3", root.scriptsDir + "/weather_provider.py", "set", loc.trim()];
        else
            weatherProc.command = ["python3", root.scriptsDir + "/weather_provider.py", "clear"];
        weatherProc.running = true;
    }

    function refreshWeather() {
        weatherProc.command = ["python3", root.scriptsDir + "/weather_provider.py", "refresh"];
        weatherProc.running = true;
    }

    // ── 8. Battery & Ecosystem Devices ──
    function syncBattery() {
        batProc.command = ["python3", root.scriptsDir + "/device_battery_provider.py", "sync"];
        batProc.running = true;
    }

    // ── 9. Git Activity & CI/CD Status ──
    function refreshGit() {
        gitProc.command = ["python3", root.scriptsDir + "/git_activity_provider.py", "refresh"];
        gitProc.running = true;
    }

    // ── 10. Health & Activity Tracker (macOS Health-Style) ──
    function setHealthMetric(metric, value) {
        habitProc.command = ["python3", root.scriptsDir + "/health_tracker_provider.py", "set", metric, value.toString()];
        habitProc.running = true;
    }

    function adjustHealthMetric(metric, delta) {
        habitProc.command = ["python3", root.scriptsDir + "/health_tracker_provider.py", "adjust", metric, delta.toString()];
        habitProc.running = true;
    }

    function toggleHabit(taskId) {
        habitProc.command = ["python3", root.scriptsDir + "/habit_tracker_provider.py", "toggle", taskId];
        habitProc.running = true;
    }

    function saveHealthMetrics(cal, ex, steps, water) {
        root.healthCalories = cal;
        root.healthExercise = ex;
        root.healthSteps = steps;
        root.healthWater = water;
        habitProc.command = ["python3", root.scriptsDir + "/health_tracker_provider.py", "set_metrics", cal.toString(), ex.toString(), steps.toString(), water.toString()];
        habitProc.running = false;
        habitProc.running = true;
    }

    function resetHealthData() {
        habitProc.command = ["python3", root.scriptsDir + "/health_tracker_provider.py", "reset"];
        habitProc.running = false;
        habitProc.running = true;
    }

    // ── 11. Timetable UNaB & Workspace Notes ──
    function refreshTimetable() {
        ttProc.command = ["python3", root.scriptsDir + "/timetable_provider.py", "get"];
        ttProc.running = true;
    }

    function toggleTimetableTask(id) {
        ttProc.command = ["python3", root.scriptsDir + "/timetable_provider.py", "toggle_task", id.toString()];
        ttProc.running = true;
    }

    function addTimetableTask(title, tag, due) {
        ttProc.command = ["python3", root.scriptsDir + "/timetable_provider.py", "add_task", title, tag || "UNaB", due || "Pendiente"];
        ttProc.running = true;
    }

    function deleteTimetableTask(id) {
        ttProc.command = ["python3", root.scriptsDir + "/timetable_provider.py", "delete_task", id.toString()];
        ttProc.running = true;
    }

    function setTimetableNotes(notes) {
        ttProc.command = ["python3", root.scriptsDir + "/timetable_provider.py", "set_notes", notes];
        ttProc.running = true;
    }

    // ── 12. Media Player (Now Playing) ──
    function parseMediaData(data) {
        try {
            var p = JSON.parse(data.trim());
            root.mediaStatus = p.status || "Stopped";
            root.mediaIsPlaying = !!p.is_playing;
            root.mediaTitle = p.title || "Sin reproducción";
            root.mediaArtist = p.artist || "Ningún reproductor activo";
            root.mediaAlbum = p.album || "";
            root.mediaArtUrl = p.art_url || "";
            root.mediaPosition = p.position || 0;
            root.mediaLength = p.length || 0;
            root.mediaPositionStr = p.position_str || "0:00";
            root.mediaLengthStr = p.length_str || "0:00";
            root.mediaProgress = p.progress !== undefined ? p.progress : 0;
            if (p.dominant_color)
                root.mediaDominantColor = p.dominant_color;

        } catch (e) {
        }
    }

    function mediaPlayPause() {
        root.mediaIsPlaying = !root.mediaIsPlaying;
        mediaActionProc.command = ["python3", root.scriptsDir + "/media_provider.py", "play-pause"];
        mediaActionProc.running = false;
        mediaActionProc.running = true;
    }

    function mediaNext() {
        mediaActionProc.command = ["python3", root.scriptsDir + "/media_provider.py", "next"];
        mediaActionProc.running = false;
        mediaActionProc.running = true;
    }

    function mediaPrevious() {
        mediaActionProc.command = ["python3", root.scriptsDir + "/media_provider.py", "previous"];
        mediaActionProc.running = false;
        mediaActionProc.running = true;
    }

    onIsEditingChanged: {
        Quickshell.execDetached(["bash", "-c", "echo " + (root.isEditing ? "1" : "0") + " > /tmp/lunita_widgets_editing"]);
    }
    // ── Initial State Loading ──
    Component.onCompleted: {
        loadActiveTokens();
        loadMatugenColors();
        loadScreensLayout();
        refreshAllData();
        Quickshell.execDetached(["bash", "-c", "echo 0 > /tmp/lunita_widgets_editing"]);
    }

    FileView {
        id: tokensWatcher

        path: Quickshell.env("HOME") + "/.config/lunita/active_tokens.json"
        watchChanges: true
        onLoaded: root.loadActiveTokens()
        onFileChanged: root.loadActiveTokens()
    }

    FileView {
        id: matugenWatcher

        path: Quickshell.env("HOME") + "/.config/quickshell/colors.json"
        watchChanges: true
        onLoaded: root.loadMatugenColors()
        onFileChanged: root.loadMatugenColors()
    }

    // ── Widget Edit Mode IPC Listener ──
    Process {
        id: widgetIpcProc

        command: ["python3", "-u", root.scriptsDir + "/widget_ipc_listener.py"]
        running: true

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (data) => {
                var cmd = data.trim();
                if (cmd === "toggle_edit")
                    root.toggleEdit();
                else if (cmd === "edit_on")
                    root.isEditing = true;
                else if (cmd === "edit_off")
                    root.isEditing = false;
                else if (cmd === "reset")
                    root.resetLayout();
                else if (cmd === "toggle_clock")
                    root.toggleClockExpanded();
            }
        }

    }

    Process {
        id: loadScreensLayoutProc

        command: ["bash", "-c", "if [ -f " + root.screensLayoutFile + " ]; then tr -d '\\r\\n' < " + root.screensLayoutFile + "; else echo '{}'; fi"]

        stdout: SplitParser {
            onRead: (data) => {
                var str = data.trim();
                var parsed = null;
                try {
                    if (str && str !== "" && str !== "{}")
                        parsed = JSON.parse(str);

                } catch (e) {
                }
                if (parsed && typeof parsed === "object" && !Array.isArray(parsed) && Object.keys(parsed).length > 0) {
                    root.screensLayout = parsed;
                } else {
                    var initMap = {
                        "HDMI-A-1": root.defaultScreenWidgets("HDMI-A-1"),
                        "DP-1": root.defaultScreenWidgets("DP-1")
                    };
                    root.screensLayout = initMap;
                    root.saveScreensLayout();
                }
                root.widgetsList = root.getScreenWidgets("HDMI-A-1");
                root.screenLayoutChanged("all");
            }
        }

    }

    // ── 1. Theme Mode Tracker ──
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            themeProc.running = true;
        }
    }

    Process {
        id: themeProc

        command: ["bash", "-c", "cat $HOME/.config/lunita/color_scheme 2>/dev/null || echo 'dark'"]

        stdout: SplitParser {
            onRead: (data) => {
                var str = data.trim().toLowerCase();
                root.isDarkTheme = (str.indexOf("light") === -1);
            }
        }

    }

    // ── 2. System Resources Tracker (CPU, RAM GB, GPU, VRAM, Disk) ──
    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            sysProc.running = true;
        }
    }

    Process {
        id: sysProc

        command: ["python3", root.scriptsDir + "/sys_provider.py"]

        stdout: SplitParser {
            onRead: (data) => {
                try {
                    var p = JSON.parse(data.trim());
                    root.cpuPercent = p.cpu || 0;
                    root.ramPercent = p.ram || 0;
                    root.ramUsed = p.ram_used || "";
                    root.ramTotal = p.ram_total || "";
                    root.gpuPercent = p.gpu || 0;
                    root.vramPercent = p.vram_pct || 0;
                    root.vramUsed = p.vram_used || "0.0 GB";
                    root.vramTotal = p.vram_total || "0.0 GB";
                    root.diskPercent = p.disk || 0;
                    root.diskUsed = p.disk_used || "";
                    root.diskTotal = p.disk_total || "";
                } catch (e) {
                }
            }
        }

    }

    // ── 3. Network Traffic Tracker with 60s Sparkline Buffer ──
    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            netProc.running = true;
        }
    }

    Process {
        id: netProc

        command: ["python3", root.scriptsDir + "/net_provider.py"]

        stdout: SplitParser {
            onRead: (data) => {
                try {
                    var p = JSON.parse(data.trim());
                    root.netDownVal = p.down_val || "0";
                    root.netDownUnit = p.down_unit || "KB/s";
                    root.netUpVal = p.up_val || "0";
                    root.netUpUnit = p.up_unit || "KB/s";
                    root.netIp = p.ip || "127.0.0.1";
                    root.netInterface = p.interface || "Ethernet";
                    root.netStatus = p.status || "UP";
                    // Buffer for sparkline (30 samples @ 2s = 60s history)
                    var curSpeed = p.total_kb !== undefined ? p.total_kb : 0;
                    var hist = root.netHistory.slice();
                    hist.push(curSpeed);
                    if (hist.length > 30)
                        hist.shift();

                    root.netHistory = hist;
                } catch (e) {
                }
            }
        }

    }

    Timer {
        id: photoTimer

        interval: 45000 // 45 segundos de rotación automática
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            photoProc.command = ["python3", root.scriptsDir + "/photo_provider.py", "next"];
            photoProc.running = true;
        }
    }

    Process {
        id: photoProc

        command: ["python3", root.scriptsDir + "/photo_provider.py", "get"]

        stdout: SplitParser {
            onRead: (data) => {
                try {
                    var p = JSON.parse(data.trim());
                    root.photoDirection = p.direction || 1;
                    root.photoPath = p.path || "";
                    root.photoTitle = p.title || "Recuerdos";
                    root.photoCategory = p.subtitle || "Fotos";
                    root.photoIndex = p.index || 1;
                    root.photoTotal = p.total || 1;
                } catch (e) {
                }
            }
        }

    }

    // ── 5. Calendar Info & Events ──
    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            calProc.command = ["python3", root.scriptsDir + "/calendar_provider.py", "get"];
            calProc.running = true;
        }
    }

    Process {
        id: calProc

        command: ["python3", root.scriptsDir + "/calendar_provider.py", "get"]

        stdout: SplitParser {
            onRead: (data) => {
                try {
                    var p = JSON.parse(data.trim());
                    root.calMonthName = p.month_name || "";
                    root.calYear = p.year || "";
                    root.calMonthNum = p.month_num || 9;
                    root.calToday = p.today || "";
                    root.calWeekday = p.weekday || "";
                    root.calWeeks = p.weeks || [];
                    root.calEvents = p.all_events || {
                    };
                    if (!root.calSelectedDay || root.calSelectedDay === "")
                        root.calSelectedDay = p.today || "1";

                    root.selectCalendarDay(root.calSelectedDay);
                } catch (e) {
                }
            }
        }

    }

    // ── 6. Clock Info ──
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date();
            var hours = now.getHours();
            var minutes = now.getMinutes();
            var displayHours = hours % 12;
            if (displayHours === 0)
                displayHours = 12;

            var displayMinutes = minutes < 10 ? "0" + minutes : minutes;
            root.clockTime = displayHours + ":" + displayMinutes;
            root.clockDay = now.getDate().toString();
            var days = ["DOM", "LUN", "MAR", "MIÉ", "JUE", "VIE", "SÁB"];
            root.clockWeekday = days[now.getDay()];
        }
    }

    Timer {
        interval: 600000 // 10 minutos
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            weatherProc.command = ["python3", root.scriptsDir + "/weather_provider.py"];
            weatherProc.running = true;
        }
    }

    Process {
        id: weatherProc

        command: ["python3", root.scriptsDir + "/weather_provider.py"]

        stdout: SplitParser {
            onRead: (data) => {
                try {
                    var p = JSON.parse(data.trim());
                    root.weatherTemp = p.temp || "--°C";
                    root.weatherIcon = p.icon || "󰖐";
                    root.weatherDesc = p.desc || "";
                    root.weatherHumidity = p.humidity || "--%";
                    root.weatherWind = p.wind || "-- km/h";
                    root.weatherHourly = p.hourly || [];
                    root.weatherDaily = p.daily || [];
                    root.isCustomLocation = !!p.is_custom_location;
                    if (p.city)
                        root.clockCity = p.city;

                } catch (e) {
                }
            }
        }

    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            batProc.command = ["python3", root.scriptsDir + "/device_battery_provider.py", "get"];
            batProc.running = true;
        }
    }

    Process {
        id: batProc

        command: ["python3", root.scriptsDir + "/device_battery_provider.py", "get"]

        stdout: SplitParser {
            onRead: (data) => {
                try {
                    var p = JSON.parse(data.trim());
                    root.batteryDevices = p.devices || [];
                    root.batteryLastSync = p.last_sync || "";
                } catch (e) {
                }
            }
        }

    }

    Timer {
        interval: 300000 // 5 minutos
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            gitProc.command = ["python3", root.scriptsDir + "/git_activity_provider.py"];
            gitProc.running = true;
        }
    }

    Process {
        id: gitProc

        command: ["python3", root.scriptsDir + "/git_activity_provider.py"]

        stdout: SplitParser {
            onRead: (data) => {
                try {
                    var p = JSON.parse(data.trim());
                    root.gitUser = p.user || "Facuud2";
                    root.gitCiStatus = p.ci_status || "success";
                    root.gitCiMessage = p.ci_message || "Pipelines OK";
                    root.gitCiRepo = p.ci_repo || "Comitas-App";
                    root.gitLatestCommit = p.latest_commit || {
                    };
                    root.gitRecentCommits = p.recent_commits || [];
                    root.gitHeatmap = p.heatmap || [];
                    root.gitUpdatedAt = p.updated_at || "";
                } catch (e) {
                }
            }
        }

    }

    Timer {
        interval: 60000 // 1 minuto para chequear medianoche y mantener sincronizado
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            habitProc.command = ["python3", root.scriptsDir + "/health_tracker_provider.py", "get"];
            habitProc.running = true;
        }
    }

    Process {
        id: habitProc

        command: ["python3", root.scriptsDir + "/health_tracker_provider.py", "get"]

        stdout: SplitParser {
            onRead: (data) => {
                try {
                    var p = JSON.parse(data.trim());
                    // Health & Fitness metrics
                    root.healthCalories = p.calories !== undefined ? p.calories : 0;
                    root.healthCaloriesGoal = p.calories_goal || 600;
                    root.healthExercise = p.exercise !== undefined ? p.exercise : 0;
                    root.healthExerciseGoal = p.exercise_goal || 30;
                    root.healthSteps = p.steps !== undefined ? p.steps : 0;
                    root.healthStepsGoal = p.steps_goal || 10000;
                    root.healthWater = p.water !== undefined ? p.water : 0;
                    root.healthWaterGoal = p.water_goal || 2.5;
                    root.healthHistory = p.history || [];
                    // Legacy habit compat
                    root.habitDay = p.day || 14;
                    root.habitTotalDays = p.total_days || 75;
                    root.habitStreak = p.streak || 14;
                    root.habitCompletedCount = p.completed_count !== undefined ? p.completed_count : 0;
                    root.habitTotalTasks = p.total_tasks || 5;
                    root.habitPercent = p.percent !== undefined ? p.percent : 0;
                    root.habitDate = p.date || "";
                    root.habitTasks = p.tasks || [];
                } catch (e) {
                }
            }
        }

    }

    Timer {
        interval: 10000 // 10 segundos para actualizar cuenta regresiva con fluidez
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            ttProc.command = ["python3", root.scriptsDir + "/timetable_provider.py", "get"];
            ttProc.running = true;
        }
    }

    Process {
        id: ttProc

        command: ["python3", root.scriptsDir + "/timetable_provider.py", "get"]

        stdout: SplitParser {
            onRead: (data) => {
                try {
                    var p = JSON.parse(data.trim());
                    root.ttUniversity = p.university || "UNaB";
                    root.ttCareer = p.career || "Tecnicatura en Programación";
                    root.ttSubject = p.subject || "Sin clases";
                    root.ttCode = p.code || "";
                    root.ttRoom = p.room || "";
                    root.ttProfessor = p.professor || "";
                    root.ttStart = p.start || "";
                    root.ttEnd = p.end || "";
                    root.ttStatusLabel = p.status_label || "";
                    root.ttTimeLeftStr = p.time_left_str || "";
                    root.ttIsActive = !!p.is_active;
                    root.ttIsFinishingSoon = !!p.is_finishing_soon;
                    root.ttProgressPct = p.progress_pct || 0;
                    root.ttSchedule = p.schedule || [];
                    root.ttTasks = p.tasks || [];
                    root.ttNotes = p.notes || "";
                } catch (e) {
                }
            }
        }

    }

    Timer {
        interval: 2000 // 2 segundos
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!mediaProc.running) {
                mediaProc.command = ["python3", root.scriptsDir + "/media_provider.py", "get"];
                mediaProc.running = true;
            }
        }
    }

    Process {
        id: mediaActionProc

        command: ["python3", root.scriptsDir + "/media_provider.py", "get"]

        stdout: SplitParser {
            onRead: (data) => {
                return root.parseMediaData(data);
            }
        }

    }

    Process {
        id: mediaProc

        command: ["python3", root.scriptsDir + "/media_provider.py", "get"]

        stdout: SplitParser {
            onRead: (data) => {
                return root.parseMediaData(data);
            }
        }

    }

}
