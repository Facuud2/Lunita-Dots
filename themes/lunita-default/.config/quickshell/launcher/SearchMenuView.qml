import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

Item {
    id: root

    required property var launcherState

    function launchCurrent() {
        if (launcherState.filteredApps.length > 0) {
            var selectedApp = launcherState.filteredApps[launcherState.searchSelectedIndex];
            launcherState.launchSelectedApp(selectedApp);
        }
    }

    implicitHeight: 310
    width: parent.width
    Component.onCompleted: {
        searchInput.forceActiveFocus();
    }

    Timer {
        id: focusTimer

        interval: 30
        running: true
        repeat: false
        onTriggered: searchInput.forceActiveFocus()
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // ── Inputbar estilo Nothing OS ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                Layout.preferredWidth: 84
                Layout.preferredHeight: 38
                radius: 8
                color: backMouseArea.containsMouse ? launcherState.cellHoverBg : launcherState.accentColor
                border.width: 1
                border.color: backMouseArea.containsMouse ? launcherState.accentColor : "transparent"

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: "\uf060"
                        font.family: launcherState.fontSymbols
                        font.pixelSize: 14
                        color: backMouseArea.containsMouse ? launcherState.accentColor : launcherState.accentFg
                    }

                    Text {
                        text: "Volver"
                        font.family: launcherState.fontComfortaa
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        color: backMouseArea.containsMouse ? launcherState.fgColor : launcherState.accentFg
                    }

                }

                MouseArea {
                    id: backMouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: launcherState.closeSearch()
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }

                }

            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                radius: 8
                color: launcherState.cellBg
                border.width: 1
                border.color: searchInput.activeFocus ? launcherState.accentColor : launcherState.cellBorder

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 10

                    Text {
                        text: "\ue9cc"
                        font.family: launcherState.fontFeather
                        font.pixelSize: 16
                        color: searchInput.activeFocus ? launcherState.accentColor : launcherState.fgDimColor
                    }

                    TextInput {
                        id: searchInput

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        verticalAlignment: TextInput.AlignVCenter
                        color: launcherState.fgColor
                        font.family: launcherState.fontComfortaa
                        font.pixelSize: 12
                        clip: true
                        text: launcherState.searchQuery
                        onTextChanged: {
                            launcherState.searchQuery = text;
                        }
                        Keys.onDownPressed: {
                            if (launcherState.filteredApps.length > 0) {
                                launcherState.searchSelectedIndex = Math.min(launcherState.filteredApps.length - 1, launcherState.searchSelectedIndex + 1);
                                appList.positionViewAtIndex(launcherState.searchSelectedIndex, ListView.Contain);
                            }
                        }
                        Keys.onUpPressed: {
                            if (launcherState.filteredApps.length > 0) {
                                launcherState.searchSelectedIndex = Math.max(0, launcherState.searchSelectedIndex - 1);
                                appList.positionViewAtIndex(launcherState.searchSelectedIndex, ListView.Contain);
                            }
                        }
                        Keys.onReturnPressed: root.launchCurrent()
                        Keys.onEnterPressed: root.launchCurrent()
                        Keys.onPressed: function(event) {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                root.launchCurrent();
                                event.accepted = true;
                            }
                        }
                        Keys.onEscapePressed: {
                            if (launcherState.searchQuery !== "")
                                launcherState.searchQuery = "";

                            launcherState.closeSearch();
                        }

                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            visible: !searchInput.text
                            text: "Buscar aplicaciones…"
                            color: launcherState.fgFaintColor
                            font.family: launcherState.fontComfortaa
                            font.pixelSize: 12
                        }

                    }

                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: 140
                    }

                }

            }

        }

        // ── Lista de Resultados Estilo Nothing OS ──
        ListView {
            id: appList

            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 3
            model: launcherState.filteredApps

            Text {
                anchors.centerIn: parent
                visible: launcherState.filteredApps.length === 0
                text: "No se encontraron aplicaciones"
                font.family: launcherState.fontComfortaa
                font.pixelSize: 12
                color: launcherState.fgFaintColor
            }

            delegate: Rectangle {
                id: rowDelegate

                required property int index
                required property var modelData
                readonly property bool isSelected: launcherState.searchSelectedIndex === rowDelegate.index
                readonly property bool isHovered: rowMouseArea.containsMouse

                width: appList.width
                height: 40
                radius: 8
                color: isSelected ? launcherState.accentColor : isHovered ? launcherState.cellHoverBg : "transparent"
                border.width: isSelected ? 1 : 0
                border.color: launcherState.accentColor

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 12

                    Item {
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        Layout.alignment: Qt.AlignVCenter

                        Image {
                            id: appIconImg

                            anchors.fill: parent
                            anchors.margins: 1
                            source: {
                                var ic = rowDelegate.modelData.icon;
                                if (!ic)
                                    return "image://icon/application-x-executable";

                                if (ic.startsWith("/") || ic.startsWith("file://") || ic.startsWith("image://"))
                                    return ic;

                                return "image://icon/" + ic;
                            }
                            sourceSize: Qt.size(48, 48)
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            mipmap: true
                        }

                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 8

                        Text {
                            text: rowDelegate.modelData.name || ""
                            font.family: launcherState.fontComfortaa
                            font.pixelSize: 12
                            font.weight: rowDelegate.isSelected ? Font.Bold : Font.DemiBold
                            color: rowDelegate.isSelected ? launcherState.accentFg : launcherState.fgColor
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }

                        Text {
                            text: rowDelegate.modelData.generic || ""
                            visible: text !== ""
                            Layout.fillWidth: true
                            font.family: launcherState.fontComfortaa
                            font.pixelSize: 10
                            color: rowDelegate.isSelected ? Qt.rgba(launcherState.accentFg.r, launcherState.accentFg.g, launcherState.accentFg.b, 0.7) : launcherState.fgDimColor
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }

                    }

                    Rectangle {
                        visible: rowDelegate.isSelected
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20
                        radius: 4
                        color: Qt.rgba(launcherState.accentFg.r, launcherState.accentFg.g, launcherState.accentFg.b, 0.2)
                        Layout.alignment: Qt.AlignVCenter

                        Text {
                            anchors.centerIn: parent
                            text: "↵"
                            font.family: launcherState.fontComfortaa
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: launcherState.accentFg
                        }

                    }

                }

                MouseArea {
                    id: rowMouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        launcherState.searchSelectedIndex = rowDelegate.index;
                        launcherState.launchSelectedApp(rowDelegate.modelData);
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 100
                    }

                }

            }

        }

    }

}
