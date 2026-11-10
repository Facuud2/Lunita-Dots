import QtQuick
import QtQuick.Controls

Item {
    id: root

    required property var launcherState
    property var appsList: []
    property string viewTitle: ""

    width: parent ? parent.width : 580
    height: parent ? parent.height : 520

    Column {
        anchors.fill: parent
        spacing: 12

        // Header Row with Back Button and Title
        Item {
            width: parent.width
            height: 28
            visible: root.launcherState.activeViewMode === "detail"

            Rectangle {
                anchors.left: parent.left
                width: backLabel.implicitWidth + 20
                height: 28
                radius: 6
                color: backMouse.containsMouse ? root.launcherState.appHoverBg : "transparent"

                Row {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: "‹"
                        color: root.launcherState.accentColor
                        font.pixelSize: 16
                        font.weight: Font.Bold
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        id: backLabel

                        text: "Volver a Inicio"
                        color: root.launcherState.headerTitleColor
                        font.pixelSize: 12
                        font.family: "Segoe UI Variable Text, Segoe UI, Inter, sans-serif"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                }

                MouseArea {
                    id: backMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.launcherState.backToStandard()
                }

            }

            Text {
                text: root.viewTitle
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                color: root.launcherState.headerSubColor
                font.pixelSize: 13
                font.weight: Font.DemiBold
                font.family: "Segoe UI Variable Text, Segoe UI, Inter, sans-serif"
            }

        }

        // Apps Grid Flickable
        Flickable {
            id: flick

            width: parent.width
            height: parent.height - (root.launcherState.activeViewMode === "detail" ? 40 : 0)
            contentWidth: width
            contentHeight: appsGrid.implicitHeight + 20
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Grid {
                id: appsGrid

                width: parent.width
                columns: 6
                spacing: Math.max(2, Math.floor((root.width - (6 * 94)) / 5))
                anchors.horizontalCenter: parent.horizontalCenter
                topPadding: 4
                bottomPadding: 16

                Repeater {
                    model: root.appsList

                    delegate: AppItem {
                        required property var modelData

                        launcherState: root.launcherState
                        app: modelData
                    }

                }

            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                width: 4
                anchors.right: flick.right
                anchors.rightMargin: 2
            }

        }

    }

}
