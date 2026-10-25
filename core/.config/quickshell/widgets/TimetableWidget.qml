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

    // Índice activo para navegación en modo compacto (pequeño)
    property int activeNoteIndex: 0
    property real lastWheelTime: 0

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

        // Interacción nativa: clic abre el Gestor de Notas y Agenda
        MouseArea {
            id: cardMa

            anchors.fill: parent
            enabled: !root.widgetsState || !root.widgetsState.isEditing
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                Quickshell.execDetached(["lunita-widgets-manager", "timetable"]);
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── CABECERA AMARILLA CON CARPETA + "Notas" (COMÚN EN LOS 3 MODOS) ─
        // ═══════════════════════════════════════════════════════════════════
        Item {
            id: headerArea

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: root.isLarge ? 48 : 38
            z: 2

            // Fondo amarillo con esquinas superiores redondeadas
            Rectangle {
                anchors.fill: parent
                radius: root.cardRadius
                color: root.yellowHeaderColor

                // Cuadrado inferior para esquinas rectas abajo
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: root.cardRadius
                    color: root.yellowHeaderColor
                }
            }

            // Contenedor de Icono de Carpeta + Texto "Notas"
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 8

                // Icono vectorial de Carpeta Apple Notes (trazo blanco nítido)
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
                    Layout.alignment: Qt.AlignVCenter
                }

                Item {
                    Layout.fillWidth: true
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
            anchors.topMargin: 5
            spacing: 5
            clip: true
            z: 2

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
        // ── 1. MODO COMPACTO / PEQUEÑO (170 x 170): EXACTO A IMAGEN 3 ────
        // ═══════════════════════════════════════════════════════════════════
        Item {
            id: smallView

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.top: perforationRow.bottom
            anchors.topMargin: 4
            visible: root.isSmall

            // Soporte para navegación con rueda del mouse entre notas
            WheelHandler {
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                onWheel: (event) => {
                    var now = Date.now();
                    if (now - root.lastWheelTime > 140) {
                        root.lastWheelTime = now;
                        if (event.angleDelta.y < 0)
                            root.nextNote();
                        else if (event.angleDelta.y > 0)
                            root.prevNote();
                    }
                }
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                anchors.topMargin: 14
                spacing: 3

                Text {
                    text: root.currentNote ? (root.currentNote.title || "Nueva nota") : "Nueva nota"
                    font.family: root.fontFamily
                    font.pixelSize: 15
                    font.weight: Font.Medium
                    color: root.textPrimaryColor
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    text: root.currentNote ? (root.currentNote.body || "Nota a mano") : "Nota a mano"
                    font.family: root.fontFamily
                    font.pixelSize: 14
                    font.weight: Font.Normal
                    color: root.textSecondaryColor
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }

            // Fecha fijada en la parte inferior izquierda
            Text {
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.leftMargin: 16
                anchors.bottomMargin: 16
                text: root.currentNote ? (root.currentNote.date || "miércoles") : "miércoles"
                font.family: root.fontFamily
                font.pixelSize: 14
                font.weight: Font.Normal
                color: root.textSecondaryColor
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 2. MODO MEDIANO (354 x 176): EXACTO A IMAGEN 1 ───────────────
        // ═══════════════════════════════════════════════════════════════════
        Item {
            id: mediumView

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.top: perforationRow.bottom
            anchors.topMargin: 4
            visible: root.isMedium

            ListView {
                id: mediumListView

                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                clip: true
                model: root.notesList
                spacing: 0

                delegate: Item {
                    width: mediumListView.width
                    height: 38

                    RowLayout {
                        anchors.fill: parent
                        anchors.bottomMargin: 1
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

                        // Thumbnail de previsualización cuadrado si la nota tiene adjunto
                        Rectangle {
                            visible: !!modelData.has_thumbnail
                            Layout.preferredWidth: 24
                            Layout.preferredHeight: 24
                            radius: 4
                            color: root.isDark ? "#2C2C2E" : "#F8F8FA"
                            border.color: root.dividerColor
                            border.width: 1
                            Layout.alignment: Qt.AlignVCenter

                            Canvas {
                                anchors.centerIn: parent
                                width: 14
                                height: 12
                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.reset();
                                    ctx.strokeStyle = root.isDark ? "#8E8E93" : "#C7C7CC";
                                    ctx.lineWidth = 1.2;
                                    ctx.beginPath();
                                    ctx.arc(4, 4, 1.5, 0, Math.PI * 2);
                                    ctx.stroke();
                                    ctx.beginPath();
                                    ctx.moveTo(1, 10);
                                    ctx.lineTo(5, 6);
                                    ctx.lineTo(9, 9);
                                    ctx.lineTo(13, 5);
                                    ctx.stroke();
                                }
                            }
                        }
                    }

                    // Línea divisoria hairline horizontal
                    // taste-skill-ignore
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 1
                        color: root.dividerColor
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 3. MODO EXPANDIDO / GRANDE (354 x 354): EXACTO A IMAGEN 2 ─────
        // ═══════════════════════════════════════════════════════════════════
        Item {
            id: largeView

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.top: perforationRow.bottom
            anchors.topMargin: 4
            visible: root.isLarge || (!root.isSmall && !root.isMedium)

            ListView {
                id: largeListView

                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                clip: true
                model: root.notesList
                spacing: 0

                delegate: Item {
                    width: largeListView.width
                    height: 48

                    RowLayout {
                        anchors.fill: parent
                        anchors.bottomMargin: 1
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

                        // Thumbnail de previsualización cuadrado si la nota tiene adjunto
                        Rectangle {
                            visible: !!modelData.has_thumbnail
                            Layout.preferredWidth: 28
                            Layout.preferredHeight: 28
                            radius: 5
                            color: root.isDark ? "#2C2C2E" : "#F8F8FA"
                            border.color: root.dividerColor
                            border.width: 1
                            Layout.alignment: Qt.AlignVCenter

                            Canvas {
                                anchors.centerIn: parent
                                width: 16
                                height: 14
                                onPaint: {
                                    var ctx = getContext("2d");
                                    ctx.reset();
                                    ctx.strokeStyle = root.isDark ? "#8E8E93" : "#C7C7CC";
                                    ctx.lineWidth = 1.2;
                                    ctx.beginPath();
                                    ctx.arc(5, 4, 1.8, 0, Math.PI * 2);
                                    ctx.stroke();
                                    ctx.beginPath();
                                    ctx.moveTo(1, 12);
                                    ctx.lineTo(6, 7);
                                    ctx.lineTo(10, 10);
                                    ctx.lineTo(15, 6);
                                    ctx.stroke();
                                }
                            }
                        }
                    }

                    // Línea divisoria hairline horizontal
                    // taste-skill-ignore
                    Rectangle {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        height: 1
                        color: root.dividerColor
                    }
                }
            }
        }
    }
}
