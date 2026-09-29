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
            spacing: 4

            // Header Row: MONTH YEAR
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: root.widgetsState.calMonthName
                    font.family: "SF Pro Display"
                    font.pixelSize: 13
                    font.weight: Font.ExtraBold
                    color: root.widgetsState.textColor
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: root.widgetsState.calYear
                    font.family: "SF Pro Display"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    color: root.widgetsState.textDim
                }
            }

            // Weekdays Row: D L M M J V S
            RowLayout {
                Layout.fillWidth: true
                Repeater {
                    model: root.widgetsState.calWeekdays
                    Item {
                        Layout.fillWidth: true
                        height: 16
                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            font.family: "SF Pro Display"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            color: root.widgetsState.textDim
                        }
                    }
                }
            }

            // Calendar Grid Rows
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 2

                Repeater {
                    model: root.widgetsState.calWeeks
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        property var weekData: modelData

                        Repeater {
                            model: weekData
                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 20
                                    height: 20
                                    radius: 10
                                    color: modelData.is_today
                                        ? (root.widgetsState.isDarkTheme ? "#FFFFFF" : "#FF3B30")
                                        : "transparent"

                                    Text {
                                        anchors.centerIn: parent
                                        text: modelData.day
                                        font.family: "SF Pro Display"
                                        font.pixelSize: 10
                                        font.weight: modelData.is_today ? Font.ExtraBold : Font.Normal
                                        color: modelData.is_today
                                            ? (root.widgetsState.isDarkTheme ? "#1C1C1E" : "#FFFFFF")
                                            : (modelData.in_month ? root.widgetsState.textColor : "transparent")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
