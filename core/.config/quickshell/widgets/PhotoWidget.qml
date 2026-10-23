import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    property var widgetsState
    property bool contextMenuOpen: false

    // ── Outer Rounded Container with Glass Border ──
    Rectangle {
        id: cardContainer

        anchors.fill: parent
        radius: root.widgetsState ? root.widgetsState.cardRadius : 22
        color: root.widgetsState ? root.widgetsState.cardBg : Qt.rgba(0.12, 0.14, 0.18, 0.75)
        border.color: root.widgetsState ? root.widgetsState.cardBorder : Qt.rgba(1, 1, 1, 0.14)
        border.width: 1

        // ── 1. Masked Content (Ensures 100% Rounded Corners) ──
        Item {
            id: maskedLayer

            // State tracker for smooth crossfade and backdrop slide
            property bool usingA: true

            anchors.fill: parent
            layer.enabled: true
            Component.onCompleted: {
                if (root.widgetsState && root.widgetsState.photoPath) {
                    imgA.source = "file://" + root.widgetsState.photoPath;
                    imgA.opacity = 1;
                    imgA.x = 0;
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
                opacity: 1
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
                opacity: 0
                x: 0
            }

            Connections {
                function onPhotoPathChanged() {
                    var newPath = root.widgetsState.photoPath;
                    if (!newPath)
                        return ;

                    var fileUrl = "file://" + newPath;
                    var dir = root.widgetsState.photoDirection || 1;
                    var slideDistance = 35;
                    if (maskedLayer.usingA) {
                        // Transition from A to B
                        imgB.source = fileUrl;
                        imgB.x = dir * slideDistance;
                        imgB.opacity = 0;
                        transAnimB.dir = dir;
                        transAnimB.slideDist = slideDistance;
                        transAnimB.restart();
                        maskedLayer.usingA = false;
                    } else {
                        // Transition from B to A
                        imgA.source = fileUrl;
                        imgA.x = dir * slideDistance;
                        imgA.opacity = 0;
                        transAnimA.dir = dir;
                        transAnimA.slideDist = slideDistance;
                        transAnimA.restart();
                        maskedLayer.usingA = true;
                    }
                }

                target: root.widgetsState
            }

            // Animation A -> B
            ParallelAnimation {
                id: transAnimB

                property int dir: 1
                property real slideDist: 35

                NumberAnimation {
                    target: imgA
                    property: "opacity"
                    to: 0
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
                    to: 1
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
                    to: 0
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
                    to: 1
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

            // Vignette Gradient Layer
            Rectangle {
                anchors.fill: parent

                gradient: Gradient {
                    GradientStop {
                        position: 0
                        color: Qt.rgba(0, 0, 0, 0.35)
                    }

                    GradientStop {
                        position: 0.4
                        color: Qt.rgba(0, 0, 0, 0)
                    }

                    GradientStop {
                        position: 1
                        color: Qt.rgba(0, 0, 0, 0.85)
                    }

                }

            }

            layer.effect: OpacityMask {

                maskSource: Rectangle {
                    width: root.width
                    height: root.height
                    radius: root.widgetsState ? root.widgetsState.cardRadius : 22
                }

            }

        }

        // ── 2. Right-Click Area for Context Menu ──
        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            cursorShape: Qt.ArrowCursor
            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton)
                    root.contextMenuOpen = !root.contextMenuOpen;

            }
        }

        // ── 3. Overlay UI Content ──
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

                Item {
                    Layout.fillWidth: true
                }

                // Navigation Buttons (Prev & Next)
                RowLayout {
                    spacing: 4

                    // Prev Button
                    Rectangle {
                        radius: 12
                        width: 26
                        height: 24
                        color: prevMa.containsMouse ? Qt.rgba(1, 1, 1, 0.9) : Qt.rgba(0.12, 0.12, 0.16, 0.82)
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
                        color: nextMa.containsMouse ? Qt.rgba(1, 1, 1, 0.9) : Qt.rgba(0.12, 0.12, 0.16, 0.82)
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

            Item {
                Layout.fillHeight: true
            }

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

        // ── 4. Dismiss Overlay for Context Menu ──
        MouseArea {
            id: dismissOverlay

            anchors.fill: parent
            visible: root.contextMenuOpen
            z: 99
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: root.contextMenuOpen = false
        }

        // ── 5. Native Context Menu (Right Click) ──
        Rectangle {
            id: contextMenu

            visible: root.contextMenuOpen
            z: 100
            anchors.centerIn: parent
            width: Math.min(parent.width - 24, 250)
            height: menuColumn.implicitHeight + 16
            radius: 14
            color: root.widgetsState.isDarkTheme ? "#f2181a24" : "#f5ffffff"
            border.color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.22)" : "rgba(0,0,0,0.15)"
            border.width: 1
            scale: root.contextMenuOpen ? 1 : 0.92
            opacity: root.contextMenuOpen ? 1 : 0

            Column {
                id: menuColumn

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 8
                spacing: 3

                // Menu Header: Photo Name
                Text {
                    width: parent.width
                    text: root.widgetsState.photoTitle || "Captura"
                    font.family: "SF Pro Display"
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.75)" : "rgba(0,0,0,0.75)"
                    elide: Text.ElideRight
                    leftPadding: 6
                    bottomPadding: 2
                }

                // Divider Line
                Rectangle {
                    width: parent.width
                    height: 1
                    color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.12)" : "rgba(0,0,0,0.10)"
                }

                Item {
                    width: parent.width
                    height: 2
                }

                // 1. Establecer como fondo de pantalla
                Rectangle {
                    width: parent.width
                    height: 22
                    radius: 7
                    color: btn1Ma.containsMouse ? (root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.16)" : "rgba(0,0,0,0.08)") : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
                        spacing: 6

                        Text {
                            text: "󰸉"
                            font.family: "CaskaydiaCove Nerd Font"
                            font.pixelSize: 11
                            color: "#64D2FF"
                        }

                        Text {
                            text: "Establecer como fondo de pantalla"
                            font.family: "SF Pro Display"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: root.widgetsState.textColor
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                    }

                    MouseArea {
                        id: btn1Ma

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var p = root.widgetsState.photoPath;
                            if (p) {
                                var cmd = "swww img '" + p + "' --transition-type wipe --transition-angle 30 --transition-step 90 2>/dev/null || (hyprctl hyprpaper preload '" + p + "' 2>/dev/null && hyprctl hyprpaper wallpaper '," + p + "' 2>/dev/null) || true; cp '" + p + "' $HOME/.config/hypr/current_wallpaper.png 2>/dev/null; echo '" + p + "' > $HOME/.cache/hyprquickpaper/current_wallpaper 2>/dev/null; notify-send 'Fondo de pantalla' 'Fondo establecido correctamente' -i '" + p + "'";
                                Quickshell.execDetached(["bash", "-c", cmd]);
                            }
                            root.contextMenuOpen = false;
                        }
                    }

                }

                // 2. Abrir ubicación de imagen
                Rectangle {
                    width: parent.width
                    height: 22
                    radius: 7
                    color: btn2Ma.containsMouse ? (root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.16)" : "rgba(0,0,0,0.08)") : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
                        spacing: 6

                        Text {
                            text: "󰈟"
                            font.family: "CaskaydiaCove Nerd Font"
                            font.pixelSize: 11
                            color: "#30D158"
                        }

                        Text {
                            text: "Abrir ubicación de imagen"
                            font.family: "SF Pro Display"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: root.widgetsState.textColor
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                    }

                    MouseArea {
                        id: btn2Ma

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var p = root.widgetsState.photoPath;
                            if (p)
                                Quickshell.execDetached(["xdg-open", p]);

                            root.contextMenuOpen = false;
                        }
                    }

                }

                // 3. Abrir carpeta contenedora
                Rectangle {
                    width: parent.width
                    height: 22
                    radius: 7
                    color: btn3Ma.containsMouse ? (root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.16)" : "rgba(0,0,0,0.08)") : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
                        spacing: 6

                        Text {
                            text: "󰉋"
                            font.family: "CaskaydiaCove Nerd Font"
                            font.pixelSize: 11
                            color: "#FF9F0A"
                        }

                        Text {
                            text: "Abrir carpeta contenedora"
                            font.family: "SF Pro Display"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: root.widgetsState.textColor
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                    }

                    MouseArea {
                        id: btn3Ma

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var p = root.widgetsState.photoPath;
                            if (p) {
                                var cmd = "dolphin --select '" + p + "' 2>/dev/null || nautilus --select '" + p + "' 2>/dev/null || xdg-open \"$(dirname '" + p + "')\"";
                                Quickshell.execDetached(["bash", "-c", cmd]);
                            }
                            root.contextMenuOpen = false;
                        }
                    }

                }

                // 4. Copiar imagen al portapapeles
                Rectangle {
                    width: parent.width
                    height: 22
                    radius: 7
                    color: btn4Ma.containsMouse ? (root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.16)" : "rgba(0,0,0,0.08)") : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
                        spacing: 6

                        Text {
                            text: "󰆏"
                            font.family: "CaskaydiaCove Nerd Font"
                            font.pixelSize: 11
                            color: "#0A84FF"
                        }

                        Text {
                            text: "Copiar imagen al portapapeles"
                            font.family: "SF Pro Display"
                            font.pixelSize: 11
                            font.weight: Font.Medium
                            color: root.widgetsState.textColor
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                    }

                    MouseArea {
                        id: btn4Ma

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var p = root.widgetsState.photoPath;
                            if (p) {
                                var cmd = "wl-copy -t image/png < '" + p + "' 2>/dev/null || wl-copy < '" + p + "' 2>/dev/null || xclip -selection clipboard -target image/png -i '" + p + "' 2>/dev/null; notify-send 'Galería' 'Imagen copiada al portapapeles' -i '" + p + "'";
                                Quickshell.execDetached(["bash", "-c", cmd]);
                            }
                            root.contextMenuOpen = false;
                        }
                    }

                }

                // Divider Line before Destructive Action
                Rectangle {
                    width: parent.width
                    height: 1
                    color: root.widgetsState.isDarkTheme ? "rgba(255,255,255,0.12)" : "rgba(0,0,0,0.10)"
                }

                // 5. Eliminar de galería (Acción Destructiva)
                Rectangle {
                    width: parent.width
                    height: 22
                    radius: 7
                    color: btn5Ma.containsMouse ? "rgba(255, 69, 58, 0.22)" : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
                        spacing: 6

                        Text {
                            text: "󰩹"
                            font.family: "CaskaydiaCove Nerd Font"
                            font.pixelSize: 11
                            color: "#FF453A"
                        }

                        Text {
                            text: "Eliminar de galería"
                            font.family: "SF Pro Display"
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            color: "#FF453A"
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                    }

                    MouseArea {
                        id: btn5Ma

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var p = root.widgetsState.photoPath;
                            var cmd = "python3 " + root.widgetsState.scriptsDir + "/photo_provider.py delete; notify-send 'Galería' 'Captura eliminada de la galería' -a 'Galería'";
                            Quickshell.execDetached(["bash", "-c", cmd]);
                            root.widgetsState.nextPhoto();
                            root.contextMenuOpen = false;
                        }
                    }

                }

            }

            Behavior on scale {
                NumberAnimation {
                    duration: 140
                    easing.type: Easing.OutCubic
                }

            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 140
                    easing.type: Easing.OutCubic
                }

            }

        }

    }

}
