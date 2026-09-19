import { Gtk } from "ags/gtk4"
import { getSystemFetch } from "./PowerMenuState"

export default function FetchCard() {
  const fetch = getSystemFetch()

  const archAscii = `   /\\
  /  \\
 /    \\
/  __  \\
| /  \\ |
\\_\\  /_/`

  return (
    <box class="pm-card pm-fetch-card" spacing={16} valign={Gtk.Align.START} halign={Gtk.Align.START}>
      {/* Logo ASCII de Arch Linux */}
      <label
        class="pm-fetch-ascii font-dots"
        label={archAscii}
        valign={Gtk.Align.CENTER}
      />

      {/* Especificaciones del Sistema */}
      <box orientation={Gtk.Orientation.VERTICAL} spacing={4} valign={Gtk.Align.CENTER}>
        {/* user@host */}
        <label
          class="pm-fetch-user font-dots"
          label={`${fetch.user}@${fetch.host}`}
          halign={Gtk.Align.START}
        />

        {/* Distro */}
        <box spacing={6} halign={Gtk.Align.START}>
          <label class="pm-fetch-dot dot-red" label="󰣇" />
          <label class="pm-fetch-text font-dots" label={fetch.distro} />
        </box>

        {/* Init */}
        <box spacing={6} halign={Gtk.Align.START}>
          <label class="pm-fetch-dot dot-yellow" label="󱐌" />
          <label class="pm-fetch-text font-dots" label={fetch.init} />
        </box>

        {/* Packages */}
        <box spacing={6} halign={Gtk.Align.START}>
          <label class="pm-fetch-dot dot-cyan" label="󰏖" />
          <label class="pm-fetch-text font-dots" label={String(fetch.pkgs)} />
        </box>

        {/* Shell / Terminal */}
        <box spacing={6} halign={Gtk.Align.START}>
          <label class="pm-fetch-dot dot-purple" label="󰞷" />
          <label class="pm-fetch-text font-dots" label={fetch.shell} />
        </box>

        {/* Prompt line */}
        <label
          class="pm-fetch-prompt font-dots"
          label="-> ~/"
          halign={Gtk.Align.START}
        />
      </box>
    </box>
  )
}
