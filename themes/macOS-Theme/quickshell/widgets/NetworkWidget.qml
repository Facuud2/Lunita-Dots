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

            // Speed Row: Download & Upload
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // Download
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    Text {
                        text: root.widgetsState.netDownVal
                        font.family: "SF Pro Display"
                        font.pixelSize: 22
                        font.weight: Font.ExtraBold
                        color: root.widgetsState.textColor
                    }
                    Text {
                        text: root.widgetsState.netDownUnit
                        font.family: "SF Pro Display"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        color: root.widgetsState.textDim
                    }
                    Text {
                        text: "Download"
                        font.family: "SF Pro Display"
                        font.pixelSize: 9
                        font.weight: Font.Medium
                        color: root.widgetsState.textDim
                    }
                }

                // Upload
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    Text {
                        text: root.widgetsState.netUpVal
                        font.family: "SF Pro Display"
                        font.pixelSize: 22
                        font.weight: Font.ExtraBold
                        color: root.widgetsState.textColor
                    }
                    Text {
                        text: root.widgetsState.netUpUnit
                        font.family: "SF Pro Display"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        color: root.widgetsState.textDim
                    }
                    Text {
                        text: "Upload"
                        font.family: "SF Pro Display"
                        font.pixelSize: 9
                        font.weight: Font.Medium
                        color: root.widgetsState.textDim
                    }
                }
            }

            // Divider Line
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.10)" : "rgba(0,0,0,0.08)"
            }

            // Info rows: Status, Interface, IP
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Status"
                        font.family: "SF Pro Display"
                        font.pixelSize: 10
                        font.weight: Font.Medium
                        color: root.widgetsState.textDim
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: root.widgetsState.netStatus
                        font.family: "SF Pro Display"
                        font.pixelSize: 10
                        font.weight: Font.ExtraBold
                        color: root.widgetsState.accentGreen
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Interface"
                        font.family: "SF Pro Display"
                        font.pixelSize: 10
                        font.weight: Font.Medium
                        color: root.widgetsState.textDim
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: root.widgetsState.netInterface
                        font.family: "SF Pro Display"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        color: root.widgetsState.textColor
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "IP"
                        font.family: "SF Pro Display"
                        font.pixelSize: 10
                        font.weight: Font.Medium
                        color: root.widgetsState.textDim
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: root.widgetsState.netIp
                        font.family: "CaskaydiaCove Nerd Font"
                        font.pixelSize: 9
                        font.weight: Font.Normal
                        color: root.widgetsState.textColor
                    }
                }
            }
        }
    }
}
