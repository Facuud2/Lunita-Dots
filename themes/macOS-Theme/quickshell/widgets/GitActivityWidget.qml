import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property var widgetsState

    readonly property bool isCiFail: root.widgetsState ? (root.widgetsState.gitCiStatus === "failure") : false

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: 22
        color: root.widgetsState ? root.widgetsState.cardBg : Qt.rgba(0.12, 0.14, 0.18, 0.75)
        border.color: isCiFail ? "#FF453A" : (root.widgetsState ? root.widgetsState.cardBorder : Qt.rgba(1, 1, 1, 0.14))
        border.width: isCiFail ? 1.5 : 1
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 5

            // ── Header ──
            RowLayout {
                Layout.fillWidth: true
                spacing: 5

                Text {
                    text: ""
                    font.family: "CaskaydiaCove Nerd Font"
                    font.pixelSize: 13
                    color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"
                }

                Text {
                    text: "GITHUB"
                    font.family: "SF Pro Display"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.6)
                    font.letterSpacing: 0.5
                }

                Item { Layout.fillWidth: true }

                // CI/CD Badge
                Rectangle {
                    height: 16
                    radius: 8
                    implicitWidth: ciRow.implicitWidth + 8
                    color: isCiFail ? Qt.rgba(1.0, 0.27, 0.23, 0.20) : Qt.rgba(0.19, 0.82, 0.35, 0.20)
                    border.color: isCiFail ? "#FF453A" : "#30D158"
                    border.width: 1

                    RowLayout {
                        id: ciRow
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            text: isCiFail ? "󰅚" : "󰄬"
                            font.family: "CaskaydiaCove Nerd Font"
                            font.pixelSize: 9
                            color: isCiFail ? "#FF453A" : "#30D158"
                        }

                        Text {
                            text: isCiFail ? "FAIL" : "PASS"
                            font.family: "SF Pro Display"
                            font.pixelSize: 8
                            font.weight: Font.Bold
                            color: isCiFail ? "#FF453A" : "#30D158"
                        }
                    }
                }
            }

            // ── 7-Day GitHub Heatmap ──
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 5

                Repeater {
                    model: root.widgetsState && root.widgetsState.gitHeatmap.length > 0 ? root.widgetsState.gitHeatmap : defaultHeatmap

                    delegate: ColumnLayout {
                        spacing: 2
                        Layout.alignment: Qt.AlignHCenter

                        Rectangle {
                            width: 12
                            height: 12
                            radius: 2.5
                            color: {
                                var lvl = modelData.level !== undefined ? modelData.level : 0;
                                if (lvl === 4) return "#39D353";
                                if (lvl === 3) return "#26A641";
                                if (lvl === 2) return "#006D32";
                                if (lvl === 1) return "#0E4429";
                                return root.widgetsState && root.widgetsState.isDarkTheme ? "#161B22" : "#E1E4E8";
                            }
                            border.color: root.widgetsState && root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.06)" : "rgba(0,0,0,0.06)"
                            border.width: 0.5
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.day_letter || "-"
                            font.family: "SF Pro Display"
                            font.pixelSize: 8
                            font.weight: Font.Medium
                            color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.5)
                        }
                    }
                }
            }

            // ── Latest Commit Card ──
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 10
                color: root.widgetsState && root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.06)" : "rgba(0,0,0,0.04)"
                border.color: root.widgetsState && root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.08)" : "rgba(0,0,0,0.06)"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 7
                    spacing: 2

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: root.widgetsState && root.widgetsState.gitLatestCommit && root.widgetsState.gitLatestCommit.repo ? root.widgetsState.gitLatestCommit.repo : "Lunita-Dots"
                            font.family: "SF Pro Display"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            color: root.widgetsState ? root.widgetsState.accentBlue : "#007AFF"
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: root.widgetsState && root.widgetsState.gitLatestCommit && root.widgetsState.gitLatestCommit.hash ? root.widgetsState.gitLatestCommit.hash : "adf8df3"
                            font.family: "JetBrains Mono"
                            font.pixelSize: 8
                            font.weight: Font.DemiBold
                            color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.6)
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.widgetsState && root.widgetsState.gitLatestCommit && root.widgetsState.gitLatestCommit.relative_time ? root.widgetsState.gitLatestCommit.relative_time : "reciente"
                        font.family: "SF Pro Display"
                        font.pixelSize: 8
                        font.weight: Font.Medium
                        color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.5)
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: root.widgetsState && root.widgetsState.gitLatestCommit && root.widgetsState.gitLatestCommit.message ? root.widgetsState.gitLatestCommit.message : "Actualizaciones en componentes"
                        font.family: "SF Pro Display"
                        font.pixelSize: 9
                        font.weight: Font.Normal
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: root.widgetsState ? !root.widgetsState.isEditing : true
            cursorShape: Qt.PointingHandCursor
            onDoubleClicked: {
                if (root.widgetsState) root.widgetsState.refreshGit();
            }
        }
    }

    readonly property var defaultHeatmap: [
        { day_letter: "L", level: 1 },
        { day_letter: "M", level: 2 },
        { day_letter: "M", level: 0 },
        { day_letter: "J", level: 3 },
        { day_letter: "V", level: 4 },
        { day_letter: "S", level: 2 },
        { day_letter: "D", level: 3 }
    ]
}
