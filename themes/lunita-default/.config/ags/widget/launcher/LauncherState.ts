import { createState } from "ags"
import { execAsync } from "ags/process"
import Gio from "gi://Gio"
import GLib from "gi://GLib"
import { Gdk } from "ags/gtk4"

// ── Active monitor & workspace tracking ───────────────────────────────────────
// Holds the connector name (e.g. "DP-1" or "HDMI-A-1") of the currently focused monitor,
// or null when the launcher is closed.
export const [activeLauncherMonitor, setActiveLauncherMonitor] = createState<string | null>(null)
export const [activeLauncherWorkspace, setActiveLauncherWorkspace] = createState<string | number>(1)

export const getActiveLauncherWorkspace = (): string | number => {
  return activeLauncherWorkspace.peek() ?? 1
}

export function getWorkspaceRule(ws: string | number): string {
  if (ws === null || ws === undefined || ws === "") return ""
  if (typeof ws === "number") {
    if (ws > 0) return `[workspace ${ws}] `
    return ""
  }
  const parsed = parseInt(ws, 10)
  if (!isNaN(parsed) && parsed > 0) {
    return `[workspace ${parsed}] `
  }
  return `[workspace name:${ws}] `
}

export function launchOnActiveWorkspace(cmd: string) {
  const ws = getActiveLauncherWorkspace()
  const rule = getWorkspaceRule(ws)
  const fullCmd = `${rule}${cmd}`
  const hyprLua = `hl.dsp.exec_cmd([=[${fullCmd}]=])`

  execAsync(["hyprctl", "dispatch", hyprLua]).catch(() => {
    execAsync(["bash", "-c", `${cmd} &`]).catch((err) => {
      console.error(`[AppLauncher] Failed to launch ${cmd}:`, err)
    })
  })
}

// Keep launcherOpen as boolean for components that check it
export const [launcherOpen, setLauncherOpen] = createState(false)

// ── Panel Animation Class ─────────────────────────────────────────────────────
export const [panelAnimClass, setPanelAnimClass] = createState("al-panel al-panel-quick")
let bounceSeq = 0
let openSeq = 0
let isClosing = false
let closeTimeoutId: any = null
let lastOpenTime = 0

export const isLauncherClosing = () => isClosing
export const getLauncherOpenTime = () => lastOpenTime

export function triggerTabBounce() {
  if (isClosing) return
  bounceSeq++
  const suffix = bounceSeq % 2 === 1 ? "al-bounce-odd" : "al-bounce-even"
  setPanelAnimClass(`al-panel al-panel-quick ${suffix}`)
}

interface FocusedInfo {
  monitor: string
  workspace: string | number
}

async function getFocusedInfo(): Promise<FocusedInfo> {
  try {
    const wsOut = await execAsync("hyprctl activeworkspace -j")
    const wsJson = JSON.parse(wsOut)
    if (wsJson) {
      const mon = wsJson.monitor || "DP-1"
      const ws = wsJson.id ?? wsJson.name ?? 1
      return { monitor: mon, workspace: ws }
    }
  } catch {
    try {
      const out = await execAsync("hyprctl monitors -j")
      const list = JSON.parse(out)
      const focused = list.find((m: any) => m.focused)
      if (focused) {
        const mon = focused.name || "DP-1"
        const ws = focused.activeWorkspace?.id ?? focused.activeWorkspace?.name ?? 1
        return { monitor: mon, workspace: ws }
      }
    } catch {}
  }
  return { monitor: "DP-1", workspace: 1 }
}

