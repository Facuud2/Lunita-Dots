import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell

Item {
    id: root
    required property var dockState
    property var panelWindow: null

    implicitWidth: platterBg.width
    implicitHeight: platterBg.height
    width: implicitWidth
    height: implicitHeight


    // ── Glass Capsule Platter Background ──
    Rectangle {
        id: platterBg
        height: 64
        width: contentRow.implicitWidth + 20
        radius: 18
        clip: true

        // Multi-layer frosted liquid glass material
        color: "#30ffffff"
        border.color: "#52ffffff"
        border.width: 1

        // Inner specular highlight & glass sheen
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: 17
            color: "#0dffffff"
            border.color: "#38ffffff"
            border.width: 1
        }

        // Row of Dock Icons
        Row {
            id: contentRow
            anchors.centerIn: parent
            spacing: 2

            // 1. Pinned Applications
            Repeater {
                model: dockState.pinnedList
                DockItem {
                    dockState: root.dockState
                    panelWindow: root.panelWindow
                    app: modelData
                    itemIndex: index
                }
            }

            // 2. Running Unpinned Apps
            Repeater {
                model: dockState.runningList
                DockItem {
                    dockState: root.dockState
                    panelWindow: root.panelWindow
                    runningApp: modelData
                }
            }

            // 3. Add App (+) Button
            DockItem {
                dockState: root.dockState
                panelWindow: root.panelWindow
                isAdd: true
            }

            // 4. Vertical Divider
            Item {
                width: 10
                height: 48
                Rectangle {
                    width: 1
                    height: 34
                    radius: 1
                    color: "#38ffffff"
                    anchors.centerIn: parent
                }
            }

            // 5. Right Stacks (Shortcuts, Keychain)
            Repeater {
                model: dockState.rightStackApps
                DockItem {
                    dockState: root.dockState
                    panelWindow: root.panelWindow
                    app: modelData
                }
            }

            // 6. Downloads Folder
            DockItem {
                dockState: root.dockState
                panelWindow: root.panelWindow
                isFolder: true
            }

            // 7. Trash Can
            DockItem {
                dockState: root.dockState
                panelWindow: root.panelWindow
                isTrash: true
            }
        }
    }
}
