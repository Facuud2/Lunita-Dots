import { Gtk, Gdk } from "ags/gtk4"
import {
  closeLauncher,
  openSearch,
  selectedIndex,
  registerActionHandler,
  onCellHover,
  onCellLeave,
  launchOnActiveWorkspace,
} from "./LauncherState"
import { getProgram, ProgramKey } from "./ConfigResolver"

export interface AppItem {
  icon: string
  label: string
  key?: ProgramKey
  isSearch?: boolean
}

export const APPS: AppItem[] = [
  {
    icon: "\ue9cc", // Feather search (lupa)
    label: "Buscar",
    isSearch: true,
  },
  {
    icon: "\ue9e9", // Feather terminal (>_)
    label: "Terminal",
    key: "terminal",
  },
  {
    icon: "\ue96c", // Feather folder (archivos)
    label: "Archivos",
    key: "fileManager",
  },
  {
    icon: "\ue95b", // Feather editor
    label: "Editor",
    key: "ide",
  },
  {
    icon: "\ue978", // Feather globe (browser)
    label: "Browser",
    key: "browser",
  },
  {
    icon: "\ue9a8", // Feather music note (música)
    label: "Música",
    key: "music",
  },
]

export function launchApp(index: number) {
  const app = APPS[index]
  if (!app) return

  if (app.isSearch) {
    openSearch()
    return
  }

  if (app.key) {
    const cmd = getProgram(app.key)
    launchOnActiveWorkspace(cmd)
    closeLauncher()
  }
}

function AppCell(app: AppItem, index: number) {
  const prog = app.key ? getProgram(app.key) : ""
  const tooltip = prog ? `${app.label} (${prog})` : app.label

  return (
    <button
      class={selectedIndex((sel) => (sel === index ? "al-cell selected" : "al-cell"))}
      canFocus={false}
      focusable={false}
      cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
      onClicked={() => launchApp(index)}
      tooltipText={tooltip}
      $={(self) => {
        const motion = new Gtk.EventControllerMotion()
        motion.connect("enter", () => {
          onCellHover(index)
        })
        motion.connect("leave", () => {
          onCellLeave(index)
        })
        self.add_controller(motion)
      }}
    >
      <box
        orientation={Gtk.Orientation.VERTICAL}
        spacing={8}
        halign={Gtk.Align.CENTER}
        valign={Gtk.Align.CENTER}
      >
        <label class="al-cell-icon" label={app.icon} />
        <label class="al-cell-label" label={app.label} />
      </box>
    </button>
  )
}

export default function AppsTab() {
  registerActionHandler(launchApp)

  return (
    <box class="al-grid" spacing={12} homogeneous>
      {APPS.map((app, i) => AppCell(app, i))}
    </box>
  )
}
