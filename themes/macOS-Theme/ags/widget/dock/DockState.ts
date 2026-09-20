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
  iconFile: string
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

// ── Complete Pinned Applications (Matching Reference Image 1:1) ─────────────
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

// ── Reactive States ──────────────────────────────────────────────────────────
export const [clients, setClients] = createState<HyprlandClient[]>([])
export const [activeWindowAddress, setActiveWindowAddress] = createState<string>("")
export const [trashCount, setTrashCount] = createState<number>(0)
export const [hoveredAppId, setHoveredAppId] = createState<string | null>(null)

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

  return candidate1
}

// ── Resolve System App Icons ──────────────────────────────────────────────────
const iconCache = new Map<string, { icon: string; iconFile?: string }>()

export function resolveAppIconInfo(appClass: string, fallbackIcon: string = "application-x-executable"): { icon: string; iconFile?: string } {
  if (!appClass) return { icon: fallbackIcon }
  const lower = appClass.toLowerCase()
  if (iconCache.has(lower)) return iconCache.get(lower)!

  if (lower.includes("zen") || lower.includes("firefox") || lower.includes("chrome")) {
    const res = { icon: "web-browser", iconFile: getIconAssetPath("safari.svg") }
    iconCache.set(lower, res)
    return res
  }
  if (lower.includes("kitty") || lower.includes("terminal") || lower.includes("alacritty") || lower.includes("foot")) {
    const res = { icon: "utilities-terminal", iconFile: getIconAssetPath("terminal.svg") }
    iconCache.set(lower, res)
    return res
  }
  if (lower.includes("dolphin") || lower.includes("nautilus") || lower.includes("thunar")) {
    const res = { icon: "system-file-manager", iconFile: getIconAssetPath("finder.svg") }
    iconCache.set(lower, res)
    return res
  }
  if (lower.includes("code") || lower.includes("antigravity") || lower.includes("cursor")) {
    const res = { icon: "visual-studio-code", iconFile: getIconAssetPath("code.svg") }
    iconCache.set(lower, res)
    return res
  }
  if (lower.includes("spotify") || lower.includes("cider") || lower.includes("music")) {
    const res = { icon: "spotify-client", iconFile: getIconAssetPath("music.svg") }
    iconCache.set(lower, res)
    return res
  }
  if (lower.includes("telegram") || lower.includes("discord") || lower.includes("vesktop")) {
    const res = { icon: "telegram", iconFile: getIconAssetPath("messages.svg") }
    iconCache.set(lower, res)
    return res
  }
  if (lower.includes("setting") || lower.includes("pavucontrol")) {
    const res = { icon: "preferences-system", iconFile: getIconAssetPath("settings.svg") }
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

// ── Get Running Unpinned Apps ─────────────────────────────────────────────────
export function getRunningUnpinnedApps(
  pinnedList: PinnedApp[],
  clientList: HyprlandClient[]
): RunningApp[] {
  const map = new Map<string, RunningApp>()
  const allPinned = [...pinnedList, ...RIGHT_STACK_APPS]

  for (const c of clientList) {
    if (!c.mapped || c.class === "macos-dock" || c.class === "ags") continue

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
  const currentClients = clients.peek()
  const matchingClient = currentClients.find((c: HyprlandClient) =>
    pinned.matchClasses.some(
      (m: string) =>
        c.class.toLowerCase().includes(m.toLowerCase()) ||
        c.initialClass.toLowerCase().includes(m.toLowerCase())
    )
  )

  if (matchingClient) {
    execAsync(["hyprctl", "dispatch", "focuswindow", `address:${matchingClient.address}`]).catch(() => {
      execAsync(["bash", "-c", `${pinned.cmd} &`]).catch(() => {})
    })
  } else {
    execAsync(["bash", "-c", `${pinned.cmd} &`]).catch((e: unknown) => {
      console.error(`[Dock] Error al ejecutar ${pinned.cmd}:`, e)
    })
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
