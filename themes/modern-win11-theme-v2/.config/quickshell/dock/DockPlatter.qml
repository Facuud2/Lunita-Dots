import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    required property var dockState
    property var panelWindow: null

    readonly property real targetWidth: contentRow.implicitWidth + 28
    width: targetWidth
    height: 52
    implicitWidth: width
    implicitHeight: height
    radius: 26

    // Pure Transparent Liquid Glass Base
    color: Qt.rgba(1.0, 1.0, 1.0, 0.04)
    border.color: Qt.rgba(1.0, 1.0, 1.0, 0.18)
    border.width: 1



    Row {
        id: contentRow
        anchors.left: parent.left
        anchors.leftMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4

        // 1. Windows Start Button (Always present)
        DockItem {
            app: root.dockState.startApp
            dockState: root.dockState
            panelWindow: root.panelWindow
            itemIndex: 0
        }

        // 2. Windows 11 Pinned Apps (Permanent delegates, in-place state updates)
        Repeater {
            model: root.dockState.pinnedAppsModel
            DockItem {
                app: model
                dockState: root.dockState
                panelWindow: root.panelWindow
                itemIndex: index + 1
            }
        }

        // 3. Real-Time Open Running Unpinned Apps (Dynamic with smooth enter/exit animations)
        Repeater {
            model: root.dockState.unpinnedAppsModel
            DockItem {
                app: model
                dockState: root.dockState
                panelWindow: root.panelWindow
                itemIndex: root.dockState.pinnedAppsModel.count + index + 1
            }
        }
    }
}
