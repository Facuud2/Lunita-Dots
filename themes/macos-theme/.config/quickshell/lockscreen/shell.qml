import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
    id: lockShellRoot

    LockState {
        id: globalLockState

        onUnlockSuccess: {
            rootLock.locked = false;
            let home = Quickshell.env("HOME") || "";
            Quickshell.execDetached(["quickshell", "kill", "-p", home + "/.config/quickshell/lockscreen"]);
            Qt.quit();
        }
    }

    WlSessionLock {
        id: rootLock
        locked: true

        surface: Component {
            WlSessionLockSurface {
                id: lockSurface

                LockView {
                    lockState: globalLockState
                }
            }
        }
    }
}
