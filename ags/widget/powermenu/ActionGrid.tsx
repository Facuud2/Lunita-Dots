import { Gtk, Gdk } from "ags/gtk4"
import { execAsync } from "ags/process"
import { closePowerMenu } from "./PowerMenuState"

export default function ActionGrid() {
  const shutdown = () => {
    closePowerMenu()
    execAsync("systemctl poweroff").catch(() => {})
  }

  const reboot = () => {
    closePowerMenu()
    execAsync("systemctl reboot").catch(() => {})
  }

  const suspend = () => {
    closePowerMenu()
    execAsync("systemctl suspend").catch(() => {})
  }

  const logout = () => {
    closePowerMenu()
    execAsync("uwsm stop || loginctl terminate-user $USER || hyprctl dispatch exit").catch(() => {})
  }

  return (
    <box class="pm-card pm-actions-card" orientation={Gtk.Orientation.VERTICAL} spacing={10} halign={Gtk.Align.CENTER}>
      {/* Fila 1: Shutdown & Reboot */}
      <box spacing={10} halign={Gtk.Align.CENTER}>
        <button
          canFocus={false}
          focusable={false}
          class="pm-action-btn pm-btn-shutdown"
          tooltipText="Apagar equipo (s)"
          onClicked={shutdown}
          cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
        >
          <label class="font-icon" label="power_settings_new" />
        </button>

        <button
          canFocus={false}
          focusable={false}
          class="pm-action-btn pm-btn-reboot"
          tooltipText="Reiniciar equipo (r)"
          onClicked={reboot}
          cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
        >
          <label class="font-icon" label="restart_alt" />
        </button>
      </box>

      {/* Fila 2: Suspend & Logout */}
      <box spacing={10} halign={Gtk.Align.CENTER}>
        <button
          canFocus={false}
          focusable={false}
          class="pm-action-btn pm-btn-suspend"
          tooltipText="Suspender (u)"
          onClicked={suspend}
          cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
        >
          <label class="font-icon" label="mode_night" />
        </button>

        <button
          canFocus={false}
          focusable={false}
          class="pm-action-btn pm-btn-logout"
          tooltipText="Cerrar sesión (e)"
          onClicked={logout}
          cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
        >
          <label class="font-icon" label="logout" />
        </button>
      </box>
    </box>
  )
}
