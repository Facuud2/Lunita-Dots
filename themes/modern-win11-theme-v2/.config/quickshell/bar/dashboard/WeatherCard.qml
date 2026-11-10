import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root

    required property var barState

    color: root.barState.themeSurfaceContainer
    radius: root.barState.themeCardRadius
    border.color: cardHover.hovered ? root.barState.themeBorderSpecular : root.barState.themeBorder
    border.width: 1
    clip: true

    implicitWidth: 180
    implicitHeight: 168

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
        anchors.margins: 14
        spacing: 4

        // Top Header: Weather Icon & Astraeus Stacked Clock
        RowLayout {
            Layout.fillWidth: true

            Text {
                text: "󰖙"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 26
                color: root.barState.themeAccent
            }

            Item { Layout.fillWidth: true }

            // Astraeus Stacked Clock (HH on top, MM on bottom)
            Column {
                spacing: -4

                Text {
                    anchors.right: parent.right
                    text: {
                        var parts = root.barState.timeStr.split(":");
                        return parts[0] || "20";
                    }
                    font.family: root.barState.themeFontDisplay
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                    color: root.barState.themeOnSurface
                }

                Text {
                    anchors.right: parent.right
                    text: {
                        var parts = root.barState.timeStr.split(":");
                        if (parts.length > 1) {
                            return parts[1].split(" ")[0] || "00";
                        }
                        return "00";
                    }
                    font.family: root.barState.themeFontDisplay
                    font.pixelSize: 22
                    font.weight: Font.DemiBold
                    color: root.barState.themeAccent
                }
            }
        }

        Item { Layout.fillHeight: true }

        // Temperature Headline
        Text {
            text: root.barState.weatherTemp || "22°C"
            font.family: root.barState.themeFontDisplay
            font.pixelSize: 28
            font.weight: Font.Light
            color: root.barState.themeOnSurface
        }

        // Weather Condition & Date
        Text {
            Layout.fillWidth: true
            text: root.barState.weatherDesc || "Soleado"
            font.family: root.barState.themeFontInterface
            font.pixelSize: 11
            font.weight: Font.Medium
            color: root.barState.themeOnSurface
            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true
            text: root.barState.dateStr || "Hoy"
            font.family: root.barState.themeFontInterface
            font.pixelSize: 10
            color: root.barState.themeOnSurfaceDim
            elide: Text.ElideRight
        }
    }
}
