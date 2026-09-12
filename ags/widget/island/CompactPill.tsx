import { Gtk } from "ags/gtk4"
import { clock, activeWorkspace, networkState, volumeState, batteryState, mediaState } from "./services"

export default function CompactPill() {
  const wsArray = [1, 2, 3, 4, 5]

  return (
    <box class="compact-pill" hexpand valign={Gtk.Align.CENTER}>
      {/* ── Left Group: Workspaces ── */}
      <box halign={Gtk.Align.START} valign={Gtk.Align.CENTER} spacing={6}>
        {wsArray.map((wsId) => (
          <box
            class={activeWorkspace((active) =>
              active === wsId ? "ws-dot active" : "ws-dot"
            )}
            valign={Gtk.Align.CENTER}
          />
        ))}
      </box>

      {/* ── Center: NothingOS Dot Matrix Clock ── */}
      <box hexpand halign={Gtk.Align.CENTER} valign={Gtk.Align.CENTER}>
        <label
          class="clock-text"
          label={clock((c) => c.time)}
          valign={Gtk.Align.CENTER}
        />
      </box>

      {/* ── Right Group: Network, Volume & Battery / Media ── */}
      <box halign={Gtk.Align.END} valign={Gtk.Align.CENTER} spacing={10}>
        {/* Network indicator */}
        <box spacing={4} valign={Gtk.Align.CENTER}>
          <label
            class={networkState((net) =>
              !net.connected ? "status-icon alert-icon" : "status-icon"
            )}
            label={networkState((net) =>
              !net.connected ? "wifi_off" : net.isWifi ? "wifi" : "lan"
            )}
          />
        </box>

        {/* Audio Volume indicator */}
        <box spacing={4} valign={Gtk.Align.CENTER}>
          <label
            class={volumeState((vol) =>
              vol.muted ? "status-icon muted" : "status-icon"
            )}
            label={volumeState((vol) =>
              vol.muted ? "volume_off" : "volume_up"
            )}
          />
          <label
            class="status-item font-dots"
            label={volumeState((vol) => `${vol.volume}%`)}
          />
        </box>

        {/* Battery indicator if present */}
        <box
          spacing={4}
          valign={Gtk.Align.CENTER}
          visible={batteryState((bat) => bat.present)}
        >
          <label
            class={batteryState((bat) =>
              bat.percent <= 15 ? "status-icon alert-icon" : "status-icon"
            )}
            label={batteryState((bat) =>
              bat.charging
                ? "battery_charging_full"
                : bat.percent <= 20
                ? "battery_alert"
                : "battery_full"
            )}
          />
          <label
            class="status-item font-dots"
            label={batteryState((bat) => `${bat.percent}%`)}
          />
        </box>
      </box>
    </box>
  )
}
