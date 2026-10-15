import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes

Item {
    id: root

    required property var barState

    width: 440
    height: 260
    anchors.top: parent.top
    anchors.topMargin: 0

    visible: barState.activePopup === "calendar"
    opacity: visible ? 1.0 : 0.0

    Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    Item {
        id: cardContainer
        anchors.fill: parent

        // Main Card Rectangle (flat top, rounded bottom, flush with top)
        Rectangle {
            id: mainCardBg
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.top: parent.top
            anchors.topMargin: -2
            topLeftRadius: 0
            topRightRadius: 0
            bottomLeftRadius: 22
            bottomRightRadius: 22

            color: Qt.rgba(0.04, 0.05, 0.06, 0.97)
            border.color: Qt.rgba(1, 1, 1, 0.14)
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            anchors.topMargin: 8
            spacing: 10

            // 1. Top Header Row: Weather, Time, Battery (SVG vector icons)
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 18

                // Weather
                Row {
                    spacing: 5
                    Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                    Image {
                        source: "../assets/moon.svg"
                        sourceSize.width: 12
                        sourceSize.height: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: root.barState.weatherTemp
                        font.family: "Segoe UI, Inter, Cantarell, sans-serif"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: Qt.rgba(1, 1, 1, 0.85)
                    }
                }

                Item { Layout.fillWidth: true }

                // Clock
                Text {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    text: root.barState.timeStr
                    font.family: "Segoe UI, Inter, Cantarell, sans-serif"
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    color: "#FFFFFF"
                }

                Item { Layout.fillWidth: true }

                // Battery
                Row {
                    spacing: 4
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                    Image {
                        source: "../assets/battery.svg"
                        sourceSize.width: 15
                        sourceSize.height: 15
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: root.barState.batteryPercent + "%"
                        font.family: "Segoe UI, Inter, Cantarell, sans-serif"
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: Qt.rgba(1, 1, 1, 0.85)
                    }
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Qt.rgba(1, 1, 1, 0.08)
            }

            // 2. Main Body: Calendar (Left) & Focus Timer (Right)
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 16

                // ── Left Column: Calendar ──
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 6

                    Text {
                        text: root.barState.monthName + " " + root.barState.currentYear
                        font.family: "Segoe UI, Inter, Cantarell, sans-serif"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                    }

                    // Weekday headers: S M T W T F S
                    Row {
                        spacing: 8
                        Repeater {
                            model: ["S", "M", "T", "W", "T", "F", "S"]
                            Item {
                                width: 20
                                height: 16
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.family: "Segoe UI, Inter, sans-serif"
                                    font.pixelSize: 9
                                    font.weight: Font.DemiBold
                                    color: Qt.rgba(1, 1, 1, 0.40)
                                }
                            }
                        }
                    }

                    // Days Grid
                    Grid {
                        columns: 7
                        columnSpacing: 8
                        rowSpacing: 4

                        Repeater {
                            model: 4 // empty offset
                            Item { width: 20; height: 18 }
                        }

                        Repeater {
                            model: 31
                            Item {
                                width: 20
                                height: 18

                                property bool isSelectedDay: (index + 1) === root.barState.currentDay

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 18
                                    height: 18
                                    radius: 9
                                    color: parent.isSelectedDay ? "#FFFFFF" : "transparent"
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: (index + 1).toString()
                                    font.family: "Segoe UI, Inter, sans-serif"
                                    font.pixelSize: 10
                                    font.weight: parent.isSelectedDay ? Font.Bold : Font.Normal
                                    color: parent.isSelectedDay ? "#111215" : Qt.rgba(1, 1, 1, 0.85)
                                }
                            }
                        }
                    }
                }

                // Vertical Divider
                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.fillHeight: true
                    color: Qt.rgba(1, 1, 1, 0.08)
                }

                // ── Right Column: Pomodoro / Focus Timer ──
                ColumnLayout {
                    Layout.preferredWidth: 175
                    Layout.fillHeight: true
                    spacing: 8
                    Layout.alignment: Qt.AlignHCenter

                    Text {
                        text: "Click to edit"
                        font.family: "Segoe UI, Inter, sans-serif"
                        font.pixelSize: 10
                        font.weight: Font.Medium
                        color: Qt.rgba(1, 1, 1, 0.40)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    // Big Digital Timer
                    Text {
                        text: root.barState.timerDisplay
                        font.family: "Segoe UI, Inter, Cantarell, sans-serif"
                        font.pixelSize: 32
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                        Layout.alignment: Qt.AlignHCenter
                    }

                    // Start / Pause Pill Button
                    Rectangle {
                        Layout.preferredWidth: 110
                        Layout.preferredHeight: 30
                        Layout.alignment: Qt.AlignHCenter
                        radius: 15
                        color: startHover.containsMouse ? Qt.rgba(1, 1, 1, 0.95) : "#FFFFFF"

                        Row {
                            anchors.centerIn: parent
                            spacing: 6

                            Image {
                                source: root.barState.timerRunning ? "../assets/pause.svg" : "../assets/play.svg"
                                sourceSize.width: 10
                                sourceSize.height: 10
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: root.barState.timerRunning ? "Pausar" : "Start"
                                font.family: "Segoe UI, Inter, sans-serif"
                                font.pixelSize: 12
                                font.weight: Font.Bold
                                color: "#111215"
                            }
                        }

                        MouseArea {
                            id: startHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.barState.toggleTimer()
                        }
                    }

                    // Presets Row: 5m, 15m, 25m, 50m
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 5

                        Repeater {
                            model: [5, 15, 25, 50]
                            Rectangle {
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 22
                                radius: 11
                                color: (root.barState.timerInitialSecs === modelData * 60)
                                    ? Qt.rgba(1, 1, 1, 0.22)
                                    : (presetHover.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.08))

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData + "m"
                                    font.family: "Segoe UI, Inter, sans-serif"
                                    font.pixelSize: 10
                                    font.weight: Font.Medium
                                    color: "#FFFFFF"
                                }

                                MouseArea {
                                    id: presetHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.barState.setTimerPreset(modelData)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
