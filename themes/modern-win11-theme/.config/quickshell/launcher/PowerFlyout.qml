import QtQuick
import QtQuick.Controls

Item {
    id: root

    required property var launcherState

    width: 190
    implicitWidth: 190
    implicitHeight: flyoutCol.implicitHeight + 14
    height: implicitHeight

    Rectangle {
        id: flyoutBg

        anchors.fill: parent
        radius: 8
        color: Qt.rgba(0.12, 0.13, 0.16, 0.94)
        border.color: Qt.rgba(1, 1, 1, 0.14)
        border.width: 1

        // Ambient contact shadow
        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: 9
            color: "transparent"
            border.color: Qt.rgba(0, 0, 0, 0.4)
            border.width: 1
            z: -1
        }

        Column {
            id: flyoutCol

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 6
            spacing: 2

            // Lock Action
            PowerItemBtn {
                label: "Bloquear"
                iconSrc: Qt.resolvedUrl("assets/icons/lock.svg")
                onTriggered: root.launcherState.powerAction("lock")
            }

            // Sleep / Suspend Action
            PowerItemBtn {
                label: "Suspender"
                iconSrc: Qt.resolvedUrl("assets/icons/moon.svg")
                onTriggered: root.launcherState.powerAction("suspend")
            }

            // Reboot Action
            PowerItemBtn {
                label: "Reiniciar"
                iconSrc: Qt.resolvedUrl("assets/icons/reload.svg")
                onTriggered: root.launcherState.powerAction("reboot")
            }

            // Shutdown Action
            PowerItemBtn {
                label: "Apagar"
                iconSrc: Qt.resolvedUrl("assets/icons/win11-power.svg")
                isDanger: true
                onTriggered: root.launcherState.powerAction("shutdown")
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(1, 1, 1, 0.1)
                anchors.leftMargin: 6
                anchors.rightMargin: 6
            }

            // Sign out / Logout Action
            PowerItemBtn {
                label: "Cerrar sesión"
                iconSrc: Qt.resolvedUrl("assets/icons/logout.svg")
                onTriggered: root.launcherState.powerAction("logout")
            }

        }

    }

    component PowerItemBtn: Rectangle {
        id: btnRoot

        property string label: ""
        property var iconSrc: ""
        property bool isDanger: false

        signal triggered()

        width: parent ? parent.width : 178
        height: 32
        radius: 6
        color: btnMouse.containsMouse ? (btnRoot.isDanger ? Qt.rgba(1, 0.23, 0.23, 0.2) : Qt.rgba(1, 1, 1, 0.08)) : "transparent"
        border.width: btnMouse.containsMouse ? 1 : 0
        border.color: btnRoot.isDanger ? Qt.rgba(1, 0.23, 0.23, 0.35) : Qt.rgba(1, 1, 1, 0.08)

        Row {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 10

            Image {
                source: btnRoot.iconSrc
                width: 14
                height: 14
                sourceSize.width: 14
                sourceSize.height: 14
                anchors.verticalCenter: parent.verticalCenter
                fillMode: Image.PreserveAspectFit
                smooth: true
                opacity: btnMouse.containsMouse ? 1 : 0.85
            }

            Text {
                text: btnRoot.label
                color: btnRoot.isDanger && btnMouse.containsMouse ? "#FF6B6B" : "#FFFFFF"
                font.pixelSize: 12
                font.weight: Font.Normal
                font.family: "Segoe UI Variable, Segoe UI, Inter, sans-serif"
                anchors.verticalCenter: parent.verticalCenter
                elide: Text.ElideRight
            }

        }

        MouseArea {
            id: btnMouse

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btnRoot.triggered()
        }

        Behavior on color {
            ColorAnimation {
                duration: 100
            }

        }

    }

}
