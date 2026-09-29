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
            anchors.centerIn: parent
            spacing: 2

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: root.widgetsState.clockCity
                font.family: "SF Pro Display"
                font.pixelSize: 11
                font.weight: Font.ExtraBold
                color: root.widgetsState.accentRed
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: root.widgetsState.clockTime
                font.family: "SF Pro Display"
                font.pixelSize: 38
                font.weight: Font.ExtraBold
                color: root.widgetsState.textColor
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 6

                Text {
                    text: root.widgetsState.clockWeekday
                    font.family: "SF Pro Display"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    color: root.widgetsState.textDim
                }
                Text {
                    text: root.widgetsState.clockDay
                    font.family: "SF Pro Display"
                    font.pixelSize: 12
                    font.weight: Font.ExtraBold
                    color: root.widgetsState.textColor
                }
            }
        }
    }
}
