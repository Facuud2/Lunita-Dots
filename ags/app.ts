import app from "ags/gtk4/app"
import style from "./style.scss"
import DynamicIsland from "./widget/DynamicIsland"
import AppLauncher from "./widget/AppLauncher"
import NotificationPopup from "./widget/island/NotificationPopup"
import { initNotificationDaemon, clearAllNotifications } from "./widget/island/NotificationService"
import { toggleExpand, toggleNotificationsMenu } from "./widget/islandState"
import { toggleLauncher } from "./widget/launcher/LauncherState"

// Suppress unhandled promise rejections from GLib.MainLoop.runAsync internals
globalThis.addEventListener?.("unhandledrejection", (event: PromiseRejectionEvent) => {
  // Silently ignore — these come from GLib internals, not our code
  event.preventDefault()
})

// ── Montado protegido de un componente ───────────────────────────────────────
// Patrón Lunita-Dots: cada widget se monta de forma aislada.
// Un fallo en mount() de un componente no afecta a los demás.
function safeMount(name: string, fn: () => void) {
  try {
    fn()
  } catch (e) {
    console.warn(`[App] ${name} falló al montarse:`, e)
  }
}

app.start({
  css: style,
  requestHandler(argv, res) {
    if (argv[0] === "toggle-island") {
      toggleExpand()
      res("ok")
    } else if (argv[0] === "toggle-launcher") {
      toggleLauncher().then(() => res("ok")).catch(() => res("error"))
    } else if (argv[0] === "open-search") {
      import("./widget/launcher/LauncherState").then((m) => m.openSearch(argv[1] || ""))
      res("ok")
    } else if (argv[0] === "close-search") {
      import("./widget/launcher/LauncherState").then((m) => m.closeSearch())
      res("ok")
    } else if (argv[0] === "switch-launcher-tab") {
      import("./widget/launcher/LauncherState").then((m) => {
        const target = argv[1] === "links" ? "links" : "apps"
        m.switchTab(target)
      })
      res("ok")
    } else if (argv[0] === "toggle-notifications") {
      toggleNotificationsMenu()
      res("ok")
    } else if (argv[0] === "clear-notifications") {
      clearAllNotifications()
      res("ok")
    } else if (argv[0] === "launch-search-selection") {
      import("./widget/launcher/LauncherState").then((m) => {
        m.launchCurrentSearchSelection()
      })
      res("ok")
    } else if (argv[0] === "dump-launcher-state") {
      import("./widget/launcher/LauncherState").then((m) => {
        const state = {
          activeLauncherMonitor: m.activeLauncherMonitor.peek(),
          activeLauncherWorkspace: m.activeLauncherWorkspace.peek(),
          launcherOpen: m.launcherOpen.peek(),
          isLauncherClosing: m.isLauncherClosing(),
          searchMode: m.searchMode.peek(),
          searchQuery: m.searchQuery.peek(),
          searchSelectedIndex: m.searchSelectedIndex.peek(),
          selectedIndex: m.selectedIndex.peek(),
          activeTab: m.activeTab.peek(),
          panelAnimClass: m.panelAnimClass.peek(),
        }
        res(JSON.stringify(state))
      })
    } else {
      res("unknown request: " + argv[0])
    }

  },
  main() {
    // ── Demonio DBus de Notificaciones ──
    safeMount("NotificationDaemon", () => initNotificationDaemon())

    // ── Popups de Notificaciones (flotantes, todos los monitores) ──
    app.get_monitors().map((monitor) =>
      safeMount("NotificationPopup", () => NotificationPopup(monitor))
    )

    // ── DynamicIsland (siempre montado, todos los monitores) ──
    app.get_monitors().map((monitor) =>
      safeMount("DynamicIsland", () => DynamicIsland(monitor))
    )

    // ── AppLauncher (independiente, todos los monitores) ──
    app.get_monitors().map((monitor) =>
      safeMount("AppLauncher", () => AppLauncher(monitor))
    )
  },
})

