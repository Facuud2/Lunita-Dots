import app from "ags/gtk4/app"
import { Gdk } from "ags/gtk4"
import style from "./style.scss"
import Dock from "./widget/Dock"
import { initHyprlandSocket, fetchClients, clients, DEFAULT_PINNED_APPS } from "./widget/dock/DockState"

// Suppress unhandled promise rejections from GLib.MainLoop.runAsync internals
globalThis.addEventListener?.("unhandledrejection", (event: PromiseRejectionEvent) => {
  event.preventDefault()
})

// Safe mounting helper (Lunita-Dots pattern)
function safeMount(name: string, fn: () => void) {
  try {
    fn()
  } catch (e) {
    console.warn(`[macOS Theme App] ${name} falló al montarse:`, e)
  }
}

app.start({
  css: style,
  requestHandler(argv, res) {
    if (argv[0] === "refresh-dock") {
      fetchClients().then(() => res("ok")).catch((e) => res("error: " + e))
    } else if (argv[0] === "dump-dock-state") {
      res(
        JSON.stringify({
          pinned: DEFAULT_PINNED_APPS,
          clientsCount: clients.peek().length,
        })
      )
    } else {
      res("unknown request: " + argv[0])
    }
  },
  main() {
    // ── 1. Demonio reactivo de Hyprland (Socket2 + Clients) ──
    safeMount("HyprlandSocketDaemon", () => initHyprlandSocket())

    // ── 2. Montar Dock en todos los monitores activos ──
    const mountedMonitors = new Set<Gdk.Monitor>()
    const mountDock = (monitor: Gdk.Monitor) => {
      if (mountedMonitors.has(monitor)) return
      mountedMonitors.add(monitor)
      safeMount("macOS-Dock", () => Dock(monitor))
    }

    app.get_monitors().forEach(mountDock)

    // Escuchar adición dinámica de pantallas (hotplug)
    const display = Gdk.Display.get_default()
    const monitorsModel = display?.get_monitors()
    if (monitorsModel) {
      monitorsModel.connect("items-changed", (_m, pos, _rem, added) => {
        for (let i = 0; i < added; i++) {
          const mon = monitorsModel.get_item(pos + i) as Gdk.Monitor | null
          if (mon) mountDock(mon)
        }
      })
    }
  },
})
