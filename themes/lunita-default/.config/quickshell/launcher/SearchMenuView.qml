import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

Item {
    id: root

    required property var launcherState

    implicitHeight: 310
    width: parent.width

    Component.onCompleted: {
        searchInput.forceActiveFocus();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        // ── Inputbar estilo Rofi Slate ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            Rectangle {
                Layout.preferredWidth: 84
                Layout.preferredHeight: 36
                radius: 0
                color: backMouseArea.containsMouse ? launcherState.cellHoverBg : launcherState.accentColor

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: ""
                        font.family: launcherState.fontFeather
                        font.pixelSize: 14
                        color: backMouseArea.containsMouse ? launcherState.accentColor : launcherState.accentFg
                    }

                    Text {
                        text: "Back"
                        font.family: launcherState.fontComfortaa
                        font.pixelSize: 11
                        font.weight: Font.Bold
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
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                radius: 0
                color: launcherState.cellBg
                border.width: 2
                border.color: searchInput.activeFocus ? launcherState.accentColor : launcherState.cellBorder

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    Text {
                        text: "\ue9cc"
                        font.family: launcherState.fontFeather
                        font.pixelSize: 15
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

                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            visible: !searchInput.text
                            text: "Search Applications…"
                            color: launcherState.fgFaintColor
                            font.family: launcherState.fontComfortaa
                            font.pixelSize: 12
                        }

                        Keys.onDownPressed: {
                            if (launcherState.filteredApps.length > 0) {
                                launcherState.searchSelectedIndex = Math.min(
                                    launcherState.filteredApps.length - 1, 
                                    launcherState.searchSelectedIndex + 1
                                );
                                appList.positionViewAtIndex(launcherState.searchSelectedIndex, ListView.Contain);
                            }
                        }

                        Keys.onUpPressed: {
                            if (launcherState.filteredApps.length > 0) {
                                launcherState.searchSelectedIndex = Math.max(0, launcherState.searchSelectedIndex - 1);
                                appList.positionViewAtIndex(launcherState.searchSelectedIndex, ListView.Contain);
                            }
                        }

                        Keys.onReturnPressed: {
                            if (launcherState.filteredApps.length > 0) {
                                var selectedApp = launcherState.filteredApps[launcherState.searchSelectedIndex];
                                launcherState.launchSelectedApp(selectedApp);
                            }
                        }

                        Keys.onEscapePressed: {
                            if (launcherState.searchQuery !== "") {
                                launcherState.searchQuery = "";
                            }
                            launcherState.closeSearch();
                        }
                    }
                }
            }
        }

        // ── Lista de Resultados Cuadrada ──
        ListView {
            id: appList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 2
            model: launcherState.filteredApps

            delegate: Rectangle {
                id: rowDelegate
                required property int index
                required property var modelData

                width: appList.width
                height: 38
                radius: 0

                readonly property bool isSelected: launcherState.searchSelectedIndex === rowDelegate.index
                readonly property bool isHovered: rowMouseArea.containsMouse

                color: isSelected 
                    ? launcherState.accentColor 
                    : isHovered 
                        ? launcherState.cellHoverBg 
                        : launcherState.cellBg

                Behavior on color { ColorAnimation { duration: 100 } }

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
                                if (!ic) return "image://icon/application-x-executable";
                                if (ic.startsWith("/") || ic.startsWith("file://") || ic.startsWith("image://")) return ic;
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
                            color: rowDelegate.isSelected ? Qt.rgba(launcherState.accentFg.r, launcherState.accentFg.g, launcherState.accentFg.b, 0.70) : launcherState.fgDimColor
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Text {
                        text: "↵"
                        visible: rowDelegate.isSelected
                        font.family: launcherState.fontComfortaa
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        color: launcherState.accentFg
                        Layout.alignment: Qt.AlignVCenter
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
            }

            Text {
                anchors.centerIn: parent
                visible: launcherState.filteredApps.length === 0
                text: "No applications found"
                font.family: launcherState.fontComfortaa
                font.pixelSize: 12
                color: launcherState.fgFaintColor
            }
        }
    }
}
