import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root

    required property var barState

    color: Qt.rgba(1, 1, 1, 0.08)
    radius: 16
    border.color: cardHover.hovered ? root.barState.themeBorderSpecular : Qt.rgba(1, 1, 1, 0.12)
    border.width: 1
    clip: true

    implicitWidth: 188
    implicitHeight: 166

    HoverHandler { id: cardHover }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.barState.openPopup("calendar");
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 2

        // Top Row: Weather Icon & Astraeus Stacked Clock (Coral)
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "󰖙"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 26
                color: root.barState.themeAccent
            }

            Item { Layout.fillWidth: true }

            // Astraeus Stacked Clock: HH on top, MM on bottom (both coral accent)
            Column {
                spacing: -6

                Text {
                    anchors.right: parent.right
                    text: {
                        var parts = root.barState.timeStr.split(":");
                        return parts[0] || "10";
                    }
                    font.family: root.barState.themeFontDisplay
                    font.pixelSize: 28
                    font.weight: Font.Light
                    color: root.barState.themeAccent
                }

                Text {
                    anchors.right: parent.right
                    text: {
                        var parts = root.barState.timeStr.split(":");
                        if (parts.length > 1) {
                            return parts[1].split(" ")[0] || "44";
                        }
                        return "44";
                    }
                    font.family: root.barState.themeFontDisplay
                    font.pixelSize: 28
                    font.weight: Font.Light
                    color: root.barState.themeAccent
                }
            }
        }

        Item { Layout.fillHeight: true }

        // Temperature Headline (Large, thin white typography)
        Text {
            text: root.barState.weatherTemp || "29°"
            font.family: root.barState.themeFontDisplay
            font.pixelSize: 34
            font.weight: Font.Thin
            color: "#FFFFFF"
        }

        // Weather Condition & Location
        Text {
            Layout.fillWidth: true
            text: root.barState.weatherDesc || "Clear"
            font.family: root.barState.themeFontInterface
            font.pixelSize: 11
            font.weight: Font.Medium
            color: Qt.rgba(1, 1, 1, 0.75)
            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true
            text: root.barState.dateStr || "Lisbon"
            font.family: root.barState.themeFontInterface
            font.pixelSize: 10
            color: Qt.rgba(1, 1, 1, 0.50)
            elide: Text.ElideRight
        }
    }
}
