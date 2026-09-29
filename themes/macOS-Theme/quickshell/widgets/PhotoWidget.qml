import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

Item {
    id: root
    property var widgetsState

    // ── Outer Rounded Container with Glass Border ──
    Rectangle {
        id: cardContainer
        anchors.fill: parent
        radius: 22
        color: root.widgetsState.cardBg
        border.color: root.widgetsState.cardBorder
        border.width: 1

        // ── 1. Masked Content (Ensures 100% Rounded Corners) ──
        Item {
            id: maskedLayer
            anchors.fill: parent
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: root.width
                    height: root.height
                    radius: 22
                }
            }

            // Image A (Current / Primary)
            Image {
                id: imgA
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                source: ""
                opacity: 1.0
                x: 0
            }

            // Image B (Transition / Secondary)
            Image {
                id: imgB
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                source: ""
                opacity: 0.0
                x: 0
            }

            // State tracker for smooth crossfade and backdrop slide
            property bool usingA: true

            Connections {
                target: root.widgetsState
                function onPhotoPathChanged() {
                    var newPath = root.widgetsState.photoPath;
                    if (!newPath) return;

                    var fileUrl = "file://" + newPath;
                    var dir = root.widgetsState.photoDirection || 1;
                    var slideDistance = 35;

                    if (maskedLayer.usingA) {
                        // Transition from A to B
                        imgB.source = fileUrl;
                        imgB.x = dir * slideDistance;
                        imgB.opacity = 0.0;

                        transAnimB.dir = dir;
                        transAnimB.slideDist = slideDistance;
                        transAnimB.restart();
                        maskedLayer.usingA = false;
                    } else {
                        // Transition from B to A
                        imgA.source = fileUrl;
                        imgA.x = dir * slideDistance;
                        imgA.opacity = 0.0;

                        transAnimA.dir = dir;
                        transAnimA.slideDist = slideDistance;
                        transAnimA.restart();
                        maskedLayer.usingA = true;
                    }
                }
            }

            // Animation A -> B
            ParallelAnimation {
                id: transAnimB
                property int dir: 1
                property real slideDist: 35

                NumberAnimation {
                    target: imgA
                    property: "opacity"
                    to: 0.0
                    duration: 500
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: imgA
                    property: "x"
                    to: -transAnimB.dir * transAnimB.slideDist
                    duration: 500
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: imgB
                    property: "opacity"
                    to: 1.0
                    duration: 500
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: imgB
                    property: "x"
                    to: 0
                    duration: 500
                    easing.type: Easing.OutCubic
                }
            }

            // Animation B -> A
            ParallelAnimation {
                id: transAnimA
                property int dir: 1
                property real slideDist: 35

                NumberAnimation {
                    target: imgB
                    property: "opacity"
                    to: 0.0
                    duration: 500
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: imgB
                    property: "x"
                    to: -transAnimA.dir * transAnimA.slideDist
                    duration: 500
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: imgA
                    property: "opacity"
                    to: 1.0
                    duration: 500
                    easing.type: Easing.OutCubic
                }
                NumberAnimation {
                    target: imgA
                    property: "x"
                    to: 0
                    duration: 500
                    easing.type: Easing.OutCubic
                }
            }

            Component.onCompleted: {
                if (root.widgetsState && root.widgetsState.photoPath) {
                    imgA.source = "file://" + root.widgetsState.photoPath;
                    imgA.opacity = 1.0;
                    imgA.x = 0;
                }
            }

            // Vignette Gradient Layer
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.35) }
                    GradientStop { position: 0.4; color: Qt.rgba(0, 0, 0, 0.0) }
                    GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.85) }
                }
            }
        }

        // ── 2. Overlay UI Content ──
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14

            // Top Header Row
            RowLayout {
                Layout.fillWidth: true

                // Category Pill Badge
                Rectangle {
                    radius: 12
                    height: 24
                    implicitWidth: badgeRow.implicitWidth + 16
                    color: Qt.rgba(0.12, 0.12, 0.16, 0.82)
                    border.color: Qt.rgba(1, 1, 1, 0.22)
                    border.width: 1

                    RowLayout {
                        id: badgeRow
                        anchors.centerIn: parent
                        spacing: 4
                        Text {
                            text: "🖼"
                            font.pixelSize: 11
                        }
                        Text {
                            text: root.widgetsState.photoCategory
                            font.family: "SF Pro Display"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: "#FFFFFF"
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Navigation Buttons (Prev & Next)
                RowLayout {
                    spacing: 4

                    // Prev Button
                    Rectangle {
                        radius: 12
                        width: 26
                        height: 24
                        color: prevMa.containsMouse ? Qt.rgba(1, 1, 1, 0.90) : Qt.rgba(0.12, 0.12, 0.16, 0.82)
                        border.color: Qt.rgba(1, 1, 1, 0.22)
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "◀"
                            font.pixelSize: 8
                            color: prevMa.containsMouse ? "#1C1C1E" : "#FFFFFF"
                        }

                        MouseArea {
                            id: prevMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.widgetsState.prevPhoto()
                        }
                    }

                    // Next Button
                    Rectangle {
                        radius: 12
                        width: 26
                        height: 24
                        color: nextMa.containsMouse ? Qt.rgba(1, 1, 1, 0.90) : Qt.rgba(0.12, 0.12, 0.16, 0.82)
                        border.color: Qt.rgba(1, 1, 1, 0.22)
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "▶"
                            font.pixelSize: 8
                            color: nextMa.containsMouse ? "#1C1C1E" : "#FFFFFF"
                        }

                        MouseArea {
                            id: nextMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.widgetsState.nextPhoto()
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }

            // Bottom Title & Index Counter
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: root.widgetsState.photoTitle
                    font.family: "SF Pro Display"
                    font.pixelSize: 13
                    font.weight: Font.ExtraBold
                    color: "#FFFFFF"
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                Text {
                    text: root.widgetsState.photoIndex + " de " + root.widgetsState.photoTotal
                    font.family: "SF Pro Display"
                    font.pixelSize: 10
                    font.weight: Font.Medium
                    color: Qt.rgba(1, 1, 1, 0.72)
                }
            }
        }
    }
}
