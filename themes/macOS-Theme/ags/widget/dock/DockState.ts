import { createState } from "ags"
import { execAsync } from "ags/process"
import Gio from "gi://Gio?version=2.0"
import GLib from "gi://GLib?version=2.0"

declare const SRC: string

export interface HyprlandClient {
  address: string
  mapped: boolean
  hidden: boolean
  at: [number, number]
  size: [number, number]
  workspace: { id: number; name: string }
  floating: boolean
  monitor: number
  class: string
  title: string
  initialClass: string
  initialTitle: string
  pid: number
  xwayland: boolean
  pinned: boolean
  fullscreen: number
  fullscreenClient: number
  grouped: any[]
  tags: string[]
  swallowing: string
  focusHistoryID: number
}

export interface PinnedApp {
  id: string
  name: string
  iconFile?: string
  fallbackIcon: string
  cmd: string
  matchClasses: string[]
}

export interface RunningApp {
  id: string
  name: string
  icon: string
  iconFile?: string
  class: string
  address: string
  count: number
}

export interface InstalledAppItem {
  id: string
  name: string
  displayName: string
  description: string
  executable: string
  iconName: string
  iconFile?: string
  cmd: string
  matchClasses: string[]
}

// ── Complete Pinned Applications (Defaults) ───────────────────────────────────
export const DEFAULT_PINNED_APPS: PinnedApp[] = [
  {
    id: "finder",
    name: "Finder",
    iconFile: "finder.svg",
    fallbackIcon: "system-file-manager",
    cmd: "dolphin",
    matchClasses: ["dolphin", "org.kde.dolphin", "nautilus", "thunar"],
  },
  {
    id: "launchpad",
    name: "Launchpad",
    iconFile: "launchpad.svg",
    fallbackIcon: "view-app-grid-symbolic",
    cmd: "rofi -show drun",
    matchClasses: [],
  },
  {
    id: "safari",
    name: "Safari",
    iconFile: "safari.svg",
    fallbackIcon: "web-browser",
    cmd: "zen-browser || firefox || google-chrome-stable",
    matchClasses: ["zen", "zen-alpha", "zen-browser", "firefox", "google-chrome", "chromium", "brave-browser"],
  },
  {
    id: "messages",
    name: "Mensajes",
    iconFile: "messages.svg",
    fallbackIcon: "chat",
    cmd: "telegram-desktop || discord || vesktop",
    matchClasses: ["telegram", "telegram-desktop", "discord", "vesktop"],
  },
  {
    id: "mail",
    name: "Mail",
    iconFile: "mail.svg",
    fallbackIcon: "mail-client",
    cmd: "thunderbird || zen-browser https://mail.google.com",
    matchClasses: ["thunderbird"],
  },
  {
    id: "maps",
    name: "Mapas",
    iconFile: "maps.svg",
    fallbackIcon: "maps",
    cmd: "zen-browser https://maps.google.com",
    matchClasses: [],
  },
  {
    id: "photos",
    name: "Fotos",
    iconFile: "photos.svg",
    fallbackIcon: "image-viewer",
    cmd: "gwenview || loupe || eog",
    matchClasses: ["gwenview", "loupe", "eog"],
  },
  {
    id: "facetime",
    name: "FaceTime",
    iconFile: "facetime.svg",
    fallbackIcon: "camera-video",
    cmd: "weylus || cheese || kamoso",
    matchClasses: ["weylus", "cheese"],
  },
  {
    id: "phone",
    name: "Teléfono",
    iconFile: "phone.svg",
    fallbackIcon: "call-start",
    cmd: "whatsapp-for-linux || zen-browser https://web.whatsapp.com",
    matchClasses: ["whatsapp", "whatsapp-for-linux"],
  },
  {
    id: "calendar",
    name: "Calendario",
    iconFile: "calendar.svg",
    fallbackIcon: "x-office-calendar",
    cmd: "gnome-calendar || korganizer || zen-browser https://calendar.google.com",
    matchClasses: ["gnome-calendar", "korganizer"],
  },
  {
    id: "contacts",
    name: "Contactos",
    iconFile: "contacts.svg",
    fallbackIcon: "x-office-address-book",
    cmd: "gnome-contacts || zen-browser https://contacts.google.com",
    matchClasses: ["gnome-contacts"],
  },
  {
    id: "reminders",
    name: "Recordatorios",
    iconFile: "reminders.svg",
    fallbackIcon: "checkbox",
    cmd: "zen-browser https://keep.google.com",
    matchClasses: [],
  },
  {
    id: "notes",
    name: "Notas",
    iconFile: "notes.svg",
    fallbackIcon: "accessories-text-editor",
    cmd: "obsidian || notepadqq || kate",
    matchClasses: ["obsidian", "notepadqq", "kate"],
  },
  {
    id: "appletv",
    name: "TV",
    iconFile: "appletv.svg",
    fallbackIcon: "video-player",
    cmd: "mpv || vlc || celluloid",
    matchClasses: ["mpv", "vlc", "celluloid"],
  },
  {
    id: "music",
    name: "Música",
    iconFile: "music.svg",
    fallbackIcon: "multimedia-audio-player",
    cmd: "spotify || cider || amberol",
    matchClasses: ["spotify", "Spotify", "cider", "apple-music", "amberol"],
  },
  {
    id: "code",
    name: "Visual Studio Code",
    iconFile: "code.svg",
    fallbackIcon: "text-editor",
    cmd: "antigravity || code || vscodium",
    matchClasses: ["antigravity", "code", "Code", "vscodium", "neovim", "cursor"],
  },
  {
    id: "appstore",
    name: "App Store",
    iconFile: "appstore.svg",
    fallbackIcon: "software-store",
    cmd: "discover || gnome-software || pamac-manager || rofi -show drun",
    matchClasses: ["discover", "gnome-software", "pamac-manager"],
  },
  {
    id: "terminal",
    name: "Terminal",
    iconFile: "terminal.svg",
    fallbackIcon: "utilities-terminal",
    cmd: "kitty",
    matchClasses: ["kitty", "alacritty", "foot", "org.gnome.Terminal", "wezterm"],
  },
  {
    id: "settings",
    name: "Ajustes del Sistema",
    iconFile: "settings.svg",
    fallbackIcon: "preferences-system",
    cmd: "systemsettings || gnome-control-center",
    matchClasses: ["systemsettings", "gnome-control-center", "pavucontrol", "lxappearance"],
  },
]

