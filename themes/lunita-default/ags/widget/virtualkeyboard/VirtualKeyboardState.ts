import { createState } from "ags"
import { execAsync } from "ags/process"
import GLib from "gi://GLib?version=2.0"

export const [keyboardVisible, setKeyboardVisible] = createState(false)

const SCRIPT_PATH = `${GLib.get_home_dir()}/.config/hypr/scripts/virtual_keyboard.sh`

export async function checkKeyboardStatus(): Promise<boolean> {
  try {
    const res = await execAsync(`${SCRIPT_PATH} status`)
    const isVis = res.trim() === "visible"
    setKeyboardVisible(isVis)
    return isVis
  } catch {
    return false
  }
}

export async function toggleVirtualKeyboard() {
  try {
    const nextVis = !keyboardVisible.peek()
    setKeyboardVisible(nextVis)
    await execAsync(`${SCRIPT_PATH} toggle`)
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 300, () => {
      checkKeyboardStatus()
      return GLib.SOURCE_REMOVE
    })
  } catch (err) {
    console.error("[VirtualKeyboard] Error toggling keyboard:", err)
  }
}

export async function openVirtualKeyboard() {
  try {
    await execAsync(`${SCRIPT_PATH} show`)
    setKeyboardVisible(true)
  } catch (err) {
    console.error("[VirtualKeyboard] Error opening keyboard:", err)
  }
}

export async function closeVirtualKeyboard() {
  try {
    await execAsync(`${SCRIPT_PATH} hide`)
    setKeyboardVisible(false)
  } catch (err) {
    console.error("[VirtualKeyboard] Error closing keyboard:", err)
  }
}

export function initVirtualKeyboardDaemon() {
  execAsync(`${SCRIPT_PATH} daemon`).catch(() => {})
  checkKeyboardStatus().catch(() => {})
}
