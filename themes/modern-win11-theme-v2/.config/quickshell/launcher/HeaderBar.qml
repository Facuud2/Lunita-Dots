import QtQuick
import QtQuick.Controls

Item {
    id: root

    required property var launcherState
    property alias searchInputField: searchInput

    width: parent ? parent.width : 592
    height: 42

    Rectangle {
        id: searchContainer

        anchors.fill: parent
        radius: 8
        color: root.launcherState.searchBgColor
        border.color: searchInput.activeFocus ? root.launcherState.accentColor : root.launcherState.searchBorderColor
        border.width: 1

        // Windows 11 Fluent active focus indicator bar at bottom
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            width: searchInput.activeFocus ? parent.width - 8 : 0
            height: 2
            radius: 1
            color: root.launcherState.accentColor
            visible: width > 0

            Behavior on width {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutQuad
                }

            }

        }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 12

            // Windows 11 Cyan Search Icon
            Image {
                source: Qt.resolvedUrl("assets/icons/win11-search.svg")
                width: 18
                height: 18
                anchors.verticalCenter: parent.verticalCenter
                fillMode: Image.PreserveAspectFit
                smooth: true
            }

            // Search Text Field
            Item {
                width: parent.width - 56
                height: parent.height

                TextInput {
                    id: searchInput

                    anchors.fill: parent
                    verticalAlignment: TextInput.AlignVCenter
                    color: root.launcherState.searchTextColor
                    font.pixelSize: 13
                    font.weight: Font.Normal
                    font.italic: false
                    font.family: "Segoe UI Variable, Segoe UI, Inter, sans-serif"
                    clip: true
                    text: root.launcherState.searchQuery
                    onTextChanged: root.launcherState.searchQuery = text
                    Keys.onReturnPressed: {
                        let filtered = root.launcherState.getFilteredApps();
                        if (filtered.length > 0)
                            root.launcherState.launchApp(filtered[0]);

                    }
                    Keys.onEscapePressed: {
                        if (text.length > 0)
                            text = "";
                        else
                            root.launcherState.closeLauncher();
                    }

                    Text {
                        text: "Buscar aplicaciones, configuraciones y documentos"
                        color: root.launcherState.searchPlaceholderColor
                        font: parent.font
                        visible: !parent.text
                        anchors.verticalCenter: parent.verticalCenter
                    }

                }

            }

            // Clear Button (✕)
            Rectangle {
                visible: searchInput.text.length > 0
                width: 20
                height: 20
                radius: 10
                color: clearMouse.containsMouse ? root.launcherState.appActiveBg : "transparent"
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: "✕"
                    color: root.launcherState.headerSubColor
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    anchors.centerIn: parent
                }

                MouseArea {
                    id: clearMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        searchInput.text = "";
                        searchInput.forceActiveFocus();
                    }
                }

            }

        }

        Behavior on border.color {
            ColorAnimation {
                duration: 150
            }

        }

    }

}
