import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell

Item {
    id: root

    required property var barState

    // ── 1. Sizing & State Machine ──
    property bool isHovered: hoverTracker.hovered
    property bool isFullscreen: root.barState.isWindowFullscreen === 1

    // Island modes: "notch" | "music_pill" | "long_pill"
    readonly property string islandMode: {
        if (root.barState.activePopup === "dashboard") {
            return "long_pill";
        }
        if (root.isHovered || root.barState.forceLongPill || (root.barState.mprisActive && root.barState.lyricsActive)) {
            return "long_pill";
        }
        if (root.barState.mprisActive && root.barState.mprisPlaybackStatus === "Playing") {
            return "music_pill";
        }
        return "notch";
    }

    readonly property real targetWidth: {
        if (root.islandMode === "long_pill") {
            return root.barState.mprisActive ? 520 : 380;
        }
        if (root.islandMode === "music_pill") {
            return 248;
        }
        return 160; // compact notch
    }

    readonly property real targetHeight: {
        if (root.islandMode === "long_pill") {
            return 42;
        }
        return 34; // standard 34px Astraeus height
    }

    readonly property real islandRadius: {
        if (root.islandMode === "long_pill") {
            return 21;
        }
        return 17;
    }

    width: targetWidth
    height: targetHeight
    implicitWidth: width
    implicitHeight: height

    opacity: root.isFullscreen ? 0.0 : 1.0
    y: root.isFullscreen ? -height : 0

    // ── 2. Astraeus Organic Liquid Spring Physics ──
    Behavior on width {
        NumberAnimation {
            duration: 320
            easing.type: Easing.OutBack
            easing.overshoot: 1.06
        }
    }
    Behavior on height {
        NumberAnimation {
            duration: 280
            easing.type: Easing.OutCubic
        }
    }
    Behavior on opacity {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutQuad
        }
    }
    Behavior on y {
        NumberAnimation {
            duration: 240
            easing.type: Easing.OutCubic
        }
    }

    // ── 3. Hover Handler with Grace Filter ──
    HoverHandler {
        id: hoverTracker
    }

    // ── 4. Main Background Surface Flush with Screen Top ──
    Rectangle {
        id: islandSurface
        anchors.fill: parent
        radius: root.islandRadius
        color: root.barState.themeSurface
        clip: true

        border.color: root.isHovered ? root.barState.themeBorderSpecular : root.barState.themeBorder
        border.width: 1

        Behavior on border.color {
            ColorAnimation { duration: 180 }
        }

        // Starfall Cosmic Ambient Wash
        Rectangle {
            anchors.fill: parent
            radius: root.islandRadius
            visible: root.barState.astraeusLook === "starfall"
            opacity: 0.35
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: root.barState.themeAccentGlow }
                GradientStop { position: 0.5; color: "transparent" }
                GradientStop { position: 1.0; color: root.barState.themeAccentGlow }
            }
        }

        // Top Specular Hairline (Light catching the top edge)
        Rectangle {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.max(0, parent.width - 2 * root.islandRadius)
            height: 1
            color: root.barState.themeHairlineTop
            opacity: 0.85
        }

        // ── 5A. VIEW 1: COMPACT NOTCH (Idle Mode) ──
        RowLayout {
            id: notchContent
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 8
            visible: root.islandMode === "notch"
            opacity: visible ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }

            // Windows Fluent 4-Square Emblem
            Grid {
                Layout.alignment: Qt.AlignVCenter
                rows: 2
                columns: 2
                spacing: 2
                width: 12
                height: 12

                Rectangle { width: 5; height: 5; radius: 1.2; color: root.barState.themeAccent }
                Rectangle { width: 5; height: 5; radius: 1.2; color: root.barState.themeAccentHover }
                Rectangle { width: 5; height: 5; radius: 1.2; color: root.barState.themeAccentHover }
                Rectangle { width: 5; height: 5; radius: 1.2; color: root.barState.themeAccentActive }
            }

            // Digital Clock
            Text {
                Layout.alignment: Qt.AlignVCenter
                text: {
                    var parts = root.barState.timeStr.split(" ");
                    return parts[0] || root.barState.timeStr;
                }
                font.family: root.barState.themeFontInterface
                font.pixelSize: 11.5
                font.weight: Font.Medium
                color: root.barState.themeOnSurface
            }

            Item { Layout.fillWidth: true }

            // Micro Status Badges
            Row {
                Layout.alignment: Qt.AlignVCenter
                spacing: 5

                // Wi-Fi Glyph
                Text {
                    text: root.barState.wifiConnected ? "󰤨" : "󰤭"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    color: root.barState.wifiConnected ? root.barState.themeAccent : root.barState.themeOnSurfaceLow
                }

                // Battery Glyph
                Text {
                    visible: root.barState.batteryAvailable
                    text: root.barState.isCharging ? "󰂄" : (root.barState.batteryPercent > 20 ? "󰁹" : "󰂃")
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    color: root.barState.isCharging ? "#107C41" : (root.barState.batteryPercent <= 20 ? "#E81123" : root.barState.themeOnSurfaceDim)
                }

                // Volume Muted Indicator
                Text {
                    visible: root.barState.isMuted
                    text: "󰝟"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    color: "#E81123"
                }
            }
        }

        // ── 5B. VIEW 2: MUSIC PILL (Collapsed Playing Mode) ──
        RowLayout {
            id: musicPillContent
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 10
            spacing: 8
            visible: root.islandMode === "music_pill"
            opacity: visible ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }

            // Mini Album Art
            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                width: 20
                height: 20
                radius: 4
                color: root.barState.themeSurfaceContainerHigh
                clip: true

                Image {
                    anchors.fill: parent
                    source: root.barState.mprisArtUrl || ""
                    fillMode: Image.PreserveAspectCrop
                    visible: root.barState.mprisArtUrl !== ""
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.barState.mprisArtUrl === ""
                    text: "󰝚"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10
                    color: root.barState.themeAccent
                }
            }

            // Track Title
            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                text: root.barState.mprisTrackTitle || "Reproduciendo"
                font.family: root.barState.themeFontInterface
                font.pixelSize: 11
                font.weight: Font.Medium
                color: root.barState.themeOnSurface
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            // Real-time Mini Waveform
            WaveformBars {
                Layout.alignment: Qt.AlignVCenter
                isPlaying: root.barState.mprisPlaybackStatus === "Playing"
                barColor: root.barState.themeAccent
                barCount: 4
                barWidth: 2
                barSpacing: 2
                maxSlotHeight: 14
                values: root.barState.cavaBars
            }
        }

        // ── 5C. VIEW 3: ASTRAEUS LONG PILL (Expanded Active Mode) ──
        RowLayout {
            id: longPillContent
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 12
            spacing: 10
            visible: root.islandMode === "long_pill"
            opacity: visible ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }

            // Left Slot: Album Art with Quick Transport Overlay
            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                width: 28
                height: 28
                radius: 6
                color: root.barState.themeSurfaceContainerHigh
                clip: true

                Image {
                    anchors.fill: parent
                    source: root.barState.mprisArtUrl || ""
                    fillMode: Image.PreserveAspectCrop
                    visible: root.barState.mprisArtUrl !== ""
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.barState.mprisArtUrl === ""
                    text: root.barState.mprisActive ? "󰝚" : "󰍉"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                    color: root.barState.themeAccent
                }

                // Hover Play/Pause Quick Click Overlay
                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(0, 0, 0, 0.45)
                    visible: root.barState.mprisActive && root.isHovered

                    Text {
                        anchors.centerIn: parent
                        text: root.barState.mprisPlaybackStatus === "Playing" ? "󰏤" : "󰐊"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 13
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.barState.togglePlay()
                    }
                }
            }

            // Center Slot: Two-line Title & Singing-Along Lyrics
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 1

                // Primary Headline
                Text {
                    Layout.fillWidth: true
                    text: {
                        if (root.barState.mprisActive && root.barState.mprisTrackTitle) {
                            return root.barState.mprisTrackTitle;
                        }
                        if (root.barState.activeWindowTitle) {
                            return root.barState.activeWindowTitle;
                        }
                        return "Modern Win 11 V2";
                    }
                    font.family: root.barState.themeFontInterface
                    font.pixelSize: 11.5
                    font.weight: Font.DemiBold
                    color: root.barState.themeOnSurface
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                // Secondary Subtitle / Live Lyric Line ("Singing Along")
                Text {
                    Layout.fillWidth: true
                    text: {
                        if (root.barState.currentLyricLine && root.barState.currentLyricLine.length > 0) {
                            return "♪ " + root.barState.currentLyricLine;
                        }
                        if (root.barState.mprisActive && root.barState.mprisTrackArtist) {
                            return root.barState.mprisTrackArtist;
                        }
                        return root.barState.dateStr || "Astraeus Island";
                    }
                    font.family: root.barState.themeFontInterface
                    font.pixelSize: 10
                    font.weight: root.barState.currentLyricLine ? Font.Medium : Font.Normal
                    color: root.barState.currentLyricLine ? root.barState.themeAccent : root.barState.themeOnSurfaceDim
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }
            }

            // Right Slot: Waveform & Status Badges
            Row {
                Layout.alignment: Qt.AlignVCenter
                spacing: 8

                // Waveform Bars (Reactive to Pipewire)
                WaveformBars {
                    visible: root.barState.mprisActive
                    isPlaying: root.barState.mprisPlaybackStatus === "Playing"
                    barColor: root.barState.themeAccent
                    barCount: 6
                    barWidth: 2.2
                    barSpacing: 2
                    maxSlotHeight: 16
                    values: root.barState.cavaBars
                }

                // Volume Badge
                Rectangle {
                    width: 32
                    height: 20
                    radius: 10
                    color: root.barState.themeSurfaceContainer
                    border.color: root.barState.themeBorder
                    border.width: 1

                    Row {
                        anchors.centerIn: parent
                        spacing: 2
                        Text {
                            text: root.barState.isMuted ? "󰝟" : "󰕾"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 9
                            color: root.barState.isMuted ? "#E81123" : root.barState.themeOnSurfaceDim
                        }
                        Text {
                            text: root.barState.volumePercent + "%"
                            font.family: root.barState.themeFontInterface
                            font.pixelSize: 8.5
                            color: root.barState.themeOnSurfaceDim
                        }
                    }
                }

                // Chevron indicating dropdown capability
                Text {
                    text: "󰅀"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                    color: root.isHovered ? root.barState.themeAccent : root.barState.themeOnSurfaceLow
                }
            }
        }
    }

    // ── 6. Master Interaction Trigger ──
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                // Right click toggles between Notch and Long Pill
                root.barState.forceLongPill = !root.barState.forceLongPill;
            } else {
                // Left click toggles dashboard panel
                root.barState.openPopup("dashboard");
            }
        }
    }
}
