import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: cardRoot

    required property var notifData
    required property var notifState
    signal requestDismiss(int id)
    signal requestAction(int id, int actionIndex)

    property bool isHovered: cardMouseArea.containsMouse || closeHover.containsMouse
    property bool exiting: false

    width: 360
    implicitWidth: 360
    height: exiting ? 0 : cardContainer.implicitHeight
    implicitHeight: height
    opacity: exiting ? 0.0 : 1.0
    clip: exiting

    Behavior on height {
        NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
    }
    Behavior on opacity {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }

    transform: Translate {
        id: slideTrans
        x: 0
        y: 0
    }

    Component.onCompleted: {
        entranceAnim.start();
    }

    ParallelAnimation {
        id: entranceAnim
        NumberAnimation {
            target: slideTrans
            property: "y"
            from: 25
            to: 0
            duration: 260
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: cardRoot
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: 220
            easing.type: Easing.OutCubic
        }
    }

    // Auto-dismiss countdown timer (pauses when hovered)
    Timer {
        id: dismissTimer
        interval: notifData.expireMs > 0 ? notifData.expireMs : 5500
        running: notifData.expireMs > 0 && !cardRoot.isHovered
        repeat: false
        onTriggered: {
            dismissWithAnimation();
        }
    }

    function dismissWithAnimation() {
        if (exiting) return;
        exiting = true;
        dismissFinishTimer.start();
    }

    Timer {
        id: dismissFinishTimer
        interval: 240
        running: false
        onTriggered: {
            cardRoot.requestDismiss(notifData.id);
        }
    }

    // ==========================================
    // TOTALLY TRANSPARENT BORDERLESS CARD CONTAINER
    // ==========================================
    Rectangle {
        id: cardContainer
        width: parent.width
        implicitHeight: cardInnerLayout.implicitHeight + 20
        radius: 14

        // Totally transparent background without gradients or borders (allows Hyprland blur to shine through cleanly)
        color: cardMouseArea.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.12) : Qt.rgba(1.0, 1.0, 1.0, 0.08)
        border.width: 0
        border.color: "transparent"

        // Clickable card area
        MouseArea {
            id: cardMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (notifData.actions && notifData.actions.length > 0) {
                    cardRoot.requestAction(notifData.id, 0);
                } else {
                    dismissWithAnimation();
                }
            }
        }

        // Inner Card Layout
        ColumnLayout {
            id: cardInnerLayout
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 12
            spacing: 8

            // 1. Header Row: App Icon + App Name + Timestamp + Close Button
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Image {
                    source: notifData.iconPath || "assets/icons/win11-start.svg"
                    sourceSize.width: 18
                    sourceSize.height: 18
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    smooth: true
                    mipmap: true
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    text: notifData.appName || "Notificación"
                    font.family: "SF Pro Display, Adwaita Sans, Roboto, sans-serif"
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    font.italic: false
                    color: "#FFFFFF"
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    text: "•"
                    font.pixelSize: 10
                    font.italic: false
                    color: Qt.rgba(1.0, 1.0, 1.0, 0.50)
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    text: notifData.timeStr || "Ahora"
                    font.family: "SF Pro Display, Adwaita Sans, Roboto, sans-serif"
                    font.pixelSize: 11
                    font.italic: false
                    color: Qt.rgba(1.0, 1.0, 1.0, 0.70)
                    Layout.alignment: Qt.AlignVCenter
                }

                Item { Layout.fillWidth: true }

                // Close Button "✕"
                Rectangle {
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    radius: 10
                    color: closeHover.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.22) : "transparent"
                    border.width: 0
                    border.color: "transparent"
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        font.family: "SF Pro Display, Adwaita Sans, Roboto, sans-serif"
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        font.italic: false
                        color: "#FFFFFF"
                    }

                    MouseArea {
                        id: closeHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: cardRoot.dismissWithAnimation()
                    }
                }
            }

            // 2. Title & Body
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                Text {
                    text: notifData.summary || ""
                    font.family: "SF Pro Display, Adwaita Sans, Roboto, sans-serif"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    font.italic: false
                    color: "#FFFFFF"
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    visible: text.length > 0
                }

                Text {
                    text: notifData.body || ""
                    font.family: "SF Pro Display, Adwaita Sans, Roboto, sans-serif"
                    font.pixelSize: 12
                    font.weight: Font.Normal
                    font.italic: false
                    color: Qt.rgba(1.0, 1.0, 1.0, 0.90)
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    visible: text.length > 0
                }
            }

            // 3. Optional attached image
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 110
                radius: 8
                color: "transparent"
                clip: true
                visible: notifData.image && notifData.image.length > 0 && notifData.image.indexOf("image://icon/") === -1

                Image {
                    anchors.fill: parent
                    source: notifData.image || ""
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                }
            }

            // 4. Action Buttons (if any)
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                visible: notifData.actions && notifData.actions.length > 0

                Repeater {
                    model: notifData.actions || []

                    delegate: Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 28
                        radius: 14
                        color: actHover.containsMouse ? Qt.rgba(1.0, 1.0, 1.0, 0.22) : Qt.rgba(1.0, 1.0, 1.0, 0.10)
                        border.width: 0
                        border.color: "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: modelData.text || "Abrir"
                            font.family: "SF Pro Display, Adwaita Sans, Roboto, sans-serif"
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                            font.italic: false
                            color: "#FFFFFF"
                        }

                        MouseArea {
                            id: actHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                cardRoot.requestAction(notifData.id, index);
                            }
                        }
                    }
                }
            }
        }
    }
}