export const openLauncher = async () => {
  if (closeTimeoutId !== null) {
    clearTimeout(closeTimeoutId)
    closeTimeoutId = null
  }
  isClosing = false
  lastOpenTime = Date.now()

  const focusedInfo = await getFocusedInfo()
  setActiveLauncherWorkspace(focusedInfo.workspace)

  lastHoveredIndex = null
  setActiveTab("apps")
  setSearchMode(false)
  setSearchQuery("")
  setSearchSelectedIndex(0)
  setSelectedIndex(0)
  bounceSeq = 0
  openSeq++
  const suffix = openSeq % 2 === 1 ? "al-open-odd" : "al-open-even"
  setPanelAnimClass(`al-panel al-panel-quick ${suffix}`)

  if (activeLauncherMonitor.peek() === focusedInfo.monitor) {
    setActiveLauncherMonitor(null)
  }
  setActiveLauncherMonitor(focusedInfo.monitor)
  setLauncherOpen(true)
}

export const closeLauncher = () => {
  if (isClosing) return
  if (activeLauncherMonitor.peek() === null) return

  isClosing = true
  setPanelAnimClass("al-panel al-closing")

  closeTimeoutId = setTimeout(() => {
    setSearchMode(false)
    setSearchQuery("")
    setActiveLauncherMonitor(null)
    setLauncherOpen(false)
    setPanelAnimClass("al-panel al-panel-quick")
    isClosing = false
    closeTimeoutId = null
  }, 140)
}

export const toggleLauncher = async () => {
  if (isClosing) {
    // If it was in the middle of closing, cancel closing and immediately reopen
    if (closeTimeoutId !== null) {
      clearTimeout(closeTimeoutId)
      closeTimeoutId = null
    }
    isClosing = false
    await openLauncher()
    return
  }
  if (activeLauncherMonitor.peek() !== null) {
    closeLauncher()
  } else {
    await openLauncher()
  }
}

// ── Search Mode State ─────────────────────────────────────────────────────────
export const [searchMode, setSearchMode] = createState(false)
export const [searchQuery, setSearchQuery] = createState("")
export const [searchSelectedIndex, setSearchSelectedIndex] = createState(0)

export function openSearch(initialQuery: string = "") {
  if (isClosing) return
  setSearchMode(true)
  setSearchQuery(initialQuery)
  setSearchSelectedIndex(0)
  setPanelAnimClass("al-panel al-panel-search")
}

export function closeSearch() {
  if (isClosing) return
  setSearchMode(false)
  setSearchQuery("")
  setSearchSelectedIndex(0)
  setPanelAnimClass("al-panel al-panel-quick")
}

// ── Installed Apps for Search ─────────────────────────────────────────────────
export interface AppItem {
  id: string
  name: string
  displayName: string
  description: string
  executable: string
  gicon: Gio.Icon | null
  appInfo: Gio.AppInfo
}

let cachedApps: AppItem[] | null = null

export function getInstalledApps(): AppItem[] {
  if (cachedApps) return cachedApps
  try {
    const all = Gio.AppInfo.get_all()
    cachedApps = all
      .filter((app) => app.should_show())
      .map((app) => {
        const gicon = app.get_icon()
        return {
          id: app.get_id() || "",
          name: app.get_name() || "",
          displayName: app.get_display_name() || app.get_name() || "",
          description: app.get_description() || "",
          executable: app.get_executable() || "",
          gicon: gicon || null,
          appInfo: app,
        }
      })
      .sort((a, b) => a.displayName.localeCompare(b.displayName))
    return cachedApps
  } catch {
    return []
  }
}

export function getFilteredApps(query: string): AppItem[] {
  const apps = getInstalledApps()
  const q = query.trim().toLowerCase()
  if (!q) return apps
  return apps.filter(
    (a) =>
      a.name.toLowerCase().includes(q) ||
      a.displayName.toLowerCase().includes(q) ||
      a.executable.toLowerCase().includes(q) ||
      a.description.toLowerCase().includes(q)
  )
}

