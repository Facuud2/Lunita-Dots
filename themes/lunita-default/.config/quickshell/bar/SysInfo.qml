pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property int cpu: 0
    property int cpuTemp: 0
    property int mem: 0
    property string memText: "0G / 0G"
    property string memShort: "0/0"
    property int gpu: 0
    property int gpuTemp: 0
    property bool gpuAvailable: false

    property var _prevCpu: null

    readonly property string scriptPath: Qt.resolvedUrl("scripts/metrics.py").toString().replace("file://", "")

    property var metricsProc: Process {
        command: ["python3", root.scriptPath]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return;
                try {
                    const res = JSON.parse(data.trim());
                    if (res.ram !== undefined) root.mem = res.ram;
                    if (res.cpu_temp !== undefined) root.cpuTemp = res.cpu_temp;
                    if (res.gpu !== undefined) root.gpu = res.gpu;
                    if (res.gpu_temp !== undefined) root.gpuTemp = res.gpu_temp;
                    if (res.gpu_avail !== undefined) root.gpuAvailable = res.gpu_avail;

                    if (res.cpu_raw && res.cpu_raw.length >= 4) {
                        const c = res.cpu_raw.map(Number);
                        const idle = c[3] + (c[4] || 0);
                        const total = c.reduce((a, b) => a + b, 0);

                        if (root._prevCpu) {
                            const dTotal = total - root._prevCpu.total;
                            const dIdle = idle - root._prevCpu.idle;
                            if (dTotal > 0) {
                                root.cpu = Math.max(0, Math.min(100, Math.round(100 * (dTotal - dIdle) / dTotal)));
                            }
                        }
                        root._prevCpu = { total: total, idle: idle };
                    }
                } catch (e) {
                    // ignore parse error
                }
            }
        }
    }

    readonly property Timer tick: Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (root.metricsProc) root.metricsProc.running = true;
        }
    }
}
