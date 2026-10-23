import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    required property var barState
    property var currentDate: new Date()

    visible: barState.activePopup === "calendar"
    x: Math.max(10, parent.width - width - 12)
    y: 4
    width: 300
    implicitHeight: mainCol.implicitHeight + 24
    height: implicitHeight
    z: 10
    opacity: visible ? 1 : 0
    scale: visible ? 1 : 0.96

    Rectangle {
        anchors.fill: parent
        radius: 16
        color: barState.popupBgColor
        border.color: barState.popupBorderColor
        border.width: 1

        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: 17
            color: "transparent"
            border.color: Qt.rgba(0, 0, 0, barState.isDarkTheme ? 0.4 : 0.12)
            border.width: 1
            z: -1
        }

        Behavior on color {
            ColorAnimation {
                duration: 200
            }

        }

        Behavior on border.color {
            ColorAnimation {
                duration: 200
            }

        }

    }

    ColumnLayout {
        id: mainCol

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 14
        spacing: 12

        // ── Digital Clock & Today Header ──
        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 2

                Text {
                    text: barState.dateStr
                    color: "#FF3B30"
                    font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                }

                Text {
                    text: barState.timeStr
                    color: barState.popupTextColor
                    font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                    font.pixelSize: 22
                    font.weight: Font.Bold

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }

                    }

                }

            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                width: 36
                height: 36
                radius: 18
                color: barState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(0, 0, 0, 0.06)

                Text {
                    anchors.centerIn: parent
                    text: "📅"
                    font.pixelSize: 18
                }

            }

        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: barState.popupSeparatorColor
        }

        // ── Month Calendar Grid ──
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            // Month & Year title
            Text {
                text: Qt.formatDate(root.currentDate, "MMMM yyyy")
                color: barState.popupTextColor
                font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                font.pixelSize: 13
                font.weight: Font.DemiBold

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }

                }

            }

            // Days of week header (Su Mo Tu We Th Fr Sa)
            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                Repeater {
                    model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

                    delegate: Text {
                        required property var modelData

                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        color: barState.popupTextDim
                        font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                    }

                }

            }

            // Days grid (5 rows x 7 cols = 35 cells)
            GridLayout {
                Layout.fillWidth: true
                columns: 7
                rowSpacing: 4
                columnSpacing: 0

                Repeater {
                    model: 35

                    delegate: Item {
                        required property int index
                        property int firstDayOffset: new Date(root.currentDate.getFullYear(), root.currentDate.getMonth(), 1).getDay()
                        property int daysInMonth: new Date(root.currentDate.getFullYear(), root.currentDate.getMonth() + 1, 0).getDate()
                        property int dayNum: index - firstDayOffset + 1
                        property bool isValidDay: dayNum >= 1 && dayNum <= daysInMonth
                        property bool isToday: isValidDay && (dayNum === root.currentDate.getDate())

                        Layout.fillWidth: true
                        implicitHeight: 24

                        Rectangle {
                            anchors.centerIn: parent
                            width: 22
                            height: 22
                            radius: 11
                            color: isToday ? "#007AFF" : "transparent"

                            Text {
                                anchors.centerIn: parent
                                visible: isValidDay
                                text: isValidDay ? dayNum.toString() : ""
                                color: isToday ? "#FFFFFF" : barState.popupTextColor
                                font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                                font.pixelSize: 11
                                font.weight: isToday ? Font.Bold : Font.Normal
                                opacity: isToday ? 1 : 0.88
                            }

                        }

                    }

                }

            }

        }

    }

    Behavior on opacity {
        NumberAnimation {
            duration: 140
            easing.type: Easing.OutCubic
        }

    }

    Behavior on scale {
        NumberAnimation {
            duration: 140
            easing.type: Easing.OutCubic
        }

    }

}
