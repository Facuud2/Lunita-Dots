import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property var launcherState

    implicitHeight: 75
    width: parent.width

    // Lista de accesos directos de QuickLinks exactamente como en el video:
    // 1. Google (lupa)
    // 2. YouTube
    // 3. Reddit
    // 4. Twitter
    // 5. Video/Netflix
    // 6. SoundCloud
    readonly property var quickLinks: [
        { label: "Google", icon: "\ue978", font: launcherState.fontFeather, url: "https://www.google.com" },
        { label: "YouTube", icon: "\uea15", font: launcherState.fontFeather, url: "https://www.youtube.com" },
        { label: "Reddit", icon: "\uf281", font: launcherState.fontSymbols, url: "https://www.reddit.com" },
        { label: "Twitter", icon: "\ue9f9", font: launcherState.fontFeather, url: "https://www.twitter.com" },
        { label: "Netflix", icon: "\uf008", font: launcherState.fontSymbols, url: "https://www.netflix.com" },
        { label: "SoundCloud", icon: "\uf1be", font: launcherState.fontSymbols, url: "https://www.soundcloud.com" }
    ]

    function activateIndex(idx) {
        if (idx < 0 || idx >= quickLinks.length) return;
        const item = quickLinks[idx];
        launcherState.launchCommand("zen-browser '" + item.url + "' || xdg-open '" + item.url + "'");
    }

    RowLayout {
        anchors.fill: parent
        spacing: 12

        Repeater {
            model: root.quickLinks

            Rectangle {
                id: cell
                required property int index
                required property var modelData

                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 0

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
