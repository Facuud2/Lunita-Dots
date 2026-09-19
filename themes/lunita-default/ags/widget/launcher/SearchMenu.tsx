import { Gtk, Gdk } from "ags/gtk4"
import { With } from "ags"
import GLib from "gi://GLib"
import {
  searchQuery,
  setSearchQuery,
  searchSelectedIndex,
  setSearchSelectedIndex,
  closeSearch,
  getFilteredApps,
  launchAppItem,
  launchCurrentSearchSelection,
  navigateSearch,
  type AppItem,
} from "./LauncherState"

export default function SearchMenu() {
  let scrolledRef: Gtk.ScrolledWindow | null = null
  let entryRef: Gtk.Entry | null = null

  const scrollToSelected = (index: number) => {
    if (!scrolledRef) return
    const vadj = scrolledRef.get_vadjustment()
    if (!vadj) return
    const rowHeight = 48
    const targetTop = index * rowHeight
    const targetBottom = targetTop + rowHeight
    const curScroll = vadj.get_value()
    const pageSize = vadj.get_page_size()

    if (targetTop < curScroll) {
      vadj.set_value(targetTop)
    } else if (targetBottom > curScroll + pageSize) {
      vadj.set_value(targetBottom - pageSize)
    }
  }

  searchSelectedIndex((idx) => {
    scrollToSelected(idx)
  })

  const filtered = searchQuery((q) => getFilteredApps(q))

  return (
    <box orientation={Gtk.Orientation.VERTICAL} class="al-search-menu" spacing={0}>
      {/* ── Search Header ── */}
      <box class="al-header" spacing={0}>
        <box class="al-tab-row" spacing={0}>
          {/* Back button to return to quick apps grid */}
          <button
            class="al-tab al-tab-back"
            canFocus={false}
            focusable={false}
            onClicked={closeSearch}
            cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
            tooltipText="Volver a los accesos directos"
          >
            <box spacing={6} valign={Gtk.Align.CENTER}>
              <label class="al-back-icon" label={"\ue910"} />
              <label label="Volver" />
            </box>
          </button>

          {/* Active Search Badge */}
          <box class="al-tab al-tab-active" valign={Gtk.Align.CENTER}>
            <label label="Buscar Apps" />
          </box>
        </box>

        {/* Right: Found apps count */}
        <box hexpand halign={Gtk.Align.END} valign={Gtk.Align.CENTER}>
          <label
            class="al-info-label"
            label={filtered((list) => {
              const n = list.length
              return `${n} ${n === 1 ? "aplicación" : "aplicaciones"}`
            })}
            halign={Gtk.Align.END}
          />
        </box>
      </box>

      {/* Separator */}
      <box class="al-separator" />

      {/* ── Search Content Body ── */}
      <box orientation={Gtk.Orientation.VERTICAL} class="al-search-body" spacing={12}>
        {/* Input Bar */}
        <box class="al-search-bar" spacing={10} valign={Gtk.Align.CENTER}>
          <label class="al-search-bar-icon" label={"\ue9cc"} />
          <entry
            class="al-search-entry"
            hexpand
            placeholderText="Escribe el nombre de una aplicación..."
            onChanged={(self) => {
              if (searchQuery.peek() !== self.text) {
                setSearchQuery(self.text)
                setSearchSelectedIndex(0)
              }
            }}
            onActivate={() => {
              launchCurrentSearchSelection()
            }}
            $={(self) => {
              entryRef = self
              const initial = searchQuery.peek()
              if (initial) {
                self.text = initial
              }
              self.grab_focus()
              self.set_position(-1)

              // Keep entry text in sync if searchQuery changes from outside (e.g. clear button or Escape)
              const sub = searchQuery.subscribe(() => {
                const q = searchQuery.peek() || ""
                if (entryRef && entryRef.text !== q) {
                  entryRef.text = q
                  entryRef.set_position(-1)
                }
              })
              self.connect("destroy", () => {
                if (typeof sub === "function") sub()
                entryRef = null
              })

              // Focus automatically when opened
              GLib.idle_add(GLib.PRIORITY_DEFAULT_IDLE, () => {
                if (entryRef) {
                  entryRef.grab_focus()
                  entryRef.set_position(-1)
                }
                return GLib.SOURCE_REMOVE
              })
            }}
          />
          {/* Clear button if text is not empty */}
          <button
            class="al-search-clear-btn"
            canFocus={false}
            focusable={false}
            cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
            visible={searchQuery((q) => q.length > 0)}
            onClicked={() => {
              setSearchQuery("")
              if (entryRef) {
                entryRef.text = ""
                entryRef.grab_focus()
              }
              setSearchSelectedIndex(0)
            }}
          >
            <label class="al-clear-icon" label={"\uea11"} />
          </button>
        </box>

        {/* ── Scrollable Results List ── */}
        <scrolledwindow
          class="al-search-scroll"
          hscrollbarPolicy={Gtk.PolicyType.NEVER}
          vscrollbarPolicy={Gtk.PolicyType.AUTOMATIC}
          vexpand
          $={(self) => {
            scrolledRef = self
          }}
        >
          <With value={filtered}>
            {(apps) => {
              if (apps.length === 0) {
                return (
                  <box
                    class="al-search-empty"
                    orientation={Gtk.Orientation.VERTICAL}
                    spacing={8}
                    halign={Gtk.Align.CENTER}
                    valign={Gtk.Align.CENTER}
                  >
                    <label class="al-empty-icon" label={"\ue9cc"} />
                    <label class="al-empty-text" label="No se encontraron programas con ese nombre" />
                  </box>
                )
              }

              return (
                <box orientation={Gtk.Orientation.VERTICAL} class="al-app-list" spacing={4}>
                  {apps.map((app, index) => (
                    <button
                      class={searchSelectedIndex((sel) =>
                        sel === index ? "al-app-row selected" : "al-app-row"
                      )}
                      canFocus={false}
                      focusable={false}
                      cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
                      onClicked={() => launchAppItem(app)}
                      $={(self) => {
                        const motion = new Gtk.EventControllerMotion()
                        motion.connect("enter", () => {
                          setSearchSelectedIndex(index)
                        })
                        self.add_controller(motion)
                      }}
                    >
                      <box spacing={14} valign={Gtk.Align.CENTER}>
                        <image
                          gicon={app.gicon || undefined}
                          iconName={app.gicon ? undefined : "application-x-executable"}
                          pixelSize={28}
                          valign={Gtk.Align.CENTER}
                        />
                        <box orientation={Gtk.Orientation.VERTICAL} spacing={1} hexpand valign={Gtk.Align.CENTER}>
                          <label
                            class="al-app-name"
                            label={app.displayName}
                            halign={Gtk.Align.START}
                          />
                          {app.description ? (
                            <label
                              class="al-app-desc"
                              label={app.description}
                              halign={Gtk.Align.START}
                              ellipsize={3}
                            />
                          ) : (
                            <label
                              class="al-app-desc"
                              label={app.executable}
                              halign={Gtk.Align.START}
                              ellipsize={3}
                            />
                          )}
                        </box>
                        <label class="al-app-arrow" label={"\ue912"} valign={Gtk.Align.CENTER} />
                      </box>
                    </button>
                  ))}
                </box>
              )
            }}
          </With>
        </scrolledwindow>
      </box>
    </box>
  )
}
