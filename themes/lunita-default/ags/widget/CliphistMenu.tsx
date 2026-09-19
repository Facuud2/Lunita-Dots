import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { With } from "ags"
import GLib from "gi://GLib"
import {
  activeCliphistMonitor,
  closeCliphist,
  cursorCoords,
  clipItems,
  searchQuery,
  setSearchQuery,
  selectedIndex,
  setSelectedIndex,
  navigateSelection,
  copyItem,
  deleteItem,
  copyCurrentSelection,
  deleteCurrentSelection,
  clearAllHistory,
  panelAnimClass,
  isCliphistClosing,
  getCliphistOpenTime,
  filteredItems,
  type ClipItem,
} from "./cliphist/CliphistState"

export default function CliphistMenu(gdkmonitor: Gdk.Monitor) {
  const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor
  const connector = gdkmonitor.get_connector() || ""

  let cardRef: Gtk.Widget | null = null
  let entryRef: Gtk.Entry | null = null
  let scrolledRef: Gtk.ScrolledWindow | null = null

  // Auto-scroll para seguir el elemento seleccionado por teclado
  const scrollToSelected = (index: number) => {
    if (!scrolledRef) return
    const vadj = scrolledRef.get_vadjustment()
    if (!vadj) return
    const rowHeight = 56
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

  selectedIndex((idx) => {
    scrollToSelected(idx)
  })

  return (
    <window
      name={`cliphist-menu-${connector}`}
      class="cliphist-window"
      gdkmonitor={gdkmonitor}
      anchor={TOP | BOTTOM | LEFT | RIGHT}
      exclusivity={Astal.Exclusivity.IGNORE}
      layer={Astal.Layer.OVERLAY}
      application={app}
      visible={activeCliphistMonitor((m) => m === connector)}
      keymode={Astal.Keymode.EXCLUSIVE}
      $={(self) => {
        // Enfoque automático del campo de búsqueda al abrir
        activeCliphistMonitor.subscribe(() => {
          if (activeCliphistMonitor.peek() === connector) {
            GLib.idle_add(GLib.PRIORITY_DEFAULT_IDLE, () => {
              entryRef?.grab_focus()
              return GLib.SOURCE_REMOVE
            })
          }
        })

        // Controlador de teclado para navegación y atajos
        const key = new Gtk.EventControllerKey()
        key.set_propagation_phase(Gtk.PropagationPhase.CAPTURE)
        key.connect("key-pressed", (_c: any, keyval: number, _kc: number, state: Gdk.ModifierType) => {
          if (isCliphistClosing()) return true

          // SUPER+V para alternar/cerrar si ya está abierto
          if (
            (keyval === Gdk.KEY_v || keyval === Gdk.KEY_V) &&
            state &&
            (state & Gdk.ModifierType.SUPER_MASK) !== 0
          ) {
            if (Date.now() - getCliphistOpenTime() < 250) return true
            closeCliphist()
            return true
          }

          // Escape para cerrar
          if (keyval === Gdk.KEY_Escape) {
            if (searchQuery.peek() !== "") {
              setSearchQuery("")
              setSelectedIndex(0)
            } else {
              closeCliphist()
            }
            return true
          }

          // Navegación con flechas
          if (keyval === Gdk.KEY_Down) {
            navigateSelection(1)
            return true
          }
          if (keyval === Gdk.KEY_Up) {
            navigateSelection(-1)
            return true
          }

          // Enter para copiar y auto-pegar
          if (keyval === Gdk.KEY_Return || keyval === Gdk.KEY_KP_Enter) {
            copyCurrentSelection()
            return true
          }

          // Supr o Shift+Supr para eliminar elemento seleccionado
          if (keyval === Gdk.KEY_Delete || keyval === Gdk.KEY_KP_Delete) {
            deleteCurrentSelection()
            return true
          }

          // Permitir que el resto de teclas se pasen al buscador
          return false
        })
        self.add_controller(key)
      }}
    >
      {/* Fondo transparente que captura clic fuera para cerrar */}
      <box
        class="cliphist-fullscreen-root"
        hexpand
        vexpand
        halign={Gtk.Align.FILL}
        valign={Gtk.Align.FILL}
        $={(self) => {
          const click = new Gtk.GestureClick()
          click.set_propagation_phase(Gtk.PropagationPhase.CAPTURE)
          click.connect("pressed", (gesture, _n, x, y) => {
            if (!cardRef) return
            const picked = self.pick(x, y, Gtk.PickFlags.DEFAULT)
            let cur = picked
            let inside = false
            while (cur) {
              if (cur === cardRef) {
                inside = true
                break
              }
              cur = cur.get_parent()
            }
            if (!inside) {
              gesture.set_state(Gtk.EventSequenceState.CLAIMED)
              closeCliphist()
            }
          })
          self.add_controller(click)
        }}
      >
        {/* Contenedor flotante desplegado en la posición del cursor */}
        <box
          $={(self) => {
            cardRef = self
            cursorCoords.subscribe(() => {
              const coords = cursorCoords.peek()
              self.set_margin_start(coords.x)
              self.set_margin_top(coords.y)
            })
            // Posición inicial
            const initCoords = cursorCoords.peek()
            self.set_margin_start(initCoords.x)
            self.set_margin_top(initCoords.y)
          }}
          class={panelAnimClass}
          orientation={Gtk.Orientation.VERTICAL}
          halign={Gtk.Align.START}
          valign={Gtk.Align.START}
          spacing={0}
        >
          {/* ── 1. Cabecera estilo Lunita / macOS ── */}
          <box class="cliphist-header" spacing={10} valign={Gtk.Align.CENTER}>
            {/* Píldora de estado con icono Nothing / Sonoma */}
            <box class="cliphist-title-pill" spacing={6} valign={Gtk.Align.CENTER}>
              <label class="font-icon cliphist-pill-icon" label="content_paste" />
              <label class="cliphist-pill-title" label="PORTAPAPELES" />
            </box>

            {/* Contador de elementos */}
            <box hexpand halign={Gtk.Align.END} spacing={8} valign={Gtk.Align.CENTER}>
              <label
                class="cliphist-info-badge"
                label={filteredItems((list) => {
                  const n = list.length
                  return `${n} ${n === 1 ? "elemento" : "elementos"}`
                })}
              />

              {/* Botón para vaciar historial */}
              <button
                class="cliphist-clear-btn"
                canFocus={false}
                focusable={false}
                tooltipText="Vaciar todo el historial"
                cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
                onClicked={() => clearAllHistory()}
              >
                <label class="font-icon cliphist-btn-icon" label="delete_sweep" />
              </button>

              {/* Botón de cerrar */}
              <button
                class="cliphist-close-btn"
                canFocus={false}
                focusable={false}
                tooltipText="Cerrar (Esc)"
                cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
                onClicked={() => closeCliphist()}
              >
                <label class="font-icon cliphist-btn-icon" label="close" />
              </button>
            </box>
          </box>

          {/* ── 2. Barra de Búsqueda Interactiva ── */}
          <box class="cliphist-search-wrapper" spacing={8} valign={Gtk.Align.CENTER}>
            <label class="font-icon cliphist-search-icon" label="search" />
            <entry
              $={(self) => {
                entryRef = self
              }}
              class="cliphist-search-entry"
              hexpand
              placeholderText="Buscar en el historial..."
              text={searchQuery}
              onChanged={(self) => {
                if (searchQuery.peek() !== self.text) {
                  setSearchQuery(self.text)
                  setSelectedIndex(0)
                }
              }}
            />
            {/* Botón para limpiar campo de búsqueda si hay texto */}
            <button
              class={searchQuery((q) =>
                q ? "cliphist-search-clear visible" : "cliphist-search-clear"
              )}
              canFocus={false}
              focusable={false}
              cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
              onClicked={() => {
                setSearchQuery("")
                setSelectedIndex(0)
              }}
            >
              <label class="font-icon" label="close" />
            </button>
          </box>

          {/* Separador sutil */}
          <box class="cliphist-separator" />

          {/* ── 3. Lista Desplazable de Elementos ── */}
          <scrolledwindow
            $={(self) => {
              scrolledRef = self
            }}
            class="cliphist-scroll-area"
            hexpand
            vexpand
            hscrollbarPolicy={Gtk.PolicyType.NEVER}
            vscrollbarPolicy={Gtk.PolicyType.AUTOMATIC}
          >
            <With value={filteredItems}>
              {(items) => {
                if (items.length === 0) {
                  return (
                    <box
                      orientation={Gtk.Orientation.VERTICAL}
                      class="cliphist-empty-box"
                      spacing={8}
                      halign={Gtk.Align.CENTER}
                      valign={Gtk.Align.CENTER}
                    >
                      <label class="font-icon cliphist-empty-icon" label="content_paste" />
                      <label
                        class="cliphist-empty-text"
                        label={
                          searchQuery.peek()
                            ? "No se encontraron coincidencias"
                            : "Historial de portapapeles vacío"
                        }
                      />
                      <label
                        class="cliphist-empty-sub"
                        label="Copia texto o capturas para guardarlos automáticamente"
                      />
                    </box>
                  )
                }

                return (
                  <box orientation={Gtk.Orientation.VERTICAL} class="cliphist-list" spacing={4}>
                    {items.map((item, index) => {
                      let typeIcon = "description"
                      let typeBadge = "TEXTO"
                      let badgeClass = "badge-text"

                      if (item.type === "image") {
                        typeIcon = "image"
                        typeBadge = "IMAGEN"
                        badgeClass = "badge-image"
                      } else if (item.type === "code") {
                        typeIcon = "code"
                        typeBadge = "CÓDIGO"
                        badgeClass = "badge-code"
                      } else if (item.type === "link") {
                        typeIcon = "link"
                        typeBadge = "ENLACE"
                        badgeClass = "badge-link"
                      }

                      return (
                        <box
                          class={selectedIndex((sel) =>
                            sel === index ? "cliphist-row selected" : "cliphist-row"
                          )}
                          spacing={8}
                          valign={Gtk.Align.CENTER}
                          $={(self) => {
                            const motion = new Gtk.EventControllerMotion()
                            motion.connect("enter", () => {
                              setSelectedIndex(index)
                            })
                            self.add_controller(motion)
                          }}
                        >
                          {/* Botón principal para copiar y auto-pegar al hacer clic */}
                          <button
                            class="cliphist-row-main"
                            hexpand
                            canFocus={false}
                            focusable={false}
                            cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
                            onClicked={() => copyItem(item)}
                          >
                            <box spacing={10} valign={Gtk.Align.CENTER}>
                              {/* Icono de tipo */}
                              <box class={`cliphist-type-icon ${badgeClass}`} valign={Gtk.Align.CENTER}>
                                <label class="font-icon" label={typeIcon} />
                              </box>

                              {/* Contenido textual */}
                              <box
                                orientation={Gtk.Orientation.VERTICAL}
                                spacing={2}
                                hexpand
                                valign={Gtk.Align.CENTER}
                              >
                                <box spacing={8} valign={Gtk.Align.CENTER}>
                                  <label
                                    class={`cliphist-tag ${badgeClass}`}
                                    label={typeBadge}
                                    halign={Gtk.Align.START}
                                  />
                                  {/* Fecha y hora exacta en lugar del ID #numero */}
                                  <label
                                    class="cliphist-time-label font-ui"
                                    label={item.timestamp}
                                    halign={Gtk.Align.START}
                                  />
                                </box>
                                <label
                                  class="cliphist-item-text font-ui"
                                  label={item.preview}
                                  halign={Gtk.Align.START}
                                  ellipsize={3}
                                />
                              </box>
                            </box>
                          </button>

                          {/* Botones de acción agrupados: Copiar (dos papeles) y Eliminar (trash) */}
                          <box class="cliphist-row-actions" spacing={4} valign={Gtk.Align.CENTER}>
                            <button
                              class="cliphist-action-btn cliphist-copy-btn"
                              canFocus={false}
                              focusable={false}
                              tooltipText="Copiar y Pegar"
                              cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
                              onClicked={() => copyItem(item)}
                            >
                              <label class="font-icon" label="content_copy" />
                            </button>

                            <button
                              class="cliphist-action-btn cliphist-del-btn"
                              canFocus={false}
                              focusable={false}
                              tooltipText="Eliminar del historial (Supr)"
                              cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
                              onClicked={() => deleteItem(item)}
                            >
                              <label class="font-icon" label="delete" />
                            </button>
                          </box>
                        </box>
                      )
                    })}
                  </box>
                )
              }}
            </With>
          </scrolledwindow>

          {/* ── 4. Pie con Atajos de Teclado (Limpio, sin indicador 95%) ── */}
          <box class="cliphist-footer" spacing={14} halign={Gtk.Align.CENTER} valign={Gtk.Align.CENTER}>
            <box spacing={4} valign={Gtk.Align.CENTER}>
              <label class="cliphist-key-pill font-dots" label="↑↓" />
              <label class="cliphist-key-label font-ui" label="Navegar" />
            </box>
            <box spacing={4} valign={Gtk.Align.CENTER}>
              <label class="cliphist-key-pill font-dots" label="↵" />
              <label class="cliphist-key-label font-ui" label="Copiar y Pegar" />
            </box>
            <box spacing={4} valign={Gtk.Align.CENTER}>
              <label class="cliphist-key-pill font-dots" label="Supr" />
              <label class="cliphist-key-label font-ui" label="Borrar" />
            </box>
            <box spacing={4} valign={Gtk.Align.CENTER}>
              <label class="cliphist-key-pill font-dots" label="Esc" />
              <label class="cliphist-key-label font-ui" label="Cerrar" />
            </box>
          </box>
        </box>
      </box>
    </window>
  )
}
