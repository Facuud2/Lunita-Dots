import Quickshell
import QtQuick

// Top-level Scope allows loading PanelWindow dynamically without rendering white artifacts
Scope {
    id: root

    // Layout Coverflow idéntico a la captura de pantalla del usuario
    property string activeLayout: "shell-coverflow.qml"

    // Alternative layouts:
    // property string activeLayout: "shell-floating-clean.qml"
    // property string activeLayout: "shell-floating.qml"
    // property string activeLayout: "shell-coverflow.qml"
    // property string activeLayout: "shell-bottom-dock.qml"
    // property string activeLayout: "shell-classic.qml"

    Loader {
        active: true
        source: Qt.resolvedUrl(root.activeLayout)
    }
}
