import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var widgetsState
    property var canvas: null
    readonly property bool isSmall: root.width <= 220
    readonly property bool isMedium: root.width > 220 && root.height <= 240
    readonly property bool isLarge: root.width > 220 && root.height > 240
    readonly property bool isWide: isMedium || isLarge
    readonly property color domColor: root.widgetsState && root.widgetsState.mediaDominantColor ? root.widgetsState.mediaDominantColor : "#0A84FF"
    readonly property bool isPlaying: root.widgetsState ? !!root.widgetsState.mediaIsPlaying : false
    // ── Cava Visualizer Frequency Bars (16 bands) ──
    property var cavaBars: [4, 6, 8, 12, 10, 16, 14, 20, 18, 15, 12, 10, 8, 6, 4, 3]

    // Reset visualizer bars when paused
    onIsPlayingChanged: {
        if (!isPlaying)
            root.cavaBars = [3, 4, 3, 5, 4, 6, 5, 7, 5, 4, 5, 4, 3, 4, 3, 2];

    }

    // Cava process runner (active when expanded and playing)
    Process {
        id: cavaProc

        command: ["bash", root.widgetsState ? root.widgetsState.scriptsDir + "/cava_runner.sh" : ""]
        running: root.isWide && root.isPlaying

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: (data) => {
                var raw = data.trim();
                if (!raw)
                    return ;

                var parts = raw.split(";");
                var vals = [];
                for (var i = 0; i < parts.length; i++) {
                    var p = parts[i].trim();
                    if (p !== "")
                        vals.push(Math.min(100, Math.max(3, parseInt(p) || 0)));

                }
                if (vals.length >= 12)
                    root.cavaBars = vals.slice(0, 16);

            }
        }

    }

    Rectangle {
        id: bg

        anchors.fill: parent
        radius: root.widgetsState ? root.widgetsState.cardRadius : 22
        color: root.widgetsState ? root.widgetsState.cardBg : Qt.rgba(0.12, 0.14, 0.18, 0.75)
        border.color: root.widgetsState ? root.widgetsState.cardBorder : Qt.rgba(1, 1, 1, 0.14)
        border.width: 1
        clip: true

        // ── Dominant Color Glow ──
        Rectangle {
            anchors.fill: parent
            radius: root.widgetsState ? root.widgetsState.cardRadius : 22

            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: Qt.rgba(domColor.r, domColor.g, domColor.b, 0.22)
                }

                GradientStop {
                    position: 0.6
                    color: Qt.rgba(domColor.r, domColor.g, domColor.b, 0.06)
                }

                GradientStop {
                    position: 1
                    color: "transparent"
                }

            }

            Behavior on color {
                ColorAnimation {
                    duration: 400
                }

            }

        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 1. MODO EXPANDIDO MEDIO (354 x 170): CAVA SPECTRUM + CONTROLES ──
        // ═══════════════════════════════════════════════════════════════════
        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 12
            visible: root.isMedium

            // Album Art Container
            Rectangle {
                Layout.preferredWidth: 142
                Layout.preferredHeight: 142
                radius: 16
                clip: true
                color: root.widgetsState && root.widgetsState.isDarkTheme ? "#1A1A1E" : "#E5E5EA"
                border.color: root.widgetsState && root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                Image {
                    id: albumArt

                    anchors.fill: parent
                    source: root.widgetsState && root.widgetsState.mediaArtUrl ? root.widgetsState.mediaArtUrl : ""
                    fillMode: Image.PreserveAspectCrop
                    visible: source != "" && status === Image.Ready
                    asynchronous: true
                }

                // Fallback Music Icon
                ColumnLayout {
                    anchors.centerIn: parent
                    visible: !albumArt.visible
                    spacing: 4

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "󰎆"
                        font.family: "CaskaydiaCove Nerd Font"
                        font.pixelSize: 38
                        color: domColor
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Música"
                        font.family: "SF Pro Display"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.5)
                    }

                }

            }

            // Right side: Header, Track Info, Cava Visualizer, Progress & Controls
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 3

                // Header with status & Collapse button ‹
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: root.isPlaying ? "󰐊" : "󰏤"
                        font.family: "CaskaydiaCove Nerd Font"
                        font.pixelSize: 10
                        color: domColor
                    }

                    Text {
                        text: root.isPlaying ? "REPRODUCIENDO" : "EN PAUSA"
                        font.family: "SF Pro Display"
                        font.pixelSize: 8
                        font.weight: Font.Bold
                        color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.5)
                        font.letterSpacing: 0.8
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // Botón Colapsar ‹
                    Rectangle {
                        width: 18
                        height: 18
                        radius: 9
                        color: collapseMa.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.08)

                        Text {
                            anchors.centerIn: parent
                            text: "‹"
                            font.family: "SF Pro Display"
                            font.pixelSize: 13
                            font.weight: Font.Bold
                            color: "#FFFFFF"
                        }

                        MouseArea {
                            id: collapseMa

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                            onClicked: {
                                if (root.canvas)
                                    root.canvas.toggleMediaExpanded();
                                else if (root.widgetsState)
                                    root.widgetsState.toggleMediaExpanded();
                            }
                        }

                    }

                }

                // Title & Artist
                Text {
                    Layout.fillWidth: true
                    text: root.widgetsState && root.widgetsState.mediaTitle ? root.widgetsState.mediaTitle : "Sin reproducción"
                    font.family: "SF Pro Display"
                    font.pixelSize: 12
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                    maximumLineCount: 1
                    color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"
                }

                Text {
                    Layout.fillWidth: true
                    text: root.widgetsState && root.widgetsState.mediaArtist ? root.widgetsState.mediaArtist : "Ningún reproductor activo"
                    font.family: "SF Pro Display"
                    font.pixelSize: 10
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.6)
                }

                // ── CAVA SPECTRUM VISUALIZER ──
                SpectrumVisualizer {
                    spectrumHeight: 26
                    barSpacing: 3
                }

                // Progress Bar
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Rectangle {
                        Layout.fillWidth: true
                        height: 3
                        radius: 1.5
                        color: root.widgetsState && root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.14)" : "rgba(0,0,0,0.10)"

                        Rectangle {
                            height: parent.height
                            radius: 1.5
                            width: Math.max(3, parent.width * (root.widgetsState ? root.widgetsState.mediaProgress : 0))
                            color: domColor

                            Behavior on width {
                                NumberAnimation {
                                    duration: 250
                                }

                            }

                        }

                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: root.widgetsState ? root.widgetsState.mediaPositionStr : "0:00"
                            font.family: "JetBrains Mono"
                            font.pixelSize: 8
                            color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.5)
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: root.widgetsState ? root.widgetsState.mediaLengthStr : "0:00"
                            font.family: "JetBrains Mono"
                            font.pixelSize: 8
                            color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.5)
                        }

                    }

                }

                // Media Controls Row
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 16

                    // Prev
                    Text {
                        text: "󰒮"
                        font.family: "CaskaydiaCove Nerd Font"
                        font.pixelSize: 17
                        color: prevMa.containsMouse ? (root.widgetsState ? root.widgetsState.textColor : "#FFFFFF") : (root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.6))

                        MouseArea {
                            id: prevMa

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                            onClicked: {
                                if (root.widgetsState)
                                    root.widgetsState.mediaPrevious();

                            }
                        }

                    }

                    // Play/Pause Circle
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 14
                        color: domColor

                        Text {
                            anchors.centerIn: parent
                            text: root.isPlaying ? "󰏤" : "󰐊"
                            font.family: "CaskaydiaCove Nerd Font"
                            font.pixelSize: 14
                            color: "#FFFFFF"
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                            onClicked: {
                                if (root.widgetsState)
                                    root.widgetsState.mediaPlayPause();

                            }
                        }

                    }

                    // Next
                    Text {
                        text: "󰒭"
                        font.family: "CaskaydiaCove Nerd Font"
                        font.pixelSize: 17
                        color: nextMa.containsMouse ? (root.widgetsState ? root.widgetsState.textColor : "#FFFFFF") : (root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.6))

                        MouseArea {
                            id: nextMa

                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                            onClicked: {
                                if (root.widgetsState)
                                    root.widgetsState.mediaNext();

                            }
                        }

                    }

                }

            }

        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 2. MODO COMPACTO (170 x 170): COVER + BOTÓN EXPANDIR › ──
        // ═══════════════════════════════════════════════════════════════════
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 5
            visible: root.isSmall

            RowLayout {
                Layout.fillWidth: true
                spacing: 4

                Text {
                    text: "󰎆"
                    font.family: "CaskaydiaCove Nerd Font"
                    font.pixelSize: 12
                    color: domColor
                }

                Text {
                    text: "MÚSICA"
                    font.family: "SF Pro Display"
                    font.pixelSize: 9
                    font.weight: Font.Bold
                    color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.5)
                }

                Item {
                    Layout.fillWidth: true
                }

                // Botón Expandir ›
                Rectangle {
                    width: 18
                    height: 18
                    radius: 9
                    color: expandMa.containsMouse ? Qt.rgba(1, 1, 1, 0.18) : Qt.rgba(1, 1, 1, 0.08)

                    Text {
                        anchors.centerIn: parent
                        text: "›"
                        font.family: "SF Pro Display"
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        id: expandMa

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                        onClicked: {
                            if (root.canvas)
                                root.canvas.toggleMediaExpanded();
                            else if (root.widgetsState)
                                root.widgetsState.toggleMediaExpanded();
                        }
                    }

                }

            }

            Text {
                Layout.fillWidth: true
                text: root.widgetsState && root.widgetsState.mediaTitle ? root.widgetsState.mediaTitle : "Sin reproducción"
                font.family: "SF Pro Display"
                font.pixelSize: 11
                font.weight: Font.Bold
                elide: Text.ElideRight
                color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"
            }

            Text {
                Layout.fillWidth: true
                text: root.widgetsState && root.widgetsState.mediaArtist ? root.widgetsState.mediaArtist : "Reproductor"
                font.family: "SF Pro Display"
                font.pixelSize: 10
                elide: Text.ElideRight
                color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.6)
            }

            Item {
                Layout.fillHeight: true
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 12

                Text {
                    text: "󰒮"
                    font.family: "CaskaydiaCove Nerd Font"
                    font.pixelSize: 16
                    color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"

                    MouseArea {
                        anchors.fill: parent
                        enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                        onClicked: {
                            if (root.widgetsState)
                                root.widgetsState.mediaPrevious();

                        }
                    }

                }

                Rectangle {
                    width: 28
                    height: 28
                    radius: 14
                    color: domColor

                    Text {
                        anchors.centerIn: parent
                        text: root.isPlaying ? "󰏤" : "󰐊"
                        font.family: "CaskaydiaCove Nerd Font"
                        font.pixelSize: 14
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                        onClicked: {
                            if (root.widgetsState)
                                root.widgetsState.mediaPlayPause();

                        }
                    }

                }

                Text {
                    text: "󰒭"
                    font.family: "CaskaydiaCove Nerd Font"
                    font.pixelSize: 16
                    color: root.widgetsState ? root.widgetsState.textColor : "#FFFFFF"

                    MouseArea {
                        anchors.fill: parent
                        enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                        onClicked: {
                            if (root.widgetsState)
                                root.widgetsState.mediaNext();

                        }
                    }

                }

            }

        }

        // ═══════════════════════════════════════════════════════════════════
        // ── 3. MODO GRANDE (354 x 354): COVER GRANDE + ESPECTRO AMPLIO ──
        // ═══════════════════════════════════════════════════════════════════
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10
            visible: root.isLarge

            // Album cover centered
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 170
                Layout.preferredHeight: 170
                radius: 18
                clip: true
                color: root.widgetsState && root.widgetsState.isDarkTheme ? "#1A1A1E" : "#E5E5EA"
                border.color: root.widgetsState && root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.15)" : "rgba(0,0,0,0.10)"
                border.width: 1

                Image {
                    id: albumArtLarge

                    anchors.fill: parent
                    source: root.widgetsState && root.widgetsState.mediaArtUrl ? root.widgetsState.mediaArtUrl : ""
                    fillMode: Image.PreserveAspectCrop
                    visible: source != "" && status === Image.Ready
                    asynchronous: true
                }

                // Fallback Music/Video Icon
                ColumnLayout {
                    anchors.centerIn: parent
                    visible: !albumArtLarge.visible
                    spacing: 6

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: (root.widgetsState && root.widgetsState.mediaArtist === "YouTube") ? "󰗃" : "󰎆"
                        font.family: "CaskaydiaCove Nerd Font"
                        font.pixelSize: 48
                        color: domColor
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: (root.widgetsState && root.widgetsState.mediaArtist === "YouTube") ? "YouTube" : "Multimedia"
                        font.family: "SF Pro Display"
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.5)
                    }

                }

            }

            Text {
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width - 32
                Layout.maximumWidth: parent.width - 32
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                text: root.widgetsState && root.widgetsState.mediaTitle ? root.widgetsState.mediaTitle : "Sin reproducción"
                font.family: "SF Pro Display"
                font.pixelSize: 14
                font.weight: Font.Bold
                elide: Text.ElideRight
                maximumLineCount: 1
                color: "#FFFFFF"
            }

            Text {
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width - 32
                Layout.maximumWidth: parent.width - 32
                Layout.alignment: Qt.AlignHCenter
                horizontalAlignment: Text.AlignHCenter
                text: root.widgetsState && root.widgetsState.mediaArtist ? root.widgetsState.mediaArtist : "Reproductor"
                font.family: "SF Pro Display"
                font.pixelSize: 11
                font.weight: Font.Medium
                elide: Text.ElideRight
                maximumLineCount: 1
                color: root.widgetsState ? root.widgetsState.textDim : Qt.rgba(1, 1, 1, 0.6)
            }

            // Spectrum
            SpectrumVisualizer {
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width - 32
                spectrumHeight: 36
                barSpacing: 4
            }

            // Controls
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 24

                Text {
                    text: "󰒮"
                    font.family: "CaskaydiaCove Nerd Font"
                    font.pixelSize: 22
                    color: prevLargeMa.containsMouse ? (root.widgetsState ? root.widgetsState.textColor : "#FFFFFF") : Qt.rgba(1, 1, 1, 0.7)

                    MouseArea {
                        id: prevLargeMa

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                        onClicked: {
                            if (root.widgetsState)
                                root.widgetsState.mediaPrevious();

                        }
                    }

                }

                Rectangle {
                    width: 38
                    height: 38
                    radius: 19
                    color: playLargeMa.containsMouse ? Qt.darker(domColor, 1.15) : domColor
                    scale: playLargeMa.pressed ? 0.94 : 1

                    Text {
                        anchors.centerIn: parent
                        text: root.isPlaying ? "󰏤" : "󰐊"
                        font.family: "CaskaydiaCove Nerd Font"
                        font.pixelSize: 16
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        id: playLargeMa

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                        onClicked: {
                            if (root.widgetsState)
                                root.widgetsState.mediaPlayPause();

                        }
                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 100
                        }

                    }

                }

                Text {
                    text: "󰒭"
                    font.family: "CaskaydiaCove Nerd Font"
                    font.pixelSize: 22
                    color: nextLargeMa.containsMouse ? (root.widgetsState ? root.widgetsState.textColor : "#FFFFFF") : Qt.rgba(1, 1, 1, 0.7)

                    MouseArea {
                        id: nextLargeMa

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        enabled: root.widgetsState ? !root.widgetsState.isEditing : true
                        onClicked: {
                            if (root.widgetsState)
                                root.widgetsState.mediaNext();

                        }
                    }

                }

            }

        }

        // ═══════════════════════════════════════════════════════════════════
        // ── COMPONENTE REUTILIZABLE: ESPECTRO VISUALIZADOR CAVA ──
        // ═══════════════════════════════════════════════════════════════════
        component SpectrumVisualizer: RowLayout {
            id: specRow

            property real spectrumHeight: 30
            property real barSpacing: 3.5

            spacing: barSpacing
            Layout.fillWidth: true
            Layout.preferredHeight: spectrumHeight

            Repeater {
                model: 16

                Rectangle {
                    property real barVal: index < root.cavaBars.length ? root.cavaBars[index] : 4

                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignBottom
                    height: Math.max(3.5, specRow.spectrumHeight * (barVal / 100))
                    radius: 2

                    gradient: Gradient {
                        GradientStop {
                            position: 0
                            color: Qt.rgba(domColor.r, domColor.g, domColor.b, 0.95)
                        }

                        GradientStop {
                            position: 1
                            color: Qt.rgba(domColor.r, domColor.g, domColor.b, 0.5)
                        }

                    }

                    Behavior on height {
                        NumberAnimation {
                            duration: 55
                            easing.type: Easing.OutQuad
                        }

                    }

                }

            }

        }

    }

}
