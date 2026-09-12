import app from "ags/gtk4/app"
import style from "./style.scss"
import DynamicIsland from "./widget/DynamicIsland"
import { toggleExpand } from "./widget/islandState"

// AGS bundlea todo en un solo archivo: los imports son siempre estáticos.
// El aislamiento entre componentes se logra protegiendo el *montado* con
// try/catch — si MusicPlayer falla al inicializarse, DynamicIsland continúa.
import MusicPlayerComponent from "./widget/MusicPlayer/index"

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
    } else {
      res("unknown request: " + argv[0])
    }
  },
  main() {
    // ── DynamicIsland (siempre montado, todos los monitores) ──
    app.get_monitors().map(DynamicIsland)

    // ── MusicPlayer (todos los monitores) ──
    app.get_monitors().map((monitor) =>
      safeMount("MusicPlayer", () => MusicPlayerComponent(monitor))
    )
  },
})
