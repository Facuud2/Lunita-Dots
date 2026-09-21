import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell

Item {
    id: root
    required property var dockState

    visible: dockState.addModalVisible
    anchors.fill: parent
    z: 10000

    // Backdrop Dim
    Rectangle {
        anchors.fill: parent
        color: "#66000000"

        MouseArea {
            anchors.fill: parent
            onClicked: dockState.closeAddModal()
        }
    }

    // Centered Liquid Glass Modal Panel
    Rectangle {
        id: modalPanel
        width: 560
        height: 520
        anchors.centerIn: parent
        radius: 22
        color: "#f01c1e28"
        border.color: "#38ffffff"
        border.width: 1

        layer.enabled: true
        layer.effect: DropShadow {
            color: "#80000000"
            radius: 36
            samples: 35
            horizontalOffset: 0
            verticalOffset: 16
        }

        // Inner specular border
        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: 21
            color: "transparent"
            border.color: "#33ffffff"
            border.width: 1
        }

        // Prevent clicking panel from closing backdrop
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Column {
            anchors.fill: parent
            anchors.margins: 22
            spacing: 16

            // ── Modal Header ──
            Row {
                width: parent.width
                spacing: 12

                Rectangle {
                    width: 38
                    height: 38
                    radius: 10
                    color: "#0a84ff"
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        source: "image://icon/list-add"
                        width: 20
                        height: 20
                        anchors.centerIn: parent
                    }
                }

                Column {
                    width: parent.width - 90
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        text: "Añadir al Dock"
                        color: "#ffffff"
                        font.pixelSize: 17
                        font.bold: true
                        font.family: "SF Pro Display, Space Grotesk, sans-serif"
                    }

                    Text {
                        text: "Selecciona una aplicación instalada para fijarla a tu barra"
                        color: "#99ffffff"
                        font.pixelSize: 12
                        font.family: "SF Pro Text, Space Grotesk, sans-serif"
                    }
                }

                // Close Button
                Rectangle {
                    width: 28
                    height: 28
                    radius: 14
                    color: closeMouse.containsMouse ? "#33ffffff" : "#1affffff"
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: "✕"
                        color: "#ffffff"
                        font.pixelSize: 12
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: dockState.closeAddModal()
                    }
                }
            }

            // ── Search Input ──
            Rectangle {
                width: parent.width
                height: 38
                radius: 12
                color: "#1affffff"
                border.color: searchInput.activeFocus ? "#0a84ff" : "#24ffffff"
                border.width: 1

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    Image {
                        source: "image://icon/system-search"
                        width: 16
                        height: 16
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: 0.6
                    }

                    TextInput {
                        id: searchInput
                        width: parent.width - 32
                        anchors.verticalCenter: parent.verticalCenter
                        color: "#ffffff"
                        font.pixelSize: 14
                        font.family: "SF Pro Text, Space Grotesk, sans-serif"
                        clip: true
                        text: dockState.addModalQuery
                        onTextChanged: dockState.addModalQuery = text

                        Text {
                            text: "Buscar aplicación por nombre o comando..."
                            color: "#66ffffff"
                            font: parent.font
                            visible: !parent.text && !parent.activeFocus
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

            // ── Applications List ──
            ListView {
                id: appsList
                width: parent.width
                height: parent.height - 130
                clip: true
                spacing: 6

                readonly property var filteredApps: {
                    let q = dockState.addModalQuery.trim().toLowerCase()
                    if (!q) return dockState.installedAppsList
                    return dockState.installedAppsList.filter(function(a) {
                        return (a.displayName || "").toLowerCase().includes(q) ||
                               (a.name || "").toLowerCase().includes(q) ||
                               (a.executable || "").toLowerCase().includes(q) ||
                               (a.description || "").toLowerCase().includes(q)
                    })
                }

                model: filteredApps

                delegate: Rectangle {
                    id: cardItem
                    width: appsList.width
                    height: 52
                    radius: 12
                    color: itemMouse.containsMouse ? "#24ffffff" : "#0dffffff"
                    border.color: itemMouse.containsMouse ? "#3dffffff" : "#14ffffff"
                    border.width: 1

                    readonly property bool isPinnedApp: dockState.isPinned(modelData.id)

                    Row {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 12

                        // App Icon
                        Image {
                            source: "image://icon/" + modelData.iconName
                            width: 36
                            height: 36
                            anchors.verticalCenter: parent.verticalCenter
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                        }

                        // App Info
                        Column {
                            width: parent.width - 160
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2

                            Text {
                                text: modelData.displayName || modelData.name
                                color: "#ffffff"
                                font.pixelSize: 13
                                font.bold: true
                                font.family: "SF Pro Text, Space Grotesk, sans-serif"
                                elide: Text.ElideRight
                                width: parent.width
                            }

                            Text {
                                text: modelData.description || modelData.executable
                                color: "#80ffffff"
                                font.pixelSize: 11
                                font.family: "SF Pro Text, Space Grotesk, sans-serif"
                                elide: Text.ElideRight
                                width: parent.width
                            }
                        }

                        // Action Badge
                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: badgeText.implicitWidth + 20
                            height: 26
                            radius: 13
                            color: isPinnedApp ? "#2634c759" : "#260a84ff"
                            border.color: isPinnedApp ? "#5934c759" : "#590a84ff"
                            border.width: 1

                            Text {
                                id: badgeText
                                text: isPinnedApp ? "✓ En el Dock" : "+ Añadir"
                                color: isPinnedApp ? "#34c759" : "#0a84ff"
                                font.pixelSize: 12
                                font.bold: true
                                font.family: "SF Pro Text, Space Grotesk, sans-serif"
                                anchors.centerIn: parent
                            }
                        }
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (cardItem.isPinnedApp) {
                                dockState.unpinApp(modelData.id)
                            } else {
                                dockState.pinApp({
                                    id: modelData.id,
                                    name: modelData.displayName || modelData.name,
                                    fallbackIcon: modelData.iconName,
                                    cmd: modelData.cmd,
                                    matchClasses: modelData.matchClasses
                                })
                                dockState.closeAddModal()
                            }
                        }
                    }
                }
            }
        }
    }

    // Keyboard Shortcuts
    Keys.onEscapePressed: dockState.closeAddModal()

    onVisibleChanged: {
        if (visible) {
            searchInput.forceActiveFocus()
        }
    }
}