// ── Right Stacks (After Divider) ─────────────────────────────────────────────
export const RIGHT_STACK_APPS: PinnedApp[] = [
  {
    id: "shortcuts",
    name: "Atajos",
    iconFile: "shortcuts.svg",
    fallbackIcon: "system-run",
    cmd: "rofi -show drun",
    matchClasses: [],
  },
  {
    id: "keychain",
    name: "Contraseñas y Llaveros",
    iconFile: "keychain.svg",
    fallbackIcon: "dialog-password",
    cmd: "keepassxc || seahorse || bitwarden",
    matchClasses: ["keepassxc", "seahorse", "bitwarden"],
  },
]

// ── Persistence: Load & Save Pinned Apps ──────────────────────────────────────
const CONFIG_DIR = `${GLib.get_user_config_dir()}/lunita`
const CONFIG_FILE = `${CONFIG_DIR}/dock-pinned.json`

function loadPinnedApps(): PinnedApp[] {
  try {
    const file = Gio.File.new_for_path(CONFIG_FILE)
    if (file.query_exists(null)) {
      const [, contents] = file.load_contents(null)
      const decoder = new TextDecoder("utf-8")
      const json = JSON.parse(decoder.decode(contents))
      if (Array.isArray(json) && json.length > 0) {
        return json
      }
    }
  } catch (e) {
    console.warn("[DockState] No se pudo leer la configuración de apps ancladas:", e)
  }
  return DEFAULT_PINNED_APPS
}

export function savePinnedApps(apps: PinnedApp[]) {
  try {
    const dir = Gio.File.new_for_path(CONFIG_DIR)
    if (!dir.query_exists(null)) {
      dir.make_directory_with_parents(null)
    }
    const file = Gio.File.new_for_path(CONFIG_FILE)
    const jsonStr = JSON.stringify(apps, null, 2)
    file.replace_contents(
      new TextEncoder().encode(jsonStr),
      null,
      false,
      Gio.FileCreateFlags.REPLACE_DESTINATION,
      null
    )
  } catch (e) {
    console.error("[DockState] Error al guardar apps ancladas:", e)
  }
}

// ── Reactive States ──────────────────────────────────────────────────────────
export const [pinnedApps, setPinnedApps] = createState<PinnedApp[]>(loadPinnedApps())
export const [clients, setClients] = createState<HyprlandClient[]>([])
export const [activeWindowAddress, setActiveWindowAddress] = createState<string>("")
export const [trashCount, setTrashCount] = createState<number>(0)
export const [hoveredAppId, setHoveredAppId] = createState<string | null>(null)

