import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property var widgetsState

    readonly property bool isSmall: root.width <= 220
    readonly property bool isMedium: root.width > 220 && root.height <= 240
    readonly property bool isLarge: root.width > 220 && root.height > 240
    readonly property bool isWide: isMedium || isLarge

    Rectangle {
        anchors.fill: parent
        radius: 22
        color: root.widgetsState ? root.widgetsState.cardBg : Qt.rgba(0.12, 0.14, 0.18, 0.75)
        border.color: root.widgetsState ? root.widgetsState.cardBorder : Qt.rgba(1, 1, 1, 0.14)
        border.width: 1
        clip: true

        // ═══════════════════════════════════════════════════════════════════
        // 1. MODO PEQUEÑO (170 x 170): Dashboard 2x2 con Medidores Circulares
        // ═══════════════════════════════════════════════════════════════════
        ColumnLayout {
            visible: root.isSmall
            anchors.fill: parent
            anchors.margins: 10
            spacing: 4

            // ── Fila Superior: CPU y RAM ──
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 6

                // ── Módulo CPU ──
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Canvas {
                        id: cpuCanvas
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 2
                        width: 44
                        height: 44

                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            var cx = width / 2;
                            var cy = height / 2;
                            var r = 18;

                            ctx.beginPath();
                            ctx.arc(cx, cy, r, 0, 2 * Math.PI, false);
                            ctx.lineWidth = 4;
                            ctx.strokeStyle = root.widgetsState && root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.12)" : "rgba(0,0,0,0.08)";
                            ctx.stroke();

                            var pct = Math.min(1.0, Math.max(0.0, (root.widgetsState ? root.widgetsState.cpuPercent : 0) / 100.0));
                            var startA = -0.5 * Math.PI;
                            ctx.beginPath();
                            ctx.arc(cx, cy, r, startA, startA + (pct * 2 * Math.PI), false);
                            ctx.lineWidth = 4;
                            ctx.lineCap = "round";
                            ctx.strokeStyle = "#64D2FF";
                            ctx.stroke();
                        }

                        Connections {
                            target: root.widgetsState
                            function onCpuPercentChanged() { cpuCanvas.requestPaint(); }
                        }
                    }

                    Column {
                        anchors.centerIn: cpuCanvas
                        spacing: -2
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "CPU"
                            font.family: "SF Pro Display"
                            font.pixelSize: 8
                            font.weight: Font.Bold
                            color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.5)
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: (root.widgetsState ? root.widgetsState.cpuPercent : 0) + "%"
                            font.family: "SF Pro Display"
                            font.pixelSize: 10
                            font.weight: Font.ExtraBold
                            color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: cpuCanvas.bottom
                        anchors.topMargin: 2
                        text: "Núcleos"
                        font.family: "SF Pro Display"
                        font.pixelSize: 8
                        font.weight: Font.Medium
                        color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.5)
                    }
                }

                // ── Módulo RAM ──
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Canvas {
                        id: ramCanvas
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 2
                        width: 44
                        height: 44

                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            var cx = width / 2;
                            var cy = height / 2;
                            var r = 18;

                            ctx.beginPath();
                            ctx.arc(cx, cy, r, 0, 2 * Math.PI, false);
                            ctx.lineWidth = 4;
                            ctx.strokeStyle = root.widgetsState && root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.12)" : "rgba(0,0,0,0.08)";
                            ctx.stroke();

                            var pct = Math.min(1.0, Math.max(0.0, (root.widgetsState ? root.widgetsState.ramPercent : 0) / 100.0));
                            var startA = -0.5 * Math.PI;
                            ctx.beginPath();
                            ctx.arc(cx, cy, r, startA, startA + (pct * 2 * Math.PI), false);
                            ctx.lineWidth = 4;
                            ctx.lineCap = "round";
                            ctx.strokeStyle = "#30D158";
                            ctx.stroke();
                        }

                        Connections {
                            target: root.widgetsState
                            function onRamPercentChanged() { ramCanvas.requestPaint(); }
                        }
                    }

                    Column {
                        anchors.centerIn: ramCanvas
                        spacing: -2
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "RAM"
                            font.family: "SF Pro Display"
                            font.pixelSize: 8
                            font.weight: Font.Bold
                            color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.5)
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: (root.widgetsState ? root.widgetsState.ramPercent : 0) + "%"
                            font.family: "SF Pro Display"
                            font.pixelSize: 10
                            font.weight: Font.ExtraBold
                            color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: ramCanvas.bottom
                        anchors.topMargin: 2
                        text: (root.widgetsState && root.widgetsState.ramUsed) ? root.widgetsState.ramUsed : "0 GB"
                        font.family: "SF Pro Display"
                        font.pixelSize: 8
                        font.weight: Font.ExtraBold
                        color: "#30D158"
                    }
                }
            }

            // ── Fila Inferior: GPU y Disco ──
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 6

                // ── Módulo GPU ──
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Canvas {
                        id: gpuCanvas
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 2
                        width: 44
                        height: 44

                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            var cx = width / 2;
                            var cy = height / 2;
                            var r = 18;

                            ctx.beginPath();
                            ctx.arc(cx, cy, r, 0, 2 * Math.PI, false);
                            ctx.lineWidth = 4;
                            ctx.strokeStyle = root.widgetsState && root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.12)" : "rgba(0,0,0,0.08)";
                            ctx.stroke();

                            var pct = Math.min(1.0, Math.max(0.0, (root.widgetsState ? root.widgetsState.gpuPercent : 0) / 100.0));
                            var startA = -0.5 * Math.PI;
                            ctx.beginPath();
                            ctx.arc(cx, cy, r, startA, startA + (pct * 2 * Math.PI), false);
                            ctx.lineWidth = 4;
                            ctx.lineCap = "round";
                            ctx.strokeStyle = "#BF5AF2";
                            ctx.stroke();
                        }

                        Connections {
                            target: root.widgetsState
                            function onGpuPercentChanged() { gpuCanvas.requestPaint(); }
                        }
                    }

                    Column {
                        anchors.centerIn: gpuCanvas
                        spacing: -2
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "GPU"
                            font.family: "SF Pro Display"
                            font.pixelSize: 8
                            font.weight: Font.Bold
                            color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.5)
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: (root.widgetsState ? root.widgetsState.gpuPercent : 0) + "%"
                            font.family: "SF Pro Display"
                            font.pixelSize: 10
                            font.weight: Font.ExtraBold
                            color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: gpuCanvas.bottom
                        anchors.topMargin: 2
                        text: (root.widgetsState && root.widgetsState.vramUsed) ? root.widgetsState.vramUsed : "0 GB"
                        font.family: "SF Pro Display"
                        font.pixelSize: 8
                        font.weight: Font.ExtraBold
                        color: "#BF5AF2"
                    }
                }

                // ── Módulo Disco ──
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Canvas {
                        id: diskCanvas
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 2
                        width: 44
                        height: 44

                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            var cx = width / 2;
                            var cy = height / 2;
                            var r = 18;

                            ctx.beginPath();
                            ctx.arc(cx, cy, r, 0, 2 * Math.PI, false);
                            ctx.lineWidth = 4;
                            ctx.strokeStyle = root.widgetsState && root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.12)" : "rgba(0,0,0,0.08)";
                            ctx.stroke();

                            var pct = Math.min(1.0, Math.max(0.0, (root.widgetsState ? root.widgetsState.diskPercent : 0) / 100.0));
                            var startA = -0.5 * Math.PI;
                            ctx.beginPath();
                            ctx.arc(cx, cy, r, startA, startA + (pct * 2 * Math.PI), false);
                            ctx.lineWidth = 4;
                            ctx.lineCap = "round";
                            ctx.strokeStyle = "#FF9F0A";
                            ctx.stroke();
                        }

                        Connections {
                            target: root.widgetsState
                            function onDiskPercentChanged() { diskCanvas.requestPaint(); }
                        }
                    }

                    Column {
                        anchors.centerIn: diskCanvas
                        spacing: -2
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "DISCO"
                            font.family: "SF Pro Display"
                            font.pixelSize: 8
                            font.weight: Font.Bold
                            color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.5)
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: (root.widgetsState ? root.widgetsState.diskPercent : 0) + "%"
                            font.family: "SF Pro Display"
                            font.pixelSize: 10
                            font.weight: Font.ExtraBold
                            color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: diskCanvas.bottom
                        anchors.topMargin: 2
                        text: (root.widgetsState && root.widgetsState.diskUsed) ? root.widgetsState.diskUsed : "0 GB"
                        font.family: "SF Pro Display"
                        font.pixelSize: 8
                        font.weight: Font.Bold
                        color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.5)
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // 2. MODO MEDIANO (354 x 170): 4 Barras Horizontales Modernas con Iconos
        // ═══════════════════════════════════════════════════════════════════
        ColumnLayout {
            visible: root.isMedium
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            // Header
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "MONITOR DE ACTIVIDAD"
                    font.family: "SF Pro Display"
                    font.pixelSize: 10
                    font.weight: Font.ExtraBold
                    color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.5)
                    font.letterSpacing: 0.5
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    height: 16
                    radius: 8
                    implicitWidth: liveRowM.implicitWidth + 10
                    color: Qt.rgba(100/255, 210/255, 255/255, 0.15)
                    RowLayout {
                        id: liveRowM
                        anchors.centerIn: parent
                        spacing: 4
                        Rectangle { width: 5; height: 5; radius: 2.5; color: "#64D2FF" }
                        Text { text: "SISTEMA"; font.family: "SF Pro Display"; font.pixelSize: 8; font.weight: Font.Bold; color: "#64D2FF" }
                    }
                }
            }

            // 1. CPU
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    width: 22; height: 22; radius: 6
                    color: Qt.rgba(100/255, 210/255, 255/255, 0.15)
                    Text { anchors.centerIn: parent; text: "󰻠"; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 12; color: "#64D2FF" }
                }
                Text { text: "CPU"; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold; color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"; Layout.preferredWidth: 32 }
                
                Rectangle {
                    Layout.fillWidth: true
                    height: 8
                    radius: 4
                    color: Qt.rgba(1, 1, 1, 0.08)
                    Rectangle {
                        height: parent.height
                        width: Math.max(6, parent.width * (Math.min(100, Math.max(0, root.widgetsState ? root.widgetsState.cpuPercent : 0)) / 100.0))
                        radius: 4
                        color: "#64D2FF"
                        Behavior on width { NumberAnimation { duration: 250 } }
                    }
                }
                Text {
                    text: (root.widgetsState ? root.widgetsState.cpuPercent : 0) + "%"
                    font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.ExtraBold; color: "#64D2FF"
                    Layout.preferredWidth: 40; horizontalAlignment: Text.AlignRight
                }
            }

            // 2. RAM
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    width: 22; height: 22; radius: 6
                    color: Qt.rgba(48/255, 209/255, 88/255, 0.15)
                    Text { anchors.centerIn: parent; text: "󰍛"; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 12; color: "#30D158" }
                }
                Text { text: "RAM"; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold; color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"; Layout.preferredWidth: 32 }
                
                Rectangle {
                    Layout.fillWidth: true
                    height: 8
                    radius: 4
                    color: Qt.rgba(1, 1, 1, 0.08)
                    Rectangle {
                        height: parent.height
                        width: Math.max(6, parent.width * (Math.min(100, Math.max(0, root.widgetsState ? root.widgetsState.ramPercent : 0)) / 100.0))
                        radius: 4
                        color: "#30D158"
                        Behavior on width { NumberAnimation { duration: 250 } }
                    }
                }
                Text {
                    text: (root.widgetsState ? root.widgetsState.ramUsed : "0 GB") + " (" + (root.widgetsState ? root.widgetsState.ramPercent : 0) + "%)"
                    font.family: "SF Pro Display"; font.pixelSize: 10; font.weight: Font.Bold; color: "#30D158"
                    Layout.preferredWidth: 95; horizontalAlignment: Text.AlignRight
                }
            }

            // 3. GPU
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    width: 22; height: 22; radius: 6
                    color: Qt.rgba(191/255, 90/255, 242/255, 0.15)
                    Text { anchors.centerIn: parent; text: "󰢮"; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 12; color: "#BF5AF2" }
                }
                Text { text: "GPU"; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold; color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"; Layout.preferredWidth: 32 }
                
                Rectangle {
                    Layout.fillWidth: true
                    height: 8
                    radius: 4
                    color: Qt.rgba(1, 1, 1, 0.08)
                    Rectangle {
                        height: parent.height
                        width: Math.max(6, parent.width * (Math.min(100, Math.max(0, root.widgetsState ? root.widgetsState.gpuPercent : 0)) / 100.0))
                        radius: 4
                        color: "#BF5AF2"
                        Behavior on width { NumberAnimation { duration: 250 } }
                    }
                }
                Text {
                    text: (root.widgetsState ? root.widgetsState.gpuPercent : 0) + "% (" + (root.widgetsState ? root.widgetsState.vramUsed : "0 GB") + ")"
                    font.family: "SF Pro Display"; font.pixelSize: 10; font.weight: Font.Bold; color: "#BF5AF2"
                    Layout.preferredWidth: 95; horizontalAlignment: Text.AlignRight
                }
            }

            // 4. DISCO
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    width: 22; height: 22; radius: 6
                    color: Qt.rgba(255/255, 159/255, 10/255, 0.15)
                    Text { anchors.centerIn: parent; text: "󰋊"; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 12; color: "#FF9F0A" }
                }
                Text { text: "SSD"; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold; color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"; Layout.preferredWidth: 32 }
                
                Rectangle {
                    Layout.fillWidth: true
                    height: 8
                    radius: 4
                    color: Qt.rgba(1, 1, 1, 0.08)
                    Rectangle {
                        height: parent.height
                        width: Math.max(6, parent.width * (Math.min(100, Math.max(0, root.widgetsState ? root.widgetsState.diskPercent : 0)) / 100.0))
                        radius: 4
                        color: "#FF9F0A"
                        Behavior on width { NumberAnimation { duration: 250 } }
                    }
                }
                Text {
                    text: (root.widgetsState ? root.widgetsState.diskUsed : "0 GB") + " / " + (root.widgetsState ? root.widgetsState.diskTotal : "0 GB")
                    font.family: "SF Pro Display"; font.pixelSize: 10; font.weight: Font.Bold; color: "#FF9F0A"
                    Layout.preferredWidth: 95; horizontalAlignment: Text.AlignRight
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // 3. MODO GRANDE (354 x 354): Dashboard macOS Premium 2x2 con Tarjetas
        // ═══════════════════════════════════════════════════════════════════
        ColumnLayout {
            visible: root.isLarge
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Header Superior macOS
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: "󰍛"
                    font.family: "CaskaydiaCove Nerd Font"
                    font.pixelSize: 15
                    color: "#64D2FF"
                }

                Text {
                    text: "MONITOR DE RENDIMIENTO"
                    font.family: "SF Pro Display"
                    font.pixelSize: 11
                    font.weight: Font.ExtraBold
                    color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"
                    font.letterSpacing: 0.6
                }

                Item { Layout.fillWidth: true }

                // Live Indicator Pill
                Rectangle {
                    height: 20
                    radius: 10
                    implicitWidth: liveRowL.implicitWidth + 12
                    color: Qt.rgba(48/255, 209/255, 88/255, 0.15)
                    border.color: Qt.rgba(48/255, 209/255, 88/255, 0.3)
                    border.width: 1

                    RowLayout {
                        id: liveRowL
                        anchors.centerIn: parent
                        spacing: 5
                        Rectangle {
                            width: 6
                            height: 6
                            radius: 3
                            color: "#30D158"
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { from: 0.4; to: 1.0; duration: 900; easing.type: Easing.InOutQuad }
                                NumberAnimation { from: 1.0; to: 0.4; duration: 900; easing.type: Easing.InOutQuad }
                            }
                        }
                        Text {
                            text: "EN TIEMPO REAL"
                            font.family: "SF Pro Display"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            color: "#30D158"
                        }
                    }
                }
            }

            // Grid 2x2 de Módulos
            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 2
                rowSpacing: 10
                columnSpacing: 10

                // ── Tarjeta 1: CPU ──
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 14
                    color: Qt.rgba(1, 1, 1, 0.05)
                    border.color: Qt.rgba(100/255, 210/255, 255/255, 0.22)
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        anchors.topMargin: 10
                        anchors.bottomMargin: 10
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Rectangle {
                                width: 22; height: 22; radius: 6
                                color: Qt.rgba(100/255, 210/255, 255/255, 0.18)
                                Text { anchors.centerIn: parent; text: "󰻠"; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 13; color: "#64D2FF" }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                spacing: 0
                                Text {
                                    Layout.fillWidth: true
                                    text: "Procesador"
                                    font.family: "SF Pro Display"; font.pixelSize: 10; font.weight: Font.Bold; color: "#FFFFFF"
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: "CPU"
                                    font.family: "SF Pro Display"; font.pixelSize: 8; color: Qt.rgba(1, 1, 1, 0.5)
                                    elide: Text.ElideRight
                                }
                            }
                            Text {
                                text: (root.widgetsState ? root.widgetsState.cpuPercent : 0) + "%"
                                font.family: "SF Pro Display"; font.pixelSize: 14; font.weight: Font.Bold; color: "#64D2FF"
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            }
                        }

                        Item { Layout.fillHeight: true }

                        // Progress Bar
                        Rectangle {
                            Layout.fillWidth: true
                            height: 6
                            radius: 3
                            color: Qt.rgba(1, 1, 1, 0.10)
                            Rectangle {
                                height: parent.height
                                width: Math.max(5, parent.width * (Math.min(100, Math.max(0, root.widgetsState ? root.widgetsState.cpuPercent : 0)) / 100.0))
                                radius: 3
                                color: "#64D2FF"
                                Behavior on width { NumberAnimation { duration: 250 } }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "Carga general del sistema"
                            font.family: "SF Pro Display"; font.pixelSize: 8; color: Qt.rgba(1, 1, 1, 0.55)
                            elide: Text.ElideRight
                        }
                    }
                }

                // ── Tarjeta 2: RAM ──
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 14
                    color: Qt.rgba(1, 1, 1, 0.05)
                    border.color: Qt.rgba(48/255, 209/255, 88/255, 0.22)
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        anchors.topMargin: 10
                        anchors.bottomMargin: 10
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Rectangle {
                                width: 22; height: 22; radius: 6
                                color: Qt.rgba(48/255, 209/255, 88/255, 0.18)
                                Text { anchors.centerIn: parent; text: "󰍛"; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 13; color: "#30D158" }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                spacing: 0
                                Text {
                                    Layout.fillWidth: true
                                    text: "Memoria RAM"
                                    font.family: "SF Pro Display"; font.pixelSize: 10; font.weight: Font.Bold; color: "#FFFFFF"
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: "Unificada"
                                    font.family: "SF Pro Display"; font.pixelSize: 8; color: Qt.rgba(1, 1, 1, 0.5)
                                    elide: Text.ElideRight
                                }
                            }
                            Text {
                                text: (root.widgetsState ? root.widgetsState.ramPercent : 0) + "%"
                                font.family: "SF Pro Display"; font.pixelSize: 14; font.weight: Font.Bold; color: "#30D158"
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            }
                        }

                        Item { Layout.fillHeight: true }

                        // Progress Bar
                        Rectangle {
                            Layout.fillWidth: true
                            height: 6
                            radius: 3
                            color: Qt.rgba(1, 1, 1, 0.10)
                            Rectangle {
                                height: parent.height
                                width: Math.max(5, parent.width * (Math.min(100, Math.max(0, root.widgetsState ? root.widgetsState.ramPercent : 0)) / 100.0))
                                radius: 3
                                color: "#30D158"
                                Behavior on width { NumberAnimation { duration: 250 } }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: (root.widgetsState ? root.widgetsState.ramUsed : "0 GB") + " en uso de " + (root.widgetsState ? root.widgetsState.ramTotal : "0 GB")
                            font.family: "SF Pro Display"; font.pixelSize: 8; color: Qt.rgba(1, 1, 1, 0.65)
                            elide: Text.ElideRight
                        }
                    }
                }

                // ── Tarjeta 3: GPU ──
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 14
                    color: Qt.rgba(1, 1, 1, 0.05)
                    border.color: Qt.rgba(191/255, 90/255, 242/255, 0.22)
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        anchors.topMargin: 10
                        anchors.bottomMargin: 10
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Rectangle {
                                width: 22; height: 22; radius: 6
                                color: Qt.rgba(191/255, 90/255, 242/255, 0.18)
                                Text { anchors.centerIn: parent; text: "󰢮"; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 13; color: "#BF5AF2" }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                spacing: 0
                                Text {
                                    Layout.fillWidth: true
                                    text: "Tarjeta Gráfica"
                                    font.family: "SF Pro Display"; font.pixelSize: 10; font.weight: Font.Bold; color: "#FFFFFF"
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: "GPU & VRAM"
                                    font.family: "SF Pro Display"; font.pixelSize: 8; color: Qt.rgba(1, 1, 1, 0.5)
                                    elide: Text.ElideRight
                                }
                            }
                            Text {
                                text: (root.widgetsState ? root.widgetsState.gpuPercent : 0) + "%"
                                font.family: "SF Pro Display"; font.pixelSize: 14; font.weight: Font.Bold; color: "#BF5AF2"
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            }
                        }

                        Item { Layout.fillHeight: true }

                        // Progress Bar
                        Rectangle {
                            Layout.fillWidth: true
                            height: 6
                            radius: 3
                            color: Qt.rgba(1, 1, 1, 0.10)
                            Rectangle {
                                height: parent.height
                                width: Math.max(5, parent.width * (Math.min(100, Math.max(0, root.widgetsState ? root.widgetsState.gpuPercent : 0)) / 100.0))
                                radius: 3
                                color: "#BF5AF2"
                                Behavior on width { NumberAnimation { duration: 250 } }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "VRAM: " + (root.widgetsState ? root.widgetsState.vramUsed : "0 GB") + " asignados"
                            font.family: "SF Pro Display"; font.pixelSize: 8; color: Qt.rgba(1, 1, 1, 0.65)
                            elide: Text.ElideRight
                        }
                    }
                }

                // ── Tarjeta 4: DISCO ──
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 14
                    color: Qt.rgba(1, 1, 1, 0.05)
                    border.color: Qt.rgba(255/255, 159/255, 10/255, 0.22)
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        anchors.topMargin: 10
                        anchors.bottomMargin: 10
                        spacing: 4

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 5

                            Rectangle {
                                width: 22; height: 22; radius: 6
                                color: Qt.rgba(255/255, 159/255, 10/255, 0.18)
                                Text { anchors.centerIn: parent; text: "󰋊"; font.family: "CaskaydiaCove Nerd Font"; font.pixelSize: 13; color: "#FF9F0A" }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 0
                                spacing: 0
                                Text {
                                    Layout.fillWidth: true
                                    text: "Almacenamiento"
                                    font.family: "SF Pro Display"; font.pixelSize: 10; font.weight: Font.Bold; color: "#FFFFFF"
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: "SSD Principal"
                                    font.family: "SF Pro Display"; font.pixelSize: 8; color: Qt.rgba(1, 1, 1, 0.5)
                                    elide: Text.ElideRight
                                }
                            }
                            Text {
                                text: (root.widgetsState ? root.widgetsState.diskPercent : 0) + "%"
                                font.family: "SF Pro Display"; font.pixelSize: 14; font.weight: Font.Bold; color: "#FF9F0A"
                                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                            }
                        }

                        Item { Layout.fillHeight: true }

                        // Progress Bar
                        Rectangle {
                            Layout.fillWidth: true
                            height: 6
                            radius: 3
                            color: Qt.rgba(1, 1, 1, 0.10)
                            Rectangle {
                                height: parent.height
                                width: Math.max(5, parent.width * (Math.min(100, Math.max(0, root.widgetsState ? root.widgetsState.diskPercent : 0)) / 100.0))
                                radius: 3
                                color: "#FF9F0A"
                                Behavior on width { NumberAnimation { duration: 250 } }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: (root.widgetsState ? root.widgetsState.diskUsed : "0 GB") + " ocupados de " + (root.widgetsState ? root.widgetsState.diskTotal : "0 GB")
                            font.family: "SF Pro Display"; font.pixelSize: 8; color: Qt.rgba(1, 1, 1, 0.65)
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }
}
