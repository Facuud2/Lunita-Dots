import QtQuick
import QtQuick.Controls

Item {
    id: root

    required property var launcherState

    width: 170
    height: 180

    Rectangle {
        id: flyoutBg
        anchors.fill: parent
        radius: 8
        color: Qt.rgba(24/255, 24/255, 28/255, 0.88)
        border.color: Qt.rgba(255, 255, 255, 0.12)
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: 6
            spacing: 2

            // Lock Action
            Rectangle {
                width: parent.width
                height: 32
                radius: 6
                color: lockMouse.containsMouse ? root.launcherState.appHoverBg : "transparent"

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    spacing: 10

                    Text {
                        text: "🔒"
                        font.pixelSize: 13
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Bloquear"
                        color: root.launcherState.appTitleColor
                        font.pixelSize: 12
                        font.family: "Adwaita Sans, sans-serif"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: lockMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.launcherState.powerAction("lock")
                }
            }

            // Sleep / Suspend Action
            Rectangle {
                width: parent.width
                height: 32
                radius: 6
                color: sleepMouse.containsMouse ? root.launcherState.appHoverBg : "transparent"

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    spacing: 10

                    Text {
                        text: "🌙"
                        font.pixelSize: 13
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Suspender"
                        color: root.launcherState.appTitleColor
                        font.pixelSize: 12
                        font.family: "Adwaita Sans, sans-serif"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: sleepMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.launcherState.powerAction("suspend")
                }
            }

            // Reboot Action
            Rectangle {
                width: parent.width
                height: 32
                radius: 6
                color: rebootMouse.containsMouse ? root.launcherState.appHoverBg : "transparent"

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    spacing: 10

                    Text {
                        text: "🔄"
                        font.pixelSize: 13
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Reiniciar"
                        color: root.launcherState.appTitleColor
                        font.pixelSize: 12
                        font.family: "Adwaita Sans, sans-serif"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: rebootMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.launcherState.powerAction("reboot")
                }
            }

            // Shutdown Action
            Rectangle {
                width: parent.width
                height: 32
                radius: 6
                color: shutdownMouse.containsMouse ? root.launcherState.appHoverBg : "transparent"

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    spacing: 10

                    Text {
                        text: "⏻"
                        font.pixelSize: 13
                        color: "#FF5555"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Apagar"
                        color: root.launcherState.appTitleColor
                        font.pixelSize: 12
                        font.family: "Adwaita Sans, sans-serif"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: shutdownMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.launcherState.powerAction("shutdown")
                }
            }

            // Sign out / Logout Action
            Rectangle {
                width: parent.width
                height: 32
                radius: 6
                color: logoutMouse.containsMouse ? root.launcherState.appHoverBg : "transparent"

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    spacing: 10

                    Text {
                        text: "🚪"
                        font.pixelSize: 13
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Cerrar sesión"
                        color: root.launcherState.appTitleColor
                        font.pixelSize: 12
                        font.family: "Adwaita Sans, sans-serif"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: logoutMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.launcherState.powerAction("logout")
                }
            }
        }
    }
}
