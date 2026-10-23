import "."
import QtQuick

Item {
    id: popup

    readonly property int count: Notifs.count

    signal closed()

    implicitHeight: col.implicitHeight + 44

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
                text: Cfg.t("NOTIFICACIONES")
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
                    onClicked: popup.closed()
                }

            }

        }

        // ── botones silenciar y vaciar ──
        Row {
            width: parent.width
            spacing: 8

            Rectangle {
                width: (parent.width - 8) * 0.62
                height: 46
                radius: Theme.shapeLg
                color: Notifs.muted ? Theme.inverted : muteMa.containsMouse ? Theme.surfaceHigh : Theme.surfaceAlt
                border.width: 1
                border.color: Notifs.muted ? Theme.inverted : Theme.outline

                Row {
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Notifs.muted ? "notifications_off" : "notifications"
                        color: Notifs.muted ? Theme.invertedFg : Theme.fgDim
                        font.family: Theme.fontIcon
                        font.pixelSize: 19
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Notifs.muted ? Cfg.t("SILENCIADAS") : Cfg.t("SILENCIAR")
                        color: Notifs.muted ? Theme.invertedFg : Theme.fg
                        font.family: Theme.fontUi
                        font.pixelSize: 12
                        font.weight: Font.Medium
                    }

                }

                MouseArea {
                    id: muteMa

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Notifs.toggleMute()
                }

            }

            Rectangle {
                width: (parent.width - 8) * 0.38
                height: 46
                radius: Theme.shapeLg
                color: clearMa.containsMouse ? Theme.surfaceHigh : Theme.surfaceAlt
                border.width: 1
                border.color: Theme.outline
                opacity: popup.count > 0 ? 1 : 0.4

                Row {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Icons.clearAll
                        color: Theme.fgDim
                        font.family: Theme.fontIcon
                        font.pixelSize: 19
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: Cfg.t("VACIAR")
                        color: Theme.fg
                        font.family: Theme.fontUi
                        font.pixelSize: 12
                        font.weight: Font.Medium
                    }

                }

                MouseArea {
                    id: clearMa

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    enabled: popup.count > 0
                    onClicked: Notifs.clearAll()
                }

            }

        }

        Text {
            text: popup.count + (popup.count === 1 ? " EN LA BANDEJA" : " EN LA BANDEJA")
            color: Theme.outline
            font.family: Theme.fontUi
            font.pixelSize: 11
            font.weight: Font.Medium
            visible: popup.count > 0
        }

        // ── lista de notificaciones ──
        Column {
            width: parent.width
            spacing: 4

            Repeater {
                model: Notifs.list

                Rectangle {
                    id: nrow

                    required property int index
                    required property var modelData

                    width: col.width
                    height: 56
                    radius: Theme.shapeMd
                    color: nrowMa.containsMouse ? Theme.surfaceHigh : Theme.surfaceAlt
                    border.width: 1
                    border.color: nrowMa.containsMouse ? Theme.outline : Qt.alpha(Theme.outline, 0.4)

                    Text {
                        id: nicon

                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: Icons.bell
                        color: Theme.fgDim
                        font.family: Theme.fontIcon
                        font.pixelSize: 20
                    }

                    Column {
                        anchors.left: nicon.right
                        anchors.leftMargin: 10
                        anchors.right: delBtn.left
                        anchors.rightMargin: 6
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            width: parent.width
                            text: nrow.modelData.summary || nrow.modelData.appName || "Notificación"
                            color: Theme.fg
                            font.family: Theme.fontUi
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            text: nrow.modelData.body || ""
                            color: Theme.fgDim
                            font.family: Theme.fontUi
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }

                    }

                    Rectangle {
                        id: delBtn

                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        width: 24
                        height: 24
                        radius: 12
                        color: "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: Icons.close
                            color: Theme.fgDim
                            font.family: Theme.fontIcon
                            font.pixelSize: 14
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Notifs.dismissAt(nrow.index)
                        }

                    }

                    MouseArea {
                        id: nrowMa

                        anchors.fill: parent
                        hoverEnabled: true
                    }

                }

            }

            Item {
                width: parent.width
                height: 60
                visible: popup.count === 0

                Text {
                    anchors.centerIn: parent
                    text: Cfg.t("SIN NOTIFICACIONES")
                    color: Theme.fgFaint
                    font.family: Theme.fontUi
                    font.pixelSize: 11
                    font.letterSpacing: 1
                }

            }

        }

    }

}
