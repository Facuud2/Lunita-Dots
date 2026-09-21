import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { execAsync } from "ags/process"
import {
  activePowerMenuMonitor,
  closePowerMenu,
  panelAnimClass,
  isPowerMenuClosing,
} from "./powermenu/PowerMenuState"
import MusicCard from "./powermenu/MusicCard"
import SlidersCard from "./powermenu/SlidersCard"
import TimeCard from "./powermenu/TimeCard"
import StatsCard from "./powermenu/StatsCard"
import ProfileCard from "./powermenu/ProfileCard"
import ActionGrid from "./powermenu/ActionGrid"
import FetchCard from "./powermenu/FetchCard"
import BottomClock from "./powermenu/BottomClock"

export default function PowerMenu(gdkmonitor: Gdk.Monitor) {
  const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor
  const connector = gdkmonitor.get_connector() || ""
  let centerClusterRef: Gtk.Widget | null = null

  return (
    <window
      name={`power-menu-${connector}`}
      class="pm-window"
      gdkmonitor={gdkmonitor}
      anchor={TOP | BOTTOM | LEFT | RIGHT}
      exclusivity={Astal.Exclusivity.IGNORE}
      layer={Astal.Layer.OVERLAY}
      application={app}
      visible={activePowerMenuMonitor((m) => m === connector)}
      keymode={Astal.Keymode.EXCLUSIVE}

      $={(self) => {
        // Controlador de teclado para atajos y escape
        const key = new Gtk.EventControllerKey()
        key.set_propagation_phase(Gtk.PropagationPhase.CAPTURE)
        key.connect("key-pressed", (_c: any, keyval: number) => {
          if (isPowerMenuClosing()) return true

          // Escape para cerrar
          if (keyval === Gdk.KEY_Escape) {
            closePowerMenu()
            return true
          }

          // Atajo 's' o 'S' -> Apagar
          if (keyval === Gdk.KEY_s || keyval === Gdk.KEY_S) {
            closePowerMenu()
            execAsync("systemctl poweroff").catch(() => {})
            return true
          }

          // Atajo 'r' o 'R' -> Reiniciar
          if (keyval === Gdk.KEY_r || keyval === Gdk.KEY_R) {
            closePowerMenu()
            execAsync("systemctl reboot").catch(() => {})
            return true
          }

          // Atajo 'u' o 'U' -> Suspender
          if (keyval === Gdk.KEY_u || keyval === Gdk.KEY_U) {
            closePowerMenu()
            execAsync("systemctl suspend").catch(() => {})
            return true
          }

          // Atajo 'e' o 'E' -> Salir / Logout
          if (keyval === Gdk.KEY_e || keyval === Gdk.KEY_E) {
            closePowerMenu()
            execAsync("uwsm stop || loginctl terminate-user $USER || hyprctl dispatch exit").catch(() => {})
            return true
          }

          return false
        })
        self.add_controller(key)
      }}
    >
      <box
        class="pm-fullscreen-root"
        orientation={Gtk.Orientation.VERTICAL}
        hexpand
        vexpand
        halign={Gtk.Align.FILL}
        valign={Gtk.Align.FILL}
        $={(self) => {
          // Detectar clic fuera del cuadro central para cerrar el overlay
          const click = new Gtk.GestureClick()
          click.set_propagation_phase(Gtk.PropagationPhase.CAPTURE)
          click.connect("pressed", (gesture, _n, x, y) => {
            if (!centerClusterRef) return
            const picked = self.pick(x, y, Gtk.PickFlags.DEFAULT)
            let cur = picked
            let inside = false
            while (cur) {
              if (cur === centerClusterRef) {
                inside = true
                break
              }
              cur = cur.get_parent()
            }
            if (!inside) {
              gesture.set_state(Gtk.EventSequenceState.CLAIMED)
              closePowerMenu()
            }
          })
          self.add_controller(click)
        }}
      >
        {/* Fila Superior: Tarjeta de Fetch en la esquina izquierda */}
        <box class="pm-top-row" halign={Gtk.Align.FILL} valign={Gtk.Align.START}>
          <box class="pm-corner-topleft" halign={Gtk.Align.START} valign={Gtk.Align.START}>
            <FetchCard />
          </box>
        </box>

        {/* Zona Central: Cluster principal de tarjetas del PowerMenu */}
        <box
          class="pm-center-wrapper"
          hexpand
          vexpand
          halign={Gtk.Align.CENTER}
          valign={Gtk.Align.CENTER}
        >
          <box
            $={(self) => {
              centerClusterRef = self
            }}
            class={panelAnimClass}
            spacing={16}
            halign={Gtk.Align.CENTER}
            valign={Gtk.Align.CENTER}
          >
            {/* Columna 1: Tarjeta de Música */}
            <MusicCard />

            {/* Columna 2: Sliders arriba, Reloj abajo */}
            <box orientation={Gtk.Orientation.VERTICAL} spacing={14} valign={Gtk.Align.CENTER}>
              <SlidersCard />
              <TimeCard />
            </box>

            {/* Columna 3: Estadísticas circulares y Sitios web */}
            <box valign={Gtk.Align.CENTER}>
              <StatsCard />
            </box>

            {/* Columna 4: Perfil de usuario arriba, Cuadrícula de acciones abajo */}
            <box orientation={Gtk.Orientation.VERTICAL} spacing={14} valign={Gtk.Align.CENTER}>
              <ProfileCard />
              <ActionGrid />
            </box>
          </box>
        </box>

        {/* Fila Inferior: Reloj grande de marca de agua a la derecha */}
        <box class="pm-bottom-row" halign={Gtk.Align.FILL} valign={Gtk.Align.END}>
          <box hexpand />
          <box class="pm-corner-bottomright" halign={Gtk.Align.END} valign={Gtk.Align.END}>
            <BottomClock />
          </box>
        </box>
      </box>
    </window>
  )
}
