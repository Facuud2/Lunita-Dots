pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "."

QtObject {
    id: root

    property bool connected: false
    property bool isWifi: false
    property string connectionName: ""
    property int signal_: 0

    property bool wifiEnabled: false
    property bool btEnabled: false

    property bool ethernetConnected: false
    property string ethernetName: ""
    property string ethernetDevice: ""
    property string ethernetIp: ""
    readonly property bool isEthernet: ethernetConnected

    property var nearbyNets: []
    property var savedNets: []
    property var btKnown: []
    property var btNearby: []

    property int netWatchers: 0
    property int btWatchers: 0

    property string connecting: ""
    property string failed: ""
    property string activeCmd: ""

    readonly property bool btConnected: {
        for (let i = 0; i < btKnown.length; i++) {
            if (btKnown[i].connected) return true;
        }
        return false;
    }
    readonly property string btConnectedName: {
        for (let i = 0; i < btKnown.length; i++) {
            if (btKnown[i].connected) return btKnown[i].name;
        }
        return "";
    }

    readonly property string netScript: Qt.resolvedUrl("scripts/network.py").toString().replace("file://", "")
    readonly property string btScript: Qt.resolvedUrl("scripts/bluetooth.py").toString().replace("file://", "")

    // Process de Información de Red
    property var netProc: Process {
        command: ["python3", root.netScript]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return;
                try {
                    const info = JSON.parse(data.trim());
                    root.connected = Boolean(info.connected);
                    root.isWifi = (info.activeType === "wifi");
                    root.connectionName = info.activeName || "";
                    if (info.ethernet) {
                        root.ethernetConnected = Boolean(info.ethernet.connected);
                        root.ethernetName = info.ethernet.name || "Ethernet";
                        root.ethernetDevice = info.ethernet.device || "";
                        root.ethernetIp = info.ethernet.ip || "";
                    } else {
                        root.ethernetConnected = false;
                    }
                    if (info.wifi) {
                        root.wifiEnabled = Boolean(info.wifi.enabled);
                        root.signal_ = Number(info.wifi.signal) || 0;
                    }
                    if (info.savedNets) {
                        root.savedNets = info.savedNets;
                    }
                    if (info.nearbyNets) {
                        root.nearbyNets = info.nearbyNets;
                    }
                } catch (e) {}
            }
        }
    }

    // Process de Información de Bluetooth
    property var btProc: Process {
        command: ["python3", root.btScript, "status"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return;
                try {
                    const info = JSON.parse(data.trim());
                    root.btEnabled = Boolean(info.powered);
                    root.btKnown = info.devices || [];
                } catch (e) {}
            }
        }
    }

    function refreshLists() {
        if (root.netProc) root.netProc.running = true;
        if (root.btProc) root.btProc.running = true;
    }

    function toggleWifi() {
        Exec.run("nmcli radio wifi " + (root.wifiEnabled ? "off" : "on"));
        root.wifiEnabled = !root.wifiEnabled;
        refreshTimer.restart();
    }

    function toggleBt() {
        Exec.run("bluetoothctl power " + (root.btEnabled ? "off" : "on"));
        root.btEnabled = !root.btEnabled;
        refreshTimer.restart();
    }

    function scanBt(enable) {
        if (enable) {
            Exec.run("bluetoothctl --timeout 10 scan on >/dev/null 2>&1 &");
        }
    }

    function quote(s) {
        return "'" + String(s).replace(/'/g, "'\\''") + "'";
    }

    function attempt(id, cmd) {
        root.failed = "";
        root.connecting = id;
        root.activeCmd = cmd;
        Exec.run(cmd);
        refreshTimer.restart();
    }

    readonly property Timer refreshTimer: Timer {
        interval: 1500
        onTriggered: {
            root.connecting = "";
            root.refreshLists();
        }
    }

    function connectNet(name) {
        root.attempt(name, "nmcli connection up " + root.quote(name));
    }

    function joinNet(ssid, password) {
        const extra = password ? (" password " + root.quote(password)) : "";
        root.attempt(ssid, "nmcli device wifi connect " + root.quote(ssid) + extra);
    }

    function disconnectNet(name) {
        Exec.run("nmcli connection down " + root.quote(name));
        refreshTimer.restart();
    }

    function forgetNet(name) {
        Exec.run("nmcli connection delete " + root.quote(name));
        refreshTimer.restart();
    }

    function connectBt(mac) {
        root.attempt(mac, "bluetoothctl connect " + mac);
    }

    function disconnectBt(mac) {
        Exec.run("bluetoothctl disconnect " + mac);
        refreshTimer.restart();
    }

    function pairBt(mac) {
        root.attempt(mac, "bluetoothctl --timeout 25 pair " + mac + " && bluetoothctl trust " + mac + " && bluetoothctl connect " + mac);
    }

    function forgetBt(mac) {
        Exec.run("bluetoothctl remove " + mac);
        refreshTimer.restart();
    }

    readonly property Timer tick: Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.refreshLists();
        }
    }
}
