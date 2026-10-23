import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    required property var barState

    function getMenuItems(title) {
        if (title === "File")
            return [{
            "text": "New Window / Launch App...",
            "shortcut": "⌘N",
            "cmd": "lunita-launcher toggle"
        }, {
            "text": "New Terminal Window",
            "shortcut": "⌘T",
            "cmd": "kitty || alacritty"
        }, {
            "text": "New File Manager Window",
            "shortcut": "⌘O",
            "cmd": "dolphin"
        }, {
            "separator": true
        }, {
            "text": "Close Active Window",
            "shortcut": "⌘W",
            "cmd": "hyprctl dispatch killactive"
        }, {
            "text": "Force Kill Application",
            "shortcut": "⌥⌘Q",
            "cmd": "hyprctl kill"
        }];

        if (title === "Edit")
            return [{
            "text": "Clipboard History...",
            "shortcut": "⌘V",
            "cmd": "lunita-clipboard toggle"
        }, {
            "text": "Take Screenshot (Area)...",
            "shortcut": "⇧⌘4",
            "cmd": "$HOME/.config/hypr/scripts/screenshot.sh area"
        }, {
            "text": "Take Screenshot (Screen)...",
            "shortcut": "⇧⌘3",
            "cmd": "$HOME/.config/hypr/scripts/screenshot.sh screen"
        }, {
            "text": "Screen Record (Area)...",
            "shortcut": "⌃⌘R",
            "cmd": "$HOME/.config/hypr/scripts/record.sh area"
        }, {
            "separator": true
        }, {
            "text": "Virtual Keyboard",
            "shortcut": "⌘K",
            "cmd": "$HOME/.config/hypr/scripts/virtual_keyboard.sh toggle"
        }];

        if (title === "View")
            return [{
            "text": "Toggle Fullscreen",
            "shortcut": "⌃⌘F",
            "cmd": "hyprctl dispatch fullscreen 0"
        }, {
            "text": "Toggle Floating",
            "shortcut": "⌥⌘Space",
            "cmd": "hyprctl dispatch togglefloating"
        }, {
            "text": "Pin / Always on Top",
            "shortcut": "⌘P",
            "cmd": "hyprctl dispatch pin"
        }, {
            "separator": true
        }, {
            "text": "Toggle Split Direction",
            "shortcut": "⌘J",
            "cmd": "hyprctl dispatch togglesplit"
        }, {
            "text": "Toggle Tabbed Group",
            "shortcut": "⌘G",
            "cmd": "hyprctl dispatch togglegroup"
        }, {
            "text": "Wallpaper Picker",
            "shortcut": "⌘W",
            "cmd": "hyprquickpaper"
        }, {
            "separator": true
        }, {
            "text": "Reload Hyprland Config",
            "shortcut": "⇧⌘R",
            "cmd": "hyprctl reload"
        }];

        if (title === "Window")
            return [{
            "text": "Minimize to Special",
            "shortcut": "⌘M",
            "cmd": "hyprctl dispatch movetoworkspace special:magic"
        }, {
            "text": "Toggle Minimized Workspace",
            "shortcut": "⇧⌘M",
            "cmd": "hyprctl dispatch togglespecialworkspace magic"
        }, {
            "separator": true
        }, {
            "text": "Cycle Next Window",
            "shortcut": "⌘Tab",
            "cmd": "hyprctl dispatch movefocus r"
        }, {
            "text": "Cycle Previous Window",
            "shortcut": "⇧⌘Tab",
            "cmd": "hyprctl dispatch movefocus l"
        }, {
            "separator": true
        }, {
            "text": "Next Workspace",
            "shortcut": "⌃→",
            "cmd": "hyprctl dispatch workspace e+1"
        }, {
            "text": "Previous Workspace",
            "shortcut": "⌃←",
            "cmd": "hyprctl dispatch workspace e-1"
        }];

        if (title === "Help")
            return [{
            "text": "Lunita Keybindings Cheatsheet",
            "shortcut": "⌘/",
            "cmd": "kitty -e sh -c 'less ~/.config/hypr/modules/keybinds.lua'"
        }, {
            "text": "Hyprland Documentation",
            "shortcut": "",
            "cmd": "xdg-open https://wiki.hyprland.org"
        }, {
            "text": "Lunita-Dots GitHub Repository",
            "shortcut": "",
            "cmd": "xdg-open https://github.com/Facuud2/Lunita-Dots"
        }, {
            "separator": true
        }, {
            "text": "About This Desktop...",
            "shortcut": "",
            "cmd": "kitty --title 'About Lunita OS' -e sh -c 'fastfetch; read -n 1 -s -p \"Press any key to close...\"'"
        }];

        // Active App Menu (e.g. Zen Browser, Kitty, LM Studio)
        var app = barState.activeAppName || "App";
        return [{
            "text": "About " + app,
            "shortcut": "",
            "cmd": "notify-send '" + app + "' 'Active Application\nClass: " + barState.activeWindowClass + "'"
        }, {
            "separator": true
        }, {
            "text": "Hide " + app,
            "shortcut": "⌘H",
            "cmd": "hyprctl dispatch movetoworkspace special:magic"
        }, {
            "text": "Toggle Fullscreen",
            "shortcut": "⌃⌘F",
            "cmd": "hyprctl dispatch fullscreen 0"
        }, {
            "text": "Toggle Floating",
            "shortcut": "⌥⌘Space",
            "cmd": "hyprctl dispatch togglefloating"
        }, {
            "separator": true
        }, {
            "text": "Quit " + app,
            "shortcut": "⌘Q",
            "cmd": "hyprctl dispatch killactive"
        }];
    }

    visible: barState.activePopup === "appmenu"
    x: Math.max(40, Math.min(parent.width - width - 10, barState.popupX))
    y: 4
    width: 260
    implicitHeight: menuCol.implicitHeight + 16
    height: implicitHeight
    z: 10
    opacity: visible ? 1 : 0
    scale: visible ? 1 : 0.96

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: barState.popupBgColor
        border.color: barState.popupBorderColor
        border.width: 1

        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: 11
            color: "transparent"
            border.color: Qt.rgba(0, 0, 0, barState.isDarkTheme ? 0.35 : 0.12)
            border.width: 1
            z: -1
        }

        Behavior on color {
            ColorAnimation {
                duration: 200
            }

        }

        Behavior on border.color {
            ColorAnimation {
                duration: 200
            }

        }

    }

    ColumnLayout {
        id: menuCol

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 8
        spacing: 2

        Repeater {
            model: getMenuItems(barState.activeMenuTitle)

            delegate: Item {
                id: itemDelegate

                required property var modelData
                required property int index
                property var stateRef: root.barState

                Layout.fillWidth: true
                implicitHeight: (modelData && modelData.separator) ? 9 : 24
                height: implicitHeight

                // Separator
                Rectangle {
                    visible: !!(modelData && modelData.separator)
                    anchors.centerIn: parent
                    width: parent.width
                    height: 1
                    color: itemDelegate.stateRef.popupSeparatorColor
                }

                // Action Item
                Rectangle {
                    visible: !(modelData && modelData.separator)
                    anchors.fill: parent
                    radius: 6
                    color: mArea.containsMouse ? "#007AFF" : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 8

                        Text {
                            Layout.fillWidth: true
                            text: (modelData && modelData.text) ? modelData.text : ""
                            color: mArea.containsMouse ? "#FFFFFF" : itemDelegate.stateRef.popupTextColor
                            font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                            font.pixelSize: 13
                            elide: Text.ElideRight

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }

                            }

                        }

                        Text {
                            visible: !!(modelData && modelData.shortcut)
                            text: (modelData && modelData.shortcut) ? modelData.shortcut : ""
                            color: mArea.containsMouse ? "#FFFFFF" : itemDelegate.stateRef.popupTextDim
                            font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                            font.pixelSize: 12

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }

                            }

                        }

                    }

                    MouseArea {
                        id: mArea

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var cmdToRun = (modelData && modelData.cmd) ? modelData.cmd : "";
                            itemDelegate.stateRef.closePopups();
                            if (cmdToRun)
                                itemDelegate.stateRef.launchCommand(cmdToRun);

                        }
                    }

                }

            }

        }

    }

    Behavior on opacity {
        NumberAnimation {
            duration: 140
            easing.type: Easing.OutCubic
        }

    }

    Behavior on scale {
        NumberAnimation {
            duration: 140
            easing.type: Easing.OutCubic
        }

    }

}
