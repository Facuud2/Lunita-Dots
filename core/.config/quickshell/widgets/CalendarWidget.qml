import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property var widgetsState
    property bool addEventModalOpen: false
    readonly property bool isSmall: root.width <= 220
    readonly property bool isMedium: root.width > 220 && root.height <= 240
    readonly property bool isLarge: root.width > 220 && root.height > 240

    Rectangle {
        id: cardBg

        anchors.fill: parent
        radius: root.widgetsState ? root.widgetsState.cardRadius : 22
        clip: true
        color: root.widgetsState ? root.widgetsState.cardBg : "#222328"
        border.color: root.widgetsState ? root.widgetsState.cardBorder : Qt.rgba(1, 1, 1, 0.12)
        border.width: 1

        // ═══════════════════════════════════════════════════════════════════
        // ── 1. MODO COMPACTO (170 x 170): CALENDARIO EXACTO DE LA IMAGEN ──
        // ═══════════════════════════════════════════════════════════════════
        Item {
            anchors.fill: parent
            visible: root.isSmall

            MonthGridComponent {
                anchors.fill: parent
            }

        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 2. MODO MEDIANO (354 x 170): CALENDARIO + AGENDA / EVENTOS ──
        // ═══════════════════════════════════════════════════════════════════
        Item {
            anchors.fill: parent
            visible: root.isMedium || (!root.isSmall && !root.isLarge)

            RowLayout {
                anchors.fill: parent
                spacing: 0

                // Lado izquierdo: Cuadrícula mensual (170px fija)
                MonthGridComponent {
                    Layout.preferredWidth: 170
                    Layout.fillHeight: true
                }

                // Separador sutil
                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.fillHeight: true
                    color: Qt.rgba(1, 1, 1, 0.1)
                }

                // Lado derecho: Agenda de eventos del día
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 6

                        // Cabecera: Día seleccionado + Botón añadir (+)
                        RowLayout {
                            Layout.fillWidth: true

                            ColumnLayout {
                                spacing: 1

                                Text {
                                    text: "HOY"
                                    font.family: "SF Pro Display"
                                    font.pixelSize: 9
                                    font.weight: Font.Bold
                                    font.letterSpacing: 0.5
                                    color: "#FF453A"
                                }

                                Text {
                                    text: (root.widgetsState ? root.widgetsState.calSelectedDay : "29") + " de " + (root.widgetsState ? root.widgetsState.calMonthName : "Septiembre")
                                    font.family: "SF Pro Display"
                                    font.pixelSize: 12
                                    font.weight: Font.Bold
                                    color: "#FFFFFF"
                                    elide: Text.ElideRight
                                }

                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            // Botón Añadir Evento (+)
                            Rectangle {
                                width: 22
                                height: 22
                                radius: 11
                                color: addMa.containsMouse ? "rgba(255, 255, 255, 0.20)" : "rgba(255, 255, 255, 0.10)"

                                Text {
                                    anchors.centerIn: parent
                                    text: "+"
                                    font.family: "SF Pro Display"
                                    font.pixelSize: 14
                                    font.weight: Font.Bold
                                    color: "#FFFFFF"
                                }

                                MouseArea {
                                    id: addMa

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.addEventModalOpen = true
                                }

                            }

                        }

                        // Lista de eventos
                        ListView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            model: root.widgetsState ? root.widgetsState.calSelectedEvents : []
                            spacing: 4

                            // Estado vacío cuando no hay eventos
                            Text {
                                anchors.centerIn: parent
                                visible: !root.widgetsState || !root.widgetsState.calSelectedEvents || root.widgetsState.calSelectedEvents.length === 0
                                text: "Sin eventos hoy"
                                font.family: "SF Pro Display"
                                font.pixelSize: 11
                                color: Qt.rgba(1, 1, 1, 0.45)
                            }

                            delegate: Rectangle {
                                width: parent ? parent.width : 160
                                height: 34
                                radius: 8
                                color: Qt.rgba(1, 1, 1, 0.07)

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    spacing: 6

                                    Text {
                                        text: {
                                            var s = modelData.shape || "circle";
                                            if (s === "star")
                                                return "★";

                                            if (s === "triangle")
                                                return "▲";

                                            if (s === "square")
                                                return "■";

                                            return "●";
                                        }
                                        font.pixelSize: 11
                                        color: modelData.color || "#0A84FF"
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 1

                                        Text {
                                            text: modelData.title || "Evento"
                                            font.family: "SF Pro Display"
                                            font.pixelSize: 11
                                            font.weight: Font.DemiBold
                                            color: "#FFFFFF"
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }

                                        Text {
                                            text: modelData.time || ""
                                            font.family: "SF Pro Display"
                                            font.pixelSize: 9
                                            color: Qt.rgba(1, 1, 1, 0.6)
                                        }

                                    }

                                }

                            }

                        }

                    }

                }

            }

        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 3. MODO EXPANDIDO (354 x 354): CALENDARIO + AGENDA COMPLETA ──
        // ═══════════════════════════════════════════════════════════════════
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10
            visible: root.isLarge

            // Mitad Superior: Calendario
            MonthGridComponent {
                Layout.fillWidth: true
                Layout.preferredHeight: 160
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(1, 1, 1, 0.12)
            }

            // Mitad Inferior: Agenda completa
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "EVENTOS Y RECORDATORIOS"
                    font.family: "SF Pro Display"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    font.letterSpacing: 0.6
                    color: Qt.rgba(1, 1, 1, 0.55)
                }

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    width: 20
                    height: 20
                    radius: 10
                    color: Qt.rgba(1, 1, 1, 0.1)

                    Text {
                        anchors.centerIn: parent
                        text: "+"
                        font.family: "SF Pro Display"
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.addEventModalOpen = true
                    }

                }

            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: root.widgetsState ? root.widgetsState.calSelectedEvents : []
                spacing: 6

                Text {
                    anchors.centerIn: parent
                    visible: !root.widgetsState || !root.widgetsState.calSelectedEvents || root.widgetsState.calSelectedEvents.length === 0
                    text: "No hay eventos programados para este día"
                    font.family: "SF Pro Display"
                    font.pixelSize: 11
                    color: Qt.rgba(1, 1, 1, 0.45)
                }

                delegate: Rectangle {
                    width: parent ? parent.width : 320
                    height: 38
                    radius: 8
                    color: Qt.rgba(1, 1, 1, 0.07)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 8

                        Text {
                            text: {
                                var s = modelData.shape || "circle";
                                if (s === "star")
                                    return "★";

                                if (s === "triangle")
                                    return "▲";

                                if (s === "square")
                                    return "■";

                                return "●";
                            }
                            font.pixelSize: 12
                            color: modelData.color || "#0A84FF"
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1

                            Text {
                                text: modelData.title || ""
                                font.family: "SF Pro Display"
                                font.pixelSize: 12
                                font.weight: Font.DemiBold
                                color: "#FFFFFF"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Text {
                                text: modelData.time || ""
                                font.family: "SF Pro Display"
                                font.pixelSize: 10
                                color: Qt.rgba(1, 1, 1, 0.6)
                            }

                        }

                    }

                }

            }

        }

        // ═══════════════════════════════════════════════════════════════════
        // ── MODAL: AÑADIR NUEVO EVENTO ──
        // ═══════════════════════════════════════════════════════════════════
        Rectangle {
            id: addEventModal

            property string selectedShape: "circle"

            visible: root.addEventModalOpen
            anchors.centerIn: parent
            width: Math.min(parent.width - 24, 250)
            height: modalCol.implicitHeight + 20
            radius: 14
            color: root.widgetsState && root.widgetsState.isDarkTheme ? "#1E1E24" : "#FFFFFF"
            border.color: root.widgetsState ? root.widgetsState.cardBorder : "rgba(255,255,255,0.2)"
            border.width: 1
            z: 200

            ColumnLayout {
                id: modalCol

                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                Text {
                    text: "Añadir Evento"
                    font.family: "SF Pro Display"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 26
                    radius: 6
                    color: Qt.rgba(1, 1, 1, 0.1)
                    border.color: Qt.rgba(1, 1, 1, 0.15)
                    border.width: 1

                    TextInput {
                        id: evTitleInput

                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                        color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"
                        clip: true

                        Text {
                            text: "Título del evento"
                            font.family: "SF Pro Display"
                            font.pixelSize: 11
                            color: Qt.rgba(1, 1, 1, 0.45)
                            visible: !evTitleInput.text && !evTitleInput.activeFocus
                            anchors.verticalCenter: parent.verticalCenter
                        }

                    }

                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 26
                    radius: 6
                    color: Qt.rgba(1, 1, 1, 0.1)
                    border.color: Qt.rgba(1, 1, 1, 0.15)
                    border.width: 1

                    TextInput {
                        id: evTimeInput

                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                        color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"
                        text: "15:00 - 16:00"
                        clip: true
                    }

                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Repeater {
                        model: [{
                            "shape": "circle",
                            "label": "●"
                        }, {
                            "shape": "star",
                            "label": "★"
                        }, {
                            "shape": "triangle",
                            "label": "▲"
                        }, {
                            "shape": "square",
                            "label": "■"
                        }]

                        Rectangle {
                            Layout.fillWidth: true
                            height: 22
                            radius: 5
                            color: addEventModal.selectedShape === modelData.shape ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(1, 1, 1, 0.08)
                            border.color: addEventModal.selectedShape === modelData.shape ? "#FFFFFF" : "transparent"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: modelData.label
                                font.pixelSize: 11
                                color: "#FFFFFF"
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: addEventModal.selectedShape = modelData.shape
                            }

                        }

                    }

                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        Layout.fillWidth: true
                        height: 24
                        radius: 6
                        color: "transparent"
                        border.color: Qt.rgba(1, 1, 1, 0.2)
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "Cancelar"
                            font.family: "SF Pro Display"
                            font.pixelSize: 11
                            color: Qt.rgba(1, 1, 1, 0.7)
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.addEventModalOpen = false
                        }

                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 24
                        radius: 6
                        color: "#0A84FF"

                        Text {
                            anchors.centerIn: parent
                            text: "Guardar"
                            font.family: "SF Pro Display"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: "#FFFFFF"
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (evTitleInput.text.trim() !== "") {
                                    if (root.widgetsState)
                                        root.widgetsState.addCalendarEvent(root.widgetsState.calSelectedDateStr, evTimeInput.text.trim(), evTitleInput.text.trim(), "General", "#0A84FF", addEventModal.selectedShape);

                                    evTitleInput.text = "";
                                    root.addEventModalOpen = false;
                                }
                            }
                        }

                    }

                }

            }

        }

        // ═══════════════════════════════════════════════════════════════════
        // ── COMPONENTE REUTILIZABLE: CUADRÍCULA MENSUAL macOS ──
        // ═══════════════════════════════════════════════════════════════════
        component MonthGridComponent: Item {
            id: mGrid

            implicitWidth: 170
            implicitHeight: 170

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: 12
                anchors.bottomMargin: 10
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 4

                // 1. Título del Mes en Rojo Mayúscula (Exacto a la imagen)
                Text {
                    text: root.widgetsState ? root.widgetsState.calMonthName : "SEPTIEMBRE"
                    font.family: "SF Pro Display, Inter, -apple-system, sans-serif"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    font.letterSpacing: 0.8
                    color: "#FF453A" // Rojo vibrante macOS
                }

                // 2. Fila de Días de la Semana: M T W T F S S
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    Repeater {
                        model: root.widgetsState ? root.widgetsState.calWeekdays : ["M", "T", "W", "T", "F", "S", "S"]

                        Item {
                            Layout.fillWidth: true
                            height: 16

                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                font.family: "SF Pro Display, Inter, sans-serif"
                                font.pixelSize: 10
                                font.weight: Font.Bold
                                color: Qt.rgba(1, 1, 1, 0.5)
                            }

                        }

                    }

                }

                // 3. Filas de Días del Mes
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 1

                    Repeater {
                        model: root.widgetsState ? root.widgetsState.calWeeks : []

                        RowLayout {
                            property var weekData: modelData

                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 0

                            Repeater {
                                model: weekData

                                Item {
                                    readonly property bool inMonth: modelData.in_month
                                    readonly property bool isToday: modelData.is_today
                                    readonly property bool isSelected: inMonth && (modelData.day.toString() === (root.widgetsState ? root.widgetsState.calSelectedDay.toString() : ""))

                                    Layout.fillWidth: true
                                    Layout.fillHeight: true

                                    // Círculo rojo para el día actual o selección
                                    Rectangle {
                                        id: dayBadge

                                        anchors.centerIn: parent
                                        width: 20
                                        height: 20
                                        radius: 10
                                        visible: isToday || isSelected
                                        color: isToday ? "#FF453A" : Qt.rgba(0.04, 0.52, 1, 0.35)
                                    }

                                    // Texto del día
                                    Text {
                                        anchors.centerIn: parent
                                        visible: inMonth
                                        text: modelData.day
                                        font.family: "SF Pro Display, Inter, sans-serif"
                                        font.pixelSize: 11
                                        font.weight: isToday ? Font.Bold : Font.Normal
                                        font.italic: false
                                        color: isToday ? "#FFFFFF" : (inMonth ? Qt.rgba(1, 1, 1, 0.9) : "transparent")
                                    }

                                    // Marcador geométrico del evento
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.bottom: parent.bottom
                                        anchors.bottomMargin: 0
                                        visible: inMonth && (modelData.has_events || false)
                                        text: {
                                            var s = modelData.marker_shape || "circle";
                                            if (s === "star")
                                                return "★";

                                            if (s === "triangle")
                                                return "▲";

                                            if (s === "square")
                                                return "■";

                                            return "●";
                                        }
                                        font.pixelSize: 6
                                        color: isToday ? "#FFFFFF" : (modelData.dot_color || "#0A84FF")
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        enabled: inMonth && (root.widgetsState ? !root.widgetsState.isEditing : true)
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (root.widgetsState)
                                                root.widgetsState.selectCalendarDay(modelData.day);

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
