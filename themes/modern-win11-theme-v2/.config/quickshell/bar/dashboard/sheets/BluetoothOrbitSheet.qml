import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root

    required property var barState
    signal closeRequested()

    color: root.barState.themeSurface
    radius: root.barState.themeCardRadius
    border.color: root.barState.themeBorderSpecular
    border.width: 1
    clip: true

    property real driftTime: 0.0
    property real rippleScale: 0.2
    property real rippleOpacity: 0.8

    // Continuous Orbit Drift Motion
    NumberAnimation on driftTime {
        from: 0
        to: 360
        duration: 40000
        loops: Animation.Infinite
        running: root.visible
    }

    // Scanning Radar Ripple Expanding from Core
    ParallelAnimation {
        running: root.visible && root.barState.bluetoothEnabled
        loops: Animation.Infinite
        NumberAnimation { target: root; property: "rippleScale"; from: 0.1; to: 1.0; duration: 2800; easing.type: Easing.OutCubic }
        NumberAnimation { target: root; property: "rippleOpacity"; from: 0.6; to: 0.0; duration: 2800; easing.type: Easing.OutCubic }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        // ── Header: Back button, Title & Bluetooth Power Toggle ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // Back Button
            Rectangle {
                width: 76
                height: 30
                radius: 8
                color: backHover.hovered ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.08)
                border.color: root.barState.themeBorder
                border.width: 1

                HoverHandler { id: backHover }

                Row {
                    anchors.centerIn: parent
                    spacing: 4
                    Text {
                        text: "󰁍"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 13
                        color: root.barState.themeOnSurface
                    }
                    Text {
                        text: "Volver"
                        font.family: root.barState.themeFontInterface
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        color: root.barState.themeOnSurface
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.closeRequested()
                }
            }

            Text {
                text: "Bluetooth Orbit"
                font.family: root.barState.themeFontInterface
                font.pixelSize: 15
                font.weight: Font.Bold
                color: "#FFFFFF"
            }

            Item { Layout.fillWidth: true }

            // Power Toggle Pill
            Rectangle {
                width: 74
                height: 30
                radius: 8
                color: root.barState.bluetoothEnabled ? Qt.rgba(root.barState.themeAccent.r, root.barState.themeAccent.g, root.barState.themeAccent.b, 0.25) : Qt.rgba(1, 1, 1, 0.08)
                border.color: root.barState.bluetoothEnabled ? root.barState.themeAccent : root.barState.themeBorder
                border.width: 1

                Row {
                    anchors.centerIn: parent
                    spacing: 6
                    Text {
                        text: root.barState.bluetoothEnabled ? "󰂯" : "󰂲"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 13
                        color: root.barState.bluetoothEnabled ? root.barState.themeAccent : Qt.rgba(1, 1, 1, 0.50)
                    }
                    Text {
                        text: root.barState.bluetoothEnabled ? "Activo" : "Off"
                        font.family: root.barState.themeFontInterface
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        color: root.barState.bluetoothEnabled ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.60)
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.barState.toggleBluetooth()
                }
            }
        }

        // ── Main Orbital Space ──
        Item {
            id: orbitSpace
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            property real cx: width / 2
            property real cy: height / 2

            // Concentric Elliptical Orbit Guides
            Canvas {
                id: orbitCanvas
                anchors.fill: parent

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);

                    var cx = orbitSpace.cx;
                    var cy = orbitSpace.cy;
                    var maxRx = width * 0.44;
                    var maxRy = height * 0.44;

                    var orbits = [0.42, 0.74, 1.0]; // Inner, Middle, Outer
                    for (var i = 0; i < orbits.length; ++i) {
                        ctx.beginPath();
                        ctx.strokeStyle = "rgba(255, 255, 255, 0.08)";
                        ctx.lineWidth = 1;
                        ctx.ellipse(cx - maxRx * orbits[i], cy - maxRy * orbits[i], maxRx * orbits[i] * 2, maxRy * orbits[i] * 2);
                        ctx.stroke();
                    }
                }

                Component.onCompleted: requestPaint()
            }

            // Radar Ripple Scan Expanding from Central Core
            Rectangle {
                id: rippleWave
                anchors.centerIn: parent
                width: Math.min(orbitSpace.width, orbitSpace.height) * root.rippleScale
                height: width
                radius: width / 2
                color: "transparent"
                border.color: root.barState.themeAccent
                border.width: 1.5
                opacity: root.rippleOpacity
            }

            // Central Core Node (Local PC / Host)
            Rectangle {
                anchors.centerIn: parent
                width: 44
                height: 44
                radius: 22
                color: Qt.rgba(root.barState.themeAccent.r, root.barState.themeAccent.g, root.barState.themeAccent.b, 0.28)
                border.color: root.barState.themeAccent
                border.width: 2
                z: 10

                Text {
                    anchors.centerIn: parent
                    text: "󰌢"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 20
                    color: "#FFFFFF"
                }
            }

            // Orbiting Device Bubbles
            Repeater {
                model: root.barState.bluetoothDevices

                delegate: Item {
                    id: devBubble
                    required property var modelData
                    required property int index

                    // Gravitation orbit ring: Connected = inner (0.42), Paired = middle (0.74)
                    property real orbitRatio: modelData.connected ? 0.42 : 0.74
                    property real rx: orbitSpace.width * 0.44 * orbitRatio
                    property real ry: orbitSpace.height * 0.44 * orbitRatio

                    // Angular position with drift over time
                    property real driftSpeed: modelData.connected ? 1.0 : -0.7
                    property real baseAngle: (index * (360.0 / Math.max(1, root.barState.bluetoothDevices.length))) + (root.driftTime * driftSpeed)
                    property real angleRad: baseAngle * (Math.PI / 180.0)

                    x: orbitSpace.cx + rx * Math.cos(angleRad) - width / 2
                    y: orbitSpace.cy + ry * Math.sin(angleRad) - height / 2

                    // Gravitational beam line to core when connected
                    Rectangle {
                        visible: modelData.connected || bHov.hovered
                        x: width / 2
                        y: height / 2
                        width: Math.sqrt(Math.pow(devBubble.rx, 2) + Math.pow(devBubble.ry, 2))
                        height: 1
                        color: root.barState.themeAccent
                        opacity: modelData.connected ? 0.5 : 0.2
                        transformOrigin: Item.Left
                        rotation: (devBubble.angleRad * 180.0 / Math.PI) + 180
                        z: -1
                    }

                    // Device Interactive Capsule
                    Rectangle {
                        id: bubbleCard
                        width: Math.min(150, bubbleRow.implicitWidth + 24)
                        height: 32
                        radius: 16
                        color: modelData.connected ? Qt.rgba(root.barState.themeAccent.r, root.barState.themeAccent.g, root.barState.themeAccent.b, 0.35) : (bHov.hovered ? Qt.rgba(1, 1, 1, 0.20) : Qt.rgba(0.12, 0.12, 0.16, 0.88))
                        border.color: modelData.connected ? root.barState.themeAccent : (bHov.hovered ? root.barState.themeBorderSpecular : Qt.rgba(1, 1, 1, 0.20))
                        border.width: 1.5

                        HoverHandler { id: bHov }

                        Row {
                            id: bubbleRow
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                text: modelData.isAudio ? "󰋋" : "󰂯"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 13
                                color: modelData.connected ? "#FFFFFF" : root.barState.themeAccent
                            }

                            Text {
                                text: modelData.name || "Periférico"
                                font.family: root.barState.themeFontInterface
                                font.pixelSize: 10
                                font.weight: modelData.connected ? Font.Bold : Font.Medium
                                color: "#FFFFFF"
                                elide: Text.ElideRight
                                width: Math.min(80, implicitWidth)
                            }

                            // Connection indicator dot
                            Rectangle {
                                width: 6
                                height: 6
                                radius: 3
                                color: modelData.connected ? "#107C41" : Qt.rgba(1, 1, 1, 0.30)
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData.connected) {
                                    root.barState.disconnectBluetooth(modelData.mac);
                                } else {
                                    root.barState.connectBluetooth(modelData.mac);
                                }
                            }
                        }
                    }
                }
            }

            // Fallback when no devices are paired or bluetooth is off
            Column {
                anchors.centerIn: parent
                visible: !root.barState.bluetoothEnabled || root.barState.bluetoothDevices.length === 0
                spacing: 8

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.barState.bluetoothEnabled ? "󰂲" : "󰂲"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 32
                    color: root.barState.themeAccent
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.barState.bluetoothEnabled ? "No hay dispositivos en órbita" : "Bluetooth Desactivado"
                    font.family: root.barState.themeFontInterface
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: root.barState.themeOnSurface
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.barState.bluetoothEnabled ? "Empareja periféricos para verlos gravitar alrededor de tu equipo" : "Activa el interruptor para buscar dispositivos"
                    font.family: root.barState.themeFontInterface
                    font.pixelSize: 10
                    color: root.barState.themeOnSurfaceDim
                }
            }
        }
    }
}
