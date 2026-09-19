import { Gtk } from "ags/gtk4"
import { statusTraySystem } from "./services"

export default function StatusTraySystem() {
  return (
    <box class="stats-card" orientation={Gtk.Orientation.VERTICAL} spacing={6} hexpand>
      {/* CPU Meter */}
      <box spacing={8} valign={Gtk.Align.CENTER}>
        <label class="font-icon meter-icon" label="memory" />
        <label class="meter-label" label="CPU" />
        <box class="meter-track" hexpand valign={Gtk.Align.CENTER}>
          <box
            class={statusTraySystem((m) =>
              m.cpu > 80 ? "meter-fill alert" : "meter-fill"
            )}
            css={statusTraySystem((m) => `min-width: ${Math.max(4, m.cpu * 1.4)}px;`)}
          />
        </box>
        <label class="meter-val font-dots" label={statusTraySystem((m) => `${m.cpu}%`)} />
        <box spacing={2} valign={Gtk.Align.CENTER}>
          <label class="font-icon temp-icon alert" label="local_fire_department" />
          <label class="temp-val font-dots" label={statusTraySystem((m) => `${m.cpuTemp}°`)} />
        </box>
      </box>

      {/* RAM Meter */}
      <box spacing={8} valign={Gtk.Align.CENTER}>
        <label class="font-icon meter-icon" label="developer_board" />
        <label class="meter-label" label="RAM" />
        <box class="meter-track" hexpand valign={Gtk.Align.CENTER}>
          <box
            class={statusTraySystem((m) =>
              m.ram > 85 ? "meter-fill alert" : "meter-fill"
            )}
            css={statusTraySystem((m) => `min-width: ${Math.max(4, m.ram * 1.4)}px;`)}
          />
        </box>
        <label class="meter-val font-dots" label={statusTraySystem((m) => `${m.ram}%`)} />
      </box>

      {/* GPU Meter */}
      <box spacing={8} valign={Gtk.Align.CENTER}>
        <label class="font-icon meter-icon" label="videogame_asset" />
        <label class="meter-label" label="GPU" />
        <box class="meter-track" hexpand valign={Gtk.Align.CENTER}>
          <box
            class={statusTraySystem((m) =>
              m.gpu > 80 ? "meter-fill alert" : "meter-fill"
            )}
            css={statusTraySystem((m) => `min-width: ${Math.max(4, m.gpu * 1.4)}px;`)}
          />
        </box>
        <label class="meter-val font-dots" label={statusTraySystem((m) => `${m.gpu}%`)} />
        <box spacing={2} valign={Gtk.Align.CENTER}>
          <label class="font-icon temp-icon alert" label="local_fire_department" />
          <label class="temp-val font-dots" label={statusTraySystem((m) => `${m.gpuTemp}°`)} />
        </box>
      </box>
    </box>
  )
}
