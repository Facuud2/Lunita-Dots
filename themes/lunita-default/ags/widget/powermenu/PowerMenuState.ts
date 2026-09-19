import { createState } from "ags"
import { createPoll } from "ags/time"
import { execAsync } from "ags/process"
import { readFile } from "ags/file"
import GLib from "gi://GLib?version=2.0"
import Gio from "gi://Gio?version=2.0"
import {
  volumeState,
  fetchVolume,
  setSystemVolume,
  toggleSystemMute,
  micState,
  fetchMic,
  setSystemMicVolume,
  toggleSystemMicMute,
  MicState,
} from "../island/services"

export {
  volumeState,
  fetchVolume,
  setSystemVolume,
  toggleSystemMute,
  micState,
  fetchMic,
  setSystemMicVolume,
  toggleSystemMicMute,
  MicState,
}

// ── 1. Visibilidad y Monitor Activo ───────────────────────────────────────────
export const [powermenuOpen, setPowermenuOpen] = createState(false)
export const [activePowerMenuMonitor, setActivePowerMenuMonitor] = createState<string | null>(null)
export const [panelAnimClass, setPanelAnimClass] = createState("pm-panel-enter")

let isClosing = false
export function isPowerMenuClosing(): boolean {
  return isClosing
}

export async function openPowerMenu(preferredMonitor?: string) {
  if (activePowerMenuMonitor.peek() !== null && !isClosing) return

  // Refrescar volumen y micrófono de inmediato para sincronizar al 100% con hardware
  fetchVolume().catch(() => {})
  fetchMic().catch(() => {})

  let targetMon = preferredMonitor
  if (!targetMon) {
    try {
      const wsOut = await execAsync("hyprctl activeworkspace -j")
      const wsJson = JSON.parse(wsOut)
      targetMon = wsJson?.monitor || "DP-1"
    } catch {
      try {
        const out = await execAsync("hyprctl monitors -j")
        const list = JSON.parse(out)
        const focused = list.find((m: any) => m.focused)
        targetMon = focused?.name || "DP-1"
      } catch {
        targetMon = "DP-1"
      }
    }
  }

  isClosing = false
  setPanelAnimClass("pm-panel-enter")
  if (activePowerMenuMonitor.peek() === targetMon) {
    setActivePowerMenuMonitor(null)
  }
  setActivePowerMenuMonitor(targetMon)
  setPowermenuOpen(true)
}

export function closePowerMenu() {
  if (isClosing) return
  if (activePowerMenuMonitor.peek() === null) return

  isClosing = true
  setPanelAnimClass("pm-panel-leave")

  GLib.timeout_add(GLib.PRIORITY_DEFAULT, 200, () => {
    setActivePowerMenuMonitor(null)
    setPowermenuOpen(false)
    setPanelAnimClass("pm-panel-enter")
    isClosing = false
    return GLib.SOURCE_REMOVE
  })
}

export function togglePowerMenu() {
  if (activePowerMenuMonitor.peek() !== null) {
    closePowerMenu()
  } else {
    openPowerMenu()
  }
}

// ── 2. Uptime del Sistema (desde /proc/uptime) ─────────────────────────────────
function formatUptime(seconds: number): string {
  const days = Math.floor(seconds / 86400)
  const hours = Math.floor((seconds % 86400) / 3600)
  const minutes = Math.floor((seconds % 3600) / 60)

  if (days > 0) {
    return `up ${days}d ${hours}h`
  }
  if (hours > 0) {
    return `up ${hours} ${hours === 1 ? "hour" : "hours"} ${minutes} min`
  }
  return `up ${minutes} minutes`
}

export const uptimeState = createPoll("up 0 minutes", 5000, () => {
  try {
    const content = readFile("/proc/uptime")
    const sec = parseFloat(content.split(/\s+/)[0]) || 0
    return formatUptime(sec)
  } catch {
    return "up 0 minutes"
  }
})

// ── 3. Uso de Disco / (vía Gio query_filesystem_info nativo) ───────────────────
export const diskUsageState = createPoll({ usedPerc: 0, totalGb: 0, usedGb: 0 }, 10000, () => {
  try {
    const f = Gio.File.new_for_path("/")
    const info = f.query_filesystem_info("filesystem::size,filesystem::free", null)
    const size = info.get_attribute_uint64("filesystem::size")
    const free = info.get_attribute_uint64("filesystem::free")
    const used = size - free
    const usedPerc = size > 0 ? Math.min(100, Math.max(0, Math.round((used / size) * 100))) : 0
    const totalGb = Math.round(size / (1024 * 1024 * 1024))
    const usedGb = Math.round(used / (1024 * 1024 * 1024))
    return { usedPerc, totalGb, usedGb }
  } catch {
    return { usedPerc: 0, totalGb: 0, usedGb: 0 }
  }
})
// ── 4. Control de Volumen y Micrófono importados desde island/services ──────
// ── 5. Datos de Sistema (Arch Fetch) ──────────────────────────────────────────
export interface FetchInfo {
  user: string
  host: string
  distro: string
  init: string
  pkgs: number
  shell: string
}

let cachedFetch: FetchInfo | null = null

export function getSystemFetch(): FetchInfo {
  if (cachedFetch) return cachedFetch

  const user = GLib.get_user_name() || "facuud2"
  const host = GLib.get_host_name() || "facuud2"

  let distro = "Arch Linux"
  try {
    const osRel = readFile("/etc/os-release")
    const match = osRel.match(/PRETTY_NAME="?([^"\n]+)"?/)
    if (match) distro = match[1]
  } catch {}

  let pkgs = 1000
  try {
    const dir = Gio.File.new_for_path("/var/lib/pacman/local")
    const enumerator = dir.enumerate_children("standard::name", Gio.FileQueryInfoFlags.NONE, null)
    let count = 0
    while (enumerator.next_file(null) !== null) {
      count++
    }
    if (count > 0) pkgs = count
  } catch {}

  const shell = (GLib.getenv("SHELL") || "/bin/zsh").split("/").pop() || "zsh"

  cachedFetch = {
    user,
    host,
    distro,
    init: "systemd",
    pkgs,
    shell,
  }
  return cachedFetch
}

// ── 6. Avatar del Usuario ─────────────────────────────────────────────────────
export function getUserAvatar(): string {
  const home = GLib.get_home_dir()
  const customPaths = [
    `${home}/.face`,
    `${home}/.face.icon`,
    `${home}/.config/ags/assets/avatar.png`,
    `/mnt/Desarrollo/Lunita-Dots/ags/assets/avatar.png`,
  ]

  for (const path of customPaths) {
    if (GLib.file_test(path, GLib.FileTest.EXISTS)) {
      return path
    }
  }

  return `${home}/.config/ags/assets/avatar.png`
}

export function getDefaultCover(): string {
  const home = GLib.get_home_dir()
  const paths = [
    `${home}/.config/ags/assets/default_cover.png`,
    `/mnt/Desarrollo/Lunita-Dots/ags/assets/default_cover.png`,
  ]
  for (const p of paths) {
    if (GLib.file_test(p, GLib.FileTest.EXISTS)) return p
  }
  return ""
}