// ── Add App Modal States ──────────────────────────────────────────────────────
export const [isAddAppModalOpen, setAddAppModalOpen] = createState<boolean>(false)
export const [addAppSearchQuery, setAddAppSearchQuery] = createState<string>("")
export const [addAppSelectedIndex, setAddAppSelectedIndex] = createState<number>(0)

export function openAddAppModal() {
  setAddAppSearchQuery("")
  setAddAppSelectedIndex(0)
  setAddAppModalOpen(true)
}

export function closeAddAppModal() {
  setAddAppModalOpen(false)
  setAddAppSearchQuery("")
}

export function toggleAddAppModal() {
  if (isAddAppModalOpen.peek()) {
    closeAddAppModal()
  } else {
    openAddAppModal()
  }
}

// ── Dock Pin/Unpin Management ─────────────────────────────────────────────────
export function pinApp(app: PinnedApp) {
  const current = pinnedApps.peek()
  if (current.some((p) => p.id === app.id)) return
  const updated = [...current, app]
  setPinnedApps(updated)
  savePinnedApps(updated)
}

export function unpinApp(appId: string) {
  const current = pinnedApps.peek()
  const updated = current.filter((p) => p.id !== appId)
  setPinnedApps(updated)
  savePinnedApps(updated)
}

export function isAppPinned(appId: string): boolean {
  return pinnedApps.peek().some((p) => p.id === appId)
}

export function pinRunningApp(running: RunningApp) {
  const newPinned: PinnedApp = {
    id: running.class.toLowerCase().replace(/[^a-z0-9_-]/g, "-") || `app-${Date.now()}`,
    name: running.name || running.class,
    iconFile: running.iconFile,
    fallbackIcon: running.icon || "application-x-executable",
    cmd: `gtk-launch ${running.class} || ${running.class}`,
    matchClasses: [running.class.toLowerCase()],
  }
  pinApp(newPinned)
}

// ── Get Asset Path for an Icon ────────────────────────────────────────────────
export function getIconAssetPath(filename: string): string {
  const home = GLib.getenv("HOME") || ""
  const candidate1 = `${home}/.config/ags/assets/icons/${filename}`
  if (GLib.file_test(candidate1, GLib.FileTest.EXISTS)) return candidate1

  try {
    if (typeof SRC !== "undefined" && SRC) {
      const candidate2 = `${SRC}/assets/icons/${filename}`
      if (GLib.file_test(candidate2, GLib.FileTest.EXISTS)) return candidate2
    }
  } catch {}

  const candidate3 = `/mnt/Desarrollo/Lunita-Dots/themes/macOS-Theme/ags/assets/icons/${filename}`
  if (GLib.file_test(candidate3, GLib.FileTest.EXISTS)) return candidate3

  return candidate1
}

// ── Resolve System App Icons ──────────────────────────────────────────────────
const iconCache = new Map<string, { icon: string; iconFile?: string }>()

