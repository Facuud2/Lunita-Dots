import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property var widgetsState
    readonly property bool isSmall: root.width <= 220
    readonly property bool isMedium: root.width > 220 && root.height <= 240
    readonly property bool isLarge: root.width > 220 && root.height > 240
    readonly property bool isCiFail: root.widgetsState ? (root.widgetsState.gitCiStatus === "failure") : false
    readonly property var defaultHeatmap: [{
        "day_letter": "L",
        "level": 1
    }, {
        "day_letter": "M",
        "level": 2
    }, {
        "day_letter": "M",
        "level": 0
    }, {
        "day_letter": "J",
        "level": 3
    }, {
        "day_letter": "V",
        "level": 4
    }, {
        "day_letter": "S",
        "level": 2
    }, {
        "day_letter": "D",
        "level": 3
    }]

    Rectangle {
        id: bg

        anchors.fill: parent
        radius: root.widgetsState ? root.widgetsState.cardRadius : 22
        color: root.widgetsState ? root.widgetsState.cardBg : Qt.rgba(0.12, 0.14, 0.18, 0.75)
        border.color: isCiFail ? "#FF453A" : (root.widgetsState ? root.widgetsState.cardBorder : Qt.rgba(1, 1, 1, 0.14))
        border.width: isCiFail ? 1.5 : 1
        clip: true

        // ═══════════════════════════════════════════════════════════════════
        // ── 1. MODO COMPACTO (170 x 170) ──
        // ═══════════════════════════════════════════════════════════════════
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 5
            visible: !root.isLarge

            // Header
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

                Item {
                    Layout.fillWidth: true
                }

                // CI/CD Badge
                Rectangle {
                    height: 16
                    radius: 8
                    implicitWidth: ciRow.implicitWidth + 8
                    color: isCiFail ? Qt.rgba(1, 0.27, 0.23, 0.2) : Qt.rgba(0.19, 0.82, 0.35, 0.2)
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

            // 7-Day Heatmap
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
                                if (lvl === 4)
                                    return "#39D353";

                                if (lvl === 3)
                                    return "#26A641";

                                if (lvl === 2)
                                    return "#006D32";

                                if (lvl === 1)
                                    return "#0E4429";

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

            // Latest Commit Card
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

                        Item {
                            Layout.fillWidth: true
                        }

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

        // ═══════════════════════════════════════════════════════════════════
        // ── 2. MODO GRANDE (354 x 354): DASHBOARD DE ACTIVIDAD GITHUB ──
        // ═══════════════════════════════════════════════════════════════════
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10
            visible: root.isLarge

            // 1. Header con Perfil & CI Status
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    width: 28
                    height: 28
                    radius: 14
                    color: Qt.rgba(1, 1, 1, 0.12)

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font.family: "CaskaydiaCove Nerd Font"
                        font.pixelSize: 16
                        color: "#FFFFFF"
                    }

                }

                ColumnLayout {
                    spacing: 0

                    Text {
                        text: "GitHub Activity"
                        font.family: "SF Pro Display"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                    }

                    Text {
                        text: "@" + (root.widgetsState ? root.widgetsState.gitUser : "Facuud2")
                        font.family: "SF Pro Display"
                        font.pixelSize: 9
                        color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.55)
                    }

                }

                Item {
                    Layout.fillWidth: true
                }

                // Badge CI/CD
                Rectangle {
                    height: 20
                    radius: 10
                    implicitWidth: ciLargeRow.implicitWidth + 12
                    color: isCiFail ? Qt.rgba(1, 0.27, 0.23, 0.22) : Qt.rgba(0.19, 0.82, 0.35, 0.22)
                    border.color: isCiFail ? "#FF453A" : "#30D158"
                    border.width: 1

                    RowLayout {
                        id: ciLargeRow

                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            text: isCiFail ? "󰅚" : "󰄬"
                            font.family: "CaskaydiaCove Nerd Font"
                            font.pixelSize: 11
                            color: isCiFail ? "#FF453A" : "#30D158"
                        }

                        Text {
                            text: isCiFail ? "CI FALLIDO" : "PIPELINES OK"
                            font.family: "SF Pro Display"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            color: isCiFail ? "#FF453A" : "#30D158"
                        }

                    }

                }

            }

            // 2. Tarjeta de Mapa de Calor 7 Días
            Rectangle {
                Layout.fillWidth: true
                height: 52
                radius: 12
                color: Qt.rgba(1, 1, 1, 0.05)
                border.color: Qt.rgba(1, 1, 1, 0.08)
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    ColumnLayout {
                        spacing: 1

                        Text {
                            text: "Últimos 7 días"
                            font.family: "SF Pro Display"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            color: "#FFFFFF"
                        }

                        Text {
                            text: "Registro de actividad"
                            font.family: "SF Pro Display"
                            font.pixelSize: 9
                            color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.5)
                        }

                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    RowLayout {
                        spacing: 6

                        Repeater {
                            model: root.widgetsState && root.widgetsState.gitHeatmap.length > 0 ? root.widgetsState.gitHeatmap : defaultHeatmap

                            delegate: ColumnLayout {
                                spacing: 3
                                Layout.alignment: Qt.AlignHCenter

                                Rectangle {
                                    width: 16
                                    height: 16
                                    radius: 3.5
                                    color: {
                                        var lvl = modelData.level !== undefined ? modelData.level : 0;
                                        if (lvl === 4)
                                            return "#39D353";

                                        if (lvl === 3)
                                            return "#26A641";

                                        if (lvl === 2)
                                            return "#006D32";

                                        if (lvl === 1)
                                            return "#0E4429";

                                        return root.widgetsState && root.widgetsState.isDarkTheme ? "#161B22" : "#E1E4E8";
                                    }
                                    border.color: root.widgetsState && root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.10)" : "rgba(0,0,0,0.08)"
                                    border.width: 0.5
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: modelData.day_letter || "-"
                                    font.family: "SF Pro Display"
                                    font.pixelSize: 8
                                    font.weight: Font.Bold
                                    color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.6)
                                }

                            }

                        }

                    }

                }

            }

            // 3. Título de sección: Commits Recientes
            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "󰜘"
                    font.family: "CaskaydiaCove Nerd Font"
                    font.pixelSize: 11
                    color: root.widgetsState ? root.widgetsState.accentBlue : "#007AFF"
                }

                Text {
                    text: "COMMITS RECIENTES"
                    font.family: "SF Pro Display"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    font.letterSpacing: 0.5
                    color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.6)
                }

            }

            // 4. Lista de commits recientes (ocupa el resto de la tarjeta con estilo elegante)
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 6
                model: root.widgetsState && root.widgetsState.gitRecentCommits.length > 0 ? root.widgetsState.gitRecentCommits : (root.widgetsState && root.widgetsState.gitLatestCommit ? [root.widgetsState.gitLatestCommit] : [])

                delegate: Rectangle {
                    width: parent ? parent.width : 326
                    height: 48
                    radius: 10
                    color: Qt.rgba(1, 1, 1, 0.05)
                    border.color: Qt.rgba(1, 1, 1, 0.07)
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        anchors.topMargin: 6
                        anchors.bottomMargin: 6
                        spacing: 2

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6

                            // Repo Pill
                            Rectangle {
                                height: 16
                                radius: 8
                                implicitWidth: repoTxt.implicitWidth + 8
                                color: Qt.rgba(0, 122 / 255, 255 / 255, 0.18)

                                Text {
                                    id: repoTxt

                                    anchors.centerIn: parent
                                    text: modelData.repo || "Lunita-Dots"
                                    font.family: "SF Pro Display"
                                    font.pixelSize: 9
                                    font.weight: Font.Bold
                                    color: "#0A84FF"
                                }

                            }

                            Text {
                                text: modelData.hash || "abc1234"
                                font.family: "JetBrains Mono"
                                font.pixelSize: 9
                                font.weight: Font.Bold
                                color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.6)
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text: modelData.relative_time || "reciente"
                                font.family: "SF Pro Display"
                                font.pixelSize: 9
                                color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.5)
                            }

                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.message || "Commit sin mensaje"
                            font.family: "SF Pro Display"
                            font.pixelSize: 10
                            font.weight: Font.Normal
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            color: "#FFFFFF"
                        }

                    }

                }

            }

        }

        MouseArea {
            anchors.fill: parent
            enabled: root.widgetsState ? !root.widgetsState.isEditing : true
            cursorShape: Qt.PointingHandCursor
            onDoubleClicked: {
                if (root.widgetsState)
                    root.widgetsState.refreshGit();

            }
        }

    }

}
