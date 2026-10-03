import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Item {
    id: root

    required property var spotlightState
    readonly property var itemData: spotlightState.currentItem

    clip: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16

        // ── EMPTY STATE / NO SELECTION ──
        Item {
            visible: !root.itemData
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 8

                Image {
                    Layout.alignment: Qt.AlignHCenter
                    source: "assets/spotlight.svg"
                    sourceSize.width: 48
                    sourceSize.height: 48
                    opacity: 0.35
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Spotlight Search"
                    color: root.spotlightState.textDimColor
                    font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                }
            }
        }

        // ── ACTIVE ITEM PREVIEW ──
        Item {
            visible: !!root.itemData
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                spacing: 16

                // 1. Header: Big Icon + Title + Kind Badge
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 8

                    Image {
                        Layout.alignment: Qt.AlignHCenter
                        source: (root.itemData && root.itemData.icon) ? root.itemData.icon : "assets/document.svg"
                        sourceSize.width: 72
                        sourceSize.height: 72
                        Layout.preferredWidth: 64
                        Layout.preferredHeight: 64
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.maximumWidth: parent.width - 20
                        text: (root.itemData && root.itemData.title) ? root.itemData.title : ""
                        color: root.spotlightState.textColor
                        font.family: "SF Pro Display, Inter, -apple-system, system-ui, sans-serif"
                        font.pixelSize: 17
                        font.weight: Font.DemiBold
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WrapAnywhere
                        maximumLineCount: 2
                        elide: Text.ElideRight
                    }

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        implicitWidth: kindText.implicitWidth + 14
                        implicitHeight: 20
                        radius: 10
                        color: root.spotlightState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.07)

                        Text {
                            id: kindText
                            anchors.centerIn: parent
                            text: (root.itemData && root.itemData.metadata && root.itemData.metadata.kind) 
                                ? root.itemData.metadata.kind 
                                : ((root.itemData && root.itemData.category) ? root.itemData.category : "Item")
                            color: root.spotlightState.textDimColor
                            font.family: "SF Pro Text, Inter, -apple-system, system-ui, sans-serif"
                            font.pixelSize: 10
                            font.weight: Font.Medium
                        }
                    }
                }

                // 2. Metadata / Information Card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 12
                    color: root.spotlightState.cardBgColor
                    border.color: root.spotlightState.cardBorderColor
                    border.width: 1

                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: 12
                        clip: true
                        ScrollBar.vertical.policy: ScrollBar.AsNeeded

                        ColumnLayout {
                            width: parent.width
                            spacing: 10

                            // ── CALCULATION PREVIEW ──
                            Item {
                                visible: root.itemData && root.itemData.type === "calc"
                                Layout.fillWidth: true
                                implicitHeight: 70

                                ColumnLayout {
                                    anchors.fill: parent
                                    spacing: 4

                                    Text {
                                        text: "Result"
                                        color: root.spotlightState.textDimColor
                                        font.family: "SF Pro Text, Inter, -apple-system, system-ui, sans-serif"
                                        font.pixelSize: 11
                                    }

                                    Text {
                                        text: (root.itemData && root.itemData.metadata && root.itemData.metadata.result) ? root.itemData.metadata.result : ""
                                        color: root.spotlightState.isDarkTheme ? "#30D158" : "#34C759"
                                        font.family: "SF Pro Display, Inter, -apple-system, monospace"
                                        font.pixelSize: 22
                                        font.weight: Font.Bold
                                    }

                                    Text {
                                        text: (root.itemData && root.itemData.metadata && root.itemData.metadata.expression) ? ("Expression: " + root.itemData.metadata.expression) : ""
                                        color: root.spotlightState.textDimColor
                                        font.family: "SF Pro Text, Inter, -apple-system, system-ui, sans-serif"
                                        font.pixelSize: 11
                                    }
                                }
                            }

                            // ── APPLICATION PREVIEW ──
                            ColumnLayout {
                                visible: root.itemData && root.itemData.type === "app"
                                Layout.fillWidth: true
                                spacing: 8

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text {
                                        text: "Description"
                                        color: root.spotlightState.textDimColor
                                        font.family: "SF Pro Text, Inter, -apple-system, system-ui, sans-serif"
                                        font.pixelSize: 11
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: (root.itemData && root.itemData.metadata && root.itemData.metadata.description) ? root.itemData.metadata.description : "None"
                                        color: root.spotlightState.textColor
                                        font.family: "SF Pro Text, Inter, -apple-system, system-ui, sans-serif"
                                        font.pixelSize: 12
                                        wrapMode: Text.Wrap
                                    }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text {
                                        text: "Executable"
                                        color: root.spotlightState.textDimColor
                                        font.family: "SF Pro Text, Inter, -apple-system, system-ui, sans-serif"
                                        font.pixelSize: 11
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: (root.itemData && root.itemData.metadata && root.itemData.metadata.executable) ? root.itemData.metadata.executable : ""
                                        color: root.spotlightState.textColor
                                        font.family: "SF Mono, monospace, -apple-system"
                                        font.pixelSize: 11
                                        elide: Text.ElideMiddle
                                    }
                                }
                            }

                            // ── FILE / FOLDER PREVIEW ──
                            ColumnLayout {
                                visible: root.itemData && (root.itemData.type === "file" || root.itemData.type === "folder")
                                Layout.fillWidth: true
                                spacing: 8

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text {
                                        text: "Where"
                                        color: root.spotlightState.textDimColor
                                        font.family: "SF Pro Text, Inter, -apple-system, system-ui, sans-serif"
                                        font.pixelSize: 11
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: (root.itemData && root.itemData.metadata && root.itemData.metadata.path) ? root.itemData.metadata.path : ""
                                        color: root.spotlightState.textColor
                                        font.family: "SF Pro Text, Inter, -apple-system, system-ui, sans-serif"
                                        font.pixelSize: 11
                                        wrapMode: Text.WrapAnywhere
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 12

                                    ColumnLayout {
                                        spacing: 2
                                        Text {
                                            text: "Size"
                                            color: root.spotlightState.textDimColor
                                            font.pixelSize: 11
                                        }
                                        Text {
                                            text: (root.itemData && root.itemData.metadata && root.itemData.metadata.size) ? root.itemData.metadata.size : "-"
                                            color: root.spotlightState.textColor
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                        }
                                    }

                                    ColumnLayout {
                                        spacing: 2
                                        Text {
                                            text: "Modified"
                                            color: root.spotlightState.textDimColor
                                            font.pixelSize: 11
                                        }
                                        Text {
                                            text: (root.itemData && root.itemData.metadata && root.itemData.metadata.modified) ? root.itemData.metadata.modified : "-"
                                            color: root.spotlightState.textColor
                                            font.pixelSize: 12
                                            font.weight: Font.Medium
                                        }
                                    }
                                }
                            }

                            // ── SYSTEM / WEB PREVIEW ──
                            ColumnLayout {
                                visible: root.itemData && (root.itemData.type === "command" || root.itemData.type === "terminal" || root.itemData.type === "web")
                                Layout.fillWidth: true
                                spacing: 6

                                Text {
                                    text: "Action Details"
                                    color: root.spotlightState.textDimColor
                                    font.family: "SF Pro Text, Inter, -apple-system, system-ui, sans-serif"
                                    font.pixelSize: 11
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: (root.itemData && root.itemData.metadata && root.itemData.metadata.description) ? root.itemData.metadata.description : (root.itemData ? root.itemData.subtitle : "")
                                    color: root.spotlightState.textColor
                                    font.family: "SF Pro Text, Inter, -apple-system, system-ui, sans-serif"
                                    font.pixelSize: 12
                                    wrapMode: Text.Wrap
                                }
                            }
                        }
                    }
                }

                // 3. Bottom Action Buttons
                RowLayout {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 12
                    spacing: 8

                    // Primary Action Button (Enter)
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 30
                        radius: 7
                        color: root.spotlightState.selectedBgColor

                        Text {
                            anchors.centerIn: parent
                            text: root.itemData && root.itemData.type === "calc" ? "Copiar Resultado" : (root.itemData && root.itemData.type === "web" ? "Abrir Enlace" : "Abrir")
                            color: "#FFFFFF"
                            font.family: "SF Pro Text, Inter, -apple-system, system-ui, sans-serif"
                            font.pixelSize: 12
                            font.weight: Font.Medium
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.spotlightState.activateCurrentItem()
                        }
                    }

                    // Secondary Action Button (Show in Finder / Copy)
                    Rectangle {
                        visible: root.itemData && (root.itemData.type === "file" || root.itemData.type === "folder" || root.itemData.type === "app")
                        Layout.fillWidth: true
                        implicitHeight: 30
                        radius: 7
                        color: root.spotlightState.isDarkTheme ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.08)

                        Text {
                            anchors.centerIn: parent
                            text: "En Finder"
                            color: root.spotlightState.textColor
                            font.family: "SF Pro Text, Inter, -apple-system, system-ui, sans-serif"
                            font.pixelSize: 12
                            font.weight: Font.Medium
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.spotlightState.revealCurrentItem()
                        }
                    }
                }
            }
        }
    }
}
