import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell

Item {
    id: root

    required property var launcherState
    property var app: null
    property bool isDetailed: false

    width: 96
    height: 98

    readonly property string resolvedIcon: {
        if (!app) return "image://icon/application-x-executable"
        if (app.resolvedIcon) {
            if (app.resolvedIcon.startsWith("assets/")) return Qt.resolvedUrl(app.resolvedIcon)
            return app.resolvedIcon
        }
        let id = (app.id || "").toLowerCase()
        let exec = (app.executable || "").toLowerCase()
        let name = (app.name || "").toLowerCase()

        if (id.includes("zen") || id.includes("firefox") || id.includes("safari") || id.includes("chrome") || id.includes("browser")) return Qt.resolvedUrl("assets/icons/safari.svg")
        if (id.includes("code") || id.includes("vscodium") || id.includes("vscode") || id.includes("antigravity") || id.includes("cursor") || id.includes("nvim")) return Qt.resolvedUrl("assets/icons/code.svg")
        if (id.includes("kitty") || id.includes("terminal") || id.includes("alacritty") || id.includes("foot") || id.includes("wezterm")) return Qt.resolvedUrl("assets/icons/terminal.svg")
        if (id.includes("dolphin") || id.includes("nautilus") || id.includes("thunar") || id.includes("finder") || id.includes("files")) return Qt.resolvedUrl("assets/icons/finder.svg")
        if (id.includes("spotify") || id.includes("music") || id.includes("cider") || id.includes("amberol")) return Qt.resolvedUrl("assets/icons/music.svg")
        if (id.includes("messages") || id.includes("telegram") || id.includes("discord") || id.includes("vesktop") || id.includes("whatsapp")) return Qt.resolvedUrl("assets/icons/messages.svg")
        if (id.includes("mail") || id.includes("thunderbird")) return Qt.resolvedUrl("assets/icons/mail.svg")
        if (id.includes("photos") || id.includes("gwenview") || id.includes("loupe") || id.includes("eog")) return Qt.resolvedUrl("assets/icons/photos.svg")
        if (id.includes("calendar") || id.includes("korganizer")) return Qt.resolvedUrl("assets/icons/calendar.svg")
        if (id.includes("notes") || id.includes("obsidian") || id.includes("notepadqq") || id.includes("kate")) return Qt.resolvedUrl("assets/icons/notes.svg")
        if (id.includes("settings") || id.includes("systemsettings") || id.includes("control-center")) return Qt.resolvedUrl("assets/icons/settings.svg")
        if (id.includes("shortcuts") || id.includes("rofi")) return Qt.resolvedUrl("assets/icons/shortcuts.svg")
        if (id.includes("keychain") || id.includes("keepassxc") || id.includes("bitwarden") || id.includes("seahorse")) return Qt.resolvedUrl("assets/icons/keychain.svg")
        if (id.includes("appstore") || id.includes("discover") || id.includes("pamac")) return Qt.resolvedUrl("assets/icons/appstore.svg")

        if (app.iconName) {
            if (app.iconName.startsWith("/")) return "file://" + app.iconName
            return "image://icon/" + app.iconName
        }
        return "image://icon/application-x-executable"
    }

    // Hover Highlight Pill
    Rectangle {
        id: hoverBg
        anchors.fill: parent
        anchors.margins: 2
        radius: 14
        color: launcherState.appHoverBg
        opacity: itemMouse.containsMouse ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: 140; easing.type: Easing.OutQuad }
        }
    }

    // Main Item Container with Scale Transformations
    Item {
        id: contentContainer
        anchors.fill: parent
        anchors.topMargin: 4
        anchors.bottomMargin: 4

        scale: itemMouse.pressed ? 0.94 : (itemMouse.containsMouse ? 1.07 : 1.0)
        Behavior on scale {
            NumberAnimation { duration: 160; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
        }

        // App Icon Squircle Container
        Rectangle {
            id: iconCard
            width: 64
            height: 64
            radius: 14.4
            clip: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            color: "transparent"

            // Soft icon drop shadow
            RectangularGlow {
                anchors.fill: iconCard
                glowRadius: itemMouse.containsMouse ? 10 : 4
                spread: 0.05
                color: "#33000000"
                cornerRadius: iconCard.radius + glowRadius
            }

            Image {
                id: iconImg
                anchors.fill: parent
                source: root.resolvedIcon
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
            }
        }

        // App Name Label
        Text {
            id: nameLabel
            text: root.app ? (root.app.displayName || root.app.name || "") : ""
            anchors.top: iconCard.bottom
            anchors.topMargin: 6
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 6
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            maximumLineCount: 1
            color: launcherState.appTitleColor
            font.pixelSize: 11
            font.weight: Font.Medium
            font.italic: false
            font.family: "SF Pro Text, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, sans-serif"
        }
    }

    // Mouse & Click Handler
    MouseArea {
        id: itemMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (root.app) {
                launcherState.launchApp(root.app)
            }
        }
    }

    // Native Tooltip
    ToolTip.visible: itemMouse.containsMouse && (root.app && (root.app.description || root.app.displayName))
    ToolTip.delay: 500
    ToolTip.timeout: 4000
    ToolTip.text: root.app ? (root.app.displayName + (root.app.description ? "\n" + root.app.description : "")) : ""
}
