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

    readonly property bool nothing: root.widgetsState && root.widgetsState.skin && root.widgetsState.skin.isNothing
    readonly property var skin: root.widgetsState ? root.widgetsState.skin : null

    readonly property real cardRadius: root.nothing ? root.skin.radiusCard : (root.widgetsState ? root.widgetsState.cardRadius : 22)
    readonly property string fontFamily: root.nothing ? root.skin.fontText : "-apple-system, BlinkMacSystemFont, 'SF Pro Display', 'SF Pro Text', 'Helvetica Neue', Cantarell, sans-serif"

    // ── Colores de la estética Files ─────────────────────
    readonly property color gradTop: "#86D8CA" // taste-skill-ignore
    readonly property color gradBottom: "#65C0B1" // taste-skill-ignore
    readonly property color textPrimary: root.nothing ? root.skin.ink : "#114B44"
    readonly property color textSecondary: root.nothing ? root.skin.inkDim : "#306962"
    readonly property color shelfLineColor: root.nothing ? root.skin.dotOff : Qt.rgba(255, 255, 255, 0.28)
    readonly property color pillBgColor: root.nothing ? root.skin.surface : Qt.rgba(255, 255, 255, 0.26)
    readonly property color pillBorderColor: root.nothing ? root.skin.cardBorder : Qt.rgba(255, 255, 255, 0.35)

    // ── Datos reactivos de archivos ───────────────────────────────────────
    readonly property var fallbackFiles: [
        {
            "id": "f_1",
            "name": "CV_FACUNDO_CARRIZO.pdf",
            "short_name": "CV_...IZO",
            "med_name": "CV_FACUN-DOCA...O.pdf",
            "date": "anteayer",
            "ext": "pdf",
            "type": "pdf",
            "thumb": "",
            "path": Quickshell.env("HOME") + "/Documents/CV_FACUNDO_CARRIZO.pdf"
        },
        {
            "id": "f_2",
            "name": "Planificación y Presupuesto Alfonso.pdf",
            "short_name": "Pla...onso",
            "med_name": "Planificación y Pres...lfonso",
            "date": "10/21/26",
            "ext": "pdf",
            "type": "pdf",
            "thumb": "",
            "path": Quickshell.env("HOME") + "/Downloads/Planificación y Presupuesto - App Dra. Natalia Alfonso.docx.pdf"
        },
        {
            "id": "f_3",
            "name": "Planificación Estratégica.pdf",
            "short_name": "Pla...onso",
            "med_name": "Planificación y Pres...lfonso",
            "date": "10/21/26",
            "ext": "pdf",
            "type": "pdf",
            "thumb": "",
            "path": Quickshell.env("HOME") + "/Documents/Planificacion.pdf"
        },
        {
            "id": "f_4",
            "name": "Planificación y Presupuesto 2026.pdf",
            "short_name": "Pla...onso",
            "med_name": "Planificación y Pres...lfonso",
            "date": "10/21/26",
            "ext": "pdf",
            "type": "pdf",
            "thumb": "",
            "path": Quickshell.env("HOME") + "/Documents/Presupuesto.pdf"
        },
        {
            "id": "f_5",
            "name": "Plan de Desarrollo por Etapas.pdf",
            "short_name": "Planificacion",
            "med_name": "Plan de Desarrollo por Etapas",
            "date": "10/20/26",
            "ext": "pdf",
            "type": "pdf",
            "thumb": "",
            "path": Quickshell.env("HOME") + "/Documents/PlanDesarrollo.pdf"
        },
        {
            "id": "f_6",
            "name": "CV_FACUNDO_CARRIZO 3.pdf",
            "short_name": "CV_FA...O 3.pdf",
            "med_name": "CV_FACUNDO_CARRIZO 3.pdf",
            "date": "10/18/26",
            "ext": "pdf",
            "type": "pdf",
            "thumb": "",
            "path": Quickshell.env("HOME") + "/Documents/CV_FACUNDO_CARRIZO_3.pdf"
        },
        {
            "id": "f_7",
            "name": "Total_Clase.pdf",
            "short_name": "Total_...lase.pdf",
            "med_name": "Total_Clase.pdf",
            "date": "10/15/26",
            "ext": "pdf",
            "type": "pdf",
            "thumb": "",
            "path": Quickshell.env("HOME") + "/Documents/Total_Clase.pdf"
        },
        {
            "id": "f_8",
            "name": "Inferencia_A_.pdf",
            "short_name": "Inferen...A_.pdf",
            "med_name": "Inferencia_A_.pdf",
            "date": "10/12/26",
            "ext": "pdf",
            "type": "pdf",
            "thumb": "",
            "path": Quickshell.env("HOME") + "/Documents/Inferencia_A_.pdf"
        },
        {
            "id": "f_9",
            "name": "ios-isla-dinamica-que-se.png",
            "short_name": "ios-isla...que-se",
            "med_name": "ios-isla-dinamica.png",
            "date": "10/10/26",
            "ext": "png",
            "type": "image",
            "thumb": "",
            "path": Quickshell.env("HOME") + "/Downloads/ios-isla-dinamica.png"
        }
    ]

    readonly property var activeFiles: (root.widgetsState && root.widgetsState.filesList && root.widgetsState.filesList.length > 0) ? root.widgetsState.filesList : root.fallbackFiles

    property int activePage: 0
    readonly property int totalPages: Math.max(1, Math.ceil(root.activeFiles.length / 9))

    // ═══════════════════════════════════════════════════════════════════════
    // ── Componente Reutilizable de Miniatura de Documento (FileThumbnail) ──
    // ═══════════════════════════════════════════════════════════════════════
    component FileThumbnail : Rectangle {
        id: thumbRoot

        property string thumbUrl: ""
        property string fileType: "pdf"
        property string fileName: ""

        color: root.nothing ? root.skin.surface : "#FFFFFF"
        radius: 4
        clip: true
        border.color: root.nothing ? root.skin.dotOff : Qt.rgba(0, 0, 0, 0.10)
        border.width: 1

        // 1. Imagen real (si existe thumbnail del sistema o es imagen directa)
        Image {
            id: realImg

            anchors.fill: parent
            source: thumbRoot.thumbUrl !== "" ? thumbRoot.thumbUrl : ""
            visible: thumbRoot.thumbUrl !== "" && status === Image.Ready
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            smooth: true
            clip: true
        }

        // 2. Previsualización Vectorial Documental Estilo iOS (hoja con líneas reales)
        Item {
            anchors.fill: parent
            visible: !realImg.visible
            anchors.margins: 3

            // Cabecera de Documento
            Rectangle {
                id: docHeader

                anchors.top: parent.top
                anchors.topMargin: 2
                anchors.left: parent.left
                anchors.leftMargin: 2
                anchors.right: parent.right
                anchors.rightMargin: 2
                height: thumbRoot.height > 50 ? 9 : 6
                color: root.nothing
                    ? (thumbRoot.fileName.toLowerCase().indexOf("cv") !== -1 ? root.skin.signal : root.skin.inkDim)
                    : (thumbRoot.fileType === "image" ? "#10B981" : (thumbRoot.fileName.toLowerCase().indexOf("cv") !== -1 ? "#B91C1C" : "#D97706"))
                radius: 1.5

                Rectangle {
                    anchors.right: parent.right
                    anchors.rightMargin: 2
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.height - 2
                    height: parent.height - 2
                    radius: 1
                    color: Qt.rgba(255, 255, 255, 0.8)
                    visible: thumbRoot.fileName.toLowerCase().indexOf("cv") !== -1
                }
            }

            // Líneas de texto simuladas
            Column {
                anchors.top: docHeader.bottom
                anchors.topMargin: thumbRoot.height > 50 ? 5 : 3
                anchors.left: parent.left
                anchors.leftMargin: 2
                anchors.right: parent.right
                anchors.rightMargin: 2
                spacing: thumbRoot.height > 50 ? 3 : 2

                Rectangle {
                    width: parent.width * 0.90
                    height: 1.5
                    radius: 0.75
                    color: root.nothing ? root.skin.dotOff : Qt.rgba(0, 0, 0, 0.22)
                }

                Rectangle {
                    width: parent.width * 0.75
                    height: 1.5
                    radius: 0.75
                    color: root.nothing ? root.skin.dotOff : Qt.rgba(0, 0, 0, 0.18)
                }

                Rectangle {
                    width: parent.width * 0.85
                    height: 1.5
                    radius: 0.75
                    color: root.nothing ? root.skin.dotOff : Qt.rgba(0, 0, 0, 0.18)
                }

                Rectangle {
                    width: parent.width * 0.60
                    height: 1.5
                    radius: 0.75
                    color: root.nothing ? root.skin.dotOff : Qt.rgba(0, 0, 0, 0.16)
                }

                Rectangle {
                    width: parent.width * 0.80
                    height: 1.5
                    radius: 0.75
                    color: root.nothing ? root.skin.dotOff : Qt.rgba(0, 0, 0, 0.14)
                    visible: thumbRoot.height > 50
                }

                Rectangle {
                    width: parent.width * 0.70
                    height: 1.5
                    radius: 0.75
                    color: root.nothing ? root.skin.dotOff : Qt.rgba(0, 0, 0, 0.16)
                    visible: thumbRoot.height > 50
                }

                Rectangle {
                    width: parent.width * 0.50
                    height: 1.5
                    radius: 0.75
                    color: root.nothing ? root.skin.dotOff : Qt.rgba(0, 0, 0, 0.14)
                    visible: thumbRoot.height > 60
                }
            }
        }
    }

    // ── Tarjeta Contenedora Principal ─────────────────────────────────────
    Rectangle {
        id: cardBg

        anchors.fill: parent
        radius: root.cardRadius
        clip: true
        color: root.nothing ? root.skin.card : "transparent"
        border.color: root.nothing ? root.skin.cardBorder : Qt.rgba(255, 255, 255, 0.35)
        border.width: root.nothing ? 0 : 1

        gradient: root.nothing ? null : cardGrad

        Gradient {
            id: cardGrad
            GradientStop { position: 0.0; color: root.gradTop }
            GradientStop { position: 1.0; color: root.gradBottom }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 1. MODO SMALL (170 x 170): EXACTO A REFERENCIA IMAGEN 1 ───────
        // ═══════════════════════════════════════════════════════════════════
        Item {
            id: smallView

            anchors.fill: parent
            visible: root.isSmall

            // Estante horizontal divisorio central
            Rectangle {
                x: 0
                y: Math.round(parent.height / 2) + 6
                width: parent.width
                height: 2 // taste-skill-ignore
                color: root.shelfLineColor
            }

            // Grid 2x2 exacto a la imagen de referencia
            Grid {
                anchors.fill: parent
                anchors.topMargin: 12
                anchors.bottomMargin: 10
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                columns: 2
                rows: 2
                spacing: 0

                Repeater {
                    model: Math.min(root.activeFiles.length, 4)

                    Item {
                        width: (smallView.width - 20) / 2
                        height: (smallView.height - 22) / 2

                        readonly property var fItem: root.activeFiles[index]

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.widgetsState)
                                    root.widgetsState.openFile(fItem.path);
                                else
                                    Quickshell.execDetached(["xdg-open", fItem.path]);
                            }

                            Column {
                                anchors.centerIn: parent
                                spacing: 4

                                FileThumbnail {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 36
                                    height: 48
                                    thumbUrl: fItem.thumb || ""
                                    fileType: fItem.type || "pdf"
                                    fileName: fItem.name || ""
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: (smallView.width - 24) / 2
                                    text: fItem.short_name || fItem.name || ""
                                    color: root.textPrimary
                                    font.family: root.fontFamily
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideMiddle
                                }
                            }
                        }
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 2. MODO MEDIUM (354 x 176): EXACTO A REFERENCIA IMAGEN 2 ──────
        // ═══════════════════════════════════════════════════════════════════
        Item {
            id: mediumView

            anchors.fill: parent
            visible: root.isMedium || (!root.isSmall && !root.isLarge)

            Grid {
                anchors.fill: parent
                anchors.margins: 14
                columns: 2
                rows: 2
                columnSpacing: 10
                rowSpacing: 10

                Repeater {
                    model: Math.min(root.activeFiles.length, 4)

                    Rectangle {
                        width: (mediumView.width - 38) / 2
                        height: (mediumView.height - 38) / 2
                        radius: 17
                        color: pillMa.containsMouse ? Qt.rgba(255, 255, 255, 0.36) : root.pillBgColor
                        border.color: root.pillBorderColor
                        border.width: 1 // taste-skill-ignore

                        readonly property var fItem: root.activeFiles[index]

                        MouseArea {
                            id: pillMa

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.widgetsState)
                                    root.widgetsState.openFile(fItem.path);
                                else
                                    Quickshell.execDetached(["xdg-open", fItem.path]);
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 10

                                FileThumbnail {
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 44
                                    Layout.alignment: Qt.AlignVCenter
                                    thumbUrl: fItem.thumb || ""
                                    fileType: fItem.type || "pdf"
                                    fileName: fItem.name || ""
                                }

                                Column {
                                    Layout.fillWidth: true
                                    Layout.alignment: Qt.AlignVCenter
                                    spacing: 3

                                    Text {
                                        width: parent.width
                                        text: fItem.med_name || fItem.name || ""
                                        color: root.textPrimary
                                        font.family: root.fontFamily
                                        font.pixelSize: 12
                                        font.weight: Font.DemiBold
                                        maximumLineCount: 2
                                        wrapMode: Text.Wrap
                                        elide: Text.ElideMiddle
                                    }

                                    Text {
                                        width: parent.width
                                        text: fItem.date || ""
                                        color: root.textSecondary
                                        font.family: root.fontFamily
                                        font.pixelSize: 11
                                        font.weight: Font.Normal
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 3. MODO LARGE (354 x 354): EXACTO A REFERENCIA IMAGEN 3 ───────
        // ═══════════════════════════════════════════════════════════════════
        Item {
            id: largeView

            anchors.fill: parent
            visible: root.isLarge

            // 3 Estantes divisorios horizontales de fondo
            Repeater {
                model: 3

                Rectangle {
                    x: 0
                    y: 112 + (index * 108)
                    width: parent.width - 20
                    height: 2 // taste-skill-ignore
                    color: root.shelfLineColor
                }
            }

            // Grid 3x3 de Documentos
            Grid {
                anchors.fill: parent
                anchors.topMargin: 14
                anchors.bottomMargin: 14
                anchors.leftMargin: 14
                anchors.rightMargin: 24
                columns: 3
                rows: 3
                spacing: 0

                Repeater {
                    model: 9

                    Item {
                        width: (largeView.width - 38) / 3
                        height: (largeView.height - 28) / 3

                        readonly property int itemIdx: (root.activePage * 9) + index
                        readonly property var fItem: itemIdx < root.activeFiles.length ? root.activeFiles[itemIdx] : null

                        visible: fItem !== null

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (fItem) {
                                    if (root.widgetsState)
                                        root.widgetsState.openFile(fItem.path);
                                    else
                                        Quickshell.execDetached(["xdg-open", fItem.path]);
                                }
                            }

                            Column {
                                anchors.centerIn: parent
                                spacing: 5

                                FileThumbnail {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 48
                                    height: 66
                                    radius: 5
                                    thumbUrl: fItem ? (fItem.thumb || "") : ""
                                    fileType: fItem ? (fItem.type || "pdf") : "pdf"
                                    fileName: fItem ? (fItem.name || "") : ""
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: (largeView.width - 44) / 3
                                    text: fItem ? (fItem.short_name || fItem.name || "") : ""
                                    color: root.textPrimary
                                    font.family: root.fontFamily
                                    font.pixelSize: 11
                                    font.weight: Font.DemiBold
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideMiddle
                                }
                            }
                        }
                    }
                }
            }

            // Indicador de Paginación Vertical en el lateral derecho (3 Puntos exactos)
            Column {
                anchors.right: parent.right
                anchors.rightMargin: 9
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Repeater {
                    model: 3

                    Rectangle {
                        width: 5
                        height: 5
                        radius: 2.5
                        color: root.nothing
                            ? (index === root.activePage ? root.skin.signal : root.skin.dotOff)
                            : (index === root.activePage ? "#FFFFFF" : Qt.rgba(255, 255, 255, 0.45))

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (index < root.totalPages)
                                    root.activePage = index;
                            }
                        }
                    }
                }
            }
        }
    }
}
