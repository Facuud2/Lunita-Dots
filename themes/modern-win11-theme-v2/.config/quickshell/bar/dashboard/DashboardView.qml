import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

Rectangle {
    id: root

    required property var barState
    property int activePage: 0

    width: 920
    height: 336
    radius: root.barState.themePanelRadius
    color: root.barState.themeSurface
    border.color: root.barState.themeBorderSpecular
    border.width: 1
    clip: true

    opacity: root.barState.activePopup === "dashboard" ? 1.0 : 0.0
    scale: root.barState.activePopup === "dashboard" ? 1.0 : 0.96
    transformOrigin: Item.Top

    Behavior on opacity {
        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
    }
    Behavior on scale {
        NumberAnimation { duration: 200; easing.type: Easing.OutBack }
    }

    // Catch clicks inside dashboard so they do not hit the backdrop dismiss
    MouseArea {
        anchors.fill: parent
        z: -1
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: {}
    }

    // Top Specular Hairline (Liquid Glass edge)
    Rectangle {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width - 2 * root.radius
        height: 1
        color: root.barState.themeHairlineTop
        opacity: 0.90
    }

    // Glossy Sheen Wash (Light catching the top glass bevel)
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 52
        radius: root.radius
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.09) }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    // Starfall Cosmic Backdrop Effect
    Rectangle {
        anchors.fill: parent
        radius: root.radius
        visible: root.barState.astraeusLook === "starfall"
        opacity: 0.25
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: root.barState.themeAccentGlow }
            GradientStop { position: 0.5; color: "transparent" }
            GradientStop { position: 1.0; color: root.barState.themeAccentGlow }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // ── 1. Vertical Navigation Rail ──
        RailNav {
            id: rail
            barState: root.barState
            currentPage: root.activePage
            Layout.preferredWidth: 54
            Layout.fillHeight: true
            onPageSelected: page => {
                root.activePage = page;
            }
        }

        // Vertical Separator
        Rectangle {
            Layout.fillHeight: true
            width: 1
            color: root.barState.themeBorder
            opacity: 0.6
        }

        // ── 2. Active Page Content Host ──
        StackLayout {
            id: pageStack
            currentIndex: root.activePage
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Page 0: Home Overview (Astraeus Overview)
            HomeView {
                barState: root.barState
                onNavigateToPage: page => {
                    root.activePage = page;
                }
            }

            // Page 1: Media Page Placeholder
            Rectangle {
                color: root.barState.themeSurfaceContainer
                radius: root.barState.themeCardRadius
                border.color: root.barState.themeBorder
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    spacing: 8
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰝚"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 36
                        color: root.barState.themeAccent
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Media & Fullscreen Stage"
                        font.family: root.barState.themeFontInterface
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: root.barState.themeOnSurface
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Próximamente en [ISSUE-066]"
                        font.family: root.barState.themeFontInterface
                        font.pixelSize: 11
                        color: root.barState.themeOnSurfaceDim
                    }
                }
            }

            // Page 2: System Telemetry Placeholder
            Rectangle {
                color: root.barState.themeSurfaceContainer
                radius: root.barState.themeCardRadius
                border.color: root.barState.themeBorder
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    spacing: 8
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰍹"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 36
                        color: root.barState.themeAccent
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Diagnóstico de Hardware & Procesos"
                        font.family: root.barState.themeFontInterface
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: root.barState.themeOnSurface
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Próximamente en [ISSUE-067]"
                        font.family: root.barState.themeFontInterface
                        font.pixelSize: 11
                        color: root.barState.themeOnSurfaceDim
                    }
                }
            }

            // Page 3: Network Telemetry Placeholder
            Rectangle {
                color: root.barState.themeSurfaceContainer
                radius: root.barState.themeCardRadius
                border.color: root.barState.themeBorder
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    spacing: 8
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰤨"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 36
                        color: root.barState.themeAccent
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Rendimiento de Red & Latencia (Ping/Jitter)"
                        font.family: root.barState.themeFontInterface
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: root.barState.themeOnSurface
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Próximamente en [ISSUE-067]"
                        font.family: root.barState.themeFontInterface
                        font.pixelSize: 11
                        color: root.barState.themeOnSurfaceDim
                    }
                }
            }

            // Page 4: Shelf Placeholder
            Rectangle {
                color: root.barState.themeSurfaceContainer
                radius: root.barState.themeCardRadius
                border.color: root.barState.themeBorder
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    spacing: 8
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰉋"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 36
                        color: root.barState.themeAccent
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "The Shelf — Drag & Drop Zone"
                        font.family: root.barState.themeFontInterface
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: root.barState.themeOnSurface
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Próximamente en [ISSUE-068]"
                        font.family: root.barState.themeFontInterface
                        font.pixelSize: 11
                        color: root.barState.themeOnSurfaceDim
                    }
                }
            }

            // Page 5: Tools Placeholder
            Rectangle {
                color: root.barState.themeSurfaceContainer
                radius: root.barState.themeCardRadius
                border.color: root.barState.themeBorder
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    spacing: 8
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "󰒓"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 36
                        color: root.barState.themeAccent
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Herramientas de Energía & Utilidades"
                        font.family: root.barState.themeFontInterface
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: root.barState.themeOnSurface
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Próximamente en [ISSUE-068]"
                        font.family: root.barState.themeFontInterface
                        font.pixelSize: 11
                        color: root.barState.themeOnSurfaceDim
                    }
                }
            }

            // Page 6: Settings & Look Picker
            Rectangle {
                color: root.barState.themeSurfaceContainer
                radius: root.barState.themeCardRadius
                border.color: root.barState.themeBorder
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    spacing: 12

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Apariencia de Astraeus"
                        font.family: root.barState.themeFontInterface
                        font.pixelSize: 14
                        font.weight: Font.DemiBold
                        color: root.barState.themeOnSurface
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 10

                        Repeater {
                            model: [
                                { id: "dark", label: "Dark" },
                                { id: "glass", label: "Glass" },
                                { id: "starfall", label: "Starfall" },
                                { id: "light", label: "Light" }
                            ]

                            Rectangle {
                                width: 90
                                height: 36
                                radius: 8
                                color: root.barState.astraeusLook === modelData.id ? root.barState.themeAccent : root.barState.themeSurfaceContainerHigh
                                border.color: root.barState.themeBorderSpecular
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    font.family: root.barState.themeFontInterface
                                    font.pixelSize: 11
                                    font.weight: Font.Medium
                                    color: root.barState.astraeusLook === modelData.id ? "#FFFFFF" : root.barState.themeOnSurface
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.barState.setAstraeusLook(modelData.id);
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
