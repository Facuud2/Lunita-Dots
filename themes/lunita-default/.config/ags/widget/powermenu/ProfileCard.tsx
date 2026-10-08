import { Gtk, Gdk } from "ags/gtk4"
import GLib from "gi://GLib"
import { uptimeState, getUserAvatar, closePowerMenu } from "./PowerMenuState"

export default function ProfileCard() {
  const username = GLib.get_user_name() || "facuud2"
  const avatarPath = getUserAvatar()

  return (
    <box class="pm-profile-wrapper" orientation={Gtk.Orientation.VERTICAL} spacing={6}>
      {/* Botón Flotante de Cierre (✕) en la parte superior derecha */}
      <box halign={Gtk.Align.END}>
        <button
          class="pm-exit-btn"
          tooltipText="Cerrar (Esc)"
          onClicked={closePowerMenu}
          cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
        >
          <label class="font-icon" label="close" />
        </button>
      </box>

      {/* Tarjeta de Perfil */}
      <box class="pm-card pm-profile-card" orientation={Gtk.Orientation.VERTICAL} spacing={12} halign={Gtk.Align.CENTER}>
        {/* Avatar Circular */}
        <box class="pm-avatar-container" halign={Gtk.Align.CENTER} valign={Gtk.Align.CENTER}>
          <image
            class="pm-avatar-img"
            file={avatarPath}
            pixelSize={76}
          />
        </box>

        {/* Saludo y Uptime */}
        <box orientation={Gtk.Orientation.VERTICAL} spacing={4} halign={Gtk.Align.CENTER}>
          <label
            class="pm-profile-name font-dots"
            label={`I'm ${username}!`}
            halign={Gtk.Align.CENTER}
          />
          <label
            class="pm-profile-uptime font-dots"
            label={uptimeState((u) => `- ${u}`)}
            halign={Gtk.Align.CENTER}
          />
        </box>
      </box>
    </box>
  )
}
