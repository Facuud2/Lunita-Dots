import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property var widgetsState

    readonly property bool isWide: root.width > 250

    Rectangle {
        anchors.fill: parent
        radius: 22
        color: root.widgetsState.cardBg
        border.color: root.widgetsState.cardBorder
        border.width: 1

        // ═══════════════════════════════════════════════════════════════════
        // 1. COMPACT MODE (170 x 170): Balanced 2x2 Activity Dashboard
        // ═══════════════════════════════════════════════════════════════════
        ColumnLayout {
            visible: !root.isWide
            anchors.fill: parent
            anchors.margins: 10
            spacing: 4

            // ── Top Row: CPU & RAM (with numeric GB counter) ──
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 6

                // ── CPU Module ──
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

                            // Background circle
                            ctx.beginPath();
                            ctx.arc(cx, cy, r, 0, 2 * Math.PI, false);
                            ctx.lineWidth = 4;
                            ctx.strokeStyle = root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.12)" : "rgba(0,0,0,0.08)";
                            ctx.stroke();

                            // Arc
                            var pct = Math.min(1.0, Math.max(0.0, root.widgetsState.cpuPercent / 100.0));
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
                            color: root.widgetsState.textDim
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.widgetsState.cpuPercent + "%"
                            font.family: "SF Pro Display"
                            font.pixelSize: 10
                            font.weight: Font.ExtraBold
                            color: root.widgetsState.textColor
                        }
                    }

                    // CPU Metric label below
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: cpuCanvas.bottom
                        anchors.topMargin: 2
                        text: "Núcleos"
                        font.family: "SF Pro Display"
                        font.pixelSize: 8
                        font.weight: Font.Medium
                        color: root.widgetsState.textDim
                    }
                }

                // ── RAM Module (with explicit GB counter) ──
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

                            // Background
                            ctx.beginPath();
                            ctx.arc(cx, cy, r, 0, 2 * Math.PI, false);
                            ctx.lineWidth = 4;
                            ctx.strokeStyle = root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.12)" : "rgba(0,0,0,0.08)";
                            ctx.stroke();

                            // Arc
                            var pct = Math.min(1.0, Math.max(0.0, root.widgetsState.ramPercent / 100.0));
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
                            color: root.widgetsState.textDim
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.widgetsState.ramPercent + "%"
                            font.family: "SF Pro Display"
                            font.pixelSize: 10
                            font.weight: Font.ExtraBold
                            color: root.widgetsState.textColor
                        }
                    }

                    // Numeric RAM counter (e.g. 6.6 GB)
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: ramCanvas.bottom
                        anchors.topMargin: 2
                        text: root.widgetsState.ramUsed || "0 GB"
                        font.family: "SF Pro Display"
                        font.pixelSize: 8
                        font.weight: Font.ExtraBold
                        color: "#30D158"
                    }
                }
            }

            // ── Bottom Row: GPU & Disk ──
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 6

                // ── GPU Module (with VRAM numeric counter) ──
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

                            // Background
                            ctx.beginPath();
                            ctx.arc(cx, cy, r, 0, 2 * Math.PI, false);
                            ctx.lineWidth = 4;
                            ctx.strokeStyle = root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.12)" : "rgba(0,0,0,0.08)";
                            ctx.stroke();

                            // Arc (GPU Load)
                            var pct = Math.min(1.0, Math.max(0.0, root.widgetsState.gpuPercent / 100.0));
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
                            color: root.widgetsState.textDim
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.widgetsState.gpuPercent + "%"
                            font.family: "SF Pro Display"
                            font.pixelSize: 10
                            font.weight: Font.ExtraBold
                            color: root.widgetsState.textColor
                        }
                    }

                    // Numeric VRAM counter (e.g. 1.1 GB)
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: gpuCanvas.bottom
                        anchors.topMargin: 2
                        text: root.widgetsState.vramUsed || "0 GB"
                        font.family: "SF Pro Display"
                        font.pixelSize: 8
                        font.weight: Font.ExtraBold
                        color: "#BF5AF2"
                    }
                }

                // ── Disk Module ──
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

                            // Background
                            ctx.beginPath();
                            ctx.arc(cx, cy, r, 0, 2 * Math.PI, false);
                            ctx.lineWidth = 4;
                            ctx.strokeStyle = root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.12)" : "rgba(0,0,0,0.08)";
                            ctx.stroke();

                            // Arc
                            var pct = Math.min(1.0, Math.max(0.0, root.widgetsState.diskPercent / 100.0));
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
                            color: root.widgetsState.textDim
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.widgetsState.diskPercent + "%"
                            font.family: "SF Pro Display"
                            font.pixelSize: 10
                            font.weight: Font.ExtraBold
                            color: root.widgetsState.textColor
                        }
                    }

                    // Numeric Disk counter (e.g. 271 GB)
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: diskCanvas.bottom
                        anchors.topMargin: 2
                        text: root.widgetsState.diskUsed || "0 GB"
                        font.family: "SF Pro Display"
                        font.pixelSize: 8
                        font.weight: Font.Bold
                        color: root.widgetsState.textDim
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // 2. EXPANDED / WIDE MODE (354 x 170): Detailed Horizontal Activity Bars
        // ═══════════════════════════════════════════════════════════════════
        ColumnLayout {
            visible: root.isWide
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            // Header Title
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "MONITOR DE ACTIVIDAD"
                    font.family: "SF Pro Display"
                    font.pixelSize: 10
                    font.weight: Font.ExtraBold
                    color: root.widgetsState.textDim
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: "SISTEMA"
                    font.family: "SF Pro Display"
                    font.pixelSize: 9
                    font.weight: Font.Bold
                    color: root.widgetsState.accentBlue
                }
            }

            // CPU Row
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Text {
                    text: "CPU"
                    font.family: "SF Pro Display"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    color: root.widgetsState.textColor
                    Layout.preferredWidth: 36
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 6
                    radius: 3
                    color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.10)" : "rgba(0,0,0,0.08)"
                    Rectangle {
                        height: parent.height
                        width: parent.width * (root.widgetsState.cpuPercent / 100.0)
                        radius: 3
                        color: "#64D2FF"
                    }
                }
                Text {
                    text: root.widgetsState.cpuPercent + "%"
                    font.family: "SF Pro Display"
                    font.pixelSize: 11
                    font.weight: Font.ExtraBold
                    color: root.widgetsState.textColor
                    Layout.preferredWidth: 42
                    horizontalAlignment: Text.AlignRight
                }
            }

            // RAM Row (with explicit Used / Total GB)
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Text {
                    text: "RAM"
                    font.family: "SF Pro Display"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    color: root.widgetsState.textColor
                    Layout.preferredWidth: 36
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 6
                    radius: 3
                    color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.10)" : "rgba(0,0,0,0.08)"
                    Rectangle {
                        height: parent.height
                        width: parent.width * (root.widgetsState.ramPercent / 100.0)
                        radius: 3
                        color: "#30D158"
                    }
                }
                Text {
                    text: root.widgetsState.ramUsed + " / " + root.widgetsState.ramTotal
                    font.family: "SF Pro Display"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    color: "#30D158"
                    Layout.preferredWidth: 80
                    horizontalAlignment: Text.AlignRight
                }
            }

            // GPU Row (with explicit VRAM Used / Total GB)
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Text {
                    text: "GPU"
                    font.family: "SF Pro Display"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    color: root.widgetsState.textColor
                    Layout.preferredWidth: 36
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 6
                    radius: 3
                    color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.10)" : "rgba(0,0,0,0.08)"
                    Rectangle {
                        height: parent.height
                        width: parent.width * (root.widgetsState.gpuPercent / 100.0)
                        radius: 3
                        color: "#BF5AF2"
                    }
                }
                Text {
                    text: root.widgetsState.gpuPercent + "% (" + root.widgetsState.vramUsed + ")"
                    font.family: "SF Pro Display"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    color: "#BF5AF2"
                    Layout.preferredWidth: 80
                    horizontalAlignment: Text.AlignRight
                }
            }

            // Disk Row
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Text {
                    text: "DISCO"
                    font.family: "SF Pro Display"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    color: root.widgetsState.textColor
                    Layout.preferredWidth: 36
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 6
                    radius: 3
                    color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.10)" : "rgba(0,0,0,0.08)"
                    Rectangle {
                        height: parent.height
                        width: parent.width * (root.widgetsState.diskPercent / 100.0)
                        radius: 3
                        color: "#FF9F0A"
                    }
                }
                Text {
                    text: root.widgetsState.diskUsed + " / " + root.widgetsState.diskTotal
                    font.family: "SF Pro Display"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    color: root.widgetsState.textDim
                    Layout.preferredWidth: 80
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }
}
