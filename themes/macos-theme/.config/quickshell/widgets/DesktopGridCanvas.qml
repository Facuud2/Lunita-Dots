import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    property var widgetsState
    property string screenName: "default"

    // Helper forwarding methods for WidgetFrame and top bar
    function addWidget(type) {
        if (root.widgetsState) root.widgetsState.addWidget(root.screenName, type);
    }
    function resetLayout() {
        if (root.widgetsState) root.widgetsState.resetLayout(root.screenName);
    }
    function updateWidgetPosition(id, x, y) {
        if (root.widgetsState) root.widgetsState.updateWidgetPosition(root.screenName, id, x, y);
    }
    function updateWidgetSize(id, w, h, s) {
        if (root.widgetsState) root.widgetsState.updateWidgetSize(root.screenName, id, w, h, s);
    }
    function removeWidget(id) {
        if (root.widgetsState) root.widgetsState.removeWidget(root.screenName, id);
    }
    function toggleClockExpanded() {
        if (root.widgetsState) root.widgetsState.toggleClockExpanded(root.screenName);
    }
    function toggleMediaExpanded() {
        if (root.widgetsState) root.widgetsState.toggleMediaExpanded(root.screenName);
    }
    function toggleCalendarExpansion() {
        if (root.widgetsState) root.widgetsState.toggleCalendarExpansion(root.screenName);
    }

    // ── 1. Persistent Dynamic Widgets Container (No flickering/recreation) ──
    Item {
        id: widgetsContainer
        anchors.fill: parent
    }

    Component {
        id: widgetFrameComp
        WidgetFrame {
            widgetsState: root.widgetsState
            canvas: root
        }
    }

    property var framesMap: ({})

    function syncFrames() {
        if (!root.widgetsState) return;
        var list = root.widgetsState.getScreenWidgets(root.screenName);
        if (!list || !Array.isArray(list)) list = [];

        var newMap = Object.assign({}, framesMap);
        var seen = {};

        for (var i = 0; i < list.length; i++) {
            var item = list[i];
            if (!item || !item.id) continue;
            seen[item.id] = true;

            var existing = newMap[item.id];
            if (!existing) {
                var obj = widgetFrameComp.createObject(widgetsContainer, {
                    widgetData: item,
                    canvas: root
                });
                newMap[item.id] = obj;
            } else {
                existing.applyData(item);
            }
        }

        for (var idKey in newMap) {
            if (!seen[idKey]) {
                if (newMap[idKey]) {
                    newMap[idKey].destroy();
                }
                delete newMap[idKey];
            }
        }
        framesMap = newMap;
    }

    Connections {
        target: root.widgetsState
        function onScreensLayoutChanged() {
            root.syncFrames();
        }
        function onScreenLayoutChanged(targetScreen) {
            if (targetScreen === root.screenName || targetScreen === "all") {
                root.syncFrames();
            }
        }
    }

    Component.onCompleted: {
        root.syncFrames();
    }

    // ── 2. Top Edit Mode Header Bar (Visible only when editing) ──
    Rectangle {
        id: editTopBar
        visible: root.widgetsState.isEditing
        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.horizontalCenter: parent.horizontalCenter
        height: 44
        implicitWidth: editBarRow.implicitWidth + 32
        radius: 22
        color: root.widgetsState.isDarkTheme ? Qt.rgba(0.14, 0.16, 0.20, 0.92) : Qt.rgba(0.96, 0.96, 0.98, 0.94)
        border.color: root.widgetsState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.20) : Qt.rgba(0, 0, 0, 0.14)
        border.width: 1

        RowLayout {
            id: editBarRow
            anchors.centerIn: parent
            spacing: 8

            // Reset Button
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: resetText.implicitWidth + 16
                color: resetMa.containsMouse ? (root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: resetText
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "↺"; color: root.widgetsState.textColor; font.pixelSize: 11; font.weight: Font.Bold }
                    Text { text: "Reset"; color: root.widgetsState.textColor; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold }
                }

                MouseArea {
                    id: resetMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.resetLayout()
                }
            }

            // Add Photos
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addPhoText.implicitWidth + 16
                color: addPhoMa.containsMouse ? (root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addPhoText
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "+"; color: root.widgetsState.textColor; font.pixelSize: 12; font.weight: Font.Bold }
                    Text { text: "Fotos"; color: root.widgetsState.textColor; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold }
                }

                MouseArea {
                    id: addPhoMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addWidget("photos")
                }
            }

            // Add Calendar
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addCalText.implicitWidth + 16
                color: addCalMa.containsMouse ? (root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addCalText
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "+"; color: root.widgetsState.textColor; font.pixelSize: 12; font.weight: Font.Bold }
                    Text { text: "Calendario"; color: root.widgetsState.textColor; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold }
                }

                MouseArea {
                    id: addCalMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addWidget("calendar")
                }
            }

            // Add Resources
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addSysText.implicitWidth + 16
                color: addSysMa.containsMouse ? (root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addSysText
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "+"; color: root.widgetsState.textColor; font.pixelSize: 12; font.weight: Font.Bold }
                    Text { text: "Actividad"; color: root.widgetsState.textColor; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold }
                }

                MouseArea {
                    id: addSysMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addWidget("resources")
                }
            }

            // Add Clock
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addClkText.implicitWidth + 16
                color: addClkMa.containsMouse ? (root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addClkText
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "+"; color: root.widgetsState.textColor; font.pixelSize: 12; font.weight: Font.Bold }
                    Text { text: "Reloj"; color: root.widgetsState.textColor; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold }
                }

                MouseArea {
                    id: addClkMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addWidget("clock")
                }
            }

            // Add Network
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addNetText.implicitWidth + 16
                color: addNetMa.containsMouse ? (root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addNetText
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "+"; color: root.widgetsState.textColor; font.pixelSize: 12; font.weight: Font.Bold }
                    Text { text: "Red"; color: root.widgetsState.textColor; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold }
                }

                MouseArea {
                    id: addNetMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addWidget("network")
                }
            }

            // Add Battery
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addBatText.implicitWidth + 16
                color: addBatMa.containsMouse ? (root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addBatText
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "+"; color: root.widgetsState.textColor; font.pixelSize: 12; font.weight: Font.Bold }
                    Text { text: "Batería"; color: root.widgetsState.textColor; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold }
                }

                MouseArea {
                    id: addBatMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addWidget("battery")
                }
            }

            // Add Git
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addGitText.implicitWidth + 16
                color: addGitMa.containsMouse ? (root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addGitText
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "+"; color: root.widgetsState.textColor; font.pixelSize: 12; font.weight: Font.Bold }
                    Text { text: "Git"; color: root.widgetsState.textColor; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold }
                }

                MouseArea {
                    id: addGitMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addWidget("git")
                }
            }

            // Add Habits
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addHabText.implicitWidth + 16
                color: addHabMa.containsMouse ? (root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addHabText
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "+"; color: root.widgetsState.textColor; font.pixelSize: 12; font.weight: Font.Bold }
                    Text { text: "Salud"; color: root.widgetsState.textColor; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold }
                }

                MouseArea {
                    id: addHabMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addWidget("habits")
                }
            }

            // Add Timetable
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addTtText.implicitWidth + 16
                color: addTtMa.containsMouse ? (root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addTtText
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "+"; color: root.widgetsState.textColor; font.pixelSize: 12; font.weight: Font.Bold }
                    Text { text: "Notas"; color: root.widgetsState.textColor; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold }
                }

                MouseArea {
                    id: addTtMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addWidget("timetable")
                }
            }

            // Add Media
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: addMedText.implicitWidth + 16
                color: addMedMa.containsMouse ? (root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: addMedText
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "+"; color: root.widgetsState.textColor; font.pixelSize: 12; font.weight: Font.Bold }
                    Text { text: "Música"; color: root.widgetsState.textColor; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold }
                }

                MouseArea {
                    id: addMedMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.addWidget("media")
                }
            }

            // Settings "Ajustes" Button
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: cfgText.implicitWidth + 20
                color: cfgMa.containsMouse ? (root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.20)" : "rgba(0,0,0,0.12)") : "transparent"
                border.color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                RowLayout {
                    id: cfgText
                    anchors.centerIn: parent
                    spacing: 4
                    Text { text: "󰒓"; font.family: "CaskaydiaCove Nerd Font"; color: root.widgetsState.accentBlue; font.pixelSize: 11 }
                    Text { text: "Ajustes"; color: root.widgetsState.textColor; font.family: "SF Pro Display"; font.pixelSize: 11; font.weight: Font.Bold }
                }

                MouseArea {
                    id: cfgMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Quickshell.execDetached(["lunita-widgets-manager"])
                }
            }

            // Done "Listo" Button
            Rectangle {
                radius: 14
                height: 28
                implicitWidth: doneText.implicitWidth + 24
                color: doneMa.containsMouse ? "#0088FF" : "#007AFF"

                Text {
                    id: doneText
                    anchors.centerIn: parent
                    text: "Listo"
                    font.family: "SF Pro Display"
                    font.pixelSize: 12
                    font.weight: Font.ExtraBold
                    color: "#FFFFFF"
                }

                MouseArea {
                    id: doneMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.widgetsState.toggleEdit()
                }
            }
        }
    }
}

