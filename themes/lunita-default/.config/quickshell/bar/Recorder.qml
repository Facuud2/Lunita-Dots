pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "."

QtObject {
    id: root

    property bool recording: false
    property int elapsed: 0
    property string folder: Quickshell.env("HOME") + "/Videos"
    property bool systemAudio: true
    property bool microphone: false
    property string lastFile: ""

    readonly property string elapsedText: {
        const m = Math.floor(elapsed / 60);
        const s = elapsed % 60;
        return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s;
    }

    readonly property Timer tick: Timer {
        running: root.recording
        interval: 1000
        repeat: true
        onTriggered: root.elapsed++
    }

    // Poller de comprobación de estado real de wf-recorder
    property var statusProc: Process {
        command: ["pgrep", "-x", "wf-recorder"]
        stdout: SplitParser {
            onRead: data => {
                const active = data && data.trim().length > 0;
                if (root.recording !== active) {
                    root.recording = active;
                    if (!active) root.elapsed = 0;
                }
            }
        }
    }

    readonly property Timer statusTimer: Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (root.statusProc) root.statusProc.running = true;
        }
    }

    function start() {
        if (recording) return;
        elapsed = 0;
        recording = true;
        const flags = (root.systemAudio ? " --sound" : " --no-sound") + (root.microphone ? " --mic" : " --no-mic");
        Exec.run("~/.config/hypr/scripts/record.sh screen" + flags + " >/dev/null 2>&1 &");
    }

    function stop() {
        recording = false;
        elapsed = 0;
        Exec.run("~/.config/hypr/scripts/record.sh stop >/dev/null 2>&1 &");
    }

    function toggle() {
        if (recording)
            stop();
        else
            start();
    }

    function openFolder() {
        Exec.run("xdg-open '" + root.folder + "'");
    }
}
