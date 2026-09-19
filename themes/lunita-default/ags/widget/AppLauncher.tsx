import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { With } from "ags"
import GLib from "gi://GLib"
import {
  activeLauncherMonitor,
  closeLauncher,
  isLauncherClosing,
  searchMode,
  openSearch,
  closeSearch,
  searchQuery,
  setSearchQuery,
  setSearchSelectedIndex,
  activeTab,
  switchTab,
  type LauncherTab,
  selectedIndex,
  setSelectedIndex,
  getItemCount,
  executeSelected,
  panelAnimClass,
  launchCurrentSearchSelection,
  navigateSearch,
  getLauncherOpenTime,
} from "./launcher/LauncherState"
import AppsTab, { launchApp } from "./launcher/AppsTab"
import QuickLinksTab, { launchLink } from "./launcher/QuickLinksTab"
import SearchMenu from "./launcher/SearchMenu"
import { getProgram } from "./launcher/ConfigResolver"

function executeNormalSelection() {
  const tab = activeTab.peek()
  const idx = selectedIndex.peek()
  if (tab === "apps") {
    launchApp(idx)
  } else if (tab === "links") {
    launchLink(idx)
  }
}


// ── Tab metadata ──────────────────────────────────────────────────────────────
const TABS: { id: LauncherTab; label: string }[] = [
  { id: "apps",  label: "Apps" },
  { id: "links", label: "Quick Links" },
]

// ── Helper: info label per tab ────────────────────────────────────────────────
function getInfoLabel(tab: LauncherTab): string {
  if (tab === "links") return `Open In : ${getProgram("browser")}`
  return "Most Used"
}

// ── Tab switcher header ───────────────────────────────────────────────────────
function LauncherHeader() {
  return (
    <box class="al-header" spacing={0}>
      {/* Left: Category badge tabs — strictly mouse-operated, unfocusable by keyboard */}
      <box class="al-tab-row" spacing={0}>
        {TABS.map((tab) => (
          <button
            canFocus={false}
            focusable={false}
            class={activeTab((t) => (t === tab.id ? "al-tab al-tab-active" : "al-tab"))}
            onClicked={() => switchTab(tab.id)}
            cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
          >
            <label label={tab.label} />
          </button>
        ))}
      </box>

      {/* Right: Info label */}
      <box hexpand halign={Gtk.Align.END} valign={Gtk.Align.CENTER}>
        <label
          class="al-info-label"
          label={activeTab((t) => getInfoLabel(t))}
          halign={Gtk.Align.END}
        />
      </box>
    </box>
  )
}

// ── Main content area (tab switcher) ─────────────────────────────────────────
function LauncherContent() {
  return (
    <With value={activeTab}>
      {(tab) => {
        switch (tab) {
          case "apps":  return <AppsTab />
          case "links": return <QuickLinksTab />
          default:      return <AppsTab />
        }
      }}
    </With>
  )
}

