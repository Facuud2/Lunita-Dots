import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property var widgetsState
    readonly property bool isSmall: root.width <= 220
    readonly property bool isMedium: root.width > 220 && root.height <= 240
    readonly property bool isLarge: root.width > 220 && root.height > 240
    property int activeCardIndex: 0
    property real lastWheelTime: 0
    property bool addTaskModalOpen: false
    property bool notesModalOpen: false
    readonly property var fallbackCards: [{
        "id": "n1",
        "title": "Ideas de Diseño",
        "body": "Revisar paletas dinámicas de Matugen y consistencia visual en Quickshell y paneles.",
        "date": "HOY",
        "color": "#FF9F0A"
    }, {
        "id": "n2",
        "title": "Configuración de Sistema",
        "body": "Optimizar arranque y servicios systemd para inicio y apagado instantáneo.",
        "date": "AYER",
        "color": "#0A84FF"
    }, {
        "id": "n3",
        "title": "Recordatorios Lunita",
        "body": "Sincronizar marcadores y widgets de escritorio en los tres temas activos.",
        "date": "20 OCT",
        "color": "#30D158"
    }]
    readonly property var noteCards: {
        if (root.widgetsState && root.widgetsState.ttNotesList && root.widgetsState.ttNotesList.length > 0)
            return root.widgetsState.ttNotesList;

        return fallbackCards;
    }
    readonly property var currentCard: {
        var list = root.noteCards;
        if (!list || list.length === 0)
            return null;

        var idx = Math.max(0, Math.min(root.activeCardIndex, list.length - 1));
        return list[idx];
    }

    function nextCard() {
        if (!root.noteCards || root.noteCards.length <= 1)
            return ;

        if (root.activeCardIndex < root.noteCards.length - 1)
            root.activeCardIndex++;
        else
            root.activeCardIndex = 0;
    }

    function prevCard() {
        if (!root.noteCards || root.noteCards.length <= 1)
            return ;

        if (root.activeCardIndex > 0)
            root.activeCardIndex--;
        else
            root.activeCardIndex = root.noteCards.length - 1;
    }

    onActiveCardIndexChanged: {
        cardTransitionAnim.restart();
    }

    SequentialAnimation {
        id: cardTransitionAnim

        NumberAnimation {
            target: bg
            property: "opacity"
            from: 0.75
            to: 1
            duration: 160
            easing.type: Easing.OutQuad
        }

    }

    WheelHandler {
        id: cardWheel

        target: root
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: (event) => {
            var now = Date.now();
            if (now - root.lastWheelTime > 150) {
                root.lastWheelTime = now;
                if (event.angleDelta.y < 0)
                    root.nextCard();
                else if (event.angleDelta.y > 0)
                    root.prevCard();
            }
        }
    }

    Rectangle {
        id: bg

        anchors.fill: parent
        radius: root.widgetsState ? root.widgetsState.cardRadius : 22
        color: root.widgetsState ? root.widgetsState.cardBg : Qt.rgba(0.12, 0.14, 0.18, 0.85)
        border.color: root.widgetsState ? root.widgetsState.cardBorder : Qt.rgba(1, 1, 1, 0.12)
        border.width: 1
        clip: true

        // ═══════════════════════════════════════════════════════════════════
        // ── 1. MODO COMPACTO (170 x 170): TARJETA NOTAS iOS/iPadOS ──
        // ═══════════════════════════════════════════════════════════════════
        Item {
            anchors.fill: parent
            anchors.margins: 12
            visible: root.isSmall && !root.addTaskModalOpen && !root.notesModalOpen

            ColumnLayout {
                anchors.fill: parent
                spacing: 6

                // Cabecera estilo iOS Notes
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: "󰠮"
                        font.family: "CaskaydiaCove Nerd Font"
                        font.pixelSize: 12
                        color: root.currentCard && root.currentCard.color ? root.currentCard.color : "#E5A93C"
                    }

                    Text {
                        text: "NOTAS"
                        font.family: "SF Pro Display"
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        color: root.currentCard && root.currentCard.color ? root.currentCard.color : "#E5A93C"
                        font.letterSpacing: 0.8
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: root.currentCard && root.currentCard.date ? root.currentCard.date : "HOY"
                        font.family: "SF Pro Display"
                        font.pixelSize: 8
                        font.weight: Font.Bold
                        color: Qt.rgba(1, 1, 1, 0.5)
                        font.letterSpacing: 0.5
                    }

                    Rectangle {
                        width: 18
                        height: 18
                        radius: 9
                        color: plusMaS.containsMouse ? Qt.rgba(1, 1, 1, 0.2) : Qt.rgba(1, 1, 1, 0.08)

                        Text {
                            anchors.centerIn: parent
                            text: "+"
                            font.family: "SF Pro Display"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: "#FFFFFF"
                        }

                        MouseArea {
                            id: plusMaS

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                            onClicked: root.addTaskModalOpen = true
                        }

                    }

                }

                // Separador sutil
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(1, 1, 1, 0.08)
                }

                // Contenido de la Tarjeta (Título + Cuerpo)
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 3

                    Text {
                        Layout.fillWidth: true
                        text: root.currentCard ? root.currentCard.title : "Sin notas"
                        font.family: "SF Pro Display"
                        font.pixelSize: 12
                        font.weight: Font.Bold
                        color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: root.currentCard ? root.currentCard.body : ""
                        font.family: "SF Pro Text, SF Pro Display"
                        font.pixelSize: 10
                        lineHeight: 1.2
                        color: Qt.rgba(1, 1, 1, 0.72)
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        maximumLineCount: 4
                    }

                }

                // Paginador de Tarjetas iOS (Pill dots + Contador)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: "↕ Scroll"
                        font.family: "SF Pro Display"
                        font.pixelSize: 7
                        font.weight: Font.Bold
                        color: Qt.rgba(1, 1, 1, 0.35)
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // Dots indicator
                    RowLayout {
                        spacing: 3

                        Repeater {
                            model: root.noteCards.length

                            Rectangle {
                                width: index === root.activeCardIndex ? 12 : 4
                                height: 4
                                radius: 2
                                color: index === root.activeCardIndex ? (root.currentCard && root.currentCard.color ? root.currentCard.color : "#E5A93C") : Qt.rgba(1, 1, 1, 0.25)

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.activeCardIndex = index
                                }

                                Behavior on width {
                                    NumberAnimation {
                                        duration: 150
                                    }

                                }

                            }

                        }

                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: (root.activeCardIndex + 1) + "/" + root.noteCards.length
                        font.family: "SF Pro Display"
                        font.pixelSize: 8
                        color: Qt.rgba(1, 1, 1, 0.5)
                    }

                }

            }

        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 2. MODO MEDIO (354 x 170): TARJETA iOS IZQ + TAREAS DER ──
        // ═══════════════════════════════════════════════════════════════════
        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12
            visible: root.isMedium && !root.addTaskModalOpen && !root.notesModalOpen

            // Lado Izquierdo: Tarjeta de Nota Activa
            Rectangle {
                Layout.preferredWidth: 162
                Layout.fillHeight: true
                radius: 14
                color: Qt.rgba(1, 1, 1, 0.05)
                border.color: Qt.rgba(1, 1, 1, 0.09)
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: "󰠮"
                            font.family: "CaskaydiaCove Nerd Font"
                            font.pixelSize: 11
                            color: root.currentCard && root.currentCard.color ? root.currentCard.color : "#E5A93C"
                        }

                        Text {
                            text: "NOTAS"
                            font.family: "SF Pro Display"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            color: root.currentCard && root.currentCard.color ? root.currentCard.color : "#E5A93C"
                            font.letterSpacing: 0.8
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: root.currentCard && root.currentCard.date ? root.currentCard.date : "HOY"
                            font.family: "SF Pro Display"
                            font.pixelSize: 8
                            font.weight: Font.Bold
                            color: Qt.rgba(1, 1, 1, 0.5)
                        }

                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.currentCard ? root.currentCard.title : "Sin notas"
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: root.currentCard ? root.currentCard.body : ""
                        font.family: "SF Pro Text, SF Pro Display"
                        font.pixelSize: 9
                        lineHeight: 1.2
                        color: Qt.rgba(1, 1, 1, 0.7)
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        maximumLineCount: 4
                    }

                    // Paginador
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 3

                        Text {
                            text: "↕ Scroll"
                            font.family: "SF Pro Display"
                            font.pixelSize: 7
                            color: Qt.rgba(1, 1, 1, 0.35)
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Repeater {
                            model: root.noteCards.length

                            Rectangle {
                                width: index === root.activeCardIndex ? 10 : 3
                                height: 3
                                radius: 1.5
                                color: index === root.activeCardIndex ? (root.currentCard && root.currentCard.color ? root.currentCard.color : "#E5A93C") : Qt.rgba(1, 1, 1, 0.25)
                            }

                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: (root.activeCardIndex + 1) + "/" + root.noteCards.length
                            font.family: "SF Pro Display"
                            font.pixelSize: 8
                            color: Qt.rgba(1, 1, 1, 0.45)
                        }

                    }

                }

            }

            // Lado Derecho: Lista de Tareas y Agenda
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: "TAREAS & RECORDATORIOS"
                        font.family: "SF Pro Display"
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.6)
                        font.letterSpacing: 0.6
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        height: 18
                        radius: 9
                        implicitWidth: plusMedRow.implicitWidth + 8
                        color: Qt.rgba(1, 1, 1, 0.08)

                        RowLayout {
                            id: plusMedRow

                            anchors.centerIn: parent
                            spacing: 3

                            Text {
                                text: "+"
                                font.pixelSize: 9
                                font.weight: Font.Bold
                                color: "#FFFFFF"
                            }

                            Text {
                                text: "Añadir"
                                font.family: "SF Pro Display"
                                font.pixelSize: 8
                                font.weight: Font.Bold
                                color: "#FFFFFF"
                            }

                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                            onClicked: root.addTaskModalOpen = true
                        }

                    }

                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 4
                    model: root.widgetsState && root.widgetsState.ttTasks ? root.widgetsState.ttTasks : []

                    delegate: Rectangle {
                        width: parent ? parent.width : 160
                        height: 27
                        radius: 6
                        color: Qt.rgba(1, 1, 1, 0.05)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            spacing: 5

                            Rectangle {
                                width: 13
                                height: 13
                                radius: 6.5
                                color: modelData.done ? (modelData.tag_color || "#30D158") : "transparent"
                                border.color: modelData.done ? (modelData.tag_color || "#30D158") : Qt.rgba(1, 1, 1, 0.4)
                                border.width: 1.5

                                Text {
                                    anchors.centerIn: parent
                                    text: "✓"
                                    font.pixelSize: 8
                                    font.weight: Font.Black
                                    color: "#FFFFFF"
                                    visible: modelData.done
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (root.widgetsState)
                                            root.widgetsState.toggleTimetableTask(modelData.id);

                                    }
                                }

                            }

                            Text {
                                text: modelData.title
                                font.family: "SF Pro Display"
                                font.pixelSize: 9
                                font.weight: Font.Medium
                                font.strikeout: !!modelData.done
                                color: modelData.done ? Qt.rgba(1, 1, 1, 0.35) : "#FFFFFF"
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            Rectangle {
                                height: 13
                                radius: 4
                                implicitWidth: tagTxtM.implicitWidth + 6
                                color: Qt.rgba(1, 1, 1, 0.08)

                                Text {
                                    id: tagTxtM

                                    anchors.centerIn: parent
                                    text: modelData.tag || "General"
                                    font.family: "SF Pro Display"
                                    font.pixelSize: 7
                                    font.weight: Font.Bold
                                    color: modelData.tag_color || "#007AFF"
                                }

                            }

                        }

                    }

                }

            }

        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 3. MODO EXPANDIDO (354 x 354): NOTAS iOS + TAREAS COMPLETO ──
        // ═══════════════════════════════════════════════════════════════════
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10
            visible: root.isLarge && !root.addTaskModalOpen && !root.notesModalOpen

            // Tarjeta Superior: Tarjeta de Nota Activa estilo iPadOS
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 140
                radius: 14
                color: Qt.rgba(1, 1, 1, 0.05)
                border.color: Qt.rgba(1, 1, 1, 0.09)
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 5

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: "󰠮"
                            font.family: "CaskaydiaCove Nerd Font"
                            font.pixelSize: 13
                            color: root.currentCard && root.currentCard.color ? root.currentCard.color : "#E5A93C"
                        }

                        Text {
                            text: "NOTAS & APUNTES"
                            font.family: "SF Pro Display"
                            font.pixelSize: 10
                            font.weight: Font.Bold
                            color: root.currentCard && root.currentCard.color ? root.currentCard.color : "#E5A93C"
                            font.letterSpacing: 0.8
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: root.currentCard && root.currentCard.date ? root.currentCard.date : "HOY"
                            font.family: "SF Pro Display"
                            font.pixelSize: 9
                            font.weight: Font.Bold
                            color: Qt.rgba(1, 1, 1, 0.5)
                        }

                        Rectangle {
                            height: 18
                            radius: 9
                            implicitWidth: 54
                            color: Qt.rgba(1, 1, 1, 0.08)

                            Text {
                                anchors.centerIn: parent
                                text: "+ Nota"
                                font.family: "SF Pro Display"
                                font.pixelSize: 8
                                font.weight: Font.Bold
                                color: "#FFFFFF"
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.notesModalOpen = true
                            }

                        }

                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.currentCard ? root.currentCard.title : "Sin notas"
                        font.family: "SF Pro Display"
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: root.currentCard ? root.currentCard.body : ""
                        font.family: "SF Pro Text, SF Pro Display"
                        font.pixelSize: 11
                        lineHeight: 1.25
                        color: Qt.rgba(1, 1, 1, 0.75)
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        maximumLineCount: 3
                    }

                    // Paginador
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: "↕ Usa la rueda del mouse para cambiar de nota"
                            font.family: "SF Pro Display"
                            font.pixelSize: 8
                            color: Qt.rgba(1, 1, 1, 0.4)
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Repeater {
                            model: root.noteCards.length

                            Rectangle {
                                width: index === root.activeCardIndex ? 14 : 4
                                height: 4
                                radius: 2
                                color: index === root.activeCardIndex ? (root.currentCard && root.currentCard.color ? root.currentCard.color : "#E5A93C") : Qt.rgba(1, 1, 1, 0.25)
                            }

                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: (root.activeCardIndex + 1) + " / " + root.noteCards.length
                            font.family: "SF Pro Display"
                            font.pixelSize: 8
                            font.weight: Font.Bold
                            color: Qt.rgba(1, 1, 1, 0.5)
                        }

                    }

                }

            }

            // Separador
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(1, 1, 1, 0.08)
            }

            // Sección Inferior: Lista de Tareas y Pendientes
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: "TAREAS & PENDIENTES"
                    font.family: "SF Pro Display"
                    font.pixelSize: 10
                    font.weight: Font.Bold
                    color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.6)
                    font.letterSpacing: 0.6
                }

                Item {
                    Layout.fillWidth: true
                }

                Rectangle {
                    height: 18
                    radius: 9
                    implicitWidth: 60
                    color: "#007AFF"

                    Text {
                        anchors.centerIn: parent
                        text: "+ Tarea"
                        font.family: "SF Pro Display"
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.addTaskModalOpen = true
                    }

                }

            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4
                model: root.widgetsState && root.widgetsState.ttTasks ? root.widgetsState.ttTasks : []

                delegate: Rectangle {
                    width: parent ? parent.width : 320
                    height: 30
                    radius: 6
                    color: Qt.rgba(1, 1, 1, 0.05)

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 6

                        Rectangle {
                            width: 14
                            height: 14
                            radius: 7
                            color: modelData.done ? (modelData.tag_color || "#30D158") : "transparent"
                            border.color: modelData.done ? (modelData.tag_color || "#30D158") : Qt.rgba(1, 1, 1, 0.4)
                            border.width: 1.5

                            Text {
                                anchors.centerIn: parent
                                text: "✓"
                                font.pixelSize: 8
                                font.weight: Font.Black
                                color: "#FFFFFF"
                                visible: modelData.done
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (root.widgetsState)
                                        root.widgetsState.toggleTimetableTask(modelData.id);

                                }
                            }

                        }

                        Text {
                            text: modelData.title
                            font.family: "SF Pro Display"
                            font.pixelSize: 10
                            font.strikeout: !!modelData.done
                            color: modelData.done ? Qt.rgba(1, 1, 1, 0.4) : "#FFFFFF"
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            height: 14
                            radius: 4
                            implicitWidth: tagTxtL.implicitWidth + 8
                            color: Qt.rgba(1, 1, 1, 0.08)

                            Text {
                                id: tagTxtL

                                anchors.centerIn: parent
                                text: modelData.tag || "General"
                                font.family: "SF Pro Display"
                                font.pixelSize: 8
                                font.weight: Font.Bold
                                color: modelData.tag_color || "#007AFF"
                            }

                        }

                    }

                }

            }

        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 4. MODAL: AGREGAR TAREA ──
        // ═══════════════════════════════════════════════════════════════════
        Rectangle {
            property string selectedTag: "General"
            property string selectedColor: "#007AFF"

            anchors.fill: parent
            radius: root.widgetsState ? root.widgetsState.cardRadius : 22
            color: root.widgetsState && root.widgetsState.isDarkTheme ? "#161B26" : "#FFFFFF"
            visible: root.addTaskModalOpen
            border.color: "#007AFF"
            border.width: 1.5

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Añadir Nueva Tarea"
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "✕"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: Qt.rgba(1, 1, 1, 0.6)

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.addTaskModalOpen = false
                        }

                    }

                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 26
                    radius: 6
                    color: Qt.rgba(1, 1, 1, 0.08)
                    border.color: titleInput.activeFocus ? "#007AFF" : Qt.rgba(1, 1, 1, 0.15)
                    border.width: 1

                    TextInput {
                        id: titleInput

                        anchors.fill: parent
                        anchors.margins: 4
                        font.family: "SF Pro Display"
                        font.pixelSize: 10
                        color: "#FFFFFF"
                        verticalAlignment: TextInput.AlignVCenter

                        Text {
                            text: "Descripción de la tarea..."
                            font.family: "SF Pro Display"
                            font.pixelSize: 10
                            color: Qt.rgba(1, 1, 1, 0.4)
                            visible: !titleInput.text && !titleInput.activeFocus
                            anchors.verticalCenter: parent.verticalCenter
                        }

                    }

                }

                // Selector de Categoría
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Repeater {
                        model: [{
                            "tag": "General",
                            "col": "#30D158"
                        }, {
                            "tag": "Trabajo",
                            "col": "#AF52DE"
                        }, {
                            "tag": "Estudio",
                            "col": "#007AFF"
                        }, {
                            "tag": "Prioridad",
                            "col": "#FA114F"
                        }]

                        Rectangle {
                            height: 18
                            radius: 9
                            implicitWidth: 44
                            color: parent.parent.parent.parent.selectedTag === modelData.tag ? modelData.col : Qt.rgba(1, 1, 1, 0.08)

                            Text {
                                anchors.centerIn: parent
                                text: modelData.tag
                                font.family: "SF Pro Display"
                                font.pixelSize: 8
                                font.weight: Font.Bold
                                color: parent.parent.parent.parent.parent.selectedTag === modelData.tag ? "#FFFFFF" : Qt.rgba(1, 1, 1, 0.6)
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    parent.parent.parent.parent.selectedTag = modelData.tag;
                                    parent.parent.parent.parent.selectedColor = modelData.col;
                                }
                            }

                        }

                    }

                }

                Item {
                    Layout.fillHeight: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 26
                    radius: 7
                    color: "#007AFF"

                    Text {
                        anchors.centerIn: parent
                        text: "Guardar Tarea"
                        font.family: "SF Pro Display"
                        font.pixelSize: 9
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (titleInput.text.trim() !== "") {
                                if (root.widgetsState)
                                    root.widgetsState.addTimetableTask(titleInput.text.trim(), parent.parent.parent.selectedTag, "Pendiente");

                                titleInput.text = "";
                            }
                            root.addTaskModalOpen = false;
                        }
                    }

                }

            }

        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 5. MODAL: APUNTES & NOTAS SCRATCHPAD ──
        // ═══════════════════════════════════════════════════════════════════
        Rectangle {
            anchors.fill: parent
            radius: root.widgetsState ? root.widgetsState.cardRadius : 22
            color: root.widgetsState && root.widgetsState.isDarkTheme ? "#161B26" : "#FFFFFF"
            visible: root.notesModalOpen
            border.color: "#E5A93C"
            border.width: 1.5

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "󰠮"
                        font.family: "CaskaydiaCove Nerd Font"
                        font.pixelSize: 12
                        color: "#E5A93C"
                    }

                    Text {
                        text: "APUNTES & NOTAS RÁPIDAS"
                        font.family: "SF Pro Display"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "✕"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: Qt.rgba(1, 1, 1, 0.6)

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.notesModalOpen = false
                        }

                    }

                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 8
                    color: Qt.rgba(1, 1, 1, 0.08)
                    border.color: Qt.rgba(1, 1, 1, 0.15)
                    border.width: 1

                    TextEdit {
                        id: modalNotesEdit

                        anchors.fill: parent
                        anchors.margins: 6
                        text: root.widgetsState && root.widgetsState.ttNotes ? root.widgetsState.ttNotes : ""
                        font.family: "SF Pro Display"
                        font.pixelSize: 10
                        color: "#FFFFFF"
                        wrapMode: TextEdit.Wrap
                    }

                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 28
                    radius: 8
                    color: "#E5A93C"

                    Text {
                        anchors.centerIn: parent
                        text: "Guardar Apuntes"
                        font.family: "SF Pro Display"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.widgetsState)
                                root.widgetsState.setTimetableNotes(modalNotesEdit.text);

                            root.notesModalOpen = false;
                        }
                    }

                }

            }

        }

    }

}
