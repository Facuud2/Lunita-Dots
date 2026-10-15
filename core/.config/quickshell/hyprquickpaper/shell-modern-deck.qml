import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Qt.labs.folderlistmodel
import Quickshell.Wayland

PanelWindow {
    id: main
    implicitHeight: Screen.height
    implicitWidth: Screen.width
    color: "transparent"

    property string currentImagePath: ""
    property bool bgToggle: false
    property date currentDateTime: new Date()
    property int selectedIndex: 0
    property bool didInitialSync: false

    // Color palette - harmonized with Matugen & user dotfiles
    readonly property color primaryColor: configs.border_color ? configs.border_color : "#d5bbfcee"
    readonly property color tertiaryColor: "#f1b7c3"
    readonly property color surfaceColor: "#151218"
    readonly property color surfaceContainer: "#211e24"
    readonly property color onSurface: "#e7e0e8"
    readonly property color onSurfaceVariant: "#cbc4cf"

    // Custom typography fallback
    FontLoader {
        id: customDisplayFont
        source: Quickshell.shellPath("./assets/fonts/anurati-regular.otf")
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    aboveWindows: true
    exclusionMode: "Ignore"
    exclusiveZone: 1

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "hyprquickpaper"

    // Video extension handling
    readonly property var defaultVideoExtensions: ["mp4", "webm", "mov", "avi", "mkv", "gif", "m4v", "flv", "wmv", "mpeg", "3gp"]
    readonly property var videoExtensions: (configs.video_extensions && configs.video_extensions.length > 0)
        ? configs.video_extensions
        : defaultVideoExtensions

    function isVideoFile(fileName) {
        if (!fileName) return false;
        const lower = fileName.toLowerCase();
        for (let i = 0; i < videoExtensions.length; i++) {
            if (lower.endsWith("." + videoExtensions[i])) return true;
        }
        return false;
    }

    function getThumbnailSource(fileName) {
        if (!fileName) return "";
        let basePath = configs.cache_path.replace("~", Quickshell.env("HOME"));
        if (!basePath.endsWith("/")) basePath += "/";

        let thumbName = fileName;
        if (isVideoFile(fileName)) {
            const lastDot = fileName.lastIndexOf(".");
            if (lastDot > 0) {
                thumbName = fileName.substring(0, lastDot) + ".jpg";
            }
        }
        return "file://" + basePath + thumbName;
    }

    function getFullSource(fileName) {
        if (!fileName) return "";
        let wallPath = configs.wallpaper_path.replace("~", Quickshell.env("HOME"));
        if (!wallPath.endsWith("/")) wallPath += "/";

        // For video, fallback to thumbnail for full background preview
        if (isVideoFile(fileName)) {
            return getThumbnailSource(fileName);
        }
        return "file://" + wallPath + fileName;
    }

    function formatCleanTitle(fileName) {
        if (!fileName) return "";
        let base = fileName;
        const lastDot = base.lastIndexOf(".");
        if (lastDot > 0) base = base.substring(0, lastDot);
        // Replace underscores/hyphens with spaces and capitalize
        base = base.replace(/[_-]+/g, " ");
        return base.charAt(0).toUpperCase() + base.slice(1);
    }

    // Deferred cache check
    Component.onCompleted: {
        Quickshell.execDetached(["bash", Quickshell.shellPath("cache.sh"), Quickshell.shellDir]);
    }

    FileView {
        path: Quickshell.shellPath("config.json")
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: configs
            property string wallpaper_path
            property string cache_path
            property int number_of_pictures
            property string border_color
            property var video_extensions: []
        }
    }

    FileView {
        id: activeWallpaperFile
        path: Quickshell.env("HOME") + "/.cache/hyprquickpaper/current_wallpaper"
        watchChanges: false
    }

    FolderListModel {
        id: folderModel
        folder: "file://" + configs.wallpaper_path.replace("~", Quickshell.env("HOME"))
        showDirs: false
        nameFilters: ["*.png", "*.jpg", "*.jpeg"].concat(
            main.videoExtensions.map(function(ext) { return "*." + ext; })
        )
        sortField: FolderListModel.Name
        onCountChanged: {
            if (count > 0 && selectedIndex >= count) selectedIndex = 0;
            initTimer.restart();
        }
    }

    Timer {
        id: initTimer
        interval: 30
        repeat: false
        onTriggered: {
            if (folderModel.count === 0) return;

            if (!didInitialSync) {
                didInitialSync = true;
                let rawText = "";
                try {
                    rawText = activeWallpaperFile.text();
                } catch (e) {
                    try { rawText = activeWallpaperFile.text; } catch (e2) { rawText = ""; }
                }
                let activePath = (rawText ? rawText : "").trim();

                let cleanActiveName = activePath.replace(/^file:\/\//, "");
                cleanActiveName = cleanActiveName.substring(cleanActiveName.lastIndexOf("/") + 1);

                if (cleanActiveName.length > 0) {
                    for (let i = 0; i < folderModel.count; i++) {
                        let itemPath = folderModel.get(i, "filePath");
                        let itemFileName = folderModel.get(i, "fileName");
                        if (itemFileName === cleanActiveName || itemPath === activePath || (itemPath && itemPath.endsWith("/" + cleanActiveName))) {
                            main.selectedIndex = i;
                            break;
                        }
                    }
                }
            }
            updateBackground();
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: currentDateTime = new Date()
    }

    function updateBackground() {
        if (folderModel.count === 0) return;
        const fileName = folderModel.get(main.selectedIndex, "fileName");
        const fullSource = getFullSource(fileName);
        currentImagePath = fullSource;

        if (!bgToggle) {
            bgImageB.source = fullSource;
            bgToggle = true;
        } else {
            bgImageA.source = fullSource;
            bgToggle = false;
        }
    }

    onSelectedIndexChanged: updateBackground()

    // -------------------------------------------------------------------------
    // 1. DYNAMIC AMBIENT BACKDROP (Frosted Glass with Smooth Cross-Fade)
    // -------------------------------------------------------------------------
    Item {
        id: backgroundLayer
        anchors.fill: parent
        z: 0

        // Base dark curtain
        Rectangle {
            anchors.fill: parent
            color: "#08060b"
        }

        Image {
            id: bgImageA
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            smooth: true
            visible: false
            opacity: bgToggle ? 0.0 : 1.0
            Behavior on opacity { NumberAnimation { duration: 420; easing.type: Easing.InOutQuad } }
        }

        Image {
            id: bgImageB
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            smooth: true
            visible: false
            opacity: bgToggle ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 420; easing.type: Easing.InOutQuad } }
        }

        MultiEffect {
            anchors.fill: parent
            source: bgImageA
            opacity: bgImageA.opacity
            blurEnabled: true
            blur: 1.0
            blurMax: 80
            brightness: -0.26
            saturation: 0.20
        }

        MultiEffect {
            anchors.fill: parent
            source: bgImageB
            opacity: bgImageB.opacity
            blurEnabled: true
            blur: 1.0
            blurMax: 80
            brightness: -0.26
            saturation: 0.20
        }

        // Ambient radial light vignette
        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.7
            height: parent.height * 0.7
            radius: width * 0.5
            color: main.primaryColor
            opacity: 0.12
            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 1.0
                blurMax: 100
            }
        }

        // Soft dark edge gradients for focus
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: "#aa060408" }
                GradientStop { position: 0.25; color: "#33000000" }
                GradientStop { position: 0.75; color: "#33000000" }
                GradientStop { position: 1.0; color: "#dd060408" }
            }
        }

        // Click on background to dismiss
        MouseArea {
            anchors.fill: parent
            onClicked: Qt.quit()
        }
    }

    // -------------------------------------------------------------------------
    // 2. HEADER: CLOCK, DATE & SYSTEM PILL
    // -------------------------------------------------------------------------
    Item {
        id: headerArea
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.05
        anchors.horizontalCenter: parent.horizontalCenter
        width: 440
        height: 120
        z: 50

        // Glassmorphic header card
        Rectangle {
            anchors.fill: parent
            radius: 20
            color: "#a6211e24"
            border.width: 1
            border.color: "#40d5bbfc"

            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 0.8
                blurMax: 30
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: 2

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 8

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 6
                    height: 6
                    radius: 3
                    color: main.primaryColor
                }

                Text {
                    text: "HYPRQUICKPAPER"
                    color: main.primaryColor
                    font.pixelSize: 11
                    font.weight: Font.DemiBold
                    font.letterSpacing: 4
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 6
                    height: 6
                    radius: 3
                    color: main.primaryColor
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(main.currentDateTime, "HH:mm")
                color: main.onSurface
                font.pixelSize: 42
                font.weight: Font.Bold
                font.letterSpacing: 2
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(main.currentDateTime, "dddd, d 'de' MMMM").toUpperCase()
                color: main.onSurfaceVariant
                font.pixelSize: 11
                font.weight: Font.Medium
                font.letterSpacing: 2
            }
        }
    }

    // -------------------------------------------------------------------------
    // 3. 3D FLOATING TIERED CAROUSEL
    // -------------------------------------------------------------------------
    Item {
        id: stage
        anchors.fill: parent
        focus: true
        z: 20

        Repeater {
            model: folderModel

            delegate: Item {
                id: cardDelegate

                property string fileNameStr: typeof fileName !== "undefined" ? fileName : folderModel.get(index, "fileName")
                property bool isVideo: main.isVideoFile(fileNameStr)

                // Cyclic distance from center selected index
                property int diff: {
                    if (folderModel.count === 0) return 0;
                    let d = index - main.selectedIndex;
                    let half = folderModel.count / 2;
                    if (d > half) d -= folderModel.count;
                    if (d < -half) d += folderModel.count;
                    return d;
                }

                property real absDiff: Math.abs(diff)
                visible: absDiff <= 6

                // Cinematic card sizing
                property real targetWidth: {
                    if (absDiff === 0) return 660;
                    if (absDiff === 1) return 440;
                    if (absDiff === 2) return 280;
                    return 170;
                }

                property real targetHeight: {
                    if (absDiff === 0) return 372;
                    if (absDiff === 1) return 248;
                    if (absDiff === 2) return 158;
                    return 96;
                }

                property real targetX: {
                    if (diff === 0) return (main.width - targetWidth) / 2;
                    if (absDiff === 1) return (main.width / 2) + (diff * 490) - (targetWidth / 2);
                    if (absDiff === 2) return (main.width / 2) + (Math.sign(diff) * 780) - (targetWidth / 2);
                    return (main.width / 2) + (diff * 220) - (targetWidth / 2);
                }

                property real targetY: {
                    if (absDiff === 0) return (main.height * 0.47) - (targetHeight / 2);
                    if (absDiff === 1) return (main.height * 0.45) - (targetHeight / 2);
                    if (absDiff === 2) return (main.height * 0.43) - (targetHeight / 2);
                    return (main.height * 0.40) - (targetHeight / 2);
                }

                property int targetZ: 100 - absDiff
                property real targetOpacity: {
                    if (absDiff === 0) return 1.0;
                    if (absDiff === 1) return 0.82;
                    if (absDiff === 2) return 0.45;
                    return 0.18;
                }

                x: targetX
                y: targetY
                width: targetWidth
                height: targetHeight
                z: targetZ
                opacity: targetOpacity

                Behavior on x { NumberAnimation { duration: 380; easing.type: Easing.OutQuart } }
                Behavior on y { NumberAnimation { duration: 380; easing.type: Easing.OutQuart } }
                Behavior on width { NumberAnimation { duration: 380; easing.type: Easing.OutQuart } }
                Behavior on height { NumberAnimation { duration: 380; easing.type: Easing.OutQuart } }
                Behavior on opacity { NumberAnimation { duration: 320 } }
                Behavior on z { NumberAnimation { duration: 320 } }

                // Outer Glowing Halo for active card
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 24
                    height: parent.height + 24
                    radius: 30
                    color: "transparent"
                    border.width: 3
                    border.color: main.primaryColor
                    opacity: absDiff === 0 ? 0.85 : 0.0
                    visible: absDiff === 0

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        blurEnabled: true
                        blur: 1.0
                        blurMax: 36
                    }

                    Behavior on opacity { NumberAnimation { duration: 300 } }
                }

                // Card Container
                Rectangle {
                    id: cardBox
                    anchors.fill: parent
                    radius: absDiff === 0 ? 24 : 18
                    color: "#18141e"
                    border.width: absDiff === 0 ? 2 : 1
                    border.color: absDiff === 0 ? main.primaryColor : "#4d958e99"

                    Rectangle {
                        id: maskRect
                        anchors.fill: parent
                        radius: cardBox.radius
                        visible: false
                    }

                    Item {
                        id: cardInner
                        anchors.fill: parent
                        visible: false

                        // Image / Thumbnail
                        Image {
                            id: thumbImg
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            smooth: true
                            source: main.getThumbnailSource(cardDelegate.fileNameStr)
                            sourceSize.width: cardDelegate.targetWidth * 1.5
                            sourceSize.height: cardDelegate.targetHeight * 1.5

                            Text {
                                anchors.centerIn: parent
                                text: "✦"
                                color: main.primaryColor
                                font.pixelSize: 22
                                visible: thumbImg.status !== Image.Ready
                            }
                        }

                        // Gradient shadow at bottom of card for text clarity
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: parent.height * 0.4
                            gradient: Gradient {
                                orientation: Gradient.Vertical
                                GradientStop { position: 0.0; color: "transparent" }
                                GradientStop { position: 1.0; color: "#d90a080e" }
                            }
                        }

                        // VIDEO badge
                        Rectangle {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 14
                            width: 82
                            height: 26
                            radius: 13
                            color: "#d914101a"
                            border.width: 1
                            border.color: "#f1b7c3"
                            visible: cardDelegate.isVideo

                            Row {
                                anchors.centerIn: parent
                                spacing: 5
                                Text {
                                    text: "▶"
                                    color: "#f1b7c3"
                                    font.pixelSize: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: "VIDEO"
                                    color: "#f1b7c3"
                                    font.pixelSize: 10
                                    font.weight: Font.Bold
                                    font.letterSpacing: 1
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }

                        // Dim overlay for unselected cards
                        Rectangle {
                            anchors.fill: parent
                            color: "#050308"
                            opacity: absDiff === 0 ? 0.0 : (absDiff === 1 ? 0.25 : 0.55)
                            Behavior on opacity { NumberAnimation { duration: 250 } }
                        }
                    }

                    OpacityMask {
                        anchors.fill: parent
                        source: cardInner
                        maskSource: maskRect
                    }
                }

                // Click / Interaction
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        stage.forceActiveFocus();
                        if (main.selectedIndex === index) {
                            main.activateCurrent();
                        } else {
                            main.selectedIndex = index;
                        }
                    }

                    onWheel: function(wheel) {
                        if (wheel.angleDelta.y < 0) {
                            main.selectedIndex = (main.selectedIndex + 1) % folderModel.count;
                        } else if (wheel.angleDelta.y > 0) {
                            main.selectedIndex = (main.selectedIndex - 1 + folderModel.count) % folderModel.count;
                        }
                    }
                }
            }
        }

        // Global Keyboard Navigation
        Keys.onPressed: function(event) {
            if (folderModel.count === 0) return;

            if (event.key === Qt.Key_Right || event.key === Qt.Key_L) {
                main.selectedIndex = (main.selectedIndex + 1) % folderModel.count;
            } else if (event.key === Qt.Key_Left || event.key === Qt.Key_H) {
                main.selectedIndex = (main.selectedIndex - 1 + folderModel.count) % folderModel.count;
            } else if (event.key === Qt.Key_Home) {
                main.selectedIndex = 0;
            } else if (event.key === Qt.Key_End) {
                main.selectedIndex = folderModel.count - 1;
            } else if (event.key === Qt.Key_Space || event.key === Qt.Key_Return) {
                main.activateCurrent();
            } else if (event.key === Qt.Key_Escape) {
                Qt.quit();
            } else {
                return;
            }
            event.accepted = true;
        }
    }

    // -------------------------------------------------------------------------
    // 4. FLOATING HUD PILL (Bottom Info Bar & Shortcuts)
    // -------------------------------------------------------------------------
    Item {
        id: bottomHud
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * 0.05
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(840, parent.width * 0.9)
        height: 64
        z: 60

        // Glassmorphic container
        Rectangle {
            anchors.fill: parent
            radius: 32
            color: "#c719161d"
            border.width: 1
            border.color: "#4dd5bbfc"

            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 1.0
                blurMax: 40
            }
        }

        Item {
            anchors.fill: parent
            anchors.leftMargin: 24
            anchors.rightMargin: 20

            // Wallpaper Info
            Column {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: 280
                spacing: 2

                Text {
                    id: wallTitle
                    text: folderModel.count > 0 ? main.formatCleanTitle(folderModel.get(main.selectedIndex, "fileName")) : "No hay fondos"
                    color: main.onSurface
                    font.pixelSize: 15
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                    width: parent.width
                }

                Row {
                    spacing: 8
                    Text {
                        text: folderModel.count > 0
                            ? (main.selectedIndex + 1).toString().padStart(2, '0') + " / " + folderModel.count.toString().padStart(2, '0')
                            : "-- / --"
                        color: main.primaryColor
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }
                    Text {
                        text: "·"
                        color: main.onSurfaceVariant
                        font.pixelSize: 12
                    }
                    Text {
                        text: folderModel.count > 0 && main.isVideoFile(folderModel.get(main.selectedIndex, "fileName"))
                            ? "Fondo Animado (mpvpaper)"
                            : "Imagen Estática (awww)"
                        color: main.onSurfaceVariant
                        font.pixelSize: 11
                    }
                }
            }

            // Shortcut badges
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                // Navigate pill
                Rectangle {
                    height: 28
                    width: navText.width + 16
                    radius: 14
                    color: "#14ffffff"
                    border.width: 1
                    border.color: "#1fffffff"
                    Text {
                        id: navText
                        anchors.centerIn: parent
                        text: "← → Navegar"
                        color: main.onSurface
                        font.pixelSize: 11
                        font.weight: Font.Medium
                    }
                }

                // Dismiss pill
                Rectangle {
                    height: 28
                    width: escText.width + 16
                    radius: 14
                    color: "#14ffffff"
                    border.width: 1
                    border.color: "#1fffffff"
                    Text {
                        id: escText
                        anchors.centerIn: parent
                        text: "Esc Salir"
                        color: main.onSurfaceVariant
                        font.pixelSize: 11
                        font.weight: Font.Medium
                    }
                }

                // Apply button pill
                Rectangle {
                    id: applyBtn
                    height: 34
                    width: applyText.width + 24
                    radius: 17
                    color: applyMouse.containsMouse ? Qt.lighter(main.primaryColor, 1.15) : main.primaryColor

                    Behavior on color { ColorAnimation { duration: 150 } }

                    Row {
                        id: applyText
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: "↵"
                            color: "#281347"
                            font.pixelSize: 14
                            font.weight: Font.Bold
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Aplicar Fondo"
                            color: "#281347"
                            font.pixelSize: 12
                            font.weight: Font.Bold
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: applyMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: main.activateCurrent()
                    }
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // 5. APPLICATION TRIGGER
    // -------------------------------------------------------------------------
    function activateCurrent() {
        if (folderModel.count === 0) return;
        const filePath = folderModel.get(main.selectedIndex, "filePath");
        Quickshell.execDetached(["bash", Quickshell.shellPath("commands.sh"), filePath]);
        Qt.quit();
    }
}
