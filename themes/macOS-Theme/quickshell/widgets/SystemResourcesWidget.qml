import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property var widgetsState

    Rectangle {
        anchors.fill: parent
        radius: 22
        color: root.widgetsState.cardBg
        border.color: root.widgetsState.cardBorder
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 6

            // Top Row: CPU & RAM circular gauges
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                // CPU Gauge
                Item {
                    Layout.fillWidth: true
                    height: 58

                    Canvas {
                        id: cpuCanvas
                        anchors.centerIn: parent
                        width: 58
                        height: 58
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            var centerX = width / 2;
                            var centerY = height / 2;
                            var radius = 24;
                            
                            // Background track
                            ctx.beginPath();
                            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI, false);
                            ctx.lineWidth = 5;
                            ctx.strokeStyle = root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.12)" : "rgba(0,0,0,0.08)";
                            ctx.stroke();

                            // Value arc
                            var pct = root.widgetsState.cpuPercent / 100.0;
                            var startAngle = -0.5 * Math.PI;
                            var endAngle = startAngle + (pct * 2 * Math.PI);
                            ctx.beginPath();
                            ctx.arc(centerX, centerY, radius, startAngle, endAngle, false);
                            ctx.lineWidth = 5;
                            ctx.strokeStyle = "#64D2FF";
                            ctx.stroke();
                        }
                        Connections {
                            target: root.widgetsState
                            function onCpuPercentChanged() { cpuCanvas.requestPaint(); }
                        }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: -1
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "CPU"
                            font.family: "SF Pro Display"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            color: root.widgetsState.textDim
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.widgetsState.cpuPercent + "%"
                            font.family: "SF Pro Display"
                            font.pixelSize: 11
                            font.weight: Font.ExtraBold
                            color: root.widgetsState.textColor
                        }
                    }
                }

                // RAM Gauge
                Item {
                    Layout.fillWidth: true
                    height: 58

                    Canvas {
                        id: ramCanvas
                        anchors.centerIn: parent
                        width: 58
                        height: 58
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            var centerX = width / 2;
                            var centerY = height / 2;
                            var radius = 24;
                            
                            // Background track
                            ctx.beginPath();
                            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI, false);
                            ctx.lineWidth = 5;
                            ctx.strokeStyle = root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.12)" : "rgba(0,0,0,0.08)";
                            ctx.stroke();

                            // Value arc
                            var pct = root.widgetsState.ramPercent / 100.0;
                            var startAngle = -0.5 * Math.PI;
                            var endAngle = startAngle + (pct * 2 * Math.PI);
                            ctx.beginPath();
                            ctx.arc(centerX, centerY, radius, startAngle, endAngle, false);
                            ctx.lineWidth = 5;
                            ctx.strokeStyle = "#30D158";
                            ctx.stroke();
                        }
                        Connections {
                            target: root.widgetsState
                            function onRamPercentChanged() { ramCanvas.requestPaint(); }
                        }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: -1
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "RAM"
                            font.family: "SF Pro Display"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            color: root.widgetsState.textDim
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.widgetsState.ramPercent + "%"
                            font.family: "SF Pro Display"
                            font.pixelSize: 11
                            font.weight: Font.ExtraBold
                            color: root.widgetsState.textColor
                        }
                    }
                }
            }

            // Bottom Row: Disk gauge & Macintosh HD label
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                // Disk Gauge
                Item {
                    width: 58
                    height: 58

                    Canvas {
                        id: diskCanvas
                        anchors.centerIn: parent
                        width: 58
                        height: 58
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            var centerX = width / 2;
                            var centerY = height / 2;
                            var radius = 24;
                            
                            // Background track
                            ctx.beginPath();
                            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI, false);
                            ctx.lineWidth = 5;
                            ctx.strokeStyle = root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.12)" : "rgba(0,0,0,0.08)";
                            ctx.stroke();

                            // Value arc
                            var pct = root.widgetsState.diskPercent / 100.0;
                            var startAngle = -0.5 * Math.PI;
                            var endAngle = startAngle + (pct * 2 * Math.PI);
                            ctx.beginPath();
                            ctx.arc(centerX, centerY, radius, startAngle, endAngle, false);
                            ctx.lineWidth = 5;
                            ctx.strokeStyle = "#FF9F0A";
                            ctx.stroke();
                        }
                        Connections {
                            target: root.widgetsState
                            function onDiskPercentChanged() { diskCanvas.requestPaint(); }
                        }
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: -1
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Disk"
                            font.family: "SF Pro Display"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            color: root.widgetsState.textDim
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.widgetsState.diskPercent + "%"
                            font.family: "SF Pro Display"
                            font.pixelSize: 11
                            font.weight: Font.ExtraBold
                            color: root.widgetsState.textColor
                        }
                    }
                }

                // Disk Info Labels
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: "Macintosh HD"
                        font.family: "SF Pro Display"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        color: root.widgetsState.textColor
                    }
                    Text {
                        text: root.widgetsState.diskUsed + " / " + root.widgetsState.diskTotal
                        font.family: "SF Pro Display"
                        font.pixelSize: 10
                        font.weight: Font.Medium
                        color: root.widgetsState.textDim
                    }
                }
            }
        }
    }
}