export function resolveAppIconInfo(appClass: string, fallbackIcon: string = "application-x-executable"): { icon: string; iconFile?: string } {
  if (!appClass) return { icon: fallbackIcon }
  const lower = appClass.toLowerCase()
  if (iconCache.has(lower)) return iconCache.get(lower)!

  if (lower.includes("zen") || lower.includes("firefox") || lower.includes("chrome") || lower.includes("chromium") || lower.includes("brave")) {
    const res = { icon: "web-browser", iconFile: getIconAssetPath("safari.svg") }
    iconCache.set(lower, res)
    return res
  }
  if (lower.includes("kitty") || lower.includes("terminal") || lower.includes("alacritty") || lower.includes("foot") || lower.includes("wezterm")) {
    const res = { icon: "utilities-terminal", iconFile: getIconAssetPath("terminal.svg") }
    iconCache.set(lower, res)
    return res
  }
  if (lower.includes("dolphin") || lower.includes("nautilus") || lower.includes("thunar") || lower.includes("nemo") || lower.includes("pcmanfm")) {
    const res = { icon: "system-file-manager", iconFile: getIconAssetPath("finder.svg") }
    iconCache.set(lower, res)
    return res
  }
  if (lower.includes("code") || lower.includes("antigravity") || lower.includes("cursor") || lower.includes("vscodium")) {
    const res = { icon: "visual-studio-code", iconFile: getIconAssetPath("code.svg") }
    iconCache.set(lower, res)
    return res
  }
  if (lower.includes("spotify") || lower.includes("cider") || lower.includes("music") || lower.includes("amberol") || lower.includes("rhythmbox")) {
    const res = { icon: "spotify-client", iconFile: getIconAssetPath("music.svg") }
    iconCache.set(lower, res)
    return res
  }
  if (lower.includes("telegram") || lower.includes("discord") || lower.includes("vesktop") || lower.includes("signal") || lower.includes("slack")) {
    const res = { icon: "telegram", iconFile: getIconAssetPath("messages.svg") }
    iconCache.set(lower, res)
    return res
  }
  if (lower.includes("setting") || lower.includes("pavucontrol") || lower.includes("control-center") || lower.includes("systemsettings")) {
    const res = { icon: "preferences-system", iconFile: getIconAssetPath("settings.svg") }
    iconCache.set(lower, res)
    return res
  }
  if (lower.includes("thunderbird") || lower.includes("mail") || lower.includes("evolution") || lower.includes("geary")) {
    const res = { icon: "mail-client", iconFile: getIconAssetPath("mail.svg") }
    iconCache.set(lower, res)
    return res
  }
  if (lower.includes("obsidian") || lower.includes("notepad") || lower.includes("kate") || lower.includes("gedit") || lower.includes("text-editor")) {
    const res = { icon: "accessories-text-editor", iconFile: getIconAssetPath("notes.svg") }
    iconCache.set(lower, res)
    return res
  }
  if (lower.includes("mpv") || lower.includes("vlc") || lower.includes("celluloid") || lower.includes("totem")) {
    const res = { icon: "video-player", iconFile: getIconAssetPath("appletv.svg") }
    iconCache.set(lower, res)
    return res
  }
  if (lower.includes("gwenview") || lower.includes("loupe") || lower.includes("eog") || lower.includes("shotwell") || lower.includes("pix")) {
    const res = { icon: "image-viewer", iconFile: getIconAssetPath("photos.svg") }
    iconCache.set(lower, res)
    return res
  }

  try {
    const apps = Gio.AppInfo.get_all()
    for (const app of apps) {
      const id = app.get_id()?.toLowerCase() || ""
      const exec = app.get_executable()?.toLowerCase() || ""
      const name = app.get_name()?.toLowerCase() || ""

      if (id.includes(lower) || exec.includes(lower) || name === lower) {
        const icon = app.get_icon()?.to_string() || ""
        if (icon) {
          const res = { icon }
          iconCache.set(lower, res)
          return res
        }
      }
    }
  } catch {}

  const res = { icon: lower }
  iconCache.set(lower, res)
  return res
}

// ── Check if an App is Running in Hyprland ────────────────────────────────────
export function isAppRunning(pinned: PinnedApp, clientList: HyprlandClient[]): boolean {
  if (!pinned.matchClasses || pinned.matchClasses.length === 0) return false
  return clientList.some((c: HyprlandClient) =>
    pinned.matchClasses.some(
      (m: string) =>
        c.class.toLowerCase().includes(m.toLowerCase()) ||
        c.initialClass.toLowerCase().includes(m.toLowerCase())
    )
  )
}

export function getMatchingClients(pinned: PinnedApp): HyprlandClient[] {
  const currentClients = clients.peek()
  if (!pinned.matchClasses || pinned.matchClasses.length === 0) return []
  return currentClients.filter((c: HyprlandClient) =>
    pinned.matchClasses.some(
      (m: string) =>
        c.class.toLowerCase().includes(m.toLowerCase()) ||
        c.initialClass.toLowerCase().includes(m.toLowerCase())
    )
  )
}

// ── Get Running Unpinned Apps ─────────────────────────────────────────────────
export function getRunningUnpinnedApps(
  pinnedList: PinnedApp[],
  clientList: HyprlandClient[]
): RunningApp[] {
  const map = new Map<string, RunningApp>()
  const allPinned = [...pinnedList, ...RIGHT_STACK_APPS]

  for (const c of clientList) {
    if (!c.mapped || c.class === "macos-dock" || c.class === "ags" || c.class === "hyprlock") continue

    const isPinned = allPinned.some((p: PinnedApp) =>
      p.matchClasses.some(
        (m: string) =>
          c.class.toLowerCase().includes(m.toLowerCase()) ||
          c.initialClass.toLowerCase().includes(m.toLowerCase())
      )
    )

    if (isPinned) continue

    const groupKey = c.class.toLowerCase() || c.initialClass.toLowerCase() || c.title
    if (!groupKey) continue

    if (map.has(groupKey)) {
      const existing = map.get(groupKey)!
      existing.count++
    } else {
      const appName = c.title ? c.title.split(" — ")[0].slice(0, 24) : c.class
      const iconInfo = resolveAppIconInfo(c.class)
      map.set(groupKey, {
        id: `running-${c.address}`,
        name: appName || c.class,
        icon: iconInfo.icon,
        iconFile: iconInfo.iconFile,
        class: c.class,
        address: c.address,
        count: 1,
      })
    }
  }

  return Array.from(map.values())
}

