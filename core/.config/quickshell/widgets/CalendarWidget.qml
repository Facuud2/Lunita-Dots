import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    property var widgetsState

    readonly property bool isSmall: root.width <= 220
    readonly property bool isMedium: root.width > 220 && root.height <= 240
    readonly property bool isLarge: root.width > 220 && root.height > 240

    readonly property bool isDark: root.widgetsState ? root.widgetsState.isDarkTheme : false
    readonly property real cardRadius: root.widgetsState ? root.widgetsState.cardRadius : 22
    readonly property string fontFamily: "SF Pro Display, SF Pro Text, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, sans-serif"

    // ── Apple iOS Color Tokens ──────────────────────────────────────────────
    readonly property color cardBgColor: isDark ? (root.widgetsState ? root.widgetsState.cardBg : "#1C1C1E") : "#FFFFFF"
    readonly property color cardBorderColor: isDark ? (root.widgetsState ? root.widgetsState.cardBorder : Qt.rgba(1, 1, 1, 0.10)) : Qt.rgba(0, 0, 0, 0.04)
    readonly property color redAccentColor: isDark ? "#FF453A" : "#E0483C"
    readonly property color textPrimaryColor: isDark ? "#FFFFFF" : "#000000"
    readonly property color textSecondaryColor: isDark ? "#98989D" : "#8E8E93"
    readonly property color gridLineColor: isDark ? Qt.rgba(1, 1, 1, 0.12) : "#E5E5EA"

    // ── Live Date and Time State ───────────────────────────────────────────
    property date nowTime: new Date()

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: root.nowTime = new Date()
    }

    readonly property int currentHour: root.nowTime.getHours()
    readonly property int currentMinute: root.nowTime.getMinutes()

    readonly property string todayWeekday: {
        if (root.widgetsState && root.widgetsState.calWeekday)
            return root.widgetsState.calWeekday.toUpperCase();
        var days = ["DOMINGO", "LUNES", "MARTES", "MIÉRCOLES", "JUEVES", "VIERNES", "SÁBADO"];
        return days[root.nowTime.getDay()];
    }

    readonly property string todayDayNum: {
        if (root.widgetsState && root.widgetsState.calToday)
            return root.widgetsState.calToday;
        return root.nowTime.getDate().toString();
    }

    function formatDateKey(d) {
        var y = d.getFullYear();
        var m = String(d.getMonth() + 1).padStart(2, "0"); // taste-skill-ignore
        var day = String(d.getDate()).padStart(2, "0"); // taste-skill-ignore
        return y + "-" + m + "-" + day;
    }

    readonly property string todayKey: formatDateKey(root.nowTime)
    readonly property string tomorrowKey: formatDateKey(new Date(root.nowTime.getTime() + 86400000))

    readonly property var todayEvents: {
        if (root.widgetsState && root.widgetsState.calEvents && root.widgetsState.calEvents[todayKey])
            return root.widgetsState.calEvents[todayKey];
        return [];
    }

    readonly property var tomorrowEvents: {
        if (root.widgetsState && root.widgetsState.calEvents && root.widgetsState.calEvents[tomorrowKey])
            return root.widgetsState.calEvents[tomorrowKey];
        return [];
    }

    // ── Formateo de Horas (12h sin sufijo según diseño de Apple) ────────────
    function formatHour(h) {
        var h12 = h % 12;
        return (h12 === 0 ? 12 : h12).toString();
    }

    // Calcula la hora de inicio en el timeline izquierdo para centrar el indicador actual
    function computeLeftStartHour() {
        var ch = root.currentHour;
        if (ch < 10) return 10;
        if (ch >= 10 && ch <= 13) return 10;
        if (ch >= 14 && ch <= 19) return ch - 1;
        return 10;
    }

    readonly property int leftStartHour: computeLeftStartHour()
    readonly property var leftHoursList: [leftStartHour, leftStartHour + 1, leftStartHour + 2, leftStartHour + 3, leftStartHour + 4]
    readonly property var rightHoursList: [9, 10, 11, 12, 13, 14, 15, 16]

    // Parseo de rango de tiempo para renderizado en timeline ("11:00 - 12:30")
    function parseEventSpan(timeStr) {
        if (!timeStr) return null;
        var parts = timeStr.split("-");
        var sParts = parts[0].trim().split(":");
        var sH = parseInt(sParts[0], 10);
        var sM = parseInt(sParts[1] || "0", 10);
        if (isNaN(sH)) return null;
        var sVal = sH + (isNaN(sM) ? 0 : sM) / 60.0;
        var eVal = sVal + 1.0;
        if (parts.length > 1) {
            var eParts = parts[1].trim().split(":");
            var eH = parseInt(eParts[0], 10);
            var eM = parseInt(eParts[1] || "0", 10);
            if (!isNaN(eH)) {
                eVal = eH + (isNaN(eM) ? 0 : eM) / 60.0;
            }
        }
        return { start: sVal, end: eVal };
    }

    // ── Tarjeta Principal (Squircle iOS) ────────────────────────────────────
    Rectangle {
        id: cardBg

        anchors.fill: parent
        radius: root.cardRadius
        clip: true
        color: root.cardBgColor
        border.color: root.cardBorderColor
        border.width: 1
        scale: cardMa.pressed ? 0.985 : 1.0

        Behavior on scale {
            NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
        }

        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        // Interacción nativa: clic abre el Gestor de Calendario
        MouseArea {
            id: cardMa

            anchors.fill: parent
            enabled: !root.widgetsState || !root.widgetsState.isEditing
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                Quickshell.execDetached(["lunita-widgets-manager", "calendar"]);
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 1. MODO COMPACTO / PEQUEÑO (170 x 170): EXACTO A IMAGEN 1 ────
        // ═══════════════════════════════════════════════════════════════════
        Item {
            id: smallView

            anchors.fill: parent
            visible: root.isSmall

            // Cabecera superior izquierda
            ColumnLayout {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.leftMargin: Math.round(parent.width * 0.12)
                anchors.topMargin: Math.round(parent.height * 0.11)
                spacing: -4

                Text {
                    text: root.todayWeekday
                    font.family: root.fontFamily
                    font.pixelSize: Math.max(11, Math.round(parent.width * 0.082))
                    font.weight: Font.Bold
                    font.letterSpacing: 0.4
                    color: root.redAccentColor
                }

                Text {
                    text: root.todayDayNum
                    font.family: root.fontFamily
                    font.pixelSize: Math.max(36, Math.round(parent.width * 0.28))
                    font.weight: Font.Normal
                    font.letterSpacing: -1.2
                    color: root.textPrimaryColor
                }
            }

            // Sección inferior: "Sin eventos hoy" o próximo evento
            Item {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.leftMargin: Math.round(parent.width * 0.12)
                anchors.rightMargin: Math.round(parent.width * 0.10)
                anchors.bottomMargin: Math.round(parent.height * 0.13)
                height: 38

                // Estado vacío exacto a Imagen 1
                Text {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    visible: root.todayEvents.length === 0
                    text: "Sin eventos hoy"
                    font.family: root.fontFamily
                    font.pixelSize: Math.max(12, Math.round(parent.width * 0.085))
                    font.weight: Font.Normal
                    color: root.textSecondaryColor
                }

                // Si hay eventos programados para hoy, mostrar el primero
                RowLayout {
                    anchors.fill: parent
                    visible: root.todayEvents.length > 0
                    spacing: 8

                    Rectangle {
                        Layout.preferredWidth: 3
                        Layout.fillHeight: true
                        radius: 1.5
                        color: root.todayEvents.length > 0 ? (root.todayEvents[0].color || root.redAccentColor) : root.redAccentColor
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: root.todayEvents.length > 0 ? (root.todayEvents[0].title || "Evento") : ""
                            font.family: root.fontFamily
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                            color: root.textPrimaryColor
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: root.todayEvents.length > 0 ? (root.todayEvents[0].time || "") : ""
                            font.family: root.fontFamily
                            font.pixelSize: 10
                            color: root.textSecondaryColor
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 2. MODO EXPANDIDO / GRANDE (354 x 354): EXACTO A IMAGEN 2 ─────
        // ═══════════════════════════════════════════════════════════════════
        Item {
            id: largeView

            anchors.fill: parent
            visible: root.isLarge

            readonly property real colW: Math.round(parent.width * 0.44)
            readonly property real leftX: Math.round(parent.width * 0.05)
            readonly property real rightX: Math.round(parent.width * 0.53)

            readonly property real topHeaderY: Math.round(parent.height * 0.055)
            readonly property real startYLeft: parent.height * 0.255
            readonly property real endYLeft: parent.height * 0.930
            readonly property real stepYLeft: (endYLeft - startYLeft) / 4.0

            readonly property real startYRight: parent.height * 0.142
            readonly property real endYRight: parent.height * 0.930
            readonly property real stepYRight: (endYRight - startYRight) / 7.0

            // ── COLUMNA IZQUIERDA (HOY) ────────────────────────────────────
            Item {
                x: largeView.leftX
                y: 0
                width: largeView.colW
                height: parent.height

                // Cabecera: DOMINGO + 25
                Text {
                    x: 0
                    y: largeView.topHeaderY
                    text: root.todayWeekday
                    font.family: root.fontFamily
                    font.pixelSize: Math.max(11, Math.round(largeView.height * 0.038))
                    font.weight: Font.Bold
                    font.letterSpacing: 0.3
                    color: root.redAccentColor
                }

                Text {
                    x: 0
                    y: Math.round(largeView.topHeaderY + largeView.height * 0.042)
                    text: root.todayDayNum
                    font.family: root.fontFamily
                    font.pixelSize: Math.max(34, Math.round(largeView.height * 0.125))
                    font.weight: Font.Normal
                    font.letterSpacing: -1.2
                    color: root.textPrimaryColor
                }

                // 5 Filas de Horas del Día (10, 11, 12, 1, 2)
                Repeater {
                    model: 5

                    Item {
                        readonly property real lineY: largeView.startYLeft + index * largeView.stepYLeft

                        x: 0
                        y: Math.round(lineY)
                        width: parent.width
                        height: 1

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.top
                            text: root.formatHour(root.leftHoursList[index])
                            font.family: root.fontFamily
                            font.pixelSize: Math.max(10, Math.round(largeView.height * 0.032))
                            font.weight: Font.Normal
                            color: root.textSecondaryColor
                        }

                        // taste-skill-ignore
                        Rectangle {
                            anchors.left: parent.left
                            anchors.leftMargin: 24
                            anchors.right: parent.right
                            anchors.top: parent.top
                            height: 1
                            color: root.gridLineColor
                        }
                    }
                }

                // Eventos de Hoy renderizados en el timeline izquierdo
                Repeater {
                    model: root.todayEvents

                    Item {
                        property var span: root.parseEventSpan(modelData.time)
                        readonly property bool inWindow: span && span.start < (root.leftStartHour + 5) && span.end > root.leftStartHour

                        visible: inWindow
                        x: 28
                        y: span ? Math.round(largeView.startYLeft + (Math.max(root.leftStartHour, span.start) - root.leftStartHour) * largeView.stepYLeft + 2) : 0
                        width: parent.width - 28
                        height: span ? Math.max(22, Math.round((Math.min(root.leftStartHour + 5, span.end) - Math.max(root.leftStartHour, span.start)) * largeView.stepYLeft - 4)) : 0

                        Rectangle {
                            anchors.fill: parent
                            radius: 6
                            color: modelData.color ? Qt.rgba(Qt.color(modelData.color).r, Qt.color(modelData.color).g, Qt.color(modelData.color).b, root.isDark ? 0.28 : 0.14) : Qt.rgba(0.04, 0.52, 1.0, 0.15)
                            clip: true

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: 3
                                radius: 1.5
                                color: modelData.color || root.redAccentColor
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 7
                                anchors.rightMargin: 4
                                anchors.topMargin: 2
                                anchors.bottomMargin: 2
                                spacing: 0

                                Text {
                                    text: modelData.title || ""
                                    font.family: root.fontFamily
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                    color: root.textPrimaryColor
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    visible: parent.height > 26
                                    text: modelData.time || ""
                                    font.family: root.fontFamily
                                    font.pixelSize: 9
                                    color: root.textSecondaryColor
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }

                // Indicador de Hora Actual Roja (Punto + Línea Horizontal)
                Item {
                    readonly property real curTimeVal: root.currentHour + root.currentMinute / 60.0
                    readonly property real offsetVal: curTimeVal - root.leftStartHour
                    readonly property bool isVisibleTime: offsetVal >= 0 && offsetVal <= 4.0

                    visible: isVisibleTime
                    x: 0
                    y: Math.round(largeView.startYLeft + offsetVal * largeView.stepYLeft)
                    width: parent.width
                    height: 6

                    // Punto rojo inicial
                    Rectangle {
                        x: 0
                        anchors.verticalCenter: parent.verticalCenter
                        width: 6
                        height: 6
                        radius: 3
                        color: root.redAccentColor
                    }

                    // Línea roja indicadora
                    Rectangle {
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        height: 1.5
                        color: root.redAccentColor
                    }
                }
            }

            // ── COLUMNA DERECHA (MAÑANA) ───────────────────────────────────
            Item {
                x: largeView.rightX
                y: 0
                width: largeView.colW
                height: parent.height

                // Cabecera: MAÑANA
                Text {
                    x: 0
                    y: largeView.topHeaderY
                    text: "MAÑANA"
                    font.family: root.fontFamily
                    font.pixelSize: Math.max(11, Math.round(largeView.height * 0.038))
                    font.weight: Font.Bold
                    font.letterSpacing: 0.3
                    color: root.textSecondaryColor
                }

                // 8 Filas de Horas de Mañana (9, 10, 11, 12, 1, 2, 3, 4)
                Repeater {
                    model: 8

                    Item {
                        readonly property real lineY: largeView.startYRight + index * largeView.stepYRight

                        x: 0
                        y: Math.round(lineY)
                        width: parent.width
                        height: 1

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.top
                            text: root.formatHour(root.rightHoursList[index])
                            font.family: root.fontFamily
                            font.pixelSize: Math.max(10, Math.round(largeView.height * 0.032))
                            font.weight: Font.Normal
                            color: root.textSecondaryColor
                        }

                        // taste-skill-ignore
                        Rectangle {
                            anchors.left: parent.left
                            anchors.leftMargin: 24
                            anchors.right: parent.right
                            anchors.top: parent.top
                            height: 1
                            color: root.gridLineColor
                        }
                    }
                }

                // Eventos de Mañana renderizados en el timeline derecho
                Repeater {
                    model: root.tomorrowEvents

                    Item {
                        property var span: root.parseEventSpan(modelData.time)
                        readonly property bool inWindow: span && span.start < 17 && span.end > 9

                        visible: inWindow
                        x: 28
                        y: span ? Math.round(largeView.startYRight + (Math.max(9, span.start) - 9) * largeView.stepYRight + 2) : 0
                        width: parent.width - 28
                        height: span ? Math.max(20, Math.round((Math.min(17, span.end) - Math.max(9, span.start)) * largeView.stepYRight - 4)) : 0

                        Rectangle {
                            anchors.fill: parent
                            radius: 6
                            color: modelData.color ? Qt.rgba(Qt.color(modelData.color).r, Qt.color(modelData.color).g, Qt.color(modelData.color).b, root.isDark ? 0.28 : 0.14) : Qt.rgba(0.04, 0.52, 1.0, 0.15)
                            clip: true

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: 3
                                radius: 1.5
                                color: modelData.color || "#0A84FF"
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 7
                                anchors.rightMargin: 4
                                anchors.topMargin: 2
                                anchors.bottomMargin: 2
                                spacing: 0

                                Text {
                                    text: modelData.title || ""
                                    font.family: root.fontFamily
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                    color: root.textPrimaryColor
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    visible: parent.height > 24
                                    text: modelData.time || ""
                                    font.family: root.fontFamily
                                    font.pixelSize: 9
                                    color: root.textSecondaryColor
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 3. MODO MEDIANO (354 x 176): HOY (IZQ) + TIMELINE RESUMIDO (DER)
        // ═══════════════════════════════════════════════════════════════════
        Item {
            id: mediumView

            anchors.fill: parent
            visible: root.isMedium || (!root.isSmall && !root.isLarge)

            // Lado Izquierdo: Fecha grande de Imagen 1
            Item {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: Math.round(parent.width * 0.44)

                ColumnLayout {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.leftMargin: 20
                    anchors.topMargin: 18
                    spacing: -4

                    Text {
                        text: root.todayWeekday
                        font.family: root.fontFamily
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        font.letterSpacing: 0.3
                        color: root.redAccentColor
                    }

                    Text {
                        text: root.todayDayNum
                        font.family: root.fontFamily
                        font.pixelSize: 42
                        font.weight: Font.Normal
                        font.letterSpacing: -1.2
                        color: root.textPrimaryColor
                    }
                }

                // Subtítulo inferior
                Text {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 20
                    anchors.bottomMargin: 18
                    visible: root.todayEvents.length === 0
                    text: "Sin eventos hoy"
                    font.family: root.fontFamily
                    font.pixelSize: 13
                    font.weight: Font.Normal
                    color: root.textSecondaryColor
                }

                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 20
                    anchors.rightMargin: 12
                    anchors.bottomMargin: 18
                    visible: root.todayEvents.length > 0
                    spacing: 6

                    Rectangle {
                        Layout.preferredWidth: 3
                        Layout.preferredHeight: 28
                        radius: 1.5
                        color: root.todayEvents.length > 0 ? (root.todayEvents[0].color || root.redAccentColor) : root.redAccentColor
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Text {
                            text: root.todayEvents.length > 0 ? (root.todayEvents[0].title || "Evento") : ""
                            font.family: root.fontFamily
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            color: root.textPrimaryColor
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: root.todayEvents.length > 0 ? (root.todayEvents[0].time || "") : ""
                            font.family: root.fontFamily
                            font.pixelSize: 9
                            color: root.textSecondaryColor
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }
            }

            // Lado Derecho: Timeline resumido de 4 horas con indicador rojo
            Item {
                readonly property real medStartY: 22
                readonly property real medEndY: parent.height - 22
                readonly property real medStepY: (medEndY - medStartY) / 3.0

                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: 16
                anchors.rightMargin: 18
                width: Math.round(parent.width * 0.50)

                // 4 Filas de Horas (ej. 10, 11, 12, 1)
                Repeater {
                    model: 4

                    Item {
                        readonly property real lineY: parent.medStartY + index * parent.medStepY

                        x: 0
                        y: Math.round(lineY)
                        width: parent.width
                        height: 1

                        Text {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.top
                            text: root.formatHour(root.leftHoursList[index])
                            font.family: root.fontFamily
                            font.pixelSize: 10
                            font.weight: Font.Normal
                            color: root.textSecondaryColor
                        }

                        // taste-skill-ignore
                        Rectangle {
                            anchors.left: parent.left
                            anchors.leftMargin: 22
                            anchors.right: parent.right
                            anchors.top: parent.top
                            height: 1
                            color: root.gridLineColor
                        }
                    }
                }

                // Eventos de hoy en modo mediano
                Repeater {
                    model: root.todayEvents

                    Item {
                        property var span: root.parseEventSpan(modelData.time)
                        readonly property bool inWindow: span && span.start < (root.leftStartHour + 4) && span.end > root.leftStartHour

                        visible: inWindow
                        x: 26
                        y: span ? Math.round(parent.medStartY + (Math.max(root.leftStartHour, span.start) - root.leftStartHour) * parent.medStepY + 2) : 0
                        width: parent.width - 26
                        height: span ? Math.max(18, Math.round((Math.min(root.leftStartHour + 4, span.end) - Math.max(root.leftStartHour, span.start)) * parent.medStepY - 4)) : 0

                        Rectangle {
                            anchors.fill: parent
                            radius: 5
                            color: modelData.color ? Qt.rgba(Qt.color(modelData.color).r, Qt.color(modelData.color).g, Qt.color(modelData.color).b, root.isDark ? 0.28 : 0.14) : Qt.rgba(0.04, 0.52, 1.0, 0.15)
                            clip: true

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: 2.5
                                radius: 1.25
                                color: modelData.color || root.redAccentColor
                            }

                            Text {
                                anchors.fill: parent
                                anchors.leftMargin: 6
                                anchors.rightMargin: 4
                                verticalAlignment: Text.AlignVCenter
                                text: modelData.title || ""
                                font.family: root.fontFamily
                                font.pixelSize: 10
                                font.weight: Font.DemiBold
                                color: root.textPrimaryColor
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                // Indicador de hora actual roja en modo mediano
                Item {
                    readonly property real curTimeVal: root.currentHour + root.currentMinute / 60.0
                    readonly property real offsetVal: curTimeVal - root.leftStartHour
                    readonly property bool isVisibleTime: offsetVal >= 0 && offsetVal <= 3.0

                    visible: isVisibleTime
                    x: 0
                    y: Math.round(parent.medStartY + offsetVal * parent.medStepY)
                    width: parent.width
                    height: 6

                    Rectangle {
                        x: 0
                        anchors.verticalCenter: parent.verticalCenter
                        width: 5
                        height: 5
                        radius: 2.5
                        color: root.redAccentColor
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.leftMargin: 7
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        height: 1.5
                        color: root.redAccentColor
                    }
                }
            }
        }
    }
}
