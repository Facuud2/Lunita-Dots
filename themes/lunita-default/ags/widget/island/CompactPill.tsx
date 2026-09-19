import { Gtk } from "ags/gtk4"
import {
  clock,
  activeWorkspace,
  networkState,
  volumeState,
  setSystemVolume,
  toggleSystemMute,
  batteryState,
  mediaState,
  bluetoothState,
} from "./services"

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

      {/* ── Right Group: Network, Bluetooth, Volume & Battery / Media ── */}
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

        {/* Bluetooth indicator */}
        <box spacing={4} valign={Gtk.Align.CENTER}>
          <label
            class={bluetoothState((bt) =>
              !bt.enabled
                ? "status-icon bt-off"
                : bt.connectedDevice
                ? "status-icon bt-connected"
                : "status-icon"
            )}
            label={bluetoothState((bt) =>
              !bt.enabled
                ? "bluetooth_disabled"
                : bt.connectedDevice
                ? "bluetooth_connected"
                : "bluetooth"
            )}
          />
        </box>

        {/* Audio Volume indicator (scroll wheel to change volume, click to mute) */}
        <box
          spacing={4}
          valign={Gtk.Align.CENTER}
          $={(self) => {
            const scroll = new Gtk.EventControllerScroll()
            scroll.set_flags(Gtk.EventControllerScrollFlags.VERTICAL)
            scroll.connect("scroll", (_c, _dx, dy) => {
              const cur = volumeState.peek().volume
              const next = dy < 0 ? Math.min(100, cur + 2) : Math.max(0, cur - 2)
              setSystemVolume(next)
              return true
            })
            self.add_controller(scroll)

            const click = new Gtk.GestureClick()
            click.set_button(1)
            click.connect("released", () => {
              toggleSystemMute()
            })
            self.add_controller(click)
          }}
        >
          <label
            class={volumeState((vol) =>
              vol.muted || vol.volume === 0 ? "status-icon muted" : "status-icon"
            )}
            label={volumeState((vol) =>
              vol.muted || vol.volume === 0
                ? "volume_off"
                : vol.volume < 33
                ? "volume_mute"
                : vol.volume < 66
                ? "volume_down"
                : "volume_up"
            )}
          />
          <label
            class={volumeState((vol) =>
              vol.muted || vol.volume === 0
                ? "status-item font-dots muted-text"
                : "status-item font-dots"
            )}
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
