import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "."

Scope {
    id: root

    // Resolver de monitor enfocado / destino
    function resolveScreen(preferredName) {
        if (preferredName && preferredName !== "") {
            for (let i = 0; i < Quickshell.screens.length; i++) {
                if (Quickshell.screens[i].name === preferredName) {
                    return Quickshell.screens[i];
                }
            }
        }
        if (Hyprland.focusedMonitor && Hyprland.focusedMonitor.name) {
            for (let i = 0; i < Quickshell.screens.length; i++) {
                if (Quickshell.screens[i].name === Hyprland.focusedMonitor.name) {
                    return Quickshell.screens[i];
                }
            }
        }
        return Quickshell.screens.length > 0 ? Quickshell.screens[0] : null;
    }

    // Estado global de la Nothing Dynamic Island
    QtObject {
        id: islandState
        property bool expanded: false
        property bool pinned: false
        property string activePanel: "" // "" | "audio" | "net" | "bt" | "apps" | "notifs" | "power" | "record" | "calendar"
        property var activeScreen: null

        property bool pillHovered: false
        property bool popupHovered: false
        readonly property bool anyHovered: pillHovered || popupHovered

        onAnyHoveredChanged: {
            if (anyHovered) {
                collapseTimer.stop();
                if (!expanded) {
                    activeScreen = activeScreen || root.resolveScreen("");
                    expanded = true;
                    pinned = false;
                }
            } else {
                if (!pinned && expanded) {
                    collapseTimer.restart();
                }
            }
        }

        function togglePin(screenName) {
            collapseTimer.stop();
            if (expanded && pinned) {
                collapse();
            } else {
                activeScreen = root.resolveScreen(screenName);
                expanded = true;
                pinned = true;
            }
        }

        function toggleExpand(screenName) {
            togglePin(screenName);
        }

        function collapse() {
            collapseTimer.stop();
            pillHovered = false;
            popupHovered = false;
            pinned = false;
            expanded = false;
            activePanel = "";
        }

        function openPanel(panelName, screenName) {
            collapseTimer.stop();
            activeScreen = root.resolveScreen(screenName);
            expanded = true;
            pinned = true;
            activePanel = panelName;
        }

        function togglePanel(panelName, screenName) {
            if (expanded && activePanel === panelName) {
                collapse();
            } else {
                openPanel(panelName, screenName);
            }
        }
    }

    Timer {
        id: collapseTimer
        interval: 350
        repeat: false
        onTriggered: {
            if (!islandState.pinned && !islandState.anyHovered) {
                islandState.collapse();
            }
        }
    }

    // Receptor IPC para keybinds o scripts externos
    IpcHandler {
        target: "bar"

        function toggle() {
            islandState.togglePin("");
        }

        function toggleOn(screenName: string) {
            islandState.togglePin(screenName);
        }

        function expand() {
            islandState.activeScreen = root.resolveScreen("");
            islandState.expanded = true;
            islandState.pinned = true;
        }

        function expandOn(screenName: string) {
            islandState.activeScreen = root.resolveScreen(screenName);
            islandState.expanded = true;
            islandState.pinned = true;
        }

        function collapse() {
            islandState.collapse();
        }

        function open(panelName: string) {
            islandState.openPanel(panelName, "");
        }

        function openOn(panelName: string, screenName: string) {
            islandState.openPanel(panelName, screenName);
        }

        function togglePanel(panelName: string) {
            islandState.togglePanel(panelName, "");
        }

        function togglePanelOn(panelName: string, screenName: string) {
            islandState.togglePanel(panelName, screenName);
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Scope {
            id: screenScope
            required property var modelData

            // ── 1. Compact Pill Window (36px Top Bar) ──
            PanelWindow {
                id: pillWindow
                screen: screenScope.modelData
                color: "transparent"
                implicitHeight: Theme.collapsedHeight + 12
                implicitWidth: Theme.collapsedWidth + 24

                anchors {
                    top: true
                }
                margins {
                    top: 6
                }

                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.namespace: "nothing-dynamic-island-pill"
                WlrLayershell.exclusiveZone: Theme.collapsedHeight + 12
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                CompactPill {
                    anchors.centerIn: parent
                    width: Theme.collapsedWidth
                    height: Theme.collapsedHeight

                    onRequestToggleExpand: {
                        islandState.togglePin(screenScope.modelData.name);
                    }
                    onRequestHoverEnter: {
                        islandState.activeScreen = screenScope.modelData;
                        islandState.pillHovered = true;
                    }
                    onRequestHoverExit: {
                        islandState.pillHovered = false;
                    }
                }
            }

            // ── 2. Fullscreen Dismiss Backdrop Window (solo cuando está expandido y fijo/pinned) ──
            PanelWindow {
                id: backdropWindow
                screen: screenScope.modelData
                color: "transparent"
                visible: islandState.expanded && islandState.pinned && islandState.activeScreen !== null && islandState.activeScreen.name === screenScope.modelData.name

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.namespace: "nothing-island-backdrop"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                MouseArea {
                    anchors.fill: parent
                    onClicked: islandState.collapse()
                }
            }

            // ── 3. Expanded Island Panel Window (Overlay animado) ──
            PanelWindow {
                id: popupWindow
                screen: screenScope.modelData
                color: "transparent"
                visible: (islandState.expanded || expandedShell.opacity > 0.01) && islandState.activeScreen !== null && islandState.activeScreen.name === screenScope.modelData.name

                anchors {
                    top: true
                }
                margins {
                    top: 6
                }

                implicitWidth: Theme.expandedWidth
                implicitHeight: expandedShell.height

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "nothing-island-popup"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.keyboardFocus: (islandState.expanded && islandState.activeScreen !== null && islandState.activeScreen.name === screenScope.modelData.name)
                    ? WlrKeyboardFocus.Exclusive
                    : WlrKeyboardFocus.None

                Rectangle {
                    id: expandedShell
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    width: Theme.expandedWidth
                    height: topPillHeader.height + expandedBody.implicitHeight + 24
                    radius: Theme.expandedRadius
                    color: Theme.bg
                    border.width: 1
                    border.color: Theme.outline
                    clip: true

                    opacity: islandState.expanded ? 1 : 0
                    scale: islandState.expanded ? 1 : 0.96

                    Behavior on opacity {
                        NumberAnimation { duration: Theme.durShort; easing.type: Easing.OutQuad }
                    }
                    Behavior on scale {
                        NumberAnimation { duration: Theme.durShort; easing.type: Easing.OutCubic }
                    }

                    HoverHandler {
                        id: popupHover
                        onHoveredChanged: {
                            islandState.popupHovered = hovered;
                        }
                    }

                    // Cabecera interactiva que vuelve a colapsar al hacer clic
                    Rectangle {
                        id: topPillHeader
                        width: parent.width
                        height: Theme.collapsedHeight
                        color: Theme.surface
                        radius: Theme.expandedRadius

                        CompactPill {
                            anchors.fill: parent
                            onRequestToggleExpand: islandState.collapse()
                        }
                    }

                    // Panel Expandido con toda la botonera y tarjetas Nothing
                    ExpandedPanel {
                        id: expandedBody
                        anchors.top: topPillHeader.bottom
                        anchors.topMargin: 8
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: Theme.expandedWidth
                        onCloseRequested: islandState.collapse()

                        HoverHandler {
                            id: bodyHover
                            onHoveredChanged: {
                                islandState.popupHovered = hovered || popupHover.hovered;
                            }
                        }
                    }
                }
            }
        }
    }
}
