pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    function run(cmd: string): void {
        Quickshell.execDetached(["bash", "-c", cmd]);
    }
}
