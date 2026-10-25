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

    // ── Apple Notes Color Tokens ────────────────────────────────────────────
    readonly property color cardBgColor: isDark ? (root.widgetsState ? root.widgetsState.cardBg : "#1C1C1E") : "#FFFFFF"
    readonly property color cardBorderColor: isDark ? (root.widgetsState ? root.widgetsState.cardBorder : Qt.rgba(1, 1, 1, 0.10)) : Qt.rgba(0, 0, 0, 0.04)
    readonly property color yellowHeaderColor: "#FCC603"
    readonly property color textPrimaryColor: isDark ? "#FFFFFF" : "#000000"
    readonly property color textSecondaryColor: isDark ? "#98989D" : "#8E8E93"
    readonly property color dividerColor: isDark ? Qt.rgba(1, 1, 1, 0.12) : "#E2E2E3"
    readonly property color perforationColor: isDark ? Qt.rgba(1, 1, 1, 0.20) : "#D1D1D6"
    readonly property color inputBgColor: isDark ? Qt.rgba(255, 255, 255, 0.06) : Qt.rgba(0, 0, 0, 0.04)

    // ── Fallback Notes matching reference images ────────────────────────────
    readonly property var fallbackNotes: [
        {
            "id": "n1",
            "title": "Nueva nota",
            "body": "Nota a mano",
            "date": "miércoles",
            "has_thumbnail": true
        },
        {
            "id": "n2",
            "title": "Gabriela Gama",
            "body": "No hay texto adicional",
            "date": "martes",
            "has_thumbnail": false
        },
        {
            "id": "n3",
            "title": "Manifestations",
            "body": "No hay texto adicional",
            "date": "martes",
            "has_thumbnail": false
        },
        {
            "id": "n4",
            "title": "Luli Dayli",
            "body": "No soy ni influencer, ni tiktoker, ni instagramer...",
            "date": "9/11/26",
            "has_thumbnail": false
        },
        {
            "id": "n5",
            "title": "Success Story",
            "body": "No hay texto adicional",
            "date": "9/8/26",
            "has_thumbnail": false
        },
        {
            "id": "n6",
            "title": "D - Personal",
            "body": "Rompe los estándares normales. A ella le gusta...",
            "date": "8/30/26",
            "has_thumbnail": false
        }
    ]

    readonly property var notesList: {
        if (root.widgetsState && root.widgetsState.ttNotesList && root.widgetsState.ttNotesList.length > 0)
            return root.widgetsState.ttNotesList;
        return fallbackNotes;
    }

    // ── Estados de Interacción y Navegación ─────────────────────────────────
    // Modos posibles: "list" (listado de notas), "detail" (vista completa), "create" (redactar nueva nota)
    property string viewMode: "list"
    property var selectedNote: null

    // Navegación en modo compacto / pequeño
    property int activeNoteIndex: 0
    property real lastWheelTime: 0
    property real dragOffsetY: 0
    property bool isDragging: false

    readonly property var currentNote: {
        var list = root.notesList;
        if (!list || list.length === 0)
            return null;
        var idx = Math.max(0, Math.min(root.activeNoteIndex, list.length - 1));
        return list[idx];
    }

    function nextNote() {
        if (!root.notesList || root.notesList.length <= 1)
            return;
        if (root.activeNoteIndex < root.notesList.length - 1)
            root.activeNoteIndex++;
        else
            root.activeNoteIndex = 0;
    }

    function prevNote() {
        if (!root.notesList || root.notesList.length <= 1)
            return;
        if (root.activeNoteIndex > 0)
            root.activeNoteIndex--;
        else
            root.activeNoteIndex = root.notesList.length - 1;
    }

    function openNoteDetail(noteItem) {
        root.selectedNote = noteItem;
        root.viewMode = "detail";
    }

    function saveNewNote() {
        var title = createTitleInput.text.trim();
        var body = createBodyInput.text.trim();
        if (!title && !body) {
            root.viewMode = "list";
            return;
        }
        if (!title) {
            var lines = body.split("\n");
            title = lines[0].substring(0, 32).trim() || "Nueva nota";
        }

        var now = new Date();
        var days = ["domingo", "lunes", "martes", "miércoles", "jueves", "viernes", "sábado"];
        var dateStr = days[now.getDay()];

        if (root.widgetsState && root.widgetsState.addTimetableNote) {
            root.widgetsState.addTimetableNote(title, body, dateStr, "#FCC603");
        }

        createTitleInput.text = "";
        createBodyInput.text = "";
        root.activeNoteIndex = 0;
        root.viewMode = "list";
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

        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── CABECERA AMARILLA (APPLE NOTES NATIVE STYLE) ───────────────────
        // ═══════════════════════════════════════════════════════════════════
        Item {
            id: headerArea

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: root.isLarge ? 48 : 40
            z: 10

            // Fondo amarillo con esquinas superiores redondeadas
            Rectangle {
                anchors.fill: parent
                radius: root.cardRadius
                color: root.yellowHeaderColor

                // Esquinas inferiores rectas
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: root.cardRadius
                    color: root.yellowHeaderColor
                }
            }

            // ── Contenido de Cabecera según viewMode ────────────────────────
            // MODO LISTA: Carpeta + "Notas" + Botón '+'
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 8
                visible: root.viewMode === "list"

                Item {
                    Layout.preferredWidth: folderTextRow.width
                    Layout.fillHeight: true

                    RowLayout {
                        id: folderTextRow
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 7

                        // Icono vectorial de Carpeta Apple Notes
                        Canvas {
                            id: folderCanvas
                            Layout.preferredWidth: 20
                            Layout.preferredHeight: 15
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.reset();
                                ctx.strokeStyle = "#FFFFFF";
                                ctx.lineWidth = 1.8;
                                ctx.lineJoin = "round";
                                ctx.lineCap = "round";
                                ctx.beginPath();
                                ctx.moveTo(3, 13.5);
                                ctx.lineTo(17.5, 13.5);
                                ctx.arcTo(19, 13.5, 19, 12, 1.8);
                                ctx.lineTo(19, 5);
                                ctx.arcTo(19, 3.5, 17.5, 3.5, 1.8);
                                ctx.lineTo(10, 3.5);
                                ctx.lineTo(8.5, 1.8);
                                ctx.arcTo(7.5, 1, 6, 1, 1.5);
                                ctx.lineTo(2.5, 1);
                                ctx.arcTo(1, 1, 1, 2.5, 1.8);
                                ctx.lineTo(1, 12);
                                ctx.arcTo(1, 13.5, 2.5, 13.5, 1.8);
                                ctx.closePath();
                                ctx.stroke();
                            }
                        }

                        Text {
                            text: "Notas"
                            font.family: root.fontFamily
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                            color: "#FFFFFF"
                        }
                    }

                    // Clic en el título abre el gestor externo
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            Quickshell.execDetached(["lunita-widgets-manager", "timetable"]);
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                // Indicador de posición en modo pequeño
                Text {
                    visible: root.isSmall && root.notesList && root.notesList.length > 1
                    text: (root.activeNoteIndex + 1) + "/" + root.notesList.length
                    font.family: root.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: Qt.rgba(1, 1, 1, 0.85)
                    Layout.alignment: Qt.AlignVCenter
                }

                // Botón Acción Rápida '+' para Crear Nota Directamente
                Rectangle {
                    id: addBtn
                    Layout.preferredWidth: 26
                    Layout.preferredHeight: 26
                    radius: 13
                    color: addMa.containsMouse ? Qt.rgba(1, 1, 1, 0.35) : Qt.rgba(1, 1, 1, 0.20)
                    scale: addMa.pressed ? 0.92 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 100 }
                    }

                    Behavior on color {
                        ColorAnimation { duration: 120 }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "+"
                        font.family: root.fontFamily
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                        anchors.verticalCenterOffset: -1
                    }

                    MouseArea {
                        id: addMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            createTitleInput.text = "";
                            createBodyInput.text = "";
                            root.viewMode = "create";
                        }
                    }
                }
            }

            // MODO DETALLE: Botón '< Atrás' + Título de Nota + Botón Eliminar
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 12
                spacing: 6
                visible: root.viewMode === "detail"

                // Botón '< Atrás'
                Rectangle {
                    id: backBtn
                    Layout.preferredHeight: 28
                    Layout.preferredWidth: backContentRow.width + 12
                    radius: 14
                    color: backMa.containsMouse ? Qt.rgba(1, 1, 1, 0.30) : Qt.rgba(1, 1, 1, 0.15)
                    scale: backMa.pressed ? 0.95 : 1.0

                    RowLayout {
                        id: backContentRow
                        anchors.centerIn: parent
                        spacing: 3

                        Text {
                            text: "‹"
                            font.family: root.fontFamily
                            font.pixelSize: 19
                            font.weight: Font.Bold
                            color: "#FFFFFF"
                            anchors.verticalCenterOffset: -1
                        }

                        Text {
                            text: "Notas"
                            font.family: root.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                            color: "#FFFFFF"
                        }
                    }

                    MouseArea {
                        id: backMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.viewMode = "list";
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                // Botón Borrar Nota
                Rectangle {
                    id: delBtn
                    Layout.preferredWidth: 26
                    Layout.preferredHeight: 26
                    radius: 13
                    color: delMa.containsMouse ? Qt.rgba(255, 59, 48, 0.85) : Qt.rgba(1, 1, 1, 0.20)
                    scale: delMa.pressed ? 0.92 : 1.0

                    Canvas {
                        anchors.centerIn: parent
                        width: 13
                        height: 14
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            ctx.strokeStyle = "#FFFFFF";
                            ctx.lineWidth = 1.3;
                            ctx.lineCap = "round";
                            ctx.beginPath();
                            ctx.moveTo(1.5, 4);
                            ctx.lineTo(11.5, 4);
                            ctx.moveTo(4.5, 4);
                            ctx.lineTo(4.5, 2);
                            ctx.lineTo(8.5, 2);
                            ctx.lineTo(8.5, 4);
                            ctx.moveTo(2.5, 4);
                            ctx.lineTo(3.2, 12);
                            ctx.arcTo(3.5, 13, 4.5, 13, 1);
                            ctx.lineTo(8.5, 13);
                            ctx.arcTo(9.5, 13, 9.8, 12, 1);
                            ctx.lineTo(10.5, 4);
                            ctx.stroke();
                        }
                    }

                    MouseArea {
                        id: delMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.selectedNote && root.selectedNote.id && root.widgetsState && root.widgetsState.deleteTimetableNote) {
                                root.widgetsState.deleteTimetableNote(root.selectedNote.id);
                            }
                            root.viewMode = "list";
                        }
                    }
                }
            }

            // MODO CREAR: 'Cancelar' + 'Nueva Nota' + 'Listo'
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 6
                visible: root.viewMode === "create"

                Rectangle {
                    Layout.preferredHeight: 26
                    Layout.preferredWidth: cancelTxt.width + 12
                    radius: 13
                    color: cancelMa.containsMouse ? Qt.rgba(1, 1, 1, 0.25) : "transparent"

                    Text {
                        id: cancelTxt
                        anchors.centerIn: parent
                        text: "Cancelar"
                        font.family: root.fontFamily
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        id: cancelMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.viewMode = "list";
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: "Nueva Nota"
                    font.family: root.fontFamily
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    color: "#FFFFFF"
                    Layout.alignment: Qt.AlignVCenter
                }

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    Layout.preferredHeight: 26
                    Layout.preferredWidth: saveTxt.width + 16
                    radius: 13
                    color: saveMa.containsMouse ? Qt.rgba(1, 1, 1, 0.45) : Qt.rgba(1, 1, 1, 0.28)
                    scale: saveMa.pressed ? 0.94 : 1.0

                    Text {
                        id: saveTxt
                        anchors.centerIn: parent
                        text: "Listo"
                        font.family: root.fontFamily
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        id: saveMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.saveNewNote();
                        }
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── LÍNEA PERFORADA DE PUNTOS (ESTILO BLOCK DE NOTAS APPLE) ───────
        // ═══════════════════════════════════════════════════════════════════
        Row {
            id: perforationRow

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            anchors.top: headerArea.bottom
            anchors.topMargin: 4
            spacing: 5
            clip: true
            z: 9

            Repeater {
                model: Math.floor(perforationRow.width / 7)

                Rectangle {
                    width: 2
                    height: 2
                    radius: 1
                    color: root.perforationColor
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── CONTENIDO PRINCIPAL: LISTADO DE NOTAS ─────────────────────────
        // ═══════════════════════════════════════════════════════════════════
        Item {
            id: listContainer

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.top: perforationRow.bottom
            anchors.topMargin: 2
            visible: root.viewMode === "list"

            // ───────────────────────────────────────────────────────────────
            // 1. MODO COMPACTO / PEQUEÑO (170 x 170): GESTO VERTICAL SWIPE
            // ───────────────────────────────────────────────────────────────
            Item {
                id: smallView

                anchors.fill: parent
                visible: root.isSmall

                // Gesto de Arrastre Vertical (DragHandler)
                DragHandler {
                    id: smallDragHandler
                    target: null
                    xAxis.enabled: false
                    yAxis.enabled: true
                    onActiveChanged: {
                        if (!active) {
                            if (root.dragOffsetY < -25) {
                                root.nextNote();
                            } else if (root.dragOffsetY > 25) {
                                root.prevNote();
                            }
                            root.dragOffsetY = 0;
                            root.isDragging = false;
                        } else {
                            root.isDragging = true;
                        }
                    }
                    onTranslationChanged: {
                        if (active) {
                            root.dragOffsetY = Math.max(-45, Math.min(45, translation.y));
                        }
                    }
                }

                // Gesto con rueda del ratón / touchpad
                WheelHandler {
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    onWheel: (event) => {
                        var now = Date.now();
                        if (now - root.lastWheelTime > 150) {
                            root.lastWheelTime = now;
                            if (event.angleDelta.y < 0)
                                root.nextNote();
                            else if (event.angleDelta.y > 0)
                                root.prevNote();
                        }
                    }
                }

                // Contenedor visual reactivo al desplazamiento táctil
                Item {
                    id: noteSmallContent
                    anchors.fill: parent
                    y: root.dragOffsetY

                    Behavior on y {
                        enabled: !root.isDragging
                        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
                    }

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        anchors.topMargin: 14
                        spacing: 4

                        Text {
                            text: root.currentNote ? (root.currentNote.title || "Nueva nota") : "Nueva nota"
                            font.family: root.fontFamily
                            font.pixelSize: 15
                            font.weight: Font.DemiBold
                            color: root.textPrimaryColor
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: root.currentNote ? (root.currentNote.body || "Nota a mano") : "Nota a mano"
                            font.family: root.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.Normal
                            color: root.textSecondaryColor
                            elide: Text.ElideRight
                            maximumLineCount: 2
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }
                    }

                    // Fecha fijada en la parte inferior izquierda
                    Text {
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        anchors.leftMargin: 16
                        anchors.bottomMargin: 14
                        text: root.currentNote ? (root.currentNote.date || "miércoles") : "miércoles"
                        font.family: root.fontFamily
                        font.pixelSize: 13
                        font.weight: Font.Normal
                        color: root.textSecondaryColor
                    }

                    // Clic para abrir vista de detalle
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.currentNote) {
                                root.openNoteDetail(root.currentNote);
                            }
                        }
                    }
                }

                // Micro-indicador vertical de página estilo Apple Smart Stack
                Column {
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 4
                    visible: root.notesList && root.notesList.length > 1

                    Repeater {
                        model: Math.min(root.notesList ? root.notesList.length : 0, 7)

                        Rectangle {
                            width: 3
                            height: index === root.activeNoteIndex ? 10 : 3
                            radius: 1.5
                            color: index === root.activeNoteIndex ? root.yellowHeaderColor : (root.isDark ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(0, 0, 0, 0.18))

                            Behavior on height {
                                NumberAnimation { duration: 160 }
                            }
                            Behavior on color {
                                ColorAnimation { duration: 160 }
                            }
                        }
                    }
                }
            }

            // ───────────────────────────────────────────────────────────────
            // 2. MODO MEDIANO (354 x 176): LISTVIEW INTERACTIVA
            // ───────────────────────────────────────────────────────────────
            Item {
                id: mediumView

                anchors.fill: parent
                visible: root.isMedium

                ListView {
                    id: mediumListView

                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    clip: true
                    model: root.notesList
                    spacing: 0

                    delegate: Rectangle {
                        width: mediumListView.width
                        height: 38
                        radius: 6
                        color: medDelegateMa.containsMouse ? (root.isDark ? Qt.rgba(1, 1, 1, 0.07) : Qt.rgba(0, 0, 0, 0.04)) : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            spacing: 8

                            Text {
                                text: modelData.title || ""
                                font.family: root.fontFamily
                                font.pixelSize: 14
                                font.weight: Font.Normal
                                color: root.textPrimaryColor
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Text {
                                text: modelData.date || ""
                                font.family: root.fontFamily
                                font.pixelSize: 12
                                font.weight: Font.Normal
                                color: root.textSecondaryColor
                                Layout.alignment: Qt.AlignVCenter
                            }

                            // Flecha sutil indicadora
                            Text {
                                text: "›"
                                font.family: root.fontFamily
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: medDelegateMa.containsMouse ? root.yellowHeaderColor : (root.isDark ? Qt.rgba(1, 1, 1, 0.30) : Qt.rgba(0, 0, 0, 0.25))
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        // Línea divisoria hairline horizontal
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: 1
                            color: root.dividerColor
                        }

                        MouseArea {
                            id: medDelegateMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.openNoteDetail(modelData);
                            }
                        }
                    }
                }
            }

            // ───────────────────────────────────────────────────────────────
            // 3. MODO EXPANDIDO / GRANDE (354 x 354): LISTVIEW DETALLADA
            // ───────────────────────────────────────────────────────────────
            Item {
                id: largeView

                anchors.fill: parent
                visible: root.isLarge || (!root.isSmall && !root.isMedium)

                ListView {
                    id: largeListView

                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    clip: true
                    model: root.notesList
                    spacing: 0

                    delegate: Rectangle {
                        width: largeListView.width
                        height: 50
                        radius: 7
                        color: lrgDelegateMa.containsMouse ? (root.isDark ? Qt.rgba(1, 1, 1, 0.07) : Qt.rgba(0, 0, 0, 0.04)) : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            spacing: 8

                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 2

                                Text {
                                    text: modelData.title || ""
                                    font.family: root.fontFamily
                                    font.pixelSize: 14
                                    font.weight: Font.DemiBold
                                    color: root.textPrimaryColor
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: (modelData.date ? (modelData.date + "   ") : "") + (modelData.body || "No hay texto adicional")
                                    font.family: root.fontFamily
                                    font.pixelSize: 12
                                    font.weight: Font.Normal
                                    color: root.textSecondaryColor
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            // Flecha sutil
                            Text {
                                text: "›"
                                font.family: root.fontFamily
                                font.pixelSize: 17
                                font.weight: Font.Bold
                                color: lrgDelegateMa.containsMouse ? root.yellowHeaderColor : (root.isDark ? Qt.rgba(1, 1, 1, 0.30) : Qt.rgba(0, 0, 0, 0.25))
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        // Línea divisoria hairline horizontal
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: 1
                            color: root.dividerColor
                        }

                        MouseArea {
                            id: lrgDelegateMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.openNoteDetail(modelData);
                            }
                        }
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── VISTA DE DETALLE: CONTENIDO ÍNTEGRO DE LA NOTA ────────────────
        // ═══════════════════════════════════════════════════════════════════
        Item {
            id: detailContainer

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.top: perforationRow.bottom
            anchors.topMargin: 8
            visible: root.viewMode === "detail"
            clip: true

            Flickable {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                anchors.bottomMargin: 12
                contentWidth: width
                contentHeight: detailColumn.height + 20
                clip: true

                Column {
                    id: detailColumn
                    width: parent.width
                    spacing: 8

                    // Título de la Nota
                    Text {
                        width: parent.width
                        text: root.selectedNote ? (root.selectedNote.title || "Sin título") : ""
                        font.family: root.fontFamily
                        font.pixelSize: root.isLarge ? 18 : 16
                        font.weight: Font.Bold
                        color: root.textPrimaryColor
                        wrapMode: Text.Wrap
                    }

                    // Fecha y metadatos
                    Text {
                        width: parent.width
                        text: root.selectedNote ? (root.selectedNote.date || "Hoy") : ""
                        font.family: root.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: root.textSecondaryColor
                    }

                    // Divisor
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: root.dividerColor
                    }

                    // Cuerpo completo de la nota
                    Text {
                        width: parent.width
                        text: root.selectedNote ? (root.selectedNote.body || "No hay texto adicional") : ""
                        font.family: root.fontFamily
                        font.pixelSize: 13
                        font.weight: Font.Normal
                        lineHeight: 1.35
                        color: root.textPrimaryColor
                        wrapMode: Text.Wrap
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── VISTA DE CREACIÓN: REDACTAR Y PERSISTIR NUEVA NOTA ────────────
        // ═══════════════════════════════════════════════════════════════════
        Item {
            id: createContainer

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.top: perforationRow.bottom
            anchors.topMargin: 8
            visible: root.viewMode === "create"
            clip: true

            Column {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                anchors.bottomMargin: 12
                spacing: 8

                // Campo de Título
                Rectangle {
                    width: parent.width
                    height: 36
                    radius: 8
                    color: root.inputBgColor
                    border.color: createTitleInput.activeFocus ? root.yellowHeaderColor : "transparent"
                    border.width: 1

                    TextInput {
                        id: createTitleInput
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        verticalAlignment: TextInput.AlignVCenter
                        font.family: root.fontFamily
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: root.textPrimaryColor
                        selectByMouse: true

                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            visible: !createTitleInput.text && !createTitleInput.activeFocus
                            text: "Título de la nota..."
                            font.family: root.fontFamily
                            font.pixelSize: 14
                            font.weight: Font.Normal
                            color: root.textSecondaryColor
                        }
                    }
                }

                // Divisor sutil
                Rectangle {
                    width: parent.width
                    height: 1
                    color: root.dividerColor
                }

                // Campo de Cuerpo Multilínea
                Rectangle {
                    width: parent.width
                    height: parent.height - 52
                    radius: 8
                    color: root.inputBgColor
                    border.color: createBodyInput.activeFocus ? root.yellowHeaderColor : "transparent"
                    border.width: 1
                    clip: true

                    Flickable {
                        anchors.fill: parent
                        anchors.margins: 10
                        contentWidth: width
                        contentHeight: createBodyInput.height
                        clip: true

                        TextEdit {
                            id: createBodyInput
                            width: parent.width
                            font.family: root.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.Normal
                            color: root.textPrimaryColor
                            wrapMode: TextEdit.Wrap
                            selectByMouse: true

                            Text {
                                anchors.fill: parent
                                visible: !createBodyInput.text && !createBodyInput.activeFocus
                                text: "Escribe tu nota aquí..."
                                font.family: root.fontFamily
                                font.pixelSize: 13
                                font.weight: Font.Normal
                                color: root.textSecondaryColor
                            }
                        }
                    }
                }
            }
        }
    }
}
