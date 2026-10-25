import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell

Item {
    id: root

    property var widgetsState

    readonly property var skin: root.widgetsState ? root.widgetsState.skin : null
    readonly property bool nothing: root.skin ? root.skin.isNothing : false

    readonly property bool isSmall: root.width <= 220
    readonly property bool isMedium: root.width > 220 && root.height <= 240
    readonly property bool isLarge: root.width > 220 && root.height > 240

    readonly property real cardRadius: root.nothing ? root.skin.radius : (root.widgetsState ? root.widgetsState.cardRadius : 22)
    readonly property string fontFamily: root.nothing ? root.skin.fontText : "-apple-system, BlinkMacSystemFont, 'SF Pro Display', 'SF Pro Text', 'Helvetica Neue', Cantarell, sans-serif"
    readonly property string fontFigure: root.nothing ? root.skin.fontFigure : root.fontFamily

    // ── Datos reactivos obtenidos de widgetsState ──────────────────────────
    readonly property string cityName: (root.widgetsState && root.widgetsState.weatherCityName) ? root.widgetsState.weatherCityName : "Buenos Aires"
    readonly property string tempVal: (root.widgetsState && root.widgetsState.weatherTempVal) ? root.widgetsState.weatherTempVal : "13°"
    readonly property string maxTemp: (root.widgetsState && root.widgetsState.weatherMax) ? root.widgetsState.weatherMax : "18°"
    readonly property string minTemp: (root.widgetsState && root.widgetsState.weatherMin) ? root.widgetsState.weatherMin : "11°"
    readonly property string conditionType: (root.widgetsState && root.widgetsState.weatherConditionType) ? root.widgetsState.weatherConditionType : "cloudy"
    readonly property string conditionDesc: (root.widgetsState && root.widgetsState.weatherDesc) ? root.widgetsState.weatherDesc : "Nublado"
    readonly property var hourlyData: (root.widgetsState && root.widgetsState.weatherHourly && root.widgetsState.weatherHourly.length > 0) ? root.widgetsState.weatherHourly : [
        { "time": "11 a.m.", "temp": "14°", "condition_type": "cloudy" },
        { "time": "12 p.m.", "temp": "14°", "condition_type": "cloudy" },
        { "time": "1 p.m.",  "temp": "14°", "condition_type": "cloudy" },
        { "time": "2 p.m.",  "temp": "17°", "condition_type": "partly_cloudy" },
        { "time": "3 p.m.",  "temp": "17°", "condition_type": "cloudy" },
        { "time": "4 p.m.",  "temp": "17°", "condition_type": "cloudy" }
    ]
    readonly property var dailyData: (root.widgetsState && root.widgetsState.weatherDaily && root.widgetsState.weatherDaily.length > 0) ? root.widgetsState.weatherDaily : [
        { "day": "Hoy", "min": "11°", "max": "17°", "condition_type": "cloudy", "desc": "Nublado" },
        { "day": "Mañana", "min": "9°", "max": "16°", "condition_type": "partly_cloudy", "desc": "Parcialmente nublado" },
        { "day": "MAR", "min": "11°", "max": "19°", "condition_type": "rain", "desc": "Llovizna dispersa" }
    ]

    // ── Paleta atmosférica dinámica estilo iOS Weather ────────────────────
    readonly property color gradTop: {
        switch (root.conditionType) {
            case "sunny":
            case "clear":
                return "#3A88E9";
            case "partly_cloudy":
                return "#52759B";
            case "rain":
            case "drizzle":
                return "#485567";
            case "thunder":
                return "#333A4A";
            case "snow":
                return "#5C6E80";
            case "cloudy":
            case "fog":
            default:
                return "#687585";
        }
    }

    readonly property color gradBottom: {
        switch (root.conditionType) {
            case "sunny":
            case "clear":
                return "#1C61C4";
            case "partly_cloudy":
                return "#3E5C7D";
            case "rain":
            case "drizzle":
                return "#323B47";
            case "thunder":
                return "#202530";
            case "snow":
                return "#425060";
            case "cloudy":
            case "fog":
            default:
                return "#4F5967";
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // ── Componente Reutilizable de Icono Vectorial iOS Weather ────────────
    // ═══════════════════════════════════════════════════════════════════════
    component WeatherIcon : Item {
        id: iconRoot

        property string type: "cloudy"
        property real size: 24
        property color iconColor: "#FFFFFF"

        implicitWidth: size
        implicitHeight: size

        Item {
            anchors.centerIn: parent
            width: 24
            height: 24
            scale: iconRoot.size / 24
            transformOrigin: Item.Center

            // 1. Sol de fondo (para parcialmente nublado)
            Rectangle {
                visible: iconRoot.type === "partly_cloudy"
                x: 3
                y: 2
                width: 12
                height: 12
                radius: 6
                color: root.nothing ? root.skin.ink : "#F59E0B"
            }

            // 2. Sol completo para cielo despejado
            Shape {
                visible: iconRoot.type === "clear" || iconRoot.type === "sunny"
                width: 24
                height: 24
                layer.enabled: true
                layer.smooth: true

                ShapePath {
                    strokeWidth: 0
                    fillColor: root.nothing ? root.skin.ink : "#F59E0B"
                    PathSvg {
                        path: "M12 7c-2.76 0-5 2.24-5 5s2.24 5 5 5 5-2.24 5-5-2.24-5-5-5zm0-5c.55 0 1 .45 1 1v2c0 .55-.45 1-1 1s-1-.45-1-1V3c0-.55.45-1 1-1zm0 15c.55 0 1 .45 1 1v2c0 .55-.45 1-1 1s-1-.45-1-1v-2c0-.55.45-1 1-1zm10-6c0 .55-.45 1-1 1h-2c-.55 0-1-.45-1-1s.45-1 1-1h2c.55 0 1 .45 1 1zM6 12c0 .55-.45 1-1 1H3c-.55 0-1-.45-1-1s.45-1 1-1h2c.55 0 1 .45 1 1zm11.07-5.66c.39.39.39 1.02 0 1.41-.39.39-1.02.39-1.41 0l-1.41-1.41c-.39-.39-.39-1.02 0-1.41.39-.39 1.02-.39 1.41 0l1.41 1.41zm-9.9 9.9c.39.39.39 1.02 0 1.41-.39.39-1.02.39-1.41 0l-1.41-1.41c-.39-.39-.39-1.02 0-1.41.39-.39 1.02-.39 1.41 0l1.41 1.41zm9.9 0c-.39.39-1.02.39-1.41 0-.39-.39-.39-1.02 0-1.41l1.41-1.41c.39-.39 1.02-.39 1.41 0 .39.39.39 1.02 0 1.41l-1.41 1.41zM7.17 6.34c-.39.39-1.02.39-1.41 0-.39-.39-.39-1.02 0-1.41l1.41-1.41c.39-.39 1.02-.39 1.41 0 .39.39.39 1.02 0 1.41L7.17 6.34z"
                    }
                }
            }

            // 3. Nube blanca vectorial (puffy cloud de Apple)
            Shape {
                visible: iconRoot.type !== "clear" && iconRoot.type !== "sunny"
                width: 24
                height: 24
                layer.enabled: true
                layer.smooth: true

                ShapePath {
                    strokeWidth: 0
                    fillColor: iconRoot.iconColor
                    PathSvg {
                        path: "M19.35 10.04C18.67 6.59 15.64 4 12 4 9.11 4 6.6 5.64 5.35 8.04 2.34 8.36 0 10.91 0 14c0 3.31 2.69 6 6 6h13c2.76 0 5-2.24 5-5 0-2.64-2.05-4.78-4.65-4.96z"
                    }
                }
            }

            // 4. Gotas de lluvia
            Shape {
                visible: iconRoot.type === "rain" || iconRoot.type === "drizzle"
                width: 24
                height: 24
                layer.enabled: true
                layer.smooth: true

                ShapePath {
                    strokeWidth: 0
                    fillColor: root.nothing ? root.skin.inkDim : "#60A5FA"
                    PathSvg {
                        path: "M7 21c-.55 0-1-.45-1-1v-2c0-.55.45-1 1-1s1 .45 1 1v2c0 .55-.45 1-1 1zm4 1.5c-.55 0-1-.45-1-1v-2c0-.55.45-1 1-1s1 .45 1 1v2c0 .55-.45 1-1 1zm4-1.5c-.55 0-1-.45-1-1v-2c0-.55.45-1 1-1s1 .45 1 1v2c0 .55-.45 1-1 1z"
                    }
                }
            }

            // 5. Rayo de tormenta
            Shape {
                visible: iconRoot.type === "thunder"
                width: 24
                height: 24
                layer.enabled: true
                layer.smooth: true

                ShapePath {
                    strokeWidth: 0
                    fillColor: root.nothing ? root.skin.signal : "#FBBF24"
                    PathSvg {
                        path: "M11 14h2.5l-2 6 5.5-5h-3l2.5-5h-5z"
                    }
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
        border.color: root.nothing ? "transparent" : Qt.rgba(1, 1, 1, 0.12)
        border.width: root.nothing ? 0 : 1
        color: root.nothing ? root.skin.card : "transparent"

        gradient: root.nothing ? null : appleGradient

        Gradient {
            id: appleGradient
            GradientStop { position: 0.0; color: root.gradTop }
            GradientStop { position: 1.0; color: root.gradBottom }
        }

        // Interacción nativa: clic refresca los datos meteorológicos
        MouseArea {
            id: clickArea

            anchors.fill: parent
            enabled: !root.widgetsState || !root.widgetsState.isEditing
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.widgetsState)
                    root.widgetsState.refreshWeather();
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 1. MODO SMALL (170 x 170): EXACTO A REFERENCIA IMAGEN 1 ───────
        // ═══════════════════════════════════════════════════════════════════
        Item {
            id: smallView

            anchors.fill: parent
            visible: root.isSmall

            // Sección Superior Izquierda: Ciudad y Temperatura Principal
            Column {
                anchors.top: parent.top
                anchors.topMargin: 15
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.right: parent.right
                anchors.rightMargin: 16
                spacing: 0

                Text {
                    width: parent.width
                    text: root.cityName
                    color: root.nothing ? root.skin.inkDim : "#FFFFFF"
                    font.family: root.fontFamily
                    font.pixelSize: root.nothing ? 13 : 15
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                }

                Text {
                    text: root.tempVal
                    color: root.nothing ? root.skin.ink : "#FFFFFF"
                    font.family: root.fontFigure
                    font.pixelSize: root.nothing ? 48 : 48
                    font.weight: root.nothing ? Font.Normal : Font.Light
                }
            }

            // Sección Inferior Izquierda: Icono Nube, Condición y Rango Térmico
            Column {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 14
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.right: parent.right
                anchors.rightMargin: 16
                spacing: 2

                WeatherIcon {
                    size: 24
                    type: root.conditionType
                }

                Item {
                    width: 1
                    height: 2
                }

                Text {
                    width: parent.width
                    text: root.conditionDesc
                    color: root.nothing ? root.skin.ink : "#FFFFFF"
                    font.family: root.fontFamily
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: "Máx. " + root.maxTemp + " Mín. " + root.minTemp
                    color: root.nothing ? root.skin.inkDim : Qt.rgba(1, 1, 1, 0.90)
                    font.family: root.fontFamily
                    font.pixelSize: 12
                    font.weight: Font.Normal
                    elide: Text.ElideRight
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

            // Cabecera Superior Izquierda: Ciudad y Temperatura
            Column {
                anchors.top: parent.top
                anchors.topMargin: 14
                anchors.left: parent.left
                anchors.leftMargin: 18
                spacing: 0

                Text {
                    text: root.cityName
                    color: root.nothing ? root.skin.inkDim : "#FFFFFF"
                    font.family: root.fontFamily
                    font.pixelSize: root.nothing ? 13 : 15
                    font.weight: Font.Medium
                }

                Text {
                    text: root.tempVal
                    color: root.nothing ? root.skin.ink : "#FFFFFF"
                    font.family: root.fontFigure
                    font.pixelSize: root.nothing ? 44 : 44
                    font.weight: root.nothing ? Font.Normal : Font.Light
                }
            }

            // Cabecera Superior Derecha: Icono, Condición y Máx/Mín
            Column {
                anchors.top: parent.top
                anchors.topMargin: 14
                anchors.right: parent.right
                anchors.rightMargin: 18
                spacing: 2

                WeatherIcon {
                    anchors.right: parent.right
                    size: 26
                    type: root.conditionType
                }

                Item {
                    width: 1
                    height: 2
                }

                Text {
                    anchors.right: parent.right
                    text: root.conditionDesc
                    color: root.nothing ? root.skin.ink : "#FFFFFF"
                    font.family: root.fontFamily
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    horizontalAlignment: Text.AlignRight
                }

                Text {
                    anchors.right: parent.right
                    text: "Máx. " + root.maxTemp + " Mín. " + root.minTemp
                    color: root.nothing ? root.skin.inkDim : Qt.rgba(1, 1, 1, 0.90)
                    font.family: root.fontFamily
                    font.pixelSize: 12
                    font.weight: Font.Normal
                    horizontalAlignment: Text.AlignRight
                }
            }

            // Fila Inferior de Pronóstico por Horas (6 Columnas exactas)
            Row {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 14
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.right: parent.right
                anchors.rightMargin: 16
                spacing: 0

                Repeater {
                    model: Math.min(root.hourlyData.length, 6)

                    Item {
                        width: (mediumView.width - 32) / Math.min(root.hourlyData.length, 6)
                        height: 56

                        readonly property var hItem: root.hourlyData[index]

                        Column {
                            anchors.centerIn: parent
                            spacing: 5

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: index === 0 ? "Ahora" : (hItem.time || "")
                                color: root.nothing ? root.skin.inkDim : Qt.rgba(1, 1, 1, 0.85)
                                font.family: root.fontFamily
                                font.pixelSize: 12
                                font.weight: Font.Medium
                            }

                            WeatherIcon {
                                anchors.horizontalCenter: parent.horizontalCenter
                                size: 20
                                type: hItem.condition_type || "cloudy"
                            }

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: hItem.temp || "--°"
                                color: root.nothing ? root.skin.ink : "#FFFFFF"
                                font.family: root.fontFigure
                                font.pixelSize: root.nothing ? 13 : 14
                                font.weight: Font.DemiBold
                            }
                        }
                    }
                }
            }
        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 3. MODO LARGE (354 x 354): VISTA EXPANDIDA CON DIARIO ──────────
        // ═══════════════════════════════════════════════════════════════════
        Item {
            id: largeView

            anchors.fill: parent
            visible: root.isLarge

            // Cabecera Superior Izquierda: Ciudad y Temperatura
            Column {
                anchors.top: parent.top
                anchors.topMargin: 18
                anchors.left: parent.left
                anchors.leftMargin: 20
                spacing: 0

                Text {
                    text: root.cityName
                    color: root.nothing ? root.skin.inkDim : "#FFFFFF"
                    font.family: root.fontFamily
                    font.pixelSize: root.nothing ? 14 : 16
                    font.weight: Font.Medium
                }

                Text {
                    text: root.tempVal
                    color: root.nothing ? root.skin.ink : "#FFFFFF"
                    font.family: root.fontFigure
                    font.pixelSize: root.nothing ? 52 : 48
                    font.weight: root.nothing ? Font.Normal : Font.Light
                }
            }

            // Cabecera Superior Derecha: Icono, Condición y Máx/Mín
            Column {
                anchors.top: parent.top
                anchors.topMargin: 18
                anchors.right: parent.right
                anchors.rightMargin: 20
                spacing: 3

                WeatherIcon {
                    anchors.right: parent.right
                    size: 28
                    type: root.conditionType
                }

                Item {
                    width: 1
                    height: 2
                }

                Text {
                    anchors.right: parent.right
                    text: root.conditionDesc
                    color: root.nothing ? root.skin.ink : "#FFFFFF"
                    font.family: root.fontFamily
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    horizontalAlignment: Text.AlignRight
                }

                Text {
                    anchors.right: parent.right
                    text: "Máx. " + root.maxTemp + " Mín. " + root.minTemp
                    color: root.nothing ? root.skin.inkDim : Qt.rgba(1, 1, 1, 0.90)
                    font.family: root.fontFamily
                    font.pixelSize: 13
                    font.weight: Font.Normal
                    horizontalAlignment: Text.AlignRight
                }
            }

            // Pronóstico Horario Container
            Rectangle {
                id: hourlyBox

                anchors.top: parent.top
                anchors.topMargin: 96
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.right: parent.right
                anchors.rightMargin: 16
                height: 86
                radius: root.nothing ? 16 : 14
                color: root.nothing ? root.skin.raised : Qt.rgba(0, 0, 0, 0.12)

                Row {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 0

                    Repeater {
                        model: Math.min(root.hourlyData.length, 6)

                        Item {
                            width: (hourlyBox.width - 16) / Math.min(root.hourlyData.length, 6)
                            height: parent.height

                            readonly property var hItem: root.hourlyData[index]

                            Column {
                                anchors.centerIn: parent
                                spacing: 5

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: index === 0 ? "Ahora" : (hItem.time || "")
                                    color: root.nothing ? root.skin.inkDim : Qt.rgba(1, 1, 1, 0.85)
                                    font.family: root.fontFamily
                                    font.pixelSize: 11
                                    font.weight: Font.Medium
                                }

                                WeatherIcon {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    size: 19
                                    type: hItem.condition_type || "cloudy"
                                }

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: hItem.temp || "--°"
                                    color: root.nothing ? root.skin.ink : "#FFFFFF"
                                    font.family: root.fontFigure
                                    font.pixelSize: root.nothing ? 13 : 13
                                    font.weight: Font.DemiBold
                                }
                            }
                        }
                    }
                }
            }

            // Pronóstico Diario de 3 Días Container
            Rectangle {
                id: dailyBox

                anchors.top: hourlyBox.bottom
                anchors.topMargin: 12
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 16
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.right: parent.right
                anchors.rightMargin: 16
                radius: root.nothing ? 16 : 14
                color: root.nothing ? root.skin.raised : Qt.rgba(0, 0, 0, 0.12)

                Column {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Repeater {
                        model: Math.min(root.dailyData.length, 3)

                        Item {
                            width: parent.width
                            height: 32

                            readonly property var dItem: root.dailyData[index]

                            RowLayout {
                                anchors.fill: parent
                                spacing: 10

                                Text {
                                    Layout.preferredWidth: 64
                                    text: dItem.day || ""
                                    color: root.nothing ? root.skin.ink : "#FFFFFF"
                                    font.family: root.fontFamily
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                }

                                WeatherIcon {
                                    size: 18
                                    type: dItem.condition_type || "cloudy"
                                }

                                Text {
                                    Layout.preferredWidth: 32
                                    text: dItem.min || ""
                                    color: root.nothing ? root.skin.inkDim : Qt.rgba(1, 1, 1, 0.75)
                                    font.family: root.fontFigure
                                    font.pixelSize: 13
                                    horizontalAlignment: Text.AlignRight
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 4
                                    radius: 2
                                    color: Qt.rgba(255, 255, 255, 0.2)

                                    Rectangle {
                                        anchors.left: parent.left
                                        anchors.leftMargin: index === 0 ? 12 : (index === 1 ? 6 : 16)
                                        width: Math.max(parent.width * 0.5, 20)
                                        height: parent.height
                                        radius: 2
                                        color: "#60A5FA" // taste-skill-ignore
                                    }
                                }

                                Text {
                                    Layout.preferredWidth: 32
                                    text: dItem.max || ""
                                    color: "#FFFFFF"
                                    font.family: root.fontFamily
                                    font.pixelSize: 13
                                    font.weight: Font.DemiBold
                                    horizontalAlignment: Text.AlignLeft
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
