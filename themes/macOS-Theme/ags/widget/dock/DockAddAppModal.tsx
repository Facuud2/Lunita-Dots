import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { With } from "ags"
import GLib from "gi://GLib"
import {
  isAddAppModalOpen,
  closeAddAppModal,
  addAppSearchQuery,
  setAddAppSearchQuery,
  addAppSelectedIndex,
  setAddAppSelectedIndex,
  getFilteredInstalledApps,
  pinInstalledApp,
  unpinApp,
  isAppPinned,
  pinnedApps,
  type InstalledAppItem,
} from "./DockState"

export default function DockAddAppModal(gdkmonitor: Gdk.Monitor) {
  const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor
  const connector = gdkmonitor.get_connector() || ""

  let entryRef: Gtk.Entry | null = null
  let panelRef: Gtk.Widget | null = null

  // Auto-focus search entry when modal opens
  isAddAppModalOpen.subscribe(() => {
    const isOpen = isAddAppModalOpen.peek()
    if (isOpen) {
      GLib.timeout_add(GLib.PRIORITY_DEFAULT, 80, () => {
        if (entryRef) {
          entryRef.grab_focus()
          entryRef.set_text("")
        }
        return GLib.SOURCE_REMOVE
      })
    }
  })

  return (
    <window
      name={`macos-dock-add-modal-${connector}`}
      class="dock-add-modal-window"
      gdkmonitor={gdkmonitor}
      anchor={TOP | BOTTOM | LEFT | RIGHT}
      exclusivity={Astal.Exclusivity.IGNORE}
      layer={Astal.Layer.OVERLAY}
      application={app}
      visible={isAddAppModalOpen}
      keymode={Astal.Keymode.EXCLUSIVE}
      $={(self) => {
        const key = new Gtk.EventControllerKey()
        key.connect("key-pressed", (_c, keyval) => {
          if (keyval === Gdk.KEY_Escape) {
            closeAddAppModal()
            return true
          }

          const filtered = getFilteredInstalledApps(addAppSearchQuery.peek())
          const curIdx = addAppSelectedIndex.peek()

          if (keyval === Gdk.KEY_Down) {
            if (filtered.length > 0) {
              setAddAppSelectedIndex(Math.min(curIdx + 1, filtered.length - 1))
            }
            return true
          }

          if (keyval === Gdk.KEY_Up) {
            if (filtered.length > 0) {
              setAddAppSelectedIndex(Math.max(curIdx - 1, 0))
            }
            return true
          }

          if (keyval === Gdk.KEY_Return || keyval === Gdk.KEY_KP_Enter) {
            if (filtered.length > 0 && filtered[curIdx]) {
              const selected = filtered[curIdx]
              if (!isAppPinned(selected.id)) {
                pinInstalledApp(selected)
              }
              closeAddAppModal()
            }
            return true
          }

          return false
        })
        self.add_controller(key)
      }}
    >
      <box
        class="dock-add-modal-backdrop"
        hexpand
        vexpand
        halign={Gtk.Align.FILL}
        valign={Gtk.Align.FILL}
        $={(self) => {
          const click = new Gtk.GestureClick()
          click.set_propagation_phase(Gtk.PropagationPhase.CAPTURE)
          click.connect("pressed", (_gesture, _n, x, y) => {
            if (!panelRef) return
            const picked = self.pick(x, y, Gtk.PickFlags.DEFAULT)
            if (picked) {
              let cur: Gtk.Widget | null = picked
              let inside = false
              while (cur && cur instanceof Gtk.Widget) {
                if (cur === panelRef) {
                  inside = true
                  break
                }
                cur = cur.get_parent()
              }
              if (!inside) {
                closeAddAppModal()
              }
            } else {
              closeAddAppModal()
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
            class="dock-add-modal-panel"
            orientation={Gtk.Orientation.VERTICAL}
            spacing={16}
          >
            {/* ── Modal Header ── */}
            <box class="dock-add-modal-header" spacing={12} valign={Gtk.Align.CENTER}>
              <box class="dock-add-header-icon-box" halign={Gtk.Align.CENTER} valign={Gtk.Align.CENTER}>
                <image iconName="list-add-symbolic" pixelSize={20} />
              </box>
              <box orientation={Gtk.Orientation.VERTICAL} spacing={2} hexpand>
                <label
                  label="Añadir al Dock"
                  class="dock-add-modal-title"
                  halign={Gtk.Align.START}
                  xalign={0}
                />
                <label
                  label="Selecciona una aplicación instalada para fijarla a tu barra de macOS"
                  class="dock-add-modal-subtitle"
                  halign={Gtk.Align.START}
                  xalign={0}
                />
              </box>
              <button
                class="dock-add-close-btn"
                canFocus={false}
                focusable={false}
                cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
                onClicked={() => closeAddAppModal()}
              >
                <image iconName="window-close-symbolic" pixelSize={14} />
              </button>
            </box>

            {/* ── Search Bar ── */}
            <box class="dock-add-search-container" spacing={8} valign={Gtk.Align.CENTER}>
              <image iconName="system-search-symbolic" pixelSize={16} class="dock-add-search-icon" />
              <entry
                $={(self) => {
                  entryRef = self
                  self.connect("changed", () => {
                    setAddAppSearchQuery(self.get_text())
                    setAddAppSelectedIndex(0)
                  })
                }}
                class="dock-add-search-entry"
                placeholderText="Buscar aplicación por nombre o comando..."
                hexpand
              />
            </box>

            {/* ── App List Scrollable Area ── */}
            <scrolledwindow
              class="dock-add-scrolled"
              hscrollbarPolicy={Gtk.PolicyType.NEVER}
              vscrollbarPolicy={Gtk.PolicyType.AUTOMATIC}
              vexpand
            >
              <With value={addAppSearchQuery((q) => getFilteredInstalledApps(q))}>
                {(filtered: InstalledAppItem[]) => {
                  if (filtered.length === 0) {
                    return (
                      <box
                        orientation={Gtk.Orientation.VERTICAL}
                        spacing={12}
                        halign={Gtk.Align.CENTER}
                        valign={Gtk.Align.CENTER}
                        class="dock-add-empty-state"
                      >
                        <image iconName="system-search-symbolic" pixelSize={36} class="dock-add-empty-icon" />
                        <label label="No se encontraron aplicaciones coincidentes" class="dock-add-empty-text" />
                      </box>
                    )
                  }

                  return (
                    <box orientation={Gtk.Orientation.VERTICAL} spacing={6} class="dock-add-app-list">
                      {filtered.map((item: InstalledAppItem, idx: number) => {
                        return (
                          <button
                            class={addAppSelectedIndex((sel) =>
                              sel === idx
                                ? "dock-add-app-card selected"
                                : "dock-add-app-card"
                            )}
                            canFocus={false}
                            focusable={false}
                            cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
                            onClicked={() => {
                              if (isAppPinned(item.id)) {
                                unpinApp(item.id)
                              } else {
                                pinInstalledApp(item)
                                closeAddAppModal()
                              }
                            }}
                          >
                            <box orientation={Gtk.Orientation.HORIZONTAL} spacing={14} valign={Gtk.Align.CENTER}>
                              {/* App Icon */}
                              <box class="dock-add-icon-container" halign={Gtk.Align.CENTER} valign={Gtk.Align.CENTER}>
                                {item.iconFile ? (
                                  <image file={item.iconFile} pixelSize={38} />
                                ) : (
                                  <image iconName={item.iconName} pixelSize={38} />
                                )}
                              </box>

                              {/* App Info */}
                              <box orientation={Gtk.Orientation.VERTICAL} spacing={2} hexpand valign={Gtk.Align.CENTER}>
                                <label
                                  label={item.displayName}
                                  class="dock-add-app-name"
                                  halign={Gtk.Align.START}
                                  xalign={0}
                                />
                                {item.description ? (
                                  <label
                                    label={item.description}
                                    class="dock-add-app-desc"
                                    halign={Gtk.Align.START}
                                    xalign={0}
                                    ellipsize={3}
                                  />
                                ) : (
                                  <label
                                    label={item.executable || item.cmd}
                                    class="dock-add-app-desc"
                                    halign={Gtk.Align.START}
                                    xalign={0}
                                    ellipsize={3}
                                  />
                                )}
                              </box>

                              {/* Pin / Unpin Action Badge */}
                              <box valign={Gtk.Align.CENTER}>
                                <box
                                  class={pinnedApps((pList) =>
                                    pList.some((p) => p.id === item.id) ? "dock-add-badge pinned" : "dock-add-badge add"
                                  )}
                                  spacing={4}
                                  valign={Gtk.Align.CENTER}
                                >
                                  <image
                                    iconName={pinnedApps((pList) =>
                                      pList.some((p) => p.id === item.id) ? "emblem-ok-symbolic" : "list-add-symbolic"
                                    )}
                                    pixelSize={12}
                                  />
                                  <label
                                    label={pinnedApps((pList) =>
                                      pList.some((p) => p.id === item.id) ? "En el Dock" : "Añadir"
                                    )}
                                    class="dock-add-badge-label"
                                  />
                                </box>
                              </box>
                            </box>
                          </button>
                        )
                      })}
                    </box>
                  )
                }}
              </With>
            </scrolledwindow>
          </box>
        </box>
      </box>
    </window>
  )
}