// ── App Launch & Focus Dispatch ───────────────────────────────────────────────
export function focusOrLaunchApp(pinned: PinnedApp) {
  const matching = getMatchingClients(pinned)
  if (matching.length > 0) {
    execAsync(["hyprctl", "dispatch", "focuswindow", `address:${matching[0].address}`]).catch(() => {
      execAsync(["bash", "-c", `${pinned.cmd} &`]).catch(() => {})
    })
  } else {
    execAsync(["bash", "-c", `${pinned.cmd} &`]).catch((e: unknown) => {
      console.error(`[Dock] Error al ejecutar ${pinned.cmd}:`, e)
    })
  }
}

export function launchNewInstance(pinned: PinnedApp) {
  execAsync(["bash", "-c", `${pinned.cmd} &`]).catch((e: unknown) => {
    console.error(`[Dock] Error al lanzar nueva instancia de ${pinned.cmd}:`, e)
  })
}

export function closeAppWindows(pinned?: PinnedApp, runningAddress?: string) {
  if (runningAddress) {
    execAsync(["hyprctl", "dispatch", "closewindow", `address:${runningAddress}`]).catch(() => {})
    return
  }

  if (pinned) {
    const matching = getMatchingClients(pinned)
    for (const c of matching) {
      execAsync(["hyprctl", "dispatch", "closewindow", `address:${c.address}`]).catch(() => {})
    }
  }
}

export function focusWindow(address: string) {
  execAsync(["hyprctl", "dispatch", "focuswindow", `address:${address}`]).catch((e: unknown) => {
    console.warn(`[Dock] No se pudo enfocar ventana ${address}:`, e)
  })
}

export function openDownloads() {
  execAsync(["bash", "-c", "dolphin ~/Descargas || dolphin ~/Downloads || xdg-open ~/Downloads &"]).catch(() => {})
}

export function openTrash() {
  execAsync(["bash", "-c", "dolphin trash:/// || nautilus trash:/// || xdg-open trash:/// &"]).catch(() => {})
}

export function emptyTrash() {
  execAsync(["bash", "-c", "rm -rf ~/.local/share/Trash/files/* ~/.local/share/Trash/info/* 2>/dev/null || true"])
    .then(() => {
      updateTrashCount()
    })
    .catch(() => {
      updateTrashCount()
    })
}

// ── Trash Monitor ─────────────────────────────────────────────────────────────
export function updateTrashCount() {
  try {
    const trashPath = `${GLib.get_user_data_dir()}/Trash/files`
    const dir = Gio.File.new_for_path(trashPath)
    if (!dir.query_exists(null)) {
      setTrashCount(0)
      return
    }
    const enumerator = dir.enumerate_children("standard::name", Gio.FileQueryInfoFlags.NONE, null)
    let count = 0
    while (enumerator.next_file(null) !== null) {
      count++
    }
    setTrashCount(count)
  } catch {
    setTrashCount(0)
  }
}

// ── Installed Apps for Add App Modal ──────────────────────────────────────────
let cachedInstalledApps: InstalledAppItem[] | null = null

export function getInstalledApps(): InstalledAppItem[] {
  if (cachedInstalledApps) return cachedInstalledApps
  try {
    const all = Gio.AppInfo.get_all()
    cachedInstalledApps = all
      .filter((app) => app.should_show())
      .map((app) => {
        const id = app.get_id() || ""
        const name = app.get_name() || ""
        const displayName = app.get_display_name() || name
        const description = app.get_description() || ""
        const executable = app.get_executable() || ""
        const iconName = app.get_icon()?.to_string() || "application-x-executable"
        const iconInfo = resolveAppIconInfo(executable || name, iconName)

        let cmd = ""
        if (id) {
          const desktopId = id.endsWith(".desktop") ? id : `${id}.desktop`
          cmd = `gtk-launch ${desktopId}`
        } else {
          cmd = executable
        }

        const matchClass1 = id.replace(".desktop", "").toLowerCase()
        const matchClass2 = executable.toLowerCase()
        const matchClass3 = name.toLowerCase()

        return {
          id: id || name.toLowerCase().replace(/\s+/g, "-"),
          name,
          displayName,
          description,
          executable,
          iconName: iconInfo.icon,
          iconFile: iconInfo.iconFile,
          cmd,
          matchClasses: Array.from(new Set([matchClass1, matchClass2, matchClass3].filter(Boolean))),
        }
      })
      .sort((a, b) => a.displayName.localeCompare(b.displayName))
    return cachedInstalledApps
  } catch {
    return []
  }
}

