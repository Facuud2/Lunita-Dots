pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    function run(cmd) {
        Quickshell.execDetached(["bash", "-c", cmd]);
    }
}
