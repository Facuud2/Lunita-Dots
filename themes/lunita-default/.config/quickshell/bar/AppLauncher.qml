import QtQuick
import Quickshell
import Quickshell.Io
import "."

Item {
    id: root

    signal closed

    implicitHeight: col.implicitHeight

    readonly property int maxResults: 8
    property int selected: 0
    property var apps: []

    property var scanProc: Process {
        command: ["python3", Quickshell.env("HOME") + "/.config/quickshell/bar/scripts/apps.py"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                try {
                    root.apps = JSON.parse(data || "[]");
                } catch (e) {
                    root.apps = [];
                }
            }
        }
    }

    Component.onCompleted: {
        search.forceActiveFocus();
    }

    function quote(s) {
        return "'" + String(s).replace(/'/g, "'\\''") + "'";
    }

    readonly property var results: {
        const q = search.text.trim().toLowerCase();
        const scored = [];

        for (var i = 0; i < root.apps.length; i++) {
            const app = root.apps[i];
            const name = (app && app.name ? app.name : "").toLowerCase();
            const generic = (app && app.genericName ? app.genericName : "").toLowerCase();

            if (q === "") {
                scored.push({ app: app, score: 0 });
                continue;
            }

            let score = -1;
            if (name.startsWith(q))
                score = 100 - name.length;
            else if (name.includes(q))
                score = 50 - name.indexOf(q);
            else if (generic.includes(q))
                score = 20;

            if (score >= 0)
                scored.push({ app: app, score: score });
        }

        scored.sort((a, b) => {
            if (b.score !== a.score) return b.score - a.score;
            return ((a.app && a.app.name) ? a.app.name : "").localeCompare((b.app && b.app.name) ? b.app.name : "");
        });

        return scored.slice(0, root.maxResults).map(s => s.app);
    }

    onResultsChanged: selected = 0

    function launch() {
        const app = root.results[root.selected];
        if (app) {
            Exec.run("gio launch " + root.quote(app.path) + " 2>/dev/null || gtk-launch " + root.quote(app.desktop || app.name) + " 2>/dev/null &");
            root.closed();
        }
    }

    Column {
        id: col
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 10

        // ── barra de título ──
        Item {
            width: parent.width
            height: 26

            Text {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: Cfg.t("APLICACIONES")
                color: Theme.fgFaint
                font.family: Theme.fontUi
                font.pixelSize: 11
                font.letterSpacing: 1
            }

            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 26
                height: 26
                radius: height / 2
                color: closeMa.containsMouse ? Theme.surfaceHigh : Theme.surfaceAlt

                Text {
                    anchors.centerIn: parent
                    text: Icons.close
                    color: Theme.fgDim
                    font.family: Theme.fontIcon
                    font.pixelSize: 14
                }

                MouseArea {
                    id: closeMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.closed()
                }
            }
        }

        // ── campo de búsqueda ──
        Rectangle {
            width: parent.width
            height: 44
            radius: Theme.shapeLg
            color: Theme.surfaceAlt
            border.width: 1
            border.color: search.activeFocus ? Theme.accent : Theme.outline

            TextInput {
                id: search
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.fg
                font.family: Theme.fontUi
                font.pixelSize: 13
                clip: true

                Text {
                    anchors.fill: parent
                    visible: !search.text
                    text: Cfg.t("Buscar aplicaciones…")
                    color: Theme.fgDim
                    font.family: Theme.fontUi
                    font.pixelSize: 13
                }

                Keys.onReturnPressed: root.launch()
                Keys.onDownPressed: root.selected = Math.min(root.results.length - 1, root.selected + 1)
                Keys.onUpPressed: root.selected = Math.max(0, root.selected - 1)
                Keys.onEscapePressed: root.closed()
            }
        }

        // ── resultados ──
        Column {
            width: parent.width
            spacing: 2

            Repeater {
                model: root.results

                Rectangle {
                    id: row
                    required property int index
                    required property var modelData

                    width: col.width
                    height: 44
                    radius: Theme.shapeMd
                    color: root.selected === row.index ? Theme.surfaceHigh : rowMa.containsMouse ? Theme.surfaceAlt : "transparent"

                    Text {
                        id: rIcon
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: "apps"
                        color: Theme.fgDim
                        font.family: Theme.fontIcon
                        font.pixelSize: 20
                    }

                    Column {
                        anchors.left: rIcon.right
                        anchors.leftMargin: 10
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: row.modelData.name || ""
                            color: Theme.fg
                            font.family: Theme.fontUi
                            font.pixelSize: 12
                            font.weight: Font.Medium
                        }
                    }

                    MouseArea {
                        id: rowMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.selected = row.index;
                            root.launch();
                        }
                    }
                }
            }

            Item {
                width: parent.width
                height: 44
                visible: root.results.length === 0

                Text {
                    anchors.centerIn: parent
                    text: Cfg.t("Sin resultados")
                    color: Theme.fgFaint
                    font.family: Theme.fontUi
                    font.pixelSize: 12
                }
            }
        }
    }
}
