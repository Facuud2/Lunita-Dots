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

    property real radarAngle: 0.0
    property string joiningSsid: ""
    property string joinPassword: ""

    // Continuous Radar Sweep Animation
    NumberAnimation on radarAngle {
        from: 0
        to: 360
        duration: 4000
        loops: Animation.Infinite
        running: root.visible
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        // ── Header: Back button, Title, Rescan & Wi-Fi Toggle ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // Back to Overview Button
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
                text: "Wi-Fi Radar"
                font.family: root.barState.themeFontInterface
                font.pixelSize: 15
                font.weight: Font.Bold
                color: "#FFFFFF"
            }

            Item { Layout.fillWidth: true }

            // Rescan Button
            Rectangle {
                width: 32
                height: 30
                radius: 8
                color: scanHover.hovered ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.08)
                border.color: root.barState.themeBorder
                border.width: 1

                HoverHandler { id: scanHover }

                Text {
                    anchors.centerIn: parent
                    text: "󰑐"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                    color: root.barState.themeAccent
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.barState.rescanWifi()
                }
            }

            // Power Toggle Pill
            Rectangle {
                width: 74
                height: 30
                radius: 8
                color: root.barState.wifiEnabled ? Qt.rgba(root.barState.themeAccent.r, root.barState.themeAccent.g, root.barState.themeAccent.b, 0.25) : Qt.rgba(1, 1, 1, 0.08)
                border.color: root.barState.wifiEnabled ? root.barState.themeAccent : root.barState.themeBorder
                border.width: 1

                Row {
                    anchors.centerIn: parent
                    spacing: 6
                    Text {
                        text: root.barState.wifiEnabled ? "󰤨" : "󰤭"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 13
                        color: root.barState.wifiEnabled ? root.barState.themeAccent : Qt.rgba(1, 1, 1, 0.50)
                    }
                    Text {
                        text: root.barState.wifiEnabled ? "Activo" : "Off"
                        font.family: root.barState.themeFontInterface
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        color: root.barState.wifiEnabled ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.60)
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.barState.toggleWifi()
                }
            }
        }

        // ── Main Radar Canvas & Interactive Network Fan ──
        Item {
            id: radarArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            // Radar Origin Point: Bottom Center
            property real originX: width / 2
            property real originY: height - 16

            // Concentric Radar Distance Arcs
            Canvas {
                id: arcsCanvas
                anchors.fill: parent

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);

                    var ox = radarArea.originX;
                    var oy = radarArea.originY;
                    var maxR = Math.min(width * 0.48, height - 30);

                    var arcRadii = [maxR * 0.32, maxR * 0.55, maxR * 0.78, maxR];
                    var arcLabels = ["Excelente", "Buena", "Media", "Débil"];

                    for (var i = 0; i < arcRadii.length; ++i) {
                        var r = arcRadii[i];
                        ctx.beginPath();
                        ctx.strokeStyle = "rgba(255, 255, 255, 0.08)";
                        ctx.lineWidth = 1;
                        ctx.arc(ox, oy, r, Math.PI, 2 * Math.PI, false);
                        ctx.stroke();

                        // Distance/Band Label
                        ctx.fillStyle = "rgba(255, 255, 255, 0.35)";
                        ctx.font = "9px sans-serif";
                        ctx.fillText(arcLabels[i], ox - r + 8, oy - 4);
                    }

                    // Rotating Radar Sweep Line
                    ctx.save();
                    ctx.translate(ox, oy);
                    ctx.rotate((root.radarAngle * Math.PI) / 180.0);
                    var grad = ctx.createLinearGradient(0, 0, maxR, 0);
                    grad.addColorStop(0, "rgba(96, 205, 255, 0.35)");
                    grad.addColorStop(1, "rgba(96, 205, 255, 0.00)");
                    ctx.strokeStyle = grad;
                    ctx.lineWidth = 1.5;
                    ctx.beginPath();
                    ctx.moveTo(0, 0);
                    ctx.lineTo(maxR, 0);
                    ctx.stroke();
                    ctx.restore();
                }

                Connections {
                    target: root
                    function onRadarAngleChanged() {
                        arcsCanvas.requestPaint();
                    }
                }
            }

            // Central Source Antenna Node (Local Device)
            Rectangle {
                x: radarArea.originX - width / 2
                y: radarArea.originY - height / 2
                width: 32
                height: 32
                radius: 16
                color: root.barState.themeAccent
                border.color: "#FFFFFF"
                border.width: 1.5
                z: 10

                Text {
                    anchors.centerIn: parent
                    text: root.barState.wifiConnected ? "󰤨" : "󰤭"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    color: "#FFFFFF"
                }
            }

            // Networks Positioned Along Arcs
            Repeater {
                model: root.barState.wifiNetworks

                delegate: Item {
                    id: netItem
                    required property var modelData
                    required property int index

                    // Calculate radial positioning: higher signal = closer to center
                    property real sigPct: Math.max(15, Math.min(100, modelData.signal || 50))
                    property real normDist: 1.0 - ((sigPct - 15) / 85.0) // 0.0 (closest) .. 1.0 (furthest)
                    property real maxR: Math.min(radarArea.width * 0.46, radarArea.height - 38)
                    property real radiusDist: (maxR * 0.28) + (normDist * (maxR * 0.72))

                    // Angle across upper semicircle (from 195 deg to 345 deg)
                    property real angleRad: (195 + ((index * 37) % 150)) * (Math.PI / 180.0)

                    x: radarArea.originX + radiusDist * Math.cos(angleRad) - width / 2
                    y: radarArea.originY + radiusDist * Math.sin(angleRad) - height / 2

                    // Beam line from center to active/hovered node
                    Rectangle {
                        visible: modelData.active || netChipHover.hovered
                        x: width / 2
                        y: height / 2
                        width: netItem.radiusDist
                        height: 1
                        color: root.barState.themeAccent
                        opacity: modelData.active ? 0.6 : 0.3
                        transformOrigin: Item.Left
                        rotation: (netItem.angleRad * 180.0 / Math.PI) + 180
                        z: -1
                    }

                    // Network Pill
                    Rectangle {
                        id: netChip
                        width: Math.min(140, chipContent.implicitWidth + 20)
                        height: 28
                        radius: 14
                        color: modelData.active ? root.barState.themeAccent : (netChipHover.hovered ? Qt.rgba(1, 1, 1, 0.20) : Qt.rgba(0.12, 0.12, 0.16, 0.88))
                        border.color: modelData.active ? "#FFFFFF" : (netChipHover.hovered ? root.barState.themeBorderSpecular : Qt.rgba(1, 1, 1, 0.20))
                        border.width: 1

                        HoverHandler { id: netChipHover }

                        Row {
                            id: chipContent
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                text: modelData.security && modelData.security !== "--" ? "󰌾" : "󰤨"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                color: modelData.active ? "#FFFFFF" : root.barState.themeAccent
                            }

                            Text {
                                text: modelData.ssid || "Hidden"
                                font.family: root.barState.themeFontInterface
                                font.pixelSize: 10
                                font.weight: modelData.active ? Font.Bold : Font.Medium
                                color: "#FFFFFF"
                                elide: Text.ElideRight
                                width: Math.min(75, implicitWidth)
                            }

                            Text {
                                text: (modelData.signal || 50) + "%"
                                font.family: root.barState.themeFontInterface
                                font.pixelSize: 9
                                color: modelData.active ? Qt.rgba(1, 1, 1, 0.85) : Qt.rgba(1, 1, 1, 0.50)
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData.active) {
                                    // Already connected
                                    return;
                                }
                                if (modelData.security && modelData.security !== "--") {
                                    root.joiningSsid = modelData.ssid;
                                    root.joinPassword = "";
                                } else {
                                    root.barState.connectWifi(modelData.ssid);
                                }
                            }
                        }
                    }
                }
            }

            // Fallback when Wi-Fi is disabled or no networks detected
            Column {
                anchors.centerIn: parent
                visible: !root.barState.wifiEnabled || root.barState.wifiNetworks.length === 0
                spacing: 8

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.barState.wifiEnabled ? "󰤮" : "󰤭"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 32
                    color: root.barState.themeAccent
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.barState.wifiEnabled ? "Buscando redes en el radar..." : "Wi-Fi Desactivado"
                    font.family: root.barState.themeFontInterface
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: root.barState.themeOnSurface
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.barState.wifiEnabled ? "Haz clic en Escanear para actualizar" : "Activa el interruptor para descubrir redes cercanas"
                    font.family: root.barState.themeFontInterface
                    font.pixelSize: 10
                    color: root.barState.themeOnSurfaceDim
                }
            }

            // Inline Password Connection Modal
            Rectangle {
                visible: root.joiningSsid !== ""
                anchors.centerIn: parent
                width: 260
                height: 120
                radius: 12
                color: Qt.rgba(0.12, 0.12, 0.16, 0.95)
                border.color: root.barState.themeAccent
                border.width: 1.5
                z: 20

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Text {
                        text: "Conectar a " + root.joiningSsid
                        font.family: root.barState.themeFontInterface
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    TextField {
                        id: pwdInput
                        Layout.fillWidth: true
                        placeholderText: "Contraseña de red..."
                        echoMode: TextInput.Password
                        text: root.joinPassword
                        onTextChanged: root.joinPassword = text
                        color: "#FFFFFF"
                        background: Rectangle {
                            radius: 6
                            color: Qt.rgba(1, 1, 1, 0.10)
                            border.color: pwdInput.activeFocus ? root.barState.themeAccent : Qt.rgba(1, 1, 1, 0.20)
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            height: 26
                            radius: 6
                            color: Qt.rgba(1, 1, 1, 0.12)
                            Text {
                                anchors.centerIn: parent
                                text: "Cancelar"
                                font.family: root.barState.themeFontInterface
                                font.pixelSize: 10
                                color: "#FFFFFF"
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.joiningSsid = ""
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 26
                            radius: 6
                            color: root.barState.themeAccent
                            Text {
                                anchors.centerIn: parent
                                text: "Unirse"
                                font.family: root.barState.themeFontInterface
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                color: "#FFFFFF"
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    Quickshell.execDetached(["bash", "-c", "nmcli dev wifi connect \"" + root.joiningSsid + "\" password \"" + root.joinPassword + "\" 2>/dev/null || true"]);
                                    root.joiningSsid = "";
                                    root.barState.rescanWifi();
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
