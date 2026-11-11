import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root

    required property var barState
    signal closeRequested()

    color: root.barState.themeSurface
    radius: root.barState.themeCardRadius
    border.color: root.barState.themeBorderSpecular
    border.width: 1
    clip: true

    // Calendar state
    property var currentDate: new Date()
    property int selectedYear: currentDate.getFullYear()
    property int selectedMonth: currentDate.getMonth() // 0-11
    property int selectedDay: currentDate.getDate()

    readonly property var monthNames: [
        "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio",
        "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
    ]
    readonly property var dayNames: ["Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"]

    function prevMonth() {
        if (selectedMonth === 0) {
            selectedMonth = 11;
            selectedYear -= 1;
        } else {
            selectedMonth -= 1;
        }
    }

    function nextMonth() {
        if (selectedMonth === 11) {
            selectedMonth = 0;
            selectedYear += 1;
        } else {
            selectedMonth += 1;
        }
    }

    function jumpToday() {
        var now = new Date();
        selectedYear = now.getFullYear();
        selectedMonth = now.getMonth();
        selectedDay = now.getDate();
    }

    // Generate 42 cells (6 rows x 7 days) for the calendar grid
    function getDaysGrid() {
        var cells = [];
        var firstDayIndex = new Date(selectedYear, selectedMonth, 1).getDay(); // 0 is Sun
        // Adjust so Monday is 0
        var startOffset = (firstDayIndex === 0 ? 6 : firstDayIndex - 1);

        var daysInCurMonth = new Date(selectedYear, selectedMonth + 1, 0).getDate();
        var daysInPrevMonth = new Date(selectedYear, selectedMonth, 0).getDate();

        var today = new Date();
        var isCurrentMonthAndYear = (today.getFullYear() === selectedYear && today.getMonth() === selectedMonth);

        // Previous month padding
        for (var p = startOffset - 1; p >= 0; --p) {
            cells.push({
                day: daysInPrevMonth - p,
                currentMonth: false,
                isToday: false,
                isSelected: false
            });
        }

        // Current month days
        for (var d = 1; d <= daysInCurMonth; ++d) {
            cells.push({
                day: d,
                currentMonth: true,
                isToday: isCurrentMonthAndYear && (today.getDate() === d),
                isSelected: (root.selectedDay === d && isCurrentMonthAndYear)
            });
        }

        // Next month padding to fill 42 cells
        var remaining = 42 - cells.length;
        for (var n = 1; n <= remaining; ++n) {
            cells.push({
                day: n,
                currentMonth: false,
                isToday: false,
                isSelected: false
            });
        }

        return cells;
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        // ── Header: Back button, Title & Digital Clock ──
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // Back Button
            Rectangle {
                width: 76
                height: 30
                radius: 8
                color: backHover.hovered ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.08)
                border.color: root.barState.themeBorder
                border.width: 1

                HoverHandler { id: backHover }

                Row {
                    anchors.centerIn: parent
                    spacing: 4
                    Text {
                        text: "󰁍"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 13
                        color: root.barState.themeOnSurface
                    }
                    Text {
                        text: "Volver"
                        font.family: root.barState.themeFontInterface
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        color: root.barState.themeOnSurface
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.closeRequested()
                }
            }

            Text {
                text: "Calendario & Pronóstico"
                font.family: root.barState.themeFontInterface
                font.pixelSize: 15
                font.weight: Font.Bold
                color: "#FFFFFF"
            }

            Item { Layout.fillWidth: true }

            Text {
                text: root.barState.timeStr || "12:00"
                font.family: root.barState.themeFontInterface
                font.pixelSize: 14
                font.weight: Font.DemiBold
                color: root.barState.themeAccent
            }
        }

        // ── Two Columns Layout (Hero Weather & Today / Interactive Calendar) ──
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 14

            // ── Left Column: Today & Forecast Hero (340px) ──
            Rectangle {
                Layout.preferredWidth: 320
                Layout.fillHeight: true
                radius: 14
                color: Qt.rgba(1, 1, 1, 0.06)
                border.color: Qt.rgba(1, 1, 1, 0.10)
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 8

                    // Large Day Number & Weekday
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Text {
                            text: root.selectedDay.toString()
                            font.family: root.barState.themeFontDisplay
                            font.pixelSize: 44
                            font.weight: Font.Thin
                            color: "#FFFFFF"
                        }

                        Column {
                            spacing: 1
                            Text {
                                text: root.dayNames[new Date(root.selectedYear, root.selectedMonth, root.selectedDay).getDay()] || "Hoy"
                                font.family: root.barState.themeFontInterface
                                font.pixelSize: 14
                                font.weight: Font.Bold
                                color: root.barState.themeAccent
                            }
                            Text {
                                text: root.monthNames[root.selectedMonth] + " " + root.selectedYear
                                font.family: root.barState.themeFontInterface
                                font.pixelSize: 11
                                color: Qt.rgba(1, 1, 1, 0.65)
                            }
                        }
                    }

                    // Divider
                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Qt.rgba(1, 1, 1, 0.10)
                    }

                    // Current Weather Condition Box
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Text {
                            text: "󰖙"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 32
                            color: root.barState.themeAccent
                        }

                        Column {
                            spacing: 1
                            Text {
                                text: (root.barState.weatherTemp || "21°") + "  " + (root.barState.weatherDesc || "Soleado")
                                font.family: root.barState.themeFontInterface
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                color: "#FFFFFF"
                            }
                            Text {
                                text: "Buenos Aires  ·  Máx: 25°  Mín: 15°"
                                font.family: root.barState.themeFontInterface
                                font.pixelSize: 10
                                color: Qt.rgba(1, 1, 1, 0.60)
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    // Hourly Forecast Pills (Next 4 Hours)
                    Text {
                        text: "Pronóstico por Horas"
                        font.family: root.barState.themeFontInterface
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        color: Qt.rgba(1, 1, 1, 0.50)
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Repeater {
                            model: [
                                { h: "+1h", icon: "󰖙", t: "22°" },
                                { h: "+2h", icon: "󰖙", t: "21°" },
                                { h: "+3h", icon: "󰖐", t: "19°" },
                                { h: "+4h", icon: "󰖐", t: "18°" }
                            ]

                            Rectangle {
                                Layout.fillWidth: true
                                height: 50
                                radius: 8
                                color: Qt.rgba(1, 1, 1, 0.08)
                                border.color: Qt.rgba(1, 1, 1, 0.12)

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 2
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: modelData.h
                                        font.family: root.barState.themeFontInterface
                                        font.pixelSize: 9
                                        color: Qt.rgba(1, 1, 1, 0.55)
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: modelData.icon
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: 12
                                        color: root.barState.themeAccent
                                    }
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: modelData.t
                                        font.family: root.barState.themeFontInterface
                                        font.pixelSize: 9
                                        font.weight: Font.Medium
                                        color: "#FFFFFF"
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ── Right Column: Interactive Month Calendar Grid ──
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 14
                color: Qt.rgba(1, 1, 1, 0.06)
                border.color: Qt.rgba(1, 1, 1, 0.10)
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 8

                    // Month Navigation Bar
                    RowLayout {
                        Layout.fillWidth: true

                        // Prev Month Button
                        Rectangle {
                            width: 28
                            height: 28
                            radius: 6
                            color: prevHov.hovered ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.08)
                            HoverHandler { id: prevHov }
                            Text {
                                anchors.centerIn: parent
                                text: "󰅁"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                color: "#FFFFFF"
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.prevMonth()
                            }
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: root.monthNames[root.selectedMonth] + " " + root.selectedYear
                            font.family: root.barState.themeFontInterface
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            color: "#FFFFFF"
                        }

                        Item { Layout.fillWidth: true }

                        // Today Quick Jump Button
                        Rectangle {
                            width: 44
                            height: 26
                            radius: 6
                            color: todayHov.hovered ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.08)
                            border.color: root.barState.themeBorder
                            border.width: 1
                            HoverHandler { id: todayHov }
                            Text {
                                anchors.centerIn: parent
                                text: "Hoy"
                                font.family: root.barState.themeFontInterface
                                font.pixelSize: 10
                                color: root.barState.themeAccent
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.jumpToday()
                            }
                        }

                        // Next Month Button
                        Rectangle {
                            width: 28
                            height: 28
                            radius: 6
                            color: nextHov.hovered ? Qt.rgba(1, 1, 1, 0.15) : Qt.rgba(1, 1, 1, 0.08)
                            HoverHandler { id: nextHov }
                            Text {
                                anchors.centerIn: parent
                                text: "󰅂"
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                color: "#FFFFFF"
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.nextMonth()
                            }
                        }
                    }

                    // Weekdays Row
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Repeater {
                            model: ["L", "M", "M", "J", "V", "S", "D"]
                            Text {
                                Layout.fillWidth: true
                                text: modelData
                                font.family: root.barState.themeFontInterface
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                color: Qt.rgba(1, 1, 1, 0.45)
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }

                    // Calendar Days Grid (6 rows x 7 days)
                    GridLayout {
                        id: daysGrid
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        columns: 7
                        rows: 6
                        columnSpacing: 2
                        rowSpacing: 2

                        Repeater {
                            model: root.getDaysGrid()

                            Rectangle {
                                id: dayCell
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: 6
                                color: modelData.isToday ? root.barState.themeAccent : (modelData.isSelected ? Qt.rgba(root.barState.themeAccent.r, root.barState.themeAccent.g, root.barState.themeAccent.b, 0.30) : (cellHov.hovered ? Qt.rgba(1, 1, 1, 0.12) : "transparent"))
                                border.color: modelData.isToday ? "#FFFFFF" : (modelData.isSelected ? root.barState.themeAccent : "transparent")
                                border.width: modelData.isToday || modelData.isSelected ? 1 : 0

                                HoverHandler { id: cellHov }

                                Text {
                                    anchors.centerIn: parent
                                    text: dayCell.modelData.day.toString()
                                    font.family: root.barState.themeFontInterface
                                    font.pixelSize: 11
                                    font.weight: dayCell.modelData.isToday ? Font.Bold : Font.Normal
                                    color: dayCell.modelData.currentMonth ? (dayCell.modelData.isToday ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.90)) : Qt.rgba(1, 1, 1, 0.25)
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (dayCell.modelData.currentMonth) {
                                            root.selectedDay = dayCell.modelData.day;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