export function getFilteredInstalledApps(query: string): InstalledAppItem[] {
  const apps = getInstalledApps()
  const q = query.trim().toLowerCase()
  if (!q) return apps
  return apps.filter(
    (a) =>
      a.displayName.toLowerCase().includes(q) ||
      a.name.toLowerCase().includes(q) ||
      a.executable.toLowerCase().includes(q) ||
      a.description.toLowerCase().includes(q)
  )
}

export function pinInstalledApp(item: InstalledAppItem) {
  const pinned: PinnedApp = {
    id: item.id,
    name: item.displayName || item.name,
    iconFile: item.iconFile ? item.iconFile.split("/").pop() : undefined,
    fallbackIcon: item.iconName,
    cmd: item.cmd,
    matchClasses: item.matchClasses,
  }
  pinApp(pinned)
}

// ── Hyprland Socket2 & Clients Sync ───────────────────────────────────────────
let fetchDebounce: number | null = null

export async function fetchClients() {
  try {
    const out = await execAsync("hyprctl clients -j")
    const parsed = JSON.parse(out) as HyprlandClient[]
    setClients(parsed || [])

    const activeOut = await execAsync("hyprctl activewindow -j").catch(() => "{}")
    const activeJson = JSON.parse(activeOut)
    if (activeJson?.address) {
      setActiveWindowAddress(activeJson.address)
    }
  } catch {
    // Retain state on transient error
  }
}

function queueClientsFetch() {
  if (fetchDebounce !== null) GLib.source_remove(fetchDebounce)
  fetchDebounce = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 80, () => {
    fetchDebounce = null
    fetchClients()
    return GLib.SOURCE_REMOVE
  })
}

export function initHyprlandSocket() {
  fetchClients()
  updateTrashCount()

  const his = GLib.getenv("HYPRLAND_INSTANCE_SIGNATURE")
  const xdgRuntime = GLib.getenv("XDG_RUNTIME_DIR") || `/run/user/${GLib.get_user_data_dir()}`
  const socketPath = `${xdgRuntime}/hypr/${his}/.socket2.sock`

  try {
    const socketAddress = Gio.UnixSocketAddress.new(socketPath)
    const client = new Gio.SocketClient()

    client.connect_async(socketAddress, null, (_c: unknown, res: Gio.AsyncResult) => {
      try {
        const conn = client.connect_finish(res)
        const inputStream = conn.get_input_stream()
        const dataStream = new Gio.DataInputStream({ base_stream: inputStream })

        function readEvents() {
          dataStream.read_line_async(GLib.PRIORITY_DEFAULT, null, (_d: unknown, readRes: Gio.AsyncResult) => {
            try {
              const [line] = dataStream.read_line_finish_utf8(readRes)
              if (line !== null) {
                if (
                  line.startsWith("openwindow>>") ||
                  line.startsWith("closewindow>>") ||
                  line.startsWith("activewindow>>") ||
                  line.startsWith("movewindow>>") ||
                  line.startsWith("workspace>>") ||
                  line.startsWith("focusedmon>>")
                ) {
                  queueClientsFetch()
                }
                readEvents()
              }
            } catch {
              GLib.timeout_add(GLib.PRIORITY_DEFAULT, 2000, () => {
                initHyprlandSocket()
                return GLib.SOURCE_REMOVE
              })
            }
          })
        }

        readEvents()
      } catch {
        GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1500, () => {
          fetchClients()
          return GLib.SOURCE_CONTINUE
        })
      }
    })
  } catch {
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1500, () => {
      fetchClients()
      return GLib.SOURCE_CONTINUE
    })
  }

  GLib.timeout_add(GLib.PRIORITY_DEFAULT, 5000, () => {
    fetchClients()
    updateTrashCount()
    return GLib.SOURCE_CONTINUE
  })
}
