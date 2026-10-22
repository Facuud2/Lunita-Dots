import "."
import QtQuick

// panel de sonido: elegir salida y entrada
Item {
    id: popup

    readonly property var sinks: Audio.sinks
    readonly property var sources: Audio.sources

    signal closed()

    function label(node) {
        if (!node)
            return Cfg.t("Desconocido");

        return node.description ? node.description : (node.name ? node.name : Cfg.t("Desconocido"));
    }

    implicitHeight: col.implicitHeight + 44
    // mientras el panel está abierto, Audio refresca la lista de aparatos
    Component.onCompleted: {
        Audio.watchers++;
        Audio.refreshDevices();
    }
    Component.onDestruction: Audio.watchers--

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
                text: Cfg.t("SONIDO")
                color: Theme.fgFaint
                font.family: Theme.font
                font.pixelSize: Theme.labelSmall
                font.letterSpacing: Theme.labelSpacing
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
                    text: "close"
                    color: closeMa.containsMouse ? Theme.fg : Theme.fgDim
                    font.family: Theme.fontIcons
                    font.pixelSize: 15
                }

                MouseArea {
                    id: closeMa

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: popup.closed()
                }

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.durShort
                    }

                }

            }

        }

        // ── volumen de la salida activa ──
        Rectangle {
            id: volCard

            readonly property real vol: Audio.volume
            readonly property bool muted: Audio.muted
            readonly property real maxVolume: 1

            width: parent.width
            height: 56
            radius: Theme.shapeLg
            color: Theme.surfaceAlt
            border.width: 1
            border.color: Theme.outline

            Text {
                id: volIcon

                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                text: volCard.muted ? "volume_off" : "volume_up"
                color: volCard.muted ? Theme.outline : Theme.fg
                font.family: Theme.fontIcons
                font.pixelSize: 20

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Audio.toggleMute()
                }

            }

            Text {
                id: volNum

                anchors.right: parent.right
                anchors.rightMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                width: 36
                horizontalAlignment: Text.AlignRight
                text: volCard.muted ? "0" : Math.min(100, Math.round(volCard.vol * 100))
                color: Theme.fg
                font.family: Theme.fontDots
                font.pixelSize: 17
                font.weight: Font.Bold
            }

            Rectangle {
                id: track

                anchors.left: volIcon.right
                anchors.leftMargin: 12
                anchors.right: volNum.left
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                height: 6
                radius: 3
                color: Theme.surfaceHigh

                Rectangle {
                    width: track.width * (volCard.muted ? 0 : Math.min(volCard.vol, 1))
                    height: parent.height
                    radius: parent.radius
                    color: Theme.fg
                }

                MouseArea {
                    function apply(mx) {
                        Audio.setVolume(Math.max(0, Math.min(1, mx / track.width)));
                    }

                    anchors.fill: parent
                    anchors.margins: -8
                    cursorShape: Qt.PointingHandCursor
                    onPressed: (mouse) => {
                        Audio.holding = true;
                        apply(mouse.x);
                    }
                    onPositionChanged: (mouse) => {
                        if (pressed)
                            apply(mouse.x);

                    }
                    onReleased: Audio.holding = false
                }

            }

        }

        // ── salida ──
        SectionLabel {
            text: Cfg.t("SALIDA")
        }

        Column {
            width: parent.width
            spacing: 2

            Repeater {
                model: popup.sinks

                DeviceRow {
                    required property var modelData

                    node: modelData
                    isOutput: true
                }

            }

            Text {
                width: parent.width
                visible: popup.sinks.length === 0
                horizontalAlignment: Text.AlignHCenter
                topPadding: 8
                bottomPadding: 8
                text: Cfg.t("Sin salidas")
                color: Theme.outline
                font.family: Theme.font
                font.pixelSize: Theme.bodySmall
            }

        }

        // ── entrada ──
        SectionLabel {
            text: Cfg.t("ENTRADA")
        }

        Column {
            width: parent.width
            spacing: 2

            Repeater {
                model: popup.sources

                DeviceRow {
                    required property var modelData

                    node: modelData
                    isOutput: false
                }

            }

            Text {
                width: parent.width
                visible: popup.sources.length === 0
                horizontalAlignment: Text.AlignHCenter
                topPadding: 8
                bottomPadding: 8
                text: Cfg.t("Sin entradas")
                color: Theme.outline
                font.family: Theme.font
                font.pixelSize: Theme.bodySmall
            }

        }

        // ── fila reutilizable de dispositivo ──
        component DeviceRow: Rectangle {
            id: dr

            property var node: null
            property bool isOutput: true
            readonly property bool current: {
                if (!dr.node)
                    return false;

                var nodeId = String(dr.node.id !== undefined ? dr.node.id : "");
                var nodeName = String(dr.node.name || "");
                if (dr.isOutput)
                    return (nodeId !== "" && Audio.defaultSink === nodeId) || (nodeName !== "" && Audio.defaultSink === nodeName);
                else
                    return (nodeId !== "" && Audio.defaultSource === nodeId) || (nodeName !== "" && Audio.defaultSource === nodeName);
            }

            width: col.width
            height: 42
            radius: Theme.shapeMd
            color: dr.current ? Theme.inverted : drMa.containsMouse ? Qt.alpha(Theme.fg, Theme.stateHover) : Qt.alpha(Theme.fg, 0)
            border.width: dr.current ? 1 : (drMa.containsMouse ? 1 : 0)
            border.color: dr.current ? Theme.inverted : Theme.outline

            Text {
                id: drIcon

                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    var nodeType = dr.node ? dr.node.type : "";
                    if (nodeType === "headphones")
                        return "headphones";

                    if (nodeType === "hdmi")
                        return "tv";

                    if (nodeType === "mic")
                        return "mic";

                    var nodeName = dr.node && dr.node.name ? dr.node.name : "";
                    var nodeDesc = dr.node && dr.node.description ? dr.node.description : "";
                    const n = (nodeName + " " + nodeDesc).toLowerCase();
                    if (n.includes("bluez") || n.includes("anc") || n.includes("head") || n.includes("buds"))
                        return "headphones";

                    if (n.includes("hdmi") || n.includes("tv"))
                        return "tv";

                    return dr.isOutput ? "speaker" : "mic";
                }
                color: dr.current ? Theme.invertedFg : Theme.fgFaint
                font.family: Theme.fontIcons
                font.pixelSize: 18
            }

            Text {
                anchors.left: drIcon.right
                anchors.leftMargin: 10
                anchors.right: drCheck.left
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                text: popup.label(dr.node)
                color: dr.current ? Theme.invertedFg : Theme.fg
                font.family: Theme.font
                font.pixelSize: Theme.bodySmall
                font.weight: dr.current ? Font.Medium : Font.Normal
                elide: Text.ElideRight
            }

            Text {
                id: drCheck

                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                visible: dr.current
                text: "check"
                color: Theme.invertedFg
                font.family: Theme.fontIcons
                font.pixelSize: 16
            }

            MouseArea {
                id: drMa

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (!dr.node)
                        return ;

                    if (dr.isOutput)
                        Audio.setDefaultSink(dr.node.id !== undefined ? dr.node.id : dr.node.name);
                    else
                        Audio.setDefaultSource(dr.node.id !== undefined ? dr.node.id : dr.node.name);
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: Theme.durShort
                }

            }

        }

        component SectionLabel: Text {
            color: Theme.outline
            font.family: Theme.font
            font.pixelSize: Theme.labelSmall
            font.weight: Font.Medium
            font.letterSpacing: 0.6
        }

    }

}
