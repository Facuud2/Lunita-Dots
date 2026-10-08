import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property var dockState

    width: 360
    height: mainCol.implicitHeight
    implicitWidth: 360
    implicitHeight: mainCol.implicitHeight

    // Smooth Appearance & Disappearance (Windows 11 Fluent Motion)
    opacity: (root.dockState.flyoutOpen && root.dockState.activeFlyout === "calendar") ? 1.0 : 0.0
    scale: (root.dockState.flyoutOpen && root.dockState.activeFlyout === "calendar") ? 1.0 : 0.96
    transformOrigin: Item.BottomRight

    Behavior on opacity {
        NumberAnimation {
            duration: root.dockState.flyoutOpen ? 240 : 150
            easing.type: root.dockState.flyoutOpen ? Easing.OutCubic : Easing.InQuad
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.dockState.flyoutOpen ? 260 : 170
            easing.type: root.dockState.flyoutOpen ? Easing.OutCubic : Easing.InQuad
        }
    }

    // Helper JavaScript function for calendar calculation
    function getCalendarCells(year, month) {
        var cells = [];
        var firstDayIndex = new Date(year, month, 1).getDay(); // 0 = Sunday
        var daysInCurrentMonth = new Date(year, month + 1, 0).getDate();
        var daysInPrevMonth = new Date(year, month, 0).getDate();

        // 1. Previous month trailing days
        for (var p = firstDayIndex - 1; p >= 0; p--) {
            cells.push({
                day: daysInPrevMonth - p,
                isCurrentMonth: false,
                isSelected: false
            });
        }

        // 2. Current month days
        for (var d = 1; d <= daysInCurrentMonth; d++) {
            var isSelected = (d === root.dockState.selectedDay);
            cells.push({
                day: d,
                isCurrentMonth: true,
                isSelected: isSelected
            });
        }

        // 3. Next month leading days (fill to 35 or 42)
        var totalNeeded = cells.length > 35 ? 42 : 35;
        var nextDay = 1;
        while (cells.length < totalNeeded) {
            cells.push({
                day: nextDay++,
                isCurrentMonth: false,
                isSelected: false
            });
        }

        return cells;
    }

    readonly property var monthsNames: [
        "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
        "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
    ]

    ColumnLayout {
        id: mainCol
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 10

        // ==========================================
        // CARD 1: NOTIFICATIONS HISTORY WIDGET
        // ==========================================
        Rectangle {
            id: notifCard
            Layout.fillWidth: true
            Layout.preferredHeight: notifCol.implicitHeight + 24
            radius: 18

            // Pure Transparent Liquid Glass Base
            color: Qt.rgba(0.12, 0.13, 0.17, 0.45)
            border.color: Qt.rgba(1.0, 1.0, 1.0, 0.16)
            border.width: 1

            // Specular Top Rim Line
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                height: 1
                color: Qt.rgba(1.0, 1.0, 1.0, 0.22)
            }

            ColumnLayout {
                id: notifCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 14
                spacing: 10

                // Header: "Notificaciones" + Badge + "Borrar todo"
                RowLayout {
                    Layout.fillWidth: true

                    Row {
                        spacing: 8
                        Layout.alignment: Qt.AlignVCenter

                        Image {
                            source: "assets/bell.svg"
                            sourceSize.width: 15
                            sourceSize.height: 15
                            anchors.verticalCenter: parent.verticalCenter
                            opacity: 0.90
                        }

                        Text {
                            text: "Notificaciones"
                            font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            font.italic: false
                            color: "#FFFFFF"
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        // Count Badge (when > 0)
                        Rectangle {
                            visible: root.dockState.notificationsList.length > 0
                            width: countText.implicitWidth + 10
                            height: 18
                            radius: 9
                            color: Qt.rgba(0.0, 0.90, 1.0, 0.30)
                            border.color: "#00E5FF"
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                id: countText
                                anchors.centerIn: parent
                                text: root.dockState.notificationsList.length
                                font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                font.italic: false
                                color: "#FFFFFF"
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // "Borrar todo" Pill Button (Frosted Glass Inset)
                    Rectangle {
                        visible: root.dockState.notificationsList.length > 0
                        width: clearText.implicitWidth + 18
                        height: 24
                        radius: 12
                        color: clearHover.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.18) : Qt.rgba(1.0, 1.0, 1.0, 0.08)
                        border.color: Qt.rgba(1.0, 1.0, 1.0, 0.16)
                        border.width: 1

                        Text {
                            id: clearText
                            anchors.centerIn: parent
                            text: "Borrar todo"
                            font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            font.italic: false
                            color: "#FFFFFF"
                        }

                        MouseArea {
                            id: clearHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.dockState.clearAllNotifications()
                        }
                    }
                }

                // Empty State (When no notifications)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    radius: 12
                    visible: root.dockState.notificationsList.length === 0
                    color: Qt.rgba(1.0, 1.0, 1.0, 0.06)
                    border.color: Qt.rgba(1.0, 1.0, 1.0, 0.12)
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 8
                        opacity: 0.70

                        Image {
                            source: "assets/bell.svg"
                            sourceSize.width: 14
                            sourceSize.height: 14
                            anchors.verticalCenter: parent.verticalCenter
                            opacity: 0.70
                        }

                        Text {
                            text: "No hay notificaciones nuevas"
                            font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                            font.pixelSize: 12
                            font.italic: false
                            color: "#FFFFFF"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                // Notification Items List (Scrollable if > 2 items)
                Flickable {
                    id: notifFlickable
                    visible: root.dockState.notificationsList.length > 0
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(itemsCol.implicitHeight, 180)
                    contentHeight: itemsCol.implicitHeight
                    clip: true
                    interactive: itemsCol.implicitHeight > 180
                    boundsBehavior: Flickable.StopAtBounds

                    ColumnLayout {
                        id: itemsCol
                        width: notifFlickable.width
                        spacing: 8

                        Repeater {
                            model: root.dockState.notificationsList

                            delegate: Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: itemCol.implicitHeight + 16
                                radius: 12
                                color: notifItemHover.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.12) : Qt.rgba(1.0, 1.0, 1.0, 0.05)
                                border.color: Qt.rgba(1.0, 1.0, 1.0, 0.14)
                                border.width: 1

                                ColumnLayout {
                                    id: itemCol
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 4

                                    // App Icon, Name, Timestamp, and Dismiss
                                    RowLayout {
                                        Layout.fillWidth: true
                                        spacing: 7

                                        Image {
                                            source: {
                                                if (modelData.iconPath && modelData.iconPath.length > 0) return modelData.iconPath;
                                                var app = (modelData.appName || "").toLowerCase();
                                                if (app.indexOf("whatsapp") !== -1) return "assets/icons/whatsapp.svg";
                                                if (app.indexOf("spotify") !== -1) return "assets/icons/win11-spotify.svg";
                                                if (app.indexOf("firefox") !== -1) return "assets/icons/win11-firefox.svg";
                                                return "assets/icons/win11-start.svg";
                                            }
                                            sourceSize.width: 16
                                            sourceSize.height: 16
                                            fillMode: Image.PreserveAspectFit
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        Text {
                                            text: modelData.appName || modelData.summary || "Notificación"
                                            font.family: "SF Pro Display, Adwaita Sans, Roboto, sans-serif"
                                            font.pixelSize: 12
                                            font.weight: Font.DemiBold
                                            font.italic: false
                                            color: "#FFFFFF"
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            text: modelData.timeStr || ""
                                            font.family: "SF Pro Display, Adwaita Sans, Roboto, sans-serif"
                                            font.pixelSize: 11
                                            font.italic: false
                                            color: Qt.rgba(1.0, 1.0, 1.0, 0.70)
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        // Dismiss Button on hover
                                        Rectangle {
                                            width: 18
                                            height: 18
                                            radius: 9
                                            color: dismissHover.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.35) : "transparent"
                                            border.color: dismissHover.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.50) : "transparent"
                                            border.width: 1
                                            Layout.alignment: Qt.AlignVCenter

                                            Text {
                                                anchors.centerIn: parent
                                                text: "✕"
                                                font.pixelSize: 10
                                                font.weight: Font.Bold
                                                font.italic: false
                                                color: Qt.rgba(1.0, 1.0, 1.0, 0.90)
                                            }

                                            MouseArea {
                                                id: dismissHover
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: root.dockState.dismissNotification(modelData.id)
                                            }
                                        }
                                    }

                                    // Notification Title/Summary (if different from appName)
                                    Text {
                                        text: modelData.summary || ""
                                        font.family: "SF Pro Display, Adwaita Sans, Roboto, sans-serif"
                                        font.pixelSize: 12
                                        font.weight: Font.DemiBold
                                        font.italic: false
                                        color: "#FFFFFF"
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                        visible: text.length > 0 && text !== modelData.appName
                                    }

                                    // Notification Message Body
                                    Text {
                                        text: modelData.body || ""
                                        font.family: "SF Pro Display, Adwaita Sans, Roboto, sans-serif"
                                        font.pixelSize: 12
                                        font.italic: false
                                        color: Qt.rgba(1.0, 1.0, 1.0, 0.90)
                                        Layout.fillWidth: true
                                        wrapMode: Text.WordWrap
                                        maximumLineCount: 3
                                        elide: Text.ElideRight
                                        visible: text.length > 0
                                    }
                                }

                                MouseArea {
                                    id: notifItemHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    z: -1
                                    onClicked: {
                                        root.dockState.invokeNotification(modelData.id, 0);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ==========================================
        // CARD 2: CALENDAR & CONCENTRATION WIDGET
        // ==========================================
        Rectangle {
            id: calCard
            Layout.fillWidth: true
            Layout.preferredHeight: calCol.implicitHeight + 24
            radius: 18

            // Pure Transparent Liquid Glass Base
            color: Qt.rgba(0.12, 0.13, 0.17, 0.45)
            border.color: Qt.rgba(1.0, 1.0, 1.0, 0.16)
            border.width: 1

            // Specular Top Rim Line
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                height: 1
                color: Qt.rgba(1.0, 1.0, 1.0, 0.22)
            }

            ColumnLayout {
                id: calCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 14
                spacing: 12

                // 1. Date Header Banner (e.g. "jueves, 1 de octubre ⌵")
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: {
                            var days = ["domingo", "lunes", "martes", "miércoles", "jueves", "viernes", "sábado"];
                            var months = ["enero", "febrero", "marzo", "abril", "mayo", "junio",
                                          "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre"];
                            var d = new Date(root.dockState.displayedYear, root.dockState.displayedMonth, root.dockState.selectedDay);
                            return days[d.getDay()] + ", " + root.dockState.selectedDay + " de " + months[root.dockState.displayedMonth];
                        }
                        font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        font.italic: false
                        color: Qt.rgba(1.0, 1.0, 1.0, 0.90)
                    }

                    Item { Layout.fillWidth: true }

                    // Collapse / Chevron Icon
                    Rectangle {
                        width: 20
                        height: 20
                        radius: 4
                        color: "transparent"

                        Image {
                            anchors.centerIn: parent
                            source: "assets/chevron-right.svg"
                            sourceSize.width: 11
                            sourceSize.height: 11
                            rotation: 90
                            opacity: 0.70
                        }
                    }
                }

                // 2. Month Selector Row (e.g. "Octubre de 2026" + ▲ ▼)
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: root.monthsNames[root.dockState.displayedMonth] + " de " + root.dockState.displayedYear
                        font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        font.italic: false
                        color: "#FFFFFF"
                    }

                    Item { Layout.fillWidth: true }

                    // Month Navigation Arrows
                    Row {
                        spacing: 8

                        // Up / Previous Month Arrow
                        Rectangle {
                            width: 22
                            height: 22
                            radius: 4
                            color: prevMonthHover.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.25) : "transparent"
                            border.color: prevMonthHover.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.35) : "transparent"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "▲"
                                font.pixelSize: 10
                                font.italic: false
                                color: Qt.rgba(1.0, 1.0, 1.0, 0.90)
                            }

                            MouseArea {
                                id: prevMonthHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.dockState.prevMonth()
                            }
                        }

                        // Down / Next Month Arrow
                        Rectangle {
                            width: 22
                            height: 22
                            radius: 4
                            color: nextMonthHover.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.25) : "transparent"
                            border.color: nextMonthHover.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.35) : "transparent"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "▼"
                                font.pixelSize: 10
                                font.italic: false
                                color: Qt.rgba(1.0, 1.0, 1.0, 0.90)
                            }

                            MouseArea {
                                id: nextMonthHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.dockState.nextMonth()
                            }
                        }
                    }
                }

                // 3. Days of the Week Header Row (Strictly Non-Italic)
                Row {
                    Layout.fillWidth: true
                    readonly property var daysHeader: ["DO", "LU", "MA", "MI", "JU", "VI", "SA"]

                    Repeater {
                        model: 7

                        Item {
                            width: calCol.width / 7
                            height: 22

                            Text {
                                anchors.centerIn: parent
                                text: parent.parent.daysHeader[index]
                                font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                font.italic: false
                                color: Qt.rgba(1.0, 1.0, 1.0, 0.75)
                            }
                        }
                    }
                }

                // 4. Days Grid (7 columns x 5/6 rows)
                Grid {
                    id: daysGrid
                    Layout.fillWidth: true
                    columns: 7

                    property var cellsData: root.getCalendarCells(root.dockState.displayedYear, root.dockState.displayedMonth)

                    Repeater {
                        model: daysGrid.cellsData

                        Item {
                            width: calCol.width / 7
                            height: 32

                            // Highlight Circle ONLY for Selected / Active Day
                            Rectangle {
                                anchors.centerIn: parent
                                width: 28
                                height: 28
                                radius: 14
                                color: modelData.isSelected ? Qt.rgba(0.0, 0.75, 1.0, 0.85) : (dayHover.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.14) : "transparent")
                                border.color: dayHover.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.20) : "transparent"
                                border.width: 1
                            }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.day
                                font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                                font.pixelSize: 11
                                font.weight: modelData.isSelected ? Font.Bold : Font.Normal
                                font.italic: false
                                color: modelData.isSelected
                                    ? "#FFFFFF"
                                    : (modelData.isCurrentMonth ? "#FFFFFF" : Qt.rgba(1.0, 1.0, 1.0, 0.40))
                            }

                            MouseArea {
                                id: dayHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (modelData.isCurrentMonth) {
                                        root.dockState.selectedDay = modelData.day;
                                    }
                                }
                            }
                        }
                    }
                }

                // 5. Bottom Focus / Concentration Bar
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 4

                    // Time adjustment: "−  30 mins  +"
                    Row {
                        spacing: 8
                        Layout.alignment: Qt.AlignVCenter

                        // Minus Button
                        Rectangle {
                            width: 22
                            height: 22
                            radius: 11
                            color: minusHover.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.18) : Qt.rgba(1.0, 1.0, 1.0, 0.08)
                            border.color: Qt.rgba(1.0, 1.0, 1.0, 0.16)
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "−"
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                font.italic: false
                                color: "#FFFFFF"
                            }

                            MouseArea {
                                id: minusHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.dockState.adjustFocus(-5)
                            }
                        }

                        // Minutes Text
                        Text {
                            text: root.dockState.focusMinutes + " mins"
                            font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            font.italic: false
                            color: "#FFFFFF"
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        // Plus Button
                        Rectangle {
                            width: 22
                            height: 22
                            radius: 11
                            color: plusHover.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.18) : Qt.rgba(1.0, 1.0, 1.0, 0.08)
                            border.color: Qt.rgba(1.0, 1.0, 1.0, 0.16)
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "+"
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                font.italic: false
                                color: "#FFFFFF"
                            }

                            MouseArea {
                                id: plusHover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.dockState.adjustFocus(5)
                            }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Concentration / Focus Action Button
                    Rectangle {
                        width: focusContent.implicitWidth + 20
                        height: 30
                        radius: 15
                        color: root.dockState.focusActive
                            ? Qt.rgba(0.0, 0.75, 1.0, 0.85)
                            : (focusHover.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.18) : Qt.rgba(1.0, 1.0, 1.0, 0.08))
                        border.color: root.dockState.focusActive ? Qt.rgba(0.0, 0.85, 1.0, 0.90) : Qt.rgba(1.0, 1.0, 1.0, 0.18)
                        border.width: 1

                        Row {
                            id: focusContent
                            anchors.centerIn: parent
                            spacing: 6

                            Text {
                                text: root.dockState.focusActive ? "⏸" : "▶"
                                font.pixelSize: 10
                                font.italic: false
                                color: "#FFFFFF"
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: root.dockState.focusActive
                                    ? (Math.floor(root.dockState.focusSecondsRemaining / 60) + ":" + ((root.dockState.focusSecondsRemaining % 60 < 10 ? "0" : "") + (root.dockState.focusSecondsRemaining % 60)))
                                    : "Concentración"
                                font.family: "Segoe UI, Inter, Roboto, Cantarell, sans-serif"
                                font.pixelSize: 11
                                font.weight: Font.DemiBold
                                font.italic: false
                                color: "#FFFFFF"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: focusHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.dockState.toggleFocus()
                        }
                    }
                }
            }
        }
    }
}
