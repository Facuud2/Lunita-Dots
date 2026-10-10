import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property var launcherState

    // Dimensiones exactas de rofi applet southeast en el video: 500px de ancho
    implicitWidth: 500
    implicitHeight: launcherState.searchMode ? 390 : 155
    width: implicitWidth
    height: implicitHeight

    Behavior on implicitHeight {
        NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
    }

    opacity: launcherState.visualOpacity
    transform: Translate {
        x: launcherState.visualXOffset
    }

    // ── Ventana Principal (Estilo Rofi square con borde de acento) ──
    Rectangle {
        id: card
        anchors.fill: parent
        radius: 0
        color: launcherState.panelBg
        border.width: 2
        border.color: launcherState.accentColor
        clip: true

        // Absorbe clics dentro del cuerpo del launcher para no activar cierre
        MouseArea {
            anchors.fill: parent
            hoverEnabled: false
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12

            // ── Cabecera (Inputbar con prompt exacto del video) ──
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                visible: !launcherState.searchMode

                RowLayout {
                    anchors.fill: parent
                    spacing: 0

                    // Prefix Badge: [ textbox-prompt-colon ] con fondo de acento
                    Rectangle {
                        Layout.preferredHeight: parent.height
                        Layout.preferredWidth: badgeText.implicitWidth + 20
                        radius: 0
                        color: launcherState.accentColor

                        Behavior on Layout.preferredWidth {
                            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                        }

                        Text {
                            id: badgeText
                            anchors.centerIn: parent
                            text: launcherState.activeTab === "apps" ? "Apps" : "Quick Links"
                            font.family: launcherState.fontComfortaa
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            color: launcherState.accentFg
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: launcherState.switchTab(launcherState.activeTab === "apps" ? "links" : "apps")
                        }
                    }

                    // Prompt Box con borde de 2px a la derecha: "Open In : <browser>" o "Most Used | <ram>"
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: parent.height
                        radius: 0
                        color: launcherState.cellBg
                        border.width: 2
                        border.color: launcherState.accentColor

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 8

                            Text {
                                Layout.fillWidth: true
                                verticalAlignment: Text.AlignVCenter
                                text: {
                                    if (launcherState.activeTab === "apps") {
                                        return launcherState.ramUsageStr ? "Most Used  |  " + launcherState.ramUsageStr : "Most Used";
                                    } else {
                                        return "Open In : " + launcherState.defaultBrowser;
                                    }
                                }
                                font.family: launcherState.fontComfortaa
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                color: launcherState.fgColor
                                elide: Text.ElideRight
                            }

                            // Botón sutil para alternar vista Apps / Links
                            Text {
                                text: launcherState.activeTab === "apps" ? "⇄ Links" : "⇄ Apps"
                                font.family: launcherState.fontComfortaa
                                font.pixelSize: 10
                                color: tabSwitchMa.containsMouse ? launcherState.accentColor : launcherState.fgDimColor

                                MouseArea {
                                    id: tabSwitchMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: launcherState.switchTab(launcherState.activeTab === "apps" ? "links" : "apps")
                                }
                            }
                        }
                    }
                }
            }

            // ── Contenido (Apps / Quick Links / Búsqueda Drun con transición fluida) ──
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Vista de Búsqueda Drun
                Loader {
                    id: searchLoader
                    anchors.fill: parent
                    active: launcherState.searchMode
                    visible: launcherState.searchMode
                    opacity: launcherState.searchMode ? 1.0 : 0.0
                    Behavior on opacity {
                        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                    }
                    sourceComponent: SearchMenuView { launcherState: root.launcherState }
                }

                // Contenedor de Pestañas con transición deslizante horizontal fluida
                Item {
                    id: tabContentContainer
                    anchors.fill: parent
                    clip: true
                    visible: !launcherState.searchMode

                    // Vista Apps
                    AppsView {
                        id: appsViewItem
                        launcherState: root.launcherState
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: parent.width

                        opacity: launcherState.activeTab === "apps" ? 1.0 : 0.0
                        x: launcherState.activeTab === "apps" ? 0 : -parent.width * 0.4
                        visible: opacity > 0.001

                        Behavior on opacity {
                            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                        }
                        Behavior on x {
                            NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
                        }
                    }

                    // Vista Quick Links
                    QuickLinksView {
                        id: linksViewItem
                        launcherState: root.launcherState
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: parent.width

                        opacity: launcherState.activeTab === "links" ? 1.0 : 0.0
                        x: launcherState.activeTab === "links" ? 0 : parent.width * 0.4
                        visible: opacity > 0.001

                        Behavior on opacity {
                            NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                        }
                        Behavior on x {
                            NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
                        }
                    }
                }
            }
        }
    }
}
