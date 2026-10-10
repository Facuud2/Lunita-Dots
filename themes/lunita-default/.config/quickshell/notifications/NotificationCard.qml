import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell

Item {
    id: cardRoot

    required property var notifData
    required property var notifState
    signal requestDismiss(int id)
    signal requestAction(int id, int actionIndex)

    property bool isHovered: cardMouseArea.containsMouse || closeBtnMouseArea.containsMouse || menuMouseArea.containsMouse
    property bool exiting: false
    property bool optionsOpen: false
    property real contentActualHeight: cardContainer.implicitHeight + (optionsOpen ? (optionsDropdown.implicitHeight + 8) : 0)

    width: 370
    implicitHeight: exiting ? 0 : contentActualHeight
    opacity: exiting ? 0.0 : 1.0
    scale: exiting ? 0.92 : 1.0
    x: exiting ? 60 : 0

    Behavior on implicitHeight {
        NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
    }
    Behavior on opacity {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
    Behavior on scale {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
    Behavior on x {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }

    Connections {
        target: notifState
        function onRequestCloseDropdowns() {
            cardRoot.optionsOpen = false;
        }
    }

    // Entrance Animation on creation
    Component.onCompleted: {
        entranceAnim.start();
    }

    ParallelAnimation {
        id: entranceAnim
        NumberAnimation {
            target: cardRoot
            property: "x"
            from: 70
            to: 0
            duration: 280
            easing.type: Easing.OutBack
            easing.overshoot: 1.1
        }
        NumberAnimation {
            target: cardRoot
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: 220
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: cardRoot
            property: "scale"
            from: 0.92
            to: 1.0
            duration: 260
            easing.type: Easing.OutCubic
        }
    }

    // Auto-dismiss countdown timer (pauses when mouse is hovered)
    Timer {
        id: dismissTimer
        interval: notifData.expireMs > 0 ? notifData.expireMs : 6500
        running: notifData.expireMs > 0 && !cardRoot.isHovered && !cardRoot.optionsOpen
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
        interval: 230
        running: false
        onTriggered: {
            cardRoot.requestDismiss(notifData.id);
        }
    }

    // ── Main Glass Card Container ──
    Rectangle {
        id: cardContainer
        width: parent.width
        implicitHeight: cardInnerLayout.implicitHeight + 24
        radius: 14
        color: notifState.cardBg
        border.width: 0

        // Borde gris pixelado característico del sistema Nothing (Dot-matrix gray border)
        Shape {
            id: pixelBorder
            anchors.fill: parent
            layer.enabled: true
            layer.samples: 4
            z: 2

            ShapePath {
                strokeColor: notifState.nothingPixelBorder
                strokeWidth: 1.5
                fillColor: "transparent"
                strokeStyle: ShapePath.DashLine
                dashPattern: [1, 1.5]
                capStyle: ShapePath.FlatCap
                joinStyle: ShapePath.RoundJoin

                startX: cardContainer.radius
                startY: 0.5
                PathLine { x: pixelBorder.width - cardContainer.radius; y: 0.5 }
                PathArc { x: pixelBorder.width - 0.5; y: cardContainer.radius; radiusX: cardContainer.radius; radiusY: cardContainer.radius; direction: PathArc.Clockwise }
                PathLine { x: pixelBorder.width - 0.5; y: pixelBorder.height - cardContainer.radius }
                PathArc { x: pixelBorder.width - cardContainer.radius; y: pixelBorder.height - 0.5; radiusX: cardContainer.radius; radiusY: cardContainer.radius; direction: PathArc.Clockwise }
                PathLine { x: cardContainer.radius; y: pixelBorder.height - 0.5 }
                PathArc { x: 0.5; y: pixelBorder.height - cardContainer.radius; radiusX: cardContainer.radius; radiusY: cardContainer.radius; direction: PathArc.Clockwise }
                PathLine { x: 0.5; y: cardContainer.radius }
                PathArc { x: cardContainer.radius; y: 0.5; radiusX: cardContainer.radius; radiusY: cardContainer.radius; direction: PathArc.Clockwise }
            }
        }

        // Drop shadow illusion
        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: 15
            color: "transparent"
            border.color: notifState.cardShadow
            border.width: 1
            z: -1
            opacity: 0.35
        }

        // Clickable card area
        MouseArea {
            id: cardMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                // If notification has default action or click handler, invoke default
                if (notifData.actions && notifData.actions.length > 0) {
                    cardRoot.requestAction(notifData.id, 0);
                } else {
                    dismissWithAnimation();
                }
            }
        }

        // Inner Card Layout (App Icon + Text + Action Pill)
        RowLayout {
            id: cardInnerLayout
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: 12
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            spacing: 12

            // ── 1. Nothing OS App Icon Box ──
            Rectangle {
                Layout.preferredWidth: 38
                Layout.preferredHeight: 38
                Layout.alignment: Qt.AlignTop
                radius: 9
                color: Qt.rgba(1, 1, 1, 0.04)
                border.color: Qt.rgba(1, 1, 1, 0.12)
                border.width: 1
                clip: true

                Image {
                    id: iconImg
                    anchors.centerIn: parent
                    width: 26
                    height: 26
                    source: notifData.iconPath
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    smooth: true
                    mipmap: true

                    // Fallback to default reminder icon if image fails
                    onStatusChanged: {
                        if (status === Image.Error) {
                            source = Quickshell.env("HOME") + "/.config/quickshell/notifications/assets/reminders.svg";
                        }
                    }
                }
            }

            // ── 2. Header, Title & Body Text ──
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                // Header Tag (e.g. TIME SENSITIVE / App Name)
                Text {
                    Layout.fillWidth: true
                    text: notifData.headerTag
                    font.family: notifState.fontDots
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    font.letterSpacing: 0.6
                    color: notifData.isTimeSensitive ? notifState.timeSensitiveColor : notifState.textSubtleColor
                    elide: Text.ElideRight
                    visible: text.length > 0
                }

                // Title / Summary (e.g. "Brunch", "Move goal achieved")
                Text {
                    Layout.fillWidth: true
                    text: notifData.summary
                    font.family: notifState.fontUi
                    font.pixelSize: 13
                    font.weight: Font.Bold
                    color: notifState.textColor
                    elide: Text.ElideRight
                    wrapMode: Text.NoWrap
                }

                // Body Message (e.g. "Today, 9:45 AM", "Joe: ...")
                Text {
                    Layout.fillWidth: true
                    text: notifData.body
                    font.family: notifState.fontUi
                    font.pixelSize: 12
                    font.weight: Font.Normal
                    color: notifState.textDimColor
                    wrapMode: Text.WordWrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    visible: text.length > 0
                }

                // Optional attached media image (screenshots/album art)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    Layout.topMargin: 4
                    radius: 10
                    color: "transparent"
                    clip: true
                    visible: notifData.image && notifData.image.length > 0 && notifData.image.indexOf("image://icon/") === -1

                    Image {
                        anchors.fill: parent
                        source: notifData.image
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                    }
                }
            }

            // ── 3. Options ▾ Pill Button (Right side, matching macOS image) ──
            Rectangle {
                id: optionsBtn
                Layout.alignment: Qt.AlignBottom
                Layout.preferredHeight: 24
                Layout.preferredWidth: optionsBtnRow.implicitWidth + 16
                radius: 7
                visible: notifData.actions && notifData.actions.length > 0
                color: optionsBtnMouse.containsMouse || cardRoot.optionsOpen 
                    ? notifState.buttonHoverBg 
                    : notifState.buttonBg
                border.color: notifState.buttonBorder
                border.width: 1

                RowLayout {
                    id: optionsBtnRow
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "Options"
                        font.pixelSize: 11
                        font.weight: Font.Medium
                        color: notifState.textColor
                    }

                    Image {
                        source: Quickshell.env("HOME") + "/.config/quickshell/notifications/assets/chevron-down.svg"
                        Layout.preferredWidth: 10
                        Layout.preferredHeight: 10
                        smooth: true
                        opacity: 0.8
                    }
                }

                MouseArea {
                    id: optionsBtnMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        cardRoot.optionsOpen = !cardRoot.optionsOpen;
                    }
                }
            }
        }
    }

    // ── Hover Close Button (x) on Top-Left (Exact macOS Sonoma/Ventura style) ──
    Rectangle {
        id: closeBtn
        width: 20
        height: 20
        radius: 10
        anchors.left: cardContainer.left
        anchors.top: cardContainer.top
        anchors.leftMargin: -4
        anchors.topMargin: -4
        z: 10
        color: closeBtnMouseArea.containsMouse ? notifState.closeBtnHoverBg : notifState.closeBtnBg
        border.color: notifState.cardBorder
        border.width: 1
        opacity: cardRoot.isHovered ? 1.0 : 0.0
        scale: cardRoot.isHovered ? 1.0 : 0.7

        Behavior on opacity {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            NumberAnimation { duration: 150; easing.type: Easing.OutBack }
        }

        Image {
            anchors.centerIn: parent
            width: 10
            height: 10
            source: Quickshell.env("HOME") + "/.config/quickshell/notifications/assets/close.svg"
            smooth: true
            opacity: 0.85
        }

        MouseArea {
            id: closeBtnMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                dismissWithAnimation();
            }
        }
    }

    // ── Floating macOS Glass Options Dropdown Menu ──
    Rectangle {
        id: optionsDropdown
        anchors.top: cardContainer.bottom
        anchors.right: cardContainer.right
        anchors.topMargin: 6
        width: Math.max(190, menuColumn.implicitWidth + 24)
        implicitHeight: menuColumn.implicitHeight + 12
        radius: 13
        z: 20
        visible: cardRoot.optionsOpen && notifData.actions && notifData.actions.length > 0
        color: notifState.menuBg
        border.width: 0

        Shape {
            id: dropdownPixelBorder
            anchors.fill: parent
            layer.enabled: true
            layer.samples: 4
            z: 2

            ShapePath {
                strokeColor: notifState.nothingPixelBorder
                strokeWidth: 1.5
                fillColor: "transparent"
                strokeStyle: ShapePath.DashLine
                dashPattern: [1, 1.5]
                capStyle: ShapePath.FlatCap
                joinStyle: ShapePath.RoundJoin

                startX: optionsDropdown.radius
                startY: 0.5
                PathLine { x: dropdownPixelBorder.width - optionsDropdown.radius; y: 0.5 }
                PathArc { x: dropdownPixelBorder.width - 0.5; y: optionsDropdown.radius; radiusX: optionsDropdown.radius; radiusY: optionsDropdown.radius; direction: PathArc.Clockwise }
                PathLine { x: dropdownPixelBorder.width - 0.5; y: dropdownPixelBorder.height - optionsDropdown.radius }
                PathArc { x: dropdownPixelBorder.width - optionsDropdown.radius; y: dropdownPixelBorder.height - 0.5; radiusX: optionsDropdown.radius; radiusY: optionsDropdown.radius; direction: PathArc.Clockwise }
                PathLine { x: optionsDropdown.radius; y: dropdownPixelBorder.height - 0.5 }
                PathArc { x: 0.5; y: dropdownPixelBorder.height - optionsDropdown.radius; radiusX: optionsDropdown.radius; radiusY: optionsDropdown.radius; direction: PathArc.Clockwise }
                PathLine { x: 0.5; y: optionsDropdown.radius }
                PathArc { x: optionsDropdown.radius; y: 0.5; radiusX: optionsDropdown.radius; radiusY: optionsDropdown.radius; direction: PathArc.Clockwise }
            }
        }
        opacity: visible ? 1.0 : 0.0
        scale: visible ? 1.0 : 0.92

        Behavior on opacity {
            NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            NumberAnimation { duration: 160; easing.type: Easing.OutBack }
        }

        // Shadow border
        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: 14
            color: "transparent"
            border.color: notifState.cardShadow
            border.width: 1
            z: -1
            opacity: 0.45
        }

        MouseArea {
            id: menuMouseArea
            anchors.fill: parent
            hoverEnabled: true
        }

        ColumnLayout {
            id: menuColumn
            anchors.fill: parent
            anchors.margins: 6
            spacing: 2

            Repeater {
                model: notifData.actions || []

                delegate: Rectangle {
                    id: menuItem
                    required property var modelData
                    required property int index

                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    radius: 7
                    color: itemMouse.containsMouse ? notifState.menuItemHover : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10

                        Text {
                            Layout.fillWidth: true
                            text: menuItem.modelData.text || "Option"
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: itemMouse.containsMouse ? "#FFFFFF" : notifState.textColor
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            cardRoot.requestAction(notifData.id, menuItem.index);
                            cardRoot.dismissWithAnimation();
                        }
                    }
                }
            }
        }
    }
}