// ── App Launcher Component ───────────────────────────────────────────────────
export default function AppLauncher(gdkmonitor: Gdk.Monitor) {
  const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor
  const connector = gdkmonitor.get_connector() || ""
  let panelRef: Gtk.Widget | null = null

  return (
    <window
      name={`app-launcher-${connector}`}
      class="al-window"
      gdkmonitor={gdkmonitor}
      anchor={TOP | BOTTOM | LEFT | RIGHT}
      exclusivity={Astal.Exclusivity.IGNORE}
      layer={Astal.Layer.OVERLAY}
      application={app}
      visible={activeLauncherMonitor((m) => m === connector)}
      keymode={Astal.Keymode.EXCLUSIVE}

      $={(self) => {
        searchMode.subscribe(() => {
          if (!searchMode.peek()) {
            try {
              self.set_focus(null)
            } catch {}
          }
        })

        const key = new Gtk.EventControllerKey()
        key.set_propagation_phase(Gtk.PropagationPhase.CAPTURE)
        key.connect("key-pressed", (_c: any, keyval: number, _keycode: number, state: Gdk.ModifierType) => {
          if (isLauncherClosing()) {
            return true
          }

          // Directly handle SUPER+A while launcher is open to close it reliably
          if (
            (keyval === Gdk.KEY_a || keyval === Gdk.KEY_A) &&
            state &&
            (state & Gdk.ModifierType.SUPER_MASK) !== 0
          ) {
            if (Date.now() - getLauncherOpenTime() < 250) {
              return true
            }
            closeLauncher()
            return true
          }

          // Ignore standalone Super key press/release
          if (keyval === Gdk.KEY_Super_L || keyval === Gdk.KEY_Super_R) {
            return false
          }

          if (keyval === Gdk.KEY_Escape) {
            if (searchMode.peek()) {
              if (searchQuery.peek() !== "") {
                setSearchQuery("")
                setSearchSelectedIndex(0)
              } else {
                closeSearch()
              }
            } else {
              closeLauncher()
            }
            return true
          }

          if (searchMode.peek()) {
            if (keyval === Gdk.KEY_Down) {
              navigateSearch(1)
              return true
            }
            if (keyval === Gdk.KEY_Up) {
              navigateSearch(-1)
              return true
            }
            if (keyval === Gdk.KEY_Return || keyval === Gdk.KEY_KP_Enter) {
              launchCurrentSearchSelection()
              return true
            }
            // Let other keys (characters, backspace) pass through to the search entry
            return false
          }

          const count = getItemCount(activeTab.peek())
          const cur = selectedIndex.peek()

          // Move right
          if (
            keyval === Gdk.KEY_Right ||
            keyval === Gdk.KEY_Down ||
            keyval === Gdk.KEY_Tab
          ) {
            setSelectedIndex((cur + 1) % count)
            return true
          }

          // Move left
          if (
            keyval === Gdk.KEY_Left ||
            keyval === Gdk.KEY_Up ||
            keyval === Gdk.KEY_ISO_Left_Tab
          ) {
            setSelectedIndex((cur - 1 + count) % count)
            return true
          }

          // Execute selected item
          if (
            keyval === Gdk.KEY_Return ||
            keyval === Gdk.KEY_KP_Enter ||
            keyval === Gdk.KEY_space
          ) {
            executeNormalSelection()
            return true
          }

          // Ignore hotkey combinations with Control or Alt
          const hasModifier = state
            ? (state & (Gdk.ModifierType.CONTROL_MASK | Gdk.ModifierType.ALT_MASK)) !== 0
            : false
          if (hasModifier) {
            return false
          }

          // Any printable character (unicode > 32) starts search immediately
          const unicode = Gdk.keyval_to_unicode(keyval)
          if (unicode > 32) {
            const char = String.fromCharCode(unicode)
            openSearch(char)
            return true
          }

          return false
        })
        self.add_controller(key)
      }}
    >
      <box
        class="al-fullscreen-root"
        hexpand
        vexpand
        halign={Gtk.Align.FILL}
        valign={Gtk.Align.FILL}
        $={(self) => {
          const click = new Gtk.GestureClick()
          click.set_propagation_phase(Gtk.PropagationPhase.CAPTURE)
          click.connect("pressed", (gesture, _n, x, y) => {
            if (!panelRef) return
            const picked = self.pick(x, y, Gtk.PickFlags.DEFAULT)
            let cur = picked
            let inside = false
            while (cur) {
              if (cur === panelRef) {
                inside = true
                break
              }
              cur = cur.get_parent()
            }
            if (!inside) {
              gesture.set_state(Gtk.EventSequenceState.CLAIMED)
              closeLauncher()
            }
          })
          self.add_controller(click)
        }}
      >
        <box
          hexpand
          vexpand
          halign={Gtk.Align.CENTER}
          valign={Gtk.Align.CENTER}
        >
          <box
            $={(self) => {
              panelRef = self
            }}
            class={panelAnimClass}
            orientation={Gtk.Orientation.VERTICAL}
            spacing={0}
          >
            <With value={searchMode}>
              {(isSearch) => {
                if (isSearch) {
                  return <SearchMenu />
                }
                return (
                  <box class="al-quick-view" orientation={Gtk.Orientation.VERTICAL} spacing={0}>
                    <LauncherHeader />
                    <box class="al-separator" />
                    <box class="al-content" spacing={0}>
                      <LauncherContent />
                    </box>
                  </box>
                )
              }}
            </With>
          </box>
        </box>
      </box>
    </window>
  )
}


