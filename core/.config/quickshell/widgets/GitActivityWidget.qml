import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property var widgetsState
    readonly property var skin: root.widgetsState ? root.widgetsState.skin : null
    readonly property bool nothing: skin ? skin.isNothing : false
    readonly property bool fluent: skin ? skin.isFluent : false
    readonly property string fontText: (skin && (nothing || fluent)) ? skin.fontText : "SF Pro Display"
    readonly property string fontFigure: (skin && (nothing || fluent)) ? skin.fontFigure : "SF Pro Display"
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
        radius: root.nothing ? root.skin.radius : (root.fluent ? root.skin.radius : (root.widgetsState ? root.widgetsState.cardRadius : 22))
        color: root.nothing ? root.skin.card : (root.fluent ? root.skin.card : (root.widgetsState ? root.widgetsState.cardBg : Qt.rgba(0.12, 0.14, 0.18, 0.75)))
        border.color: isCiFail ? (root.fluent ? "#E81123" : (root.nothing ? root.skin.signal : "#FF453A")) : (root.fluent ? root.skin.cardBorder : (root.nothing ? "transparent" : (root.widgetsState ? root.widgetsState.cardBorder : Qt.rgba(1, 1, 1, 0.14))))
        border.width: isCiFail ? 1.5 : (root.nothing ? 0 : 1)
        clip: true
        scale: cardMa.pressed ? 0.985 : 1.0
        Behavior on scale {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        MouseArea {
            id: cardMa
            anchors.fill: parent
            hoverEnabled: true
        }

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
                    color: root.nothing ? root.skin.ink : (root.widgetsState ? root.widgetsState.textColor : "#FFFFFF")
                }

                Text {
                    text: "GITHUB"
                    font.family: root.fontText
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    color: root.nothing ? root.skin.inkDim : (root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.6))
                    font.letterSpacing: 0.5
                }

                Item {
                    Layout.fillWidth: true
                }

                // CI/CD Badge
                Rectangle {
                    height: 16
                    radius: root.fluent ? 6 : 8
                    implicitWidth: ciRow.implicitWidth + 8
                    color: root.fluent ? (isCiFail ? Qt.rgba(232 / 255, 17 / 255, 35 / 255, 0.15) : Qt.rgba(16 / 255, 124 / 255, 65 / 255, 0.15)) : (root.nothing ? root.skin.raised : (isCiFail ? Qt.rgba(1, 0.27, 0.23, 0.2) : Qt.rgba(0.19, 0.82, 0.35, 0.2)))
                    border.color: root.fluent ? (isCiFail ? "#E81123" : "#107C41") : (root.nothing ? (isCiFail ? root.skin.signal : "transparent") : (isCiFail ? "#FF453A" : "#30D158"))
                    border.width: 1

                    RowLayout {
                        id: ciRow

                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            text: isCiFail ? "󰅚" : "󰄬"
                            font.family: "CaskaydiaCove Nerd Font"
                            font.pixelSize: 9
                            color: root.fluent ? (isCiFail ? "#E81123" : "#107C41") : (isCiFail ? (root.nothing ? root.skin.signal : "#FF453A") : (root.nothing ? root.skin.green : "#30D158"))
                        }

                        Text {
                            text: isCiFail ? "FAIL" : "PASS"
                            font.family: root.fontText
                            font.pixelSize: 8
                            font.weight: Font.Bold
                            color: root.fluent ? (isCiFail ? "#E81123" : "#107C41") : (isCiFail ? (root.nothing ? root.skin.signal : "#FF453A") : (root.nothing ? root.skin.green : "#30D158"))
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
                            radius: root.fluent ? 3 : (root.nothing ? width / 2 : 2.5)
                            color: {
                                var lvl = modelData.level !== undefined ? modelData.level : 0;
                                if (root.fluent) {
                                    if (lvl === 4) return "#2ea043";
                                    if (lvl === 3) return "#238636";
                                    if (lvl === 2) return "#196127";
                                    if (lvl === 1) return "#0e4429";
                                    return "rgba(255, 255, 255, 0.06)";
                                }
                                if (root.nothing) {
                                    if (lvl === 4) return root.skin.green;
                                    if (lvl === 3) return Qt.rgba(0, 0.90, 0.60, 0.75);
                                    if (lvl === 2) return Qt.rgba(0, 0.90, 0.60, 0.50);
                                    if (lvl === 1) return Qt.rgba(0, 0.90, 0.60, 0.25);
                                    return root.skin.dotOff;
                                }
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
                            border.color: root.fluent ? root.skin.cardBorder : (root.nothing ? "transparent" : (root.widgetsState && root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.06)" : "rgba(0,0,0,0.06)"))
                            border.width: 0.5
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.day_letter || "-"
                            font.family: root.fontText
                            font.pixelSize: 8
                            font.weight: Font.Medium
                            color: root.nothing ? root.skin.inkDim : (root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.5))
                        }

                    }

                }

            }

            // Latest Commit Card
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: root.fluent ? 6 : (root.nothing ? 12 : 10)
                color: root.fluent ? root.skin.cardAlt : (root.nothing ? root.skin.raised : (root.widgetsState && root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.06)" : "rgba(0,0,0,0.04)"))
                border.color: root.fluent ? root.skin.cardBorder : (root.nothing ? "transparent" : (root.widgetsState && root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.08)" : "rgba(0,0,0,0.06)"))
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
                            font.family: root.fontText
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            color: root.nothing ? root.skin.ink : (root.widgetsState ? root.widgetsState.accentBlue : "#007AFF")
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: root.widgetsState && root.widgetsState.gitLatestCommit && root.widgetsState.gitLatestCommit.hash ? root.widgetsState.gitLatestCommit.hash : "adf8df3"
                            font.family: root.nothing ? root.fontFigure : "JetBrains Mono"
                            font.pixelSize: 8
                            font.weight: Font.DemiBold
                            color: root.nothing ? root.skin.inkDim : (root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.6))
                        }

                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.widgetsState && root.widgetsState.gitLatestCommit && root.widgetsState.gitLatestCommit.relative_time ? root.widgetsState.gitLatestCommit.relative_time : "reciente"
                        font.family: root.fontText
                        font.pixelSize: 8
                        font.weight: Font.Medium
                        color: root.nothing ? root.skin.inkDim : (root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.5))
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: root.widgetsState && root.widgetsState.gitLatestCommit && root.widgetsState.gitLatestCommit.message ? root.widgetsState.gitLatestCommit.message : "Actualizaciones en componentes"
                        font.family: root.fontText
                        font.pixelSize: 9
                        font.weight: Font.Normal
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        color: root.nothing ? root.skin.ink : (root.widgetsState ? root.widgetsState.textColor : "#FFFFFF")
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
                    color: root.nothing ? root.skin.raised : Qt.rgba(1, 1, 1, 0.12)

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font.family: "CaskaydiaCove Nerd Font"
                        font.pixelSize: 16
                        color: root.nothing ? root.skin.ink : "#FFFFFF"
                    }

                }

                ColumnLayout {
                    spacing: 0

                    Text {
                        text: "GitHub Activity"
                        font.family: root.fontText
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        color: root.nothing ? root.skin.ink : "#FFFFFF"
                    }

                    Text {
                        text: "@" + (root.widgetsState ? root.widgetsState.gitUser : "Facuud2")
                        font.family: root.fontText
                        font.pixelSize: 9
                        color: root.nothing ? root.skin.inkDim : (root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.55))
                    }

                }

                Item {
                    Layout.fillWidth: true
                }

                // Badge CI/CD
                Rectangle {
                    height: 20
                    radius: root.fluent ? 6 : 10
                    implicitWidth: ciLargeRow.implicitWidth + 12
                    color: root.fluent ? (isCiFail ? Qt.rgba(232 / 255, 17 / 255, 35 / 255, 0.15) : Qt.rgba(16 / 255, 124 / 255, 65 / 255, 0.15)) : (root.nothing ? root.skin.raised : (isCiFail ? Qt.rgba(1, 0.27, 0.23, 0.22) : Qt.rgba(0.19, 0.82, 0.35, 0.22)))
                    border.color: root.fluent ? (isCiFail ? "#E81123" : "#107C41") : (root.nothing ? (isCiFail ? root.skin.signal : "transparent") : (isCiFail ? "#FF453A" : "#30D158"))
                    border.width: 1

                    RowLayout {
                        id: ciLargeRow

                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            text: isCiFail ? "󰅚" : "󰄬"
                            font.family: "CaskaydiaCove Nerd Font"
                            font.pixelSize: 11
                            color: root.fluent ? (isCiFail ? "#E81123" : "#107C41") : (isCiFail ? (root.nothing ? root.skin.signal : "#FF453A") : (root.nothing ? root.skin.green : "#30D158"))
                        }

                        Text {
                            text: isCiFail ? "CI FALLIDO" : "PIPELINES OK"
                            font.family: root.fontText
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            color: root.fluent ? (isCiFail ? "#E81123" : "#107C41") : (isCiFail ? (root.nothing ? root.skin.signal : "#FF453A") : (root.nothing ? root.skin.green : "#30D158"))
                        }

                    }

                }

            }

            // 2. Tarjeta de Mapa de Calor 7 Días
            Rectangle {
                Layout.fillWidth: true
                height: 52
                radius: root.fluent ? 6 : (root.nothing ? 16 : 12)
                color: root.fluent ? root.skin.cardAlt : (root.nothing ? root.skin.raised : Qt.rgba(1, 1, 1, 0.05))
                border.color: root.fluent ? root.skin.cardBorder : (root.nothing ? "transparent" : Qt.rgba(1, 1, 1, 0.08))
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
                            font.family: root.fontText
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            color: root.nothing ? root.skin.ink : "#FFFFFF"
                        }

                        Text {
                            text: "Registro de actividad"
                            font.family: root.fontText
                            font.pixelSize: 9
                            color: root.nothing ? root.skin.inkDim : (root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.5))
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
                                    radius: root.fluent ? 3 : (root.nothing ? width / 2 : 3.5)
                                    color: {
                                        var lvl = modelData.level !== undefined ? modelData.level : 0;
                                        if (root.fluent) {
                                            if (lvl === 4) return "#2ea043";
                                            if (lvl === 3) return "#238636";
                                            if (lvl === 2) return "#196127";
                                            if (lvl === 1) return "#0e4429";
                                            return "rgba(255, 255, 255, 0.06)";
                                        }
                                        if (root.nothing) {
                                            if (lvl === 4) return root.skin.green;
                                            if (lvl === 3) return Qt.rgba(0, 0.90, 0.60, 0.75);
                                            if (lvl === 2) return Qt.rgba(0, 0.90, 0.60, 0.50);
                                            if (lvl === 1) return Qt.rgba(0, 0.90, 0.60, 0.25);
                                            return root.skin.dotOff;
                                        }
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
                                    border.color: root.fluent ? root.skin.cardBorder : (root.nothing ? "transparent" : (root.widgetsState && root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.10)" : "rgba(0,0,0,0.08)"))
                                    border.width: 0.5
                                }

                                Text {
                                    Layout.alignment: Qt.AlignHCenter
                                    text: modelData.day_letter || "-"
                                    font.family: root.fontText
                                    font.pixelSize: 8
                                    font.weight: Font.Bold
                                    color: root.nothing ? root.skin.inkDim : (root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.6))
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
                    color: root.nothing ? root.skin.ink : (root.widgetsState ? root.widgetsState.accentBlue : "#007AFF")
                }

                Text {
                    text: "COMMITS RECIENTES"
                    font.family: root.fontText
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    font.letterSpacing: 0.5
                    color: root.nothing ? root.skin.inkDim : (root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.6))
                }

            }

            // 4. Lista de commits recientes
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 6
                model: root.widgetsState && root.widgetsState.gitRecentCommits.length > 0 ? root.widgetsState.gitRecentCommits : (root.widgetsState && root.widgetsState.gitLatestCommit ? [root.widgetsState.gitLatestCommit] : [])

                delegate: Rectangle {
                    width: parent ? parent.width : 326
                    height: 48
                    radius: root.fluent ? 6 : (root.nothing ? 14 : 10)
                    color: root.fluent ? root.skin.cardAlt : (root.nothing ? root.skin.raised : Qt.rgba(1, 1, 1, 0.05))
                    border.color: root.fluent ? root.skin.cardBorder : (root.nothing ? "transparent" : Qt.rgba(1, 1, 1, 0.07))
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
                                radius: root.fluent ? 4 : 8
                                implicitWidth: repoTxt.implicitWidth + 8
                                color: root.fluent ? Qt.rgba(0, 120 / 255, 212 / 255, 0.15) : (root.nothing ? root.skin.card : Qt.rgba(0, 122 / 255, 255 / 255, 0.18))

                                Text {
                                    id: repoTxt

                                    anchors.centerIn: parent
                                    text: modelData.repo || "Lunita-Dots"
                                    font.family: root.fontText
                                    font.pixelSize: 9
                                    font.weight: Font.Bold
                                    color: root.fluent ? "#0078D4" : (root.nothing ? root.skin.ink : "#0A84FF")
                                }

                            }

                            Text {
                                text: modelData.hash || "abc1234"
                                font.family: root.nothing ? root.fontFigure : "JetBrains Mono"
                                font.pixelSize: 9
                                font.weight: Font.Bold
                                color: root.nothing ? root.skin.inkDim : (root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.6))
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            Text {
                                text: modelData.relative_time || "reciente"
                                font.family: root.fontText
                                font.pixelSize: 9
                                color: root.nothing ? root.skin.inkDim : (root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.5))
                            }

                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.message || "Commit sin mensaje"
                            font.family: root.fontText
                            font.pixelSize: 10
                            font.weight: Font.Normal
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            color: root.nothing ? root.skin.ink : "#FFFFFF"
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