export function launchAppItem(app: AppItem) {
  closeLauncher()

  const ws = getActiveLauncherWorkspace()
  const rule = getWorkspaceRule(ws)

  // 1. Primary launch: gtk-launch by desktop ID with Hyprland workspace dispatch
  if (app.id) {
    const desktopId = app.id.endsWith(".desktop") ? app.id : `${app.id}.desktop`
    const hyprLua = `hl.dsp.exec_cmd([=[${rule}gtk-launch ${desktopId}]=])`
    execAsync(["hyprctl", "dispatch", hyprLua])
      .catch(() => {
        fallbackLaunch(app, ws)
      })
    return
  }

  fallbackLaunch(app, ws)
}

function fallbackLaunch(app: AppItem, ws?: string | number) {
  const currentWs = ws ?? getActiveLauncherWorkspace()
  const rule = getWorkspaceRule(currentWs)

  // Clean command line
  let cleanCmd = (app.executable || "").replace(/%[a-zA-Z]/g, "").trim()
  try {
    const cmdline = app.appInfo?.get_commandline?.()
    if (cmdline) {
      cleanCmd = cmdline.replace(/%[a-zA-Z]/g, "").trim()
    }
  } catch {}

  if (cleanCmd) {
    const hyprLua = `hl.dsp.exec_cmd([=[${rule}${cleanCmd}]=])`
    execAsync(["hyprctl", "dispatch", hyprLua]).catch(() => {
      execAsync(["bash", "-c", `${cleanCmd} &`]).catch((err) => {
        console.error(`[AppLauncher] Failed to launch ${cleanCmd}:`, err)
      })
    })
    return
  }

  // Fallback: appInfo.launch with Gdk display context
  try {
    const display = Gdk.Display.get_default()
    const ctx = display?.get_app_launch_context() || null
    if (app.appInfo) {
      const ok = app.appInfo.launch([], ctx)
      if (ok) return
    }
  } catch (err) {
    console.warn("[AppLauncher] appInfo.launch error:", err)
  }
}

export function launchCurrentSearchSelection() {
  const currentList = getFilteredApps(searchQuery.peek())
  if (currentList.length === 0) return
  const cur = Math.max(0, Math.min(searchSelectedIndex.peek(), currentList.length - 1))
  const selected = currentList[cur]
  if (selected) {
    launchAppItem(selected)
  }
}

export function navigateSearch(delta: number) {
  const currentList = getFilteredApps(searchQuery.peek())
  const count = currentList.length
  if (count === 0) return
  const cur = searchSelectedIndex.peek()
  const next = (cur + delta + count) % count
  setSearchSelectedIndex(next)
}

// ── Active tab ────────────────────────────────────────────────────────────────
export type LauncherTab = "apps" | "links"
export const [activeTab, setActiveTab] = createState<LauncherTab>("apps")

export function switchTab(tab: LauncherTab) {
  if (activeTab.peek() === tab && !searchMode.peek()) return
  lastHoveredIndex = null
  setSearchMode(false)
  setActiveTab(tab)
  setSelectedIndex(0)
  triggerTabBounce()
}

// ── Selected cell index (keyboard navigation & hover) ─────────────────────────
export const [selectedIndex, setSelectedIndex] = createState(0)

// Tracks which cell the mouse cursor is currently over.
// If the mouse stays on this cell, keyboard arrows have absolute priority.
// The mouse will only change the selection if it moves to a DIFFERENT cell.
export let lastHoveredIndex: number | null = null

export function onCellHover(index: number) {
  if (lastHoveredIndex !== index) {
    lastHoveredIndex = index
    setSelectedIndex(index)
  }
}

export function onCellLeave(index: number) {
  if (lastHoveredIndex === index) {
    lastHoveredIndex = null
  }
}

export function getItemCount(_tab: LauncherTab): number {
  return 6 // "apps" and "links" both have 6 items
}

// ── Action dispatch ───────────────────────────────────────────────────────────
type ActionHandler = (index: number) => void
let currentActionHandler: ActionHandler | null = null

export function registerActionHandler(handler: ActionHandler) {
  currentActionHandler = handler
}

export function executeSelected() {
  if (currentActionHandler) {
    currentActionHandler(selectedIndex.peek())
  }
}
