import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Item {
    id: root

    // ── Edit Mode State ──
    property bool isEditing: false

    // ── Theme State (Synced with Lunita Color Scheme) ──
    property bool isDarkTheme: true

    readonly property color cardBg: isDarkTheme
        ? Qt.rgba(0.12, 0.14, 0.18, 0.75)
        : Qt.rgba(0.98, 0.98, 1.0, 0.82)
    readonly property color cardBorder: isDarkTheme
        ? Qt.rgba(1, 1, 1, 0.14)
        : Qt.rgba(0, 0, 0, 0.12)
    readonly property color textColor: isDarkTheme ? "#FFFFFF" : "#1D1D1F"
    readonly property color textDim: isDarkTheme
        ? Qt.rgba(1, 1, 1, 0.60)
        : Qt.rgba(0.11, 0.11, 0.12, 0.60)
    readonly property color accentBlue: "#007AFF"
    readonly property color accentGreen: "#30D158"
    readonly property color accentOrange: "#FF9F0A"
    readonly property color accentRed: "#FF453A"

    // ── Widgets Layout Data Model ──
    property var widgetsList: []

    // ── System Statistics ──
    property int cpuPercent: 15
    property int ramPercent: 25
    property string ramUsed: "4.2 GB"
    property string ramTotal: "16.0 GB"
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
    property string calToday: "28"
    property string calWeekday: "LUNES"
    property var calWeekdays: ["D", "L", "M", "M", "J", "V", "S"]
    property var calWeeks: []

    // ── Clock Data ──
    property string clockTime: "9:41"
    property string clockCity: "BUENOS AIRES"
    property string clockDay: "28"
    property string clockWeekday: "LUN"

    // ── Configuration Paths ──
    readonly property string configDir: Quickshell.env("HOME") + "/.config/lunita"
    readonly property string layoutFile: configDir + "/widgets_layout_qml.json"
    readonly property string scriptsDir: Quickshell.env("HOME") + "/.config/quickshell/widgets/scripts"

    // ── Initial State Loading ──
    Component.onCompleted: {
        loadLayout();
        refreshAllData();
    }

    // ── Layout Persistence ──
    function defaultWidgets() {
        return [
            { id: "cal", type: "calendar", x: 1520, y: 50, size: "small", width: 170, height: 170 },
            { id: "net", type: "network",  x: 1704, y: 50, size: "small", width: 170, height: 170 },
            { id: "sys", type: "resources", x: 1520, y: 234, size: "small", width: 170, height: 170 },
            { id: "clk", type: "clock",     x: 1704, y: 234, size: "small", width: 170, height: 170 },
            { id: "pho", type: "photos",    x: 1520, y: 418, size: "medium", width: 354, height: 176 }
        ];
    }

    function loadLayout() {
        loadLayoutProc.running = true;
    }

    Process {
        id: loadLayoutProc
        command: ["bash", "-c", "if [ -f " + root.layoutFile + " ]; then cat " + root.layoutFile + "; else echo '[]'; fi"]
        stdout: SplitParser {
            onRead: data => {
                var str = data.trim();
                try {
                    var parsed = JSON.parse(str);
                    if (Array.isArray(parsed) && parsed.length > 0) {
                        root.widgetsList = parsed;
                        return;
                    }
                } catch(e) {}
                root.widgetsList = root.defaultWidgets();
                root.saveLayout();
            }
        }
    }

    function saveLayout() {
        var jsonStr = JSON.stringify(root.widgetsList);
        var cmd = "mkdir -p " + root.configDir + " && echo '" + jsonStr.replace(/'/g, "'\\''") + "' > " + root.layoutFile;
        Quickshell.execDetached(["bash", "-c", cmd]);
    }

    function updateWidgetPosition(id, newX, newY) {
        var list = root.widgetsList.slice();
        for (var i = 0; i < list.length; i++) {
            if (list[i].id === id) {
                list[i].x = Math.round(newX);
                list[i].y = Math.round(newY);
                break;
            }
        }
        root.widgetsList = list;
        saveLayout();
    }

    function updateWidgetSize(id, newWidth, newHeight, newSize) {
        var list = root.widgetsList.slice();
        for (var i = 0; i < list.length; i++) {
            if (list[i].id === id) {
                list[i].width = Math.round(newWidth);
                list[i].height = Math.round(newHeight);
                if (newSize) list[i].size = newSize;
                break;
            }
        }
        root.widgetsList = list;
        saveLayout();
    }

    function removeWidget(id) {
        var list = root.widgetsList.filter(w => w.id !== id);
        root.widgetsList = list;
        saveLayout();
    }

    function addWidget(type) {
        var defSizes = {
            "calendar": { size: "small", w: 170, h: 170 },
            "network":  { size: "small", w: 170, h: 170 },
            "resources":{ size: "small", w: 170, h: 170 },
            "clock":    { size: "small", w: 170, h: 170 },
            "photos":   { size: "medium", w: 354, h: 176 }
        };
        var s = defSizes[type] || { size: "small", w: 170, h: 170 };
        var newId = type + "_" + Math.floor(Math.random() * 1000);
        
        // Find suitable empty position
        var newX = 1520;
        var newY = 50 + (root.widgetsList.length * 90);
        if (newY > 700) newY = 50;

        var list = root.widgetsList.slice();
        list.push({
            id: newId,
            type: type,
            x: newX,
            y: newY,
            size: s.size,
            width: s.w,
            height: s.h
        });
        root.widgetsList = list;
        saveLayout();
    }

    function resetLayout() {
        root.widgetsList = root.defaultWidgets();
        saveLayout();
    }

    function toggleEdit() {
        root.isEditing = !root.isEditing;
    }

    function refreshAllData() {
        sysProc.running = true;
        netProc.running = true;
        photoProc.running = true;
        calProc.running = true;
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
            onRead: data => {
                var str = data.trim().toLowerCase();
                root.isDarkTheme = (str.indexOf("light") === -1);
            }
        }
    }

    // ── 2. System Resources Tracker (psutil) ──
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
        command: ["python3", "-c", "import psutil, json; v=psutil.virtual_memory(); d=psutil.disk_usage('/'); print(json.dumps({'cpu': int(psutil.cpu_percent(interval=None)), 'ram': int(v.percent), 'ram_used': f'{v.used/(1024**3):.1f} GB', 'ram_total': f'{v.total/(1024**3):.1f} GB', 'disk': int(d.percent), 'disk_used': f'{d.used/(1024**3):.0f} GB', 'disk_total': f'{d.total/(1024**3):.0f} GB'}))"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    var p = JSON.parse(data.trim());
                    root.cpuPercent = p.cpu || 0;
                    root.ramPercent = p.ram || 0;
                    root.ramUsed = p.ram_used || "";
                    root.ramTotal = p.ram_total || "";
                    root.diskPercent = p.disk || 0;
                    root.diskUsed = p.disk_used || "";
                    root.diskTotal = p.disk_total || "";
                } catch(e) {}
            }
        }
    }

    // ── 3. Network Traffic Tracker ──
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
        command: ["python3", "-c", "import psutil, time, json, socket; t1=psutil.net_io_counters(); time.sleep(0.3); t2=psutil.net_io_counters(); db=(t2.bytes_recv-t1.bytes_recv)/0.3; ub=(t2.bytes_sent-t1.bytes_sent)/0.3; dv, du = (f'{db/(1024**2):.1f}', 'MB/s') if db > 1024*1024 else (f'{db/1024:.0f}', 'KB/s'); uv, uu = (f'{ub/(1024**2):.1f}', 'MB/s') if ub > 1024*1024 else (f'{ub/1024:.0f}', 'KB/s'); s=socket.socket(socket.AF_INET, socket.SOCK_DGRAM); s.connect(('8.8.8.8', 80)); ip=s.getsockname()[0]; s.close(); print(json.dumps({'down_val': dv, 'down_unit': du, 'up_val': uv, 'up_unit': uu, 'ip': ip, 'interface': 'Ethernet', 'status': 'UP'}))"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    var p = JSON.parse(data.trim());
                    root.netDownVal = p.down_val || "0";
                    root.netDownUnit = p.down_unit || "KB/s";
                    root.netUpVal = p.up_val || "0";
                    root.netUpUnit = p.up_unit || "KB/s";
                    root.netIp = p.ip || "127.0.0.1";
                    root.netInterface = p.interface || "Ethernet";
                    root.netStatus = p.status || "UP";
                } catch(e) {}
            }
        }
    }

    // ── 4. Photo Memories Tracker (~/Imagenes/* recursive) ──
    property int photoDirection: 1

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
            onRead: data => {
                try {
                    var p = JSON.parse(data.trim());
                    root.photoDirection = p.direction || 1;
                    root.photoPath = p.path || "";
                    root.photoTitle = p.title || "Recuerdos";
                    root.photoCategory = p.subtitle || "Fotos";
                    root.photoIndex = p.index || 1;
                    root.photoTotal = p.total || 1;
                } catch(e) {}
            }
        }
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

    // ── 5. Calendar Info ──
    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            calProc.running = true;
        }
    }

    Process {
        id: calProc
        command: ["python3", "-c", "import calendar, datetime, json\nnow=datetime.datetime.now()\nmonths=['ENERO','FEBRERO','MARZO','ABRIL','MAYO','JUNIO','JULIO','AGOSTO','SEPTIEMBRE','OCTUBRE','NOVIEMBRE','DICIEMBRE']\ndays=['LUNES','MARTES','MIÉRCOLES','JUEVES','VIERNES','SÁBADO','DOMINGO']\ncal=calendar.Calendar(firstweekday=6)\nm_weeks=cal.monthdayscalendar(now.year, now.month)\nweeks=[]\nfor w in m_weeks:\n week_days=[]\n for d in w:\n  week_days.append({'day': str(d) if d != 0 else '', 'in_month': d != 0, 'is_today': d == now.day})\n weeks.append(week_days)\nprint(json.dumps({'month_name': months[now.month-1], 'year': str(now.year), 'today': str(now.day), 'weekday': days[now.weekday()], 'weeks': weeks}))"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    var p = JSON.parse(data.trim());
                    root.calMonthName = p.month_name || "";
                    root.calYear = p.year || "";
                    root.calToday = p.today || "";
                    root.calWeekday = p.weekday || "";
                    root.calWeeks = p.weeks || [];
                } catch(e) {}
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
            if (displayHours === 0) displayHours = 12;
            var displayMinutes = minutes < 10 ? "0" + minutes : minutes;
            root.clockTime = displayHours + ":" + displayMinutes;
            root.clockDay = now.getDate().toString();
            var days = ["DOM", "LUN", "MAR", "MIÉ", "JUE", "VIE", "SÁB"];
            root.clockWeekday = days[now.getDay()];
        }
    }
}
