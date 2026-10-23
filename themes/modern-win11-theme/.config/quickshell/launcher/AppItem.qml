import QtQuick
import QtQuick.Controls

Item {
    id: root

    required property var launcherState
    property var app: null
    readonly property string resolvedIcon: {
        if (!app)
            return "image://icon/application-x-executable";

        var s = (app.resolvedIcon !== undefined && app.resolvedIcon !== null) ? ("" + app.resolvedIcon) : "";
        if (!s && app.iconName)
            s = ("" + app.iconName);

        if (!s)
            return "image://icon/application-x-executable";

        if (s.startsWith("assets/"))
            return Qt.resolvedUrl(s);

        if (s.startsWith("/"))
            return "file://" + s;

        if (s.startsWith("file://") || s.startsWith("image://"))
            return s;

        return "image://icon/" + s;
    }

    width: 94
    height: 86
    // Native ToolTip
    ToolTip.visible: itemMouse.containsMouse && (root.app && (root.app.description || root.app.displayName))
    ToolTip.delay: 600
    ToolTip.timeout: 4000
    ToolTip.text: root.app ? (root.app.displayName + (root.app.description ? "\n" + root.app.description : "")) : ""

    // Windows 11 Fluent Soft Hover Pill (Borderless)
    Rectangle {
        id: hoverBg

        anchors.fill: parent
        anchors.margins: 2
        radius: 6
        color: itemMouse.pressed ? root.launcherState.appActiveBg : root.launcherState.appHoverBg
        opacity: itemMouse.containsMouse ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutQuad
            }

        }

    }

    // App Content
    Column {
        anchors.centerIn: parent
        spacing: 4
        width: parent.width - 8
        scale: itemMouse.pressed ? 0.95 : (itemMouse.containsMouse ? 1.03 : 1)

        // App Icon
        Item {
            width: 42
            height: 42
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                id: iconImg

                anchors.fill: parent
                source: root.resolvedIcon
                sourceSize: Qt.size(64, 64)
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
            }

        }

        // App Title Label
        Text {
            id: nameLabel

            text: root.app ? (root.app.displayName || root.app.name || "") : ""
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            elide: Text.ElideRight
            lineHeight: 1.05
            color: root.launcherState.appTitleColor
            font.pixelSize: 11
            font.weight: Font.Normal
            font.italic: false
            font.family: "Segoe UI Variable Text, Segoe UI, Inter, sans-serif"
            // Subtle text shadow for high contrast over transparent blur
            style: Text.Outline
            styleColor: Qt.rgba(0, 0, 0, 0.65)
        }

        Behavior on scale {
            NumberAnimation {
                duration: 130
                easing.type: Easing.OutCubic
            }

        }

    }

    // Click & Hover Handler
    MouseArea {
        id: itemMouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.app)
                root.launcherState.launchApp(root.app);

        }
    }

}
