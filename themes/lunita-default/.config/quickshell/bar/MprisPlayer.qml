pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import "."

QtObject {
    id: root

    readonly property var players: Mpris.players.values
    readonly property var rawPlayer: {
        const list = players;
        if (!list || list.length === 0) return null;
        const playing = list.find(p => p.playbackState === MprisPlaybackState.Playing);
        if (playing) return playing;
        const controllable = list.find(p => p.canControl);
        if (controllable) return controllable;
        return list[0];
    }

    // Estados públicos reactivos
    readonly property bool active: rawPlayer !== null || pyActive
    readonly property bool isPlaying: rawPlayer ? rawPlayer.playbackState === MprisPlaybackState.Playing : pyPlaying

    readonly property string title: rawPlayer && rawPlayer.trackTitle ? rawPlayer.trackTitle : pyTitle
    readonly property string artist: rawPlayer && rawPlayer.trackArtist ? rawPlayer.trackArtist : pyArtist
    readonly property string artUrl: rawPlayer && rawPlayer.trackArtUrl ? rawPlayer.trackArtUrl : pyArtUrl

    readonly property real length: {
        if (rawPlayer && typeof rawPlayer.length === "number" && rawPlayer.length > 0) {
            return rawPlayer.length;
        }
        if (pyLength > 0) {
            return pyLength;
        }
        return 0;
    }

    property real livePosition: 0
    readonly property real position: livePosition
    readonly property real progress: length > 0 ? Math.max(0, Math.min(1, livePosition / length)) : 0

    // Propiedades de respaldo del resolver Python
    property bool pyActive: false
    property bool pyPlaying: false
    property string pyTitle: ""
    property string pyArtist: ""
    property string pyArtUrl: ""
    property real pyLength: 0

    // Al cambiar la pista o el medio, resetea inmediatamente para no heredar duraciones antiguas
    onTitleChanged: {
        root.livePosition = 0;
        root.pyLength = 0;
        if (!infoProcess.running) {
            infoProcess.running = true;
        }
    }

    readonly property string mprisScript: Qt.resolvedUrl("scripts/mpris_info.py").toString().replace("file://", "")

    // Proceso sincronizador de metadatos Python
    property var infoProc: Process {
        id: infoProcess
        command: ["python3", root.mprisScript]
        running: false
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const raw = data.trim();
                if (!raw) return;
                try {
                    const info = JSON.parse(raw);
                    root.pyActive = !!info.active;
                    root.pyPlaying = !!info.playing;
                    root.pyTitle = info.title || "";
                    root.pyArtist = info.artist || "";
                    root.pyArtUrl = info.artUrl || "";

                    if (typeof info.length === "number") {
                        if (info.length > 0) {
                            root.pyLength = info.length;
                        } else if (!root.rawPlayer || root.rawPlayer.length <= 0) {
                            root.pyLength = 0;
                        }
                    }

                    if (typeof info.position === "number") {
                        if (Math.abs(root.livePosition - info.position) > 1.2 || root.livePosition === 0) {
                            root.livePosition = info.position;
                        }
                    }
                } catch (e) {}
            }
        }
    }

    // Timer de sondeo de metadatos (cada 1s)
    readonly property Timer pollTimer: Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (root.rawPlayer && root.rawPlayer.positionSupported && root.rawPlayer.isPlaying) {
                const pos = root.rawPlayer.position;
                if (typeof pos === "number" && pos > 0 && Math.abs(root.livePosition - pos) > 1.0) {
                    root.livePosition = pos;
                }
            }
            if (!infoProcess.running) {
                infoProcess.running = true;
            }
        }
    }

    // Progreso continuo suave en vivo
    readonly property Timer smoothTick: Timer {
        interval: 100
        running: root.active && root.isPlaying
        repeat: true
        onTriggered: {
            if (root.length > 0) {
                if (root.livePosition < root.length) {
                    root.livePosition += 0.1;
                }
            } else {
                root.livePosition += 0.1;
            }
        }
    }

    function playPause() {
        if (rawPlayer) {
            rawPlayer.togglePlaying();
        } else {
            Exec.run("playerctl play-pause 2>/dev/null || true");
        }
    }

    function next() {
        if (rawPlayer) {
            rawPlayer.next();
        } else {
            Exec.run("playerctl next 2>/dev/null || true");
        }
    }

    function previous() {
        if (rawPlayer) {
            rawPlayer.previous();
        } else {
            Exec.run("playerctl previous 2>/dev/null || true");
        }
    }

    function setPosition(posSeconds) {
        root.livePosition = posSeconds;
        Exec.run("playerctl position " + posSeconds + " 2>/dev/null || true");
        if (rawPlayer && typeof rawPlayer.position === "number") {
            try { rawPlayer.position = posSeconds; } catch (e) {}
        }
    }
}
