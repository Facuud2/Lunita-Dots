pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "."

QtObject {
    id: root

    readonly property real maxVolume: 1.0

    property real volume: 0.5
    property bool muted: false
    property string description: ""
    property string defaultSink: ""
    property string defaultSource: ""

    property var sinks: []
    property var sources: []

    readonly property int percent: Math.min(100, Math.round(volume * 100))
    readonly property bool boosted: false

    property bool holding: false
    property int watchers: 0

    readonly property string audioScript: Qt.resolvedUrl("scripts/audio.py").toString().replace("file://", "")

    property var proc: Process {
        command: ["python3", root.audioScript]
        stdout: SplitParser {
            onRead: data => root.readAudio(data)
        }
    }

    function readAudio(text) {
        if (!text) return;
        try {
            const data = JSON.parse(text.trim());
            if (!root.holding && typeof data.volume === "number") {
                root.volume = Math.min(1.0, data.volume / 100.0);
            }
            root.muted = Boolean(data.muted);
            root.description = data.description || data.activeSink || "Audio";
            root.defaultSink = String(data.defaultSink || "");
            root.defaultSource = String(data.defaultSource || "");
            root.sinks = data.sinks || [];
            root.sources = data.sources || [];
        } catch (e) {}
    }

    function refreshDevices() {
        if (root.proc) root.proc.running = true;
    }

    function setVolume(v) {
        const clamped = Math.max(0, Math.min(1.0, v));
        root.volume = clamped;
        root.muted = false;
        Exec.run("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ " + clamped.toFixed(2));
    }

    function step(delta) {
        root.setVolume(root.volume + delta);
    }

    function toggleMute() {
        root.muted = !root.muted;
        Exec.run("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle");
    }

    function setDefaultSink(idOrName) {
        root.defaultSink = String(idOrName);
        Exec.run("wpctl set-default " + idOrName);
        refreshTimer.restart();
    }

    function setDefaultSource(idOrName) {
        root.defaultSource = String(idOrName);
        Exec.run("wpctl set-default " + idOrName);
        refreshTimer.restart();
    }

    readonly property Timer refreshTimer: Timer {
        interval: 300
        onTriggered: root.refreshDevices()
    }

    readonly property Timer tick: Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.refreshDevices();
        }
    }
}
