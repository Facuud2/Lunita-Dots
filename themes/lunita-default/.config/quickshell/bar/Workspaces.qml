import QtQuick
import Quickshell
import Quickshell.Hyprland
import "."

Item {
    id: root

    implicitWidth: dots.implicitWidth
    implicitHeight: dots.implicitHeight

    function activate(id) {
        if (!id) return;
        Hyprland.dispatch("workspace " + id);
    }

    function step(delta) {
        if (delta > 0) {
            Hyprland.dispatch("workspace m+1");
        } else {
            Hyprland.dispatch("workspace m-1");
        }
    }

    // Usar workspaces de Hyprland o lista estándar del 1 al 5
    readonly property var workspaceList: [1, 2, 3, 4, 5]
    readonly property int activeWsId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1

    Row {
        id: dots
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Repeater {
            model: root.workspaceList

            Rectangle {
                required property int index
                required property var modelData

                readonly property bool focused: root.activeWsId === modelData

                width: focused ? 22 : 8
                height: 8
                radius: height / 2
                anchors.verticalCenter: parent.verticalCenter
                color: focused ? Theme.primary : Theme.containerHighest

                Behavior on width {
                    NumberAnimation {
                        duration: Theme.durMedium
                        easing.type: Easing.Bezier
                        easing.bezierCurve: Theme.emphasized
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: Theme.durShort
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -4
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.activate(parent.modelData)
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -4
        acceptedButtons: Qt.NoButton
        onWheel: wheel => root.step(wheel.angleDelta.y > 0 ? -1 : 1)
    }
}
