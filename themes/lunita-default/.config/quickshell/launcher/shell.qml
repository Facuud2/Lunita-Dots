import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: root

    LauncherState {
        id: globalLauncherState
    }

    // Detección del monitor enfocado (donde se ejecutó el atajo)
    property var targetScreen: resolveScreen("")

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

    function updateTargetScreen(preferredName) {
        let s = resolveScreen(preferredName);
        if (s) root.targetScreen = s;
    }

    Connections {
        target: Hyprland
        function onFocusedMonitorChanged() {
            if (!globalLauncherState.isOpen) {
                root.updateTargetScreen("");
            }
        }
    }

    IpcHandler {
        target: "launcher"

        function toggle() {
            root.updateTargetScreen("");
            globalLauncherState.toggleLauncher();
        }

        function toggleOn(screenName: string) {
            root.updateTargetScreen(screenName);
            globalLauncherState.toggleLauncher();
        }

        function open() {
            root.updateTargetScreen("");
            globalLauncherState.openLauncher();
        }

        function openOn(screenName: string) {
            root.updateTargetScreen(screenName);
            globalLauncherState.openLauncher();
        }

        function close() {
            globalLauncherState.closeLauncher();
        }

        function search(q: string) {
            root.updateTargetScreen("");
            if (!globalLauncherState.isOpen) globalLauncherState.openLauncher();
            globalLauncherState.openSearch(q || "");
        }

        function switchTab(t: string) {
            globalLauncherState.switchTab(t);
        }
    }

    Variants {
        model: Quickshell.screens

        delegate: Scope {
            id: screenScope
            required property var modelData

            readonly property bool isTargetScreen: root.targetScreen !== null && (root.targetScreen === screenScope.modelData || root.targetScreen.name === screenScope.modelData.name)

            // ── 1. Fullscreen Dismiss Click Catcher (100% transparente, captura clics afuera y cierra) ──
            PanelWindow {
                id: clickCatcherWindow
                screen: screenScope.modelData
                color: "transparent"
                visible: globalLauncherState.isOpen && screenScope.isTargetScreen

                anchors {
                    top: true
                    bottom: true
                    left: true
                    right: true
                }

                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.namespace: "lunita-launcher-catcher"
                WlrLayershell.exclusionMode: ExclusionMode.Ignore
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

                MouseArea {
                    anchors.fill: parent
                    onClicked: globalLauncherState.closeLauncher()
                }
            }

            // ── 2. Compact Launcher Window (esquina inferior derecha) ──
            PanelWindow {
                id: launcherWin
                screen: screenScope.modelData
                color: "transparent"
                visible: (globalLauncherState.isOpen || globalLauncherState.visualOpacity > 0.001) && screenScope.isTargetScreen

                // El PanelWindow abarca únicamente la zona necesaria en la esquina inferior derecha
                // sin cubrir toda la pantalla, permitiendo hacer clic en cualquier ventana o espacio libre.
                anchors {
                    top: false
                    left: false
                    right: true
                    bottom: true
                }

                // Márgenes para despegarlo de la esquina (derecha 30px, abajo 50px)
                margins {
                    right: 30
                    bottom: 50
                }

                implicitWidth: launcherView.implicitWidth + 140
                implicitHeight: launcherView.implicitHeight + 20

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "lunita-app-launcher"
                // Foco exclusivo para responder a teclado de forma inmediata en Hyprland 0.57+
                WlrLayershell.keyboardFocus: (globalLauncherState.isOpen && screenScope.isTargetScreen)
                    ? WlrKeyboardFocus.Exclusive
                    : WlrKeyboardFocus.None

                // Dismiss al hacer clic en el margen transparente de la ventana
                MouseArea {
                    anchors.fill: parent
                    onClicked: globalLauncherState.closeLauncher()
                }

                LauncherView {
                    id: launcherView
                    launcherState: globalLauncherState
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                }

                // Navegación por teclado
                Item {
                    id: keyHandler
                    focus: globalLauncherState.isOpen && !globalLauncherState.searchMode

                    Timer {
                        id: keyFocusTimer
                        interval: 25
                        repeat: false
                        onTriggered: {
                            if (globalLauncherState.isOpen && !globalLauncherState.searchMode) {
                                keyHandler.forceActiveFocus();
                            }
                        }
                    }

                    Connections {
                        target: globalLauncherState
                        function onIsOpenChanged() {
                            if (globalLauncherState.isOpen && !globalLauncherState.searchMode) {
                                keyHandler.forceActiveFocus();
                                keyFocusTimer.restart();
                            }
                        }
                        function onSearchModeChanged() {
                            if (globalLauncherState.isOpen && !globalLauncherState.searchMode) {
                                keyHandler.forceActiveFocus();
                                keyFocusTimer.restart();
                            }
                        }
                    }

                    Keys.onEscapePressed: {
                        if (globalLauncherState.searchMode) {
                            globalLauncherState.closeSearch();
                        } else {
                            globalLauncherState.closeLauncher();
                        }
                    }

                    Keys.onLeftPressed: {
                        if (!globalLauncherState.searchMode) {
                            globalLauncherState.selectedIndex = Math.max(0, globalLauncherState.selectedIndex - 1);
                        }
                    }

                    Keys.onRightPressed: {
                        if (!globalLauncherState.searchMode) {
                            globalLauncherState.selectedIndex = Math.min(5, globalLauncherState.selectedIndex + 1);
                        }
                    }

                    Keys.onTabPressed: {
                        if (!globalLauncherState.searchMode) {
                            globalLauncherState.switchTab(globalLauncherState.activeTab === "apps" ? "links" : "apps");
                        }
                    }

                    Keys.onReturnPressed: root.handleReturn(event)
                    Keys.onEnterPressed: root.handleReturn(event)

                    Keys.onPressed: function(event) {
                        if (!globalLauncherState.searchMode) {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                root.handleReturn(event);
                                event.accepted = true;
                                return;
                            }
                            if (event.key === Qt.Key_Escape) {
                                globalLauncherState.closeLauncher();
                                event.accepted = true;
                                return;
                            }
                            if (event.key >= Qt.Key_Space && event.key <= Qt.Key_ydiaeresis && event.text && event.text.length > 0) {
                                globalLauncherState.openSearch(event.text);
                                event.accepted = true;
                            }
                        }
                    }
                }
            }
        }
    }

    function handleReturn(event) {
        if (!globalLauncherState.searchMode) {
            if (globalLauncherState.activeTab === "apps") {
                if (globalLauncherState.selectedIndex === 0) {
                    globalLauncherState.openSearch("");
                } else {
                    const quickApps = [
                        { cmd: "", isSearch: true },
                        { cmd: "kitty", isSearch: false },
                        { cmd: "dolphin", isSearch: false },
                        { cmd: "antigravity || code", isSearch: false },
                        { cmd: "zen-browser || firefox", isSearch: false },
                        { cmd: "spotify", isSearch: false }
                    ];
                    let sel = quickApps[globalLauncherState.selectedIndex];
                    if (sel) {
                        if (sel.isSearch) globalLauncherState.openSearch("");
                        else globalLauncherState.launchCommand(sel.cmd);
                    }
                }
            } else if (globalLauncherState.activeTab === "links") {
                const quickLinks = [
                    "https://www.google.com",
                    "https://www.youtube.com",
                    "https://www.reddit.com",
                    "https://www.twitter.com",
                    "https://www.netflix.com",
                    "https://www.soundcloud.com"
                ];
                let url = quickLinks[globalLauncherState.selectedIndex];
                if (url) {
                    globalLauncherState.launchCommand("zen-browser '" + url + "' || xdg-open '" + url + "'");
                }
            }
            if (event) event.accepted = true;
        }
    }
}
