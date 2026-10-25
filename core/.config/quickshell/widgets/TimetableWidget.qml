import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    property var widgetsState
    readonly property var skin: root.widgetsState ? root.widgetsState.skin : null
    readonly property bool nothing: skin ? skin.isNothing : false
    readonly property string fontText: (nothing && skin) ? skin.fontText : "SF Pro Display"
    readonly property string fontFigure: (nothing && skin) ? skin.fontFigure : "SF Pro Display"

    readonly property bool isSmall: root.width <= 220
    readonly property bool isMedium: root.width > 220 && root.height <= 240
    readonly property bool isLarge: root.width > 220 && root.height > 240

    readonly property bool isDark: root.widgetsState ? root.widgetsState.isDarkTheme : false
    readonly property real cardRadius: root.nothing ? root.skin.radius : (root.widgetsState ? root.widgetsState.cardRadius : 22)
    readonly property string fontFamily: nothing ? fontText : "SF Pro Display, SF Pro Text, -apple-system, BlinkMacSystemFont, Segoe UI, Roboto, sans-serif"

    // ── Notes Color Tokens (Nothing OS Monocromo vs Apple Notes) ────────────
    readonly property color cardBgColor: root.nothing ? root.skin.card : (isDark ? (root.widgetsState ? root.widgetsState.cardBg : "#1C1C1E") : "#FFFFFF")
    readonly property color cardBorderColor: root.nothing ? "transparent" : (isDark ? (root.widgetsState ? root.widgetsState.cardBorder : Qt.rgba(1, 1, 1, 0.10)) : Qt.rgba(0, 0, 0, 0.04))
    readonly property color yellowHeaderColor: root.nothing ? root.skin.raised : "#FCC603"
    readonly property color textPrimaryColor: root.nothing ? root.skin.ink : (isDark ? "#FFFFFF" : "#000000")
    readonly property color textSecondaryColor: root.nothing ? root.skin.inkDim : (isDark ? "#98989D" : "#8E8E93")
    readonly property color dividerColor: root.nothing ? root.skin.dotOff : (isDark ? Qt.rgba(1, 1, 1, 0.12) : "#E2E2E3")
    readonly property color perforationColor: root.nothing ? root.skin.dotOff : (isDark ? Qt.rgba(1, 1, 1, 0.20) : "#D1D1D6")
    readonly property color inputBgColor: root.nothing ? root.skin.raised : (isDark ? Qt.rgba(255, 255, 255, 0.06) : Qt.rgba(0, 0, 0, 0.04))

    readonly property var notesList: {
        if (root.widgetsState && root.widgetsState.ttNotesList !== undefined && root.widgetsState.ttNotesList !== null)
            return root.widgetsState.ttNotesList;
        return [];
    }

    // ── Estados de Interacción y Navegación ─────────────────────────────────
    // Modos posibles: "list" (listado de notas), "detail" (vista completa), "create" (redactar nueva nota)
    property string viewMode: "list"
    property var selectedNote: null

    onViewModeChanged: {
        if (root.widgetsState) {
            root.widgetsState.wantsKeyboardFocus = (root.viewMode === "detail" || root.viewMode === "create");
        }
    }

    Connections {
        target: root.widgetsState
        function onWantsKeyboardFocusChanged() {
            if (root.widgetsState && !root.widgetsState.wantsKeyboardFocus) {
                if (root.viewMode === "create") {
                    var title = createTitleInput.text.trim();
                    var body = createBodyInput.text.trim();
                    if (title || body) {
                        root.saveNewNote();
                    } else {
                        root.viewMode = "list";
                    }
                } else if (root.viewMode === "detail") {
                    var isChanged = (root.selectedNote && (detailTitleInput.text.trim() !== (root.selectedNote.title || "").trim() || detailBodyInput.text.trim() !== (root.selectedNote.body || "").trim()));
                    if (root.detailIsModified || isChanged) {
                        root.saveNoteChanges();
                    }
                    root.viewMode = "list";
                }
            }
        }
    }

    // ── Smart Stack Navigation Properties ──────────────────────────────────
    property int activeNoteIndex: 0
    property real lastWheelTime: 0
    property real stackOffsetY: 0
    property bool isStackAnimating: false
    property int pendingIndex: -1

    readonly property var currentNote: {
        var list = root.notesList;
        if (!list || list.length === 0)
            return null;
        var idx = Math.max(0, Math.min(root.activeNoteIndex, list.length - 1));
        return list[idx];
    }

    readonly property var nextNoteItem: {
        var list = root.notesList;
        if (!list || list.length === 0)
            return null;
        return list[(root.activeNoteIndex + 1) % list.length];
    }

    readonly property var prevNoteItem: {
        var list = root.notesList;
        if (!list || list.length === 0)
            return null;
        return list[(root.activeNoteIndex - 1 + list.length) % list.length];
    }

    NumberAnimation {
        id: stackSlideAnim
        target: root
        property: "stackOffsetY"
        duration: 260
        easing.type: Easing.OutCubic
        onFinished: {
            if (root.pendingIndex !== -1) {
                root.activeNoteIndex = root.pendingIndex;
                root.pendingIndex = -1;
            }
            root.stackOffsetY = 0;
            root.isStackAnimating = false;
        }
    }

    function slideToNext() {
        if (stackSlideAnim.running || !root.notesList || root.notesList.length <= 1)
            return;
        root.isStackAnimating = true;
        root.pendingIndex = (root.activeNoteIndex + 1) % root.notesList.length;
        stackSlideAnim.from = root.stackOffsetY;
        stackSlideAnim.to = -smallView.height;
        stackSlideAnim.restart();
    }

    function slideToPrev() {
        if (stackSlideAnim.running || !root.notesList || root.notesList.length <= 1)
            return;
        root.isStackAnimating = true;
        root.pendingIndex = (root.activeNoteIndex - 1 + root.notesList.length) % root.notesList.length;
        stackSlideAnim.from = root.stackOffsetY;
        stackSlideAnim.to = smallView.height;
        stackSlideAnim.restart();
    }

    function snapStackBack() {
        if (stackSlideAnim.running)
            return;
        root.pendingIndex = -1;
        stackSlideAnim.from = root.stackOffsetY;
        stackSlideAnim.to = 0;
        stackSlideAnim.restart();
    }

    function nextNote() {
        slideToNext();
    }

    function prevNote() {
        slideToPrev();
    }

    component SmallNoteCard : Item {
        id: cardComp
        property var noteData: null
        property real cardY: 0
        property real cardScale: 1.0
        property real cardOpacity: 1.0

        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height
        y: cardY
        scale: cardScale
        opacity: cardOpacity

        ColumnLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            anchors.topMargin: 14
            spacing: 4

            Text {
                text: cardComp.noteData ? (cardComp.noteData.title || "Nueva nota") : "Nueva nota"
                font.family: root.fontFamily
                font.pixelSize: 15
                font.weight: Font.DemiBold
                color: root.textPrimaryColor
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: cardComp.noteData ? (cardComp.noteData.body || "Nota a mano") : "Nota a mano"
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

        Text {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: 16
            anchors.bottomMargin: 14
            text: cardComp.noteData ? (cardComp.noteData.date || "miércoles") : "miércoles"
            font.family: root.fontFamily
            font.pixelSize: 13
            font.weight: Font.Normal
            color: root.textSecondaryColor
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (!root.isStackAnimating && Math.abs(root.stackOffsetY) < 5 && cardComp.noteData) {
                    root.openNoteDetail(cardComp.noteData);
                }
            }
        }
    }

    property bool detailIsModified: false

    function openNoteDetail(noteItem) {
        root.selectedNote = noteItem;
        detailTitleInput.text = noteItem ? (noteItem.title || "") : "";
        detailBodyInput.text = noteItem ? (noteItem.body || "") : "";
        root.detailIsModified = false;
        root.viewMode = "detail";
        detailTitleInput.forceActiveFocus();
    }

    function saveNoteChanges() {
        if (!root.selectedNote || !root.selectedNote.id)
            return;
        var newT = detailTitleInput.text.trim();
        var newB = detailBodyInput.text.trim();
        if (!newT && !newB) {
            newT = "Nueva nota";
            newB = "";
        } else if (!newT) {
            var lines = newB.split("\n");
            newT = lines[0].substring(0, 32).trim() || "Nueva nota";
        }
        if (root.widgetsState && root.widgetsState.updateTimetableNote) {
            root.widgetsState.updateTimetableNote(root.selectedNote.id, newT, newB);
        }
        root.selectedNote.title = newT;
        root.selectedNote.body = newB;
        root.detailIsModified = false;
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
        border.width: root.nothing ? 0 : 1

        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        // Absorb clicks on card background so they never fall through to desktop canvas
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (root.widgetsState)
                    root.widgetsState.wantsKeyboardFocus = (root.viewMode === "detail" || root.viewMode === "create");
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── CABECERA DE NOTAS ──────────────────────────────────────────────
        // ═══════════════════════════════════════════════════════════════════
        Item {
            id: headerArea

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: root.isLarge ? 48 : 40
            z: 10

            // Fondo de cabecera con esquinas superiores redondeadas
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

            // Absorb clicks on header background so they never fall through to desktop canvas
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (root.widgetsState)
                        root.widgetsState.wantsKeyboardFocus = (root.viewMode === "detail" || root.viewMode === "create");
                }
            }

            // ── Contenido de Cabecera según viewMode ────────────────────────
            // MODO LISTA: Carpeta / Dot + "Notas" + Botón '+'
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

                        // Nothing Notes Dot
                        Rectangle {
                            visible: root.nothing
                            width: 6
                            height: 6
                            radius: 3
                            color: root.skin ? root.skin.yellow : "#F5D020"
                        }

                        // Icono vectorial de Carpeta Apple Notes
                        Canvas {
                            id: folderCanvas
                            visible: !root.nothing
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
                            color: root.nothing ? (root.skin ? root.skin.ink : "#FFFFFF") : "#FFFFFF"
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
                    font.family: root.nothing ? root.fontFigure : root.fontFamily
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    color: root.nothing ? (root.skin ? root.skin.inkDim : Qt.rgba(1, 1, 1, 0.85)) : Qt.rgba(1, 1, 1, 0.85)
                    Layout.alignment: Qt.AlignVCenter
                }

                // Botón Acción Rápida '+' para Crear Nota Directamente
                Rectangle {
                    id: addBtn
                    Layout.preferredWidth: 26
                    Layout.preferredHeight: 26
                    radius: 13
                    color: root.nothing ? (addMa.containsMouse ? (root.skin ? root.skin.dotOff : Qt.rgba(1,1,1,0.25)) : (root.skin ? root.skin.card : Qt.rgba(1,1,1,0.15))) : (addMa.containsMouse ? Qt.rgba(1, 1, 1, 0.35) : Qt.rgba(1, 1, 1, 0.20))
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
                        color: root.nothing ? (root.skin ? root.skin.yellow : "#F5D020") : "#FFFFFF"
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
                            createTitleInput.forceActiveFocus();
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
                    Layout.preferredWidth: Math.max(28, backContentRow.implicitWidth + 12)
                    radius: 14
                    color: backMa.containsMouse ? Qt.rgba(1, 1, 1, 0.30) : Qt.rgba(1, 1, 1, 0.15)
                    scale: backMa.pressed ? 0.95 : 1.0

                    RowLayout {
                        id: backContentRow
                        anchors.centerIn: parent
                        spacing: 2

                        Text {
                            text: "‹"
                            font.family: root.fontFamily
                            font.pixelSize: 19
                            font.weight: Font.Bold
                            color: "#FFFFFF"
                            anchors.verticalCenterOffset: -1
                        }

                        Text {
                            visible: !root.isSmall
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
                            var isChanged = (root.selectedNote && (detailTitleInput.text.trim() !== (root.selectedNote.title || "").trim() || detailBodyInput.text.trim() !== (root.selectedNote.body || "").trim()));
                            if (root.detailIsModified || isChanged) {
                                root.saveNoteChanges();
                            }
                            root.viewMode = "list";
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                // Botón 'Listo' para guardar cambios editados
                Rectangle {
                    id: saveEditBtn
                    visible: root.detailIsModified || (root.selectedNote && (detailTitleInput.text.trim() !== (root.selectedNote.title || "").trim() || detailBodyInput.text.trim() !== (root.selectedNote.body || "").trim()))
                    Layout.preferredHeight: 26
                    Layout.preferredWidth: Math.max(48, saveEditTxt.implicitWidth + 16)
                    radius: 13
                    color: saveEditMa.containsMouse ? Qt.rgba(1, 1, 1, 0.45) : Qt.rgba(1, 1, 1, 0.28)
                    scale: saveEditMa.pressed ? 0.94 : 1.0

                    Text {
                        id: saveEditTxt
                        anchors.centerIn: parent
                        text: "Listo"
                        font.family: root.fontFamily
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        id: saveEditMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.saveNoteChanges();
                            root.viewMode = "list";
                        }
                    }
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
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 6
                visible: root.viewMode === "create"

                Rectangle {
                    id: cancelBtn
                    Layout.preferredHeight: 26
                    Layout.preferredWidth: Math.max(28, cancelTxt.implicitWidth + 14)
                    radius: 13
                    color: cancelMa.containsMouse ? Qt.rgba(1, 1, 1, 0.25) : "transparent"

                    Text {
                        id: cancelTxt
                        anchors.centerIn: parent
                        text: root.isSmall ? "✕" : "Cancelar"
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
                            createTitleInput.text = "";
                            createBodyInput.text = "";
                            root.viewMode = "list";
                        }
                    }
                }

                // Título central interactivo: cliquear 'Nueva Nota' guarda la nota
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Text {
                        anchors.centerIn: parent
                        text: root.isSmall ? "Nueva" : "Nueva Nota"
                        font.family: root.fontFamily
                        font.pixelSize: root.isSmall ? 13 : 14
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.saveNewNote();
                        }
                    }
                }

                Rectangle {
                    id: saveBtn
                    Layout.preferredHeight: 26
                    Layout.preferredWidth: Math.max(52, saveTxt.implicitWidth + 18)
                    radius: 13
                    color: saveMa.containsMouse ? Qt.rgba(1, 1, 1, 0.45) : Qt.rgba(1, 1, 1, 0.28)
                    scale: saveMa.pressed ? 0.94 : 1.0

                    Behavior on scale {
                        NumberAnimation { duration: 100 }
                    }

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
                model: Math.max(0, Math.floor(perforationRow.width / 7))

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
            // 0. ESTADO VACÍO (SIN NOTAS): "Haz clic en + para añadir..."
            // ───────────────────────────────────────────────────────────────
            Item {
                id: emptyNotesView
                anchors.fill: parent
                visible: !root.notesList || root.notesList.length === 0

                ColumnLayout {
                    anchors.centerIn: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 8

                    Text {
                        text: "󰎚"
                        font.family: "CaskaydiaCove Nerd Font"
                        font.pixelSize: root.isSmall ? 28 : 36
                        color: root.yellowHeaderColor
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "No hay notas"
                        font.family: root.fontFamily
                        font.pixelSize: root.isSmall ? 14 : 16
                        font.weight: Font.DemiBold
                        color: root.textPrimaryColor
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "Haz clic en + para añadir una nueva nota"
                        font.family: root.fontFamily
                        font.pixelSize: root.isSmall ? 11 : 12
                        font.weight: Font.Normal
                        color: root.textSecondaryColor
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                        Layout.maximumWidth: parent.width > 0 ? (parent.width - 24) : 130
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        createTitleInput.text = "";
                        createBodyInput.text = "";
                        root.viewMode = "create";
                        createTitleInput.forceActiveFocus();
                    }
                }
            }

            // ───────────────────────────────────────────────────────────────
            // 1. MODO COMPACTO / PEQUEÑO (170 x 170): SMART STACK VERTICAL
            // ───────────────────────────────────────────────────────────────
            Item {
                id: smallView

                anchors.fill: parent
                visible: root.isSmall && root.notesList && root.notesList.length > 0
                clip: true

                // Gesto de Arrastre Vertical (DragHandler)
                DragHandler {
                    id: smallDragHandler
                    target: null
                    xAxis.enabled: false
                    yAxis.enabled: true
                    enabled: !root.isStackAnimating
                    onActiveChanged: {
                        if (!active) {
                            if (root.stackOffsetY < -30) {
                                root.slideToNext();
                            } else if (root.stackOffsetY > 30) {
                                root.slideToPrev();
                            } else {
                                root.snapStackBack();
                            }
                        }
                    }
                    onTranslationChanged: {
                        if (active && !root.isStackAnimating) {
                            root.stackOffsetY = Math.max(-smallView.height, Math.min(smallView.height, translation.y));
                        }
                    }
                }

                // Gesto con rueda del ratón / touchpad
                WheelHandler {
                    acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                    onWheel: (event) => {
                        var now = Date.now();
                        if (now - root.lastWheelTime > 260 && !root.isStackAnimating) {
                            root.lastWheelTime = now;
                            if (event.angleDelta.y < 0)
                                root.slideToNext();
                            else if (event.angleDelta.y > 0)
                                root.slideToPrev();
                        }
                    }
                }

                // Smart Stack Cards (exclusivas de las notas existentes)
                // 1. Nota anterior (arriba: entra hacia abajo)
                SmallNoteCard {
                    id: prevCard
                    noteData: root.prevNoteItem
                    cardY: -smallView.height + root.stackOffsetY
                    cardScale: 0.94 + 0.06 * Math.min(1.0, Math.max(0.0, root.stackOffsetY / Math.max(1, smallView.height)))
                    cardOpacity: 0.4 + 0.6 * Math.min(1.0, Math.max(0.0, root.stackOffsetY / Math.max(1, smallView.height)))
                    visible: (root.stackOffsetY > 0 || (root.isStackAnimating && root.pendingIndex === (root.activeNoteIndex - 1 + (root.notesList ? root.notesList.length : 1)) % Math.max(1, (root.notesList ? root.notesList.length : 1)))) && (root.notesList && root.notesList.length > 1)
                }

                // 2. Nota siguiente (abajo: entra hacia arriba)
                SmallNoteCard {
                    id: nextCard
                    noteData: root.nextNoteItem
                    cardY: smallView.height + root.stackOffsetY
                    cardScale: 0.94 + 0.06 * Math.min(1.0, Math.max(0.0, -root.stackOffsetY / Math.max(1, smallView.height)))
                    cardOpacity: 0.4 + 0.6 * Math.min(1.0, Math.max(0.0, -root.stackOffsetY / Math.max(1, smallView.height)))
                    visible: (root.stackOffsetY < 0 || (root.isStackAnimating && root.pendingIndex === (root.activeNoteIndex + 1) % Math.max(1, (root.notesList ? root.notesList.length : 1)))) && (root.notesList && root.notesList.length > 1)
                }

                // 3. Nota actual
                SmallNoteCard {
                    id: currentCard
                    noteData: root.currentNote
                    cardY: root.stackOffsetY
                    cardScale: 1.0 - 0.06 * Math.min(1.0, Math.abs(root.stackOffsetY) / Math.max(1, smallView.height))
                    cardOpacity: 1.0 - 0.4 * Math.min(1.0, Math.abs(root.stackOffsetY) / Math.max(1, smallView.height))
                    visible: true
                }

                // Micro-indicador vertical de página estilo Apple Smart Stack
                Column {
                    z: 10
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
                visible: root.isMedium && root.notesList && root.notesList.length > 0

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
                visible: (root.isLarge || (!root.isSmall && !root.isMedium)) && root.notesList && root.notesList.length > 0

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

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (root.widgetsState)
                        root.widgetsState.wantsKeyboardFocus = true;
                    if (!detailTitleInput.activeFocus && !detailBodyInput.activeFocus) {
                        detailBodyInput.forceActiveFocus();
                    }
                }
            }

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
                    spacing: 6

                    // Título Editable de la Nota
                    Rectangle {
                        width: parent.width
                        height: Math.max(34, detailTitleInput.implicitHeight + 8)
                        radius: 6
                        color: detailTitleInput.activeFocus ? root.inputBgColor : "transparent"
                        border.color: detailTitleInput.activeFocus ? root.yellowHeaderColor : "transparent"
                        border.width: 1

                        TextInput {
                            id: detailTitleInput
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            verticalAlignment: TextInput.AlignVCenter
                            font.family: root.fontFamily
                            font.pixelSize: root.isLarge ? 17 : 15
                            font.weight: Font.Bold
                            color: root.textPrimaryColor
                            selectByMouse: true
                            activeFocusOnTab: true
                            onTextEdited: {
                                root.detailIsModified = true;
                            }
                            onTextChanged: {
                                if (root.selectedNote && text.trim() !== (root.selectedNote.title || "").trim()) {
                                    root.detailIsModified = true;
                                }
                            }
                            Keys.onReturnPressed: {
                                detailBodyInput.forceActiveFocus();
                            }
                            Keys.onEscapePressed: {
                                if (root.detailIsModified) {
                                    root.saveNoteChanges();
                                }
                                root.viewMode = "list";
                            }
                        }
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

                    // Divisor hairline
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: root.dividerColor
                    }

                    // Cuerpo Editable de la Nota
                    Rectangle {
                        width: parent.width
                        height: Math.max(detailBodyInput.implicitHeight + 16, detailContainer.height - 110)
                        radius: 6
                        color: detailBodyInput.activeFocus ? root.inputBgColor : "transparent"
                        border.color: detailBodyInput.activeFocus ? root.yellowHeaderColor : "transparent"
                        border.width: 1

                        TextEdit {
                            id: detailBodyInput
                            anchors.fill: parent
                            anchors.margins: 6
                            font.family: root.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.Normal
                            color: root.textPrimaryColor
                            wrapMode: TextEdit.Wrap
                            selectByMouse: true
                            activeFocusOnTab: true
                            onTextEdited: {
                                root.detailIsModified = true;
                            }
                            onTextChanged: {
                                if (root.selectedNote && text.trim() !== (root.selectedNote.body || "").trim()) {
                                    root.detailIsModified = true;
                                }
                            }
                            Keys.onEscapePressed: {
                                if (root.detailIsModified) {
                                    root.saveNoteChanges();
                                }
                                root.viewMode = "list";
                            }
                        }
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

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (root.widgetsState)
                        root.widgetsState.wantsKeyboardFocus = true;
                    if (!createTitleInput.activeFocus && !createBodyInput.activeFocus) {
                        createBodyInput.forceActiveFocus();
                    }
                }
            }

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
                        activeFocusOnTab: true
                        Keys.onReturnPressed: {
                            createBodyInput.forceActiveFocus();
                        }
                        Keys.onEscapePressed: {
                            root.viewMode = "list";
                        }

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
                        contentHeight: Math.max(height, createBodyInput.implicitHeight)
                        clip: true

                        TextEdit {
                            id: createBodyInput
                            width: parent.width
                            height: Math.max(parent.height, implicitHeight)
                            font.family: root.fontFamily
                            font.pixelSize: 13
                            font.weight: Font.Normal
                            color: root.textPrimaryColor
                            wrapMode: TextEdit.Wrap
                            selectByMouse: true
                            activeFocusOnTab: true
                            Keys.onEscapePressed: {
                                root.viewMode = "list";
                            }

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
