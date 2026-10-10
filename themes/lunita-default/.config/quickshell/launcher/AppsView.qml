import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property var launcherState

    implicitHeight: 75
    width: parent.width

    // Lista de accesos directos de AppsView
    readonly property var quickApps: [
        { label: "Search", icon: "\ue9cc", font: launcherState.fontFeather, isSearch: true, cmd: "" },
        { label: "Terminal", icon: "", font: launcherState.fontFeather, isSearch: false, cmd: "kitty" },
        { label: "Files", icon: "", font: launcherState.fontFeather, isSearch: false, cmd: "dolphin" },
        { label: "Editor", icon: "", font: launcherState.fontFeather, isSearch: false, cmd: "antigravity || code" },
        { label: "Browser", icon: "", font: launcherState.fontSymbols, isSearch: false, cmd: "zen-browser || firefox" },
        { label: "Music", icon: "", font: launcherState.fontSymbols, isSearch: false, cmd: "spotify" }
    ]

    function activateIndex(idx) {
        if (idx < 0 || idx >= quickApps.length) return;
        const item = quickApps[idx];
        if (item.isSearch) {
            launcherState.openSearch("");
        } else {
            launcherState.launchCommand(item.cmd);
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 12

        Repeater {
            model: root.quickApps

            Rectangle {
                id: cell
                required property int index
                required property var modelData

                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 0 // Rofi square: sharp rectangular 0px

                readonly property bool isSelected: launcherState.selectedIndex === cell.index
                readonly property bool isHovered: cellMouseArea.containsMouse

                color: isSelected 
                    ? launcherState.accentColor 
                    : isHovered 
                        ? launcherState.cellHoverBg 
                        : launcherState.cellBg

                Behavior on color { ColorAnimation { duration: 100 } }

                scale: isSelected ? 1.04 : isHovered ? 1.02 : 1.0
                Behavior on scale {
                    NumberAnimation { duration: 140; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
                }

                // Glifo centrado (Symbols Nerd Font 20 / Feather como en el video)
                Text {
                    anchors.centerIn: parent
                    text: cell.modelData.icon
                    font.family: cell.modelData.font
                    font.pixelSize: 22
                    color: cell.isSelected ? launcherState.accentFg : cell.isHovered ? launcherState.accentColor : launcherState.fgColor
                }

                MouseArea {
                    id: cellMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: launcherState.selectedIndex = cell.index
                    onClicked: {
                        launcherState.selectedIndex = cell.index;
                        root.activateIndex(cell.index);
                    }
                }
            }
        }
    }
}
