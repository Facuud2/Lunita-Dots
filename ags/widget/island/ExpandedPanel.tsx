import { Gtk, Gdk } from "ags/gtk4"
import { createState, With } from "ags"
import { execAsync } from "ags/process"
import {
  clock,
  networkState,
  bluetoothState,
  volumeState,
  setSystemVolume,
  toggleSystemMute,
  systemMeters,
  updateSystemMetrics,
} from "./services"
import MediaCard from "./MediaCard"
import NetworkOverlay from "./NetworkOverlay"
import BluetoothOverlay from "./BluetoothOverlay"
import StatusTraySystem from "./StatusTraySystem"
import NotificationOverlay from "./NotificationOverlay"
import { notifications } from "./NotificationService"
import { toggleLauncher } from "../launcher/LauncherState"
import { togglePowerMenu } from "../powermenu/PowerMenuState"
import { activeOverlayState as activeOverlay, setActiveOverlayState as setActiveOverlay } from "../islandState"
import {
  recordingState,
  toggleRecording,
  toggleSystemAudio,
  toggleMicAudio,
} from "./RecordingService"

export default function ExpandedPanel({
  onClose,
}: {
  onClose?: () => void
}) {
  const [coffeeMode, setCoffeeMode] = createState(false)

  // Ensure fresh system metrics right when panel opens
  updateSystemMetrics().catch(() => {})

  const toggleCoffee = () => {
    const next = !coffeeMode.peek()
    setCoffeeMode(next)
    if (next) {
      execAsync("systemd-inhibit --what=idle:sleep --why='Coffee Mode' sleep infinity &").catch(() => {})
    } else {
      execAsync("pkill -f 'Coffee Mode'").catch(() => {})
    }
  }

  const toggleMute = () => {
    execAsync("pamixer -t").catch(() => {})
  }

  const openAppLauncher = () => {
    onClose?.()
    // Small delay so island closes gracefully before launcher opens
    setTimeout(() => toggleLauncher(), 160)
  }

  const openPowerMenu = () => {
    onClose?.()
    setTimeout(() => togglePowerMenu(), 160)
  }

  const openLockScreen = () => {
    execAsync(["bash", "-c", "$HOME/.config/hypr/scripts/smart_lock.sh classic || hyprlock"]).catch(() => {})
    onClose?.()
  }

  return (
    <box orientation={Gtk.Orientation.VERTICAL} class="expanded-panel" spacing={10}>
      {/* ── Overlay Display (Conditional) ── */}
      <With value={activeOverlay}>
        {(overlay) => {
          if (overlay === "wifi") {
            return <NetworkOverlay onClose={() => setActiveOverlay("none")} />
          }
          if (overlay === "bt") {
            return <BluetoothOverlay onClose={() => setActiveOverlay("none")} />
          }
          if (overlay === "notifications") {
            return <NotificationOverlay onClose={() => setActiveOverlay("none")} />
          }

          return (
            <box orientation={Gtk.Orientation.VERTICAL} spacing={10}>
              {/* ── 1. Header: Large Clock + Date ── */}
              <box class="header-clock" valign={Gtk.Align.CENTER}>
                {/* Large Time + Seconds */}
                <box spacing={4} valign={Gtk.Align.END}>
                  <label class="large-clock" label={clock((c) => c.time)} />
                  <label class="small-seconds" label={clock((c) => c.sec)} />
                </box>

                {/* Date / Calendar Card */}
                <box hexpand halign={Gtk.Align.END} valign={Gtk.Align.CENTER}>
                  <button
                    class="date-card"
                    onClicked={() => {}}
                    cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
                  >
                    <box orientation={Gtk.Orientation.VERTICAL} spacing={2} halign={Gtk.Align.END}>
                      <label class="date-title" label={clock((c) => c.date)} />
                      <label class="date-sub" label="CALENDARIO" />
                    </box>
                  </button>
                </box>
              </box>

              {/* ── 2. Status Pills Row: Network, Bluetooth, Audio ── */}
              <box class="status-pills-row" spacing={8} homogeneous>
                {/* Network Pill -> Opens Network Overlay */}
                <button
                  class={networkState((net) =>
                    net.connected ? "status-pill active" : "status-pill"
                  )}
                  onClicked={() => setActiveOverlay("wifi")}
                >
                  <box spacing={8} valign={Gtk.Align.CENTER}>
                    <label
                      class="font-icon pill-icon-bg"
                      label={networkState((net) =>
                        !net.connected ? "wifi_off" : net.isWifi ? "wifi" : "lan"
                      )}
                    />
                    <box orientation={Gtk.Orientation.VERTICAL} spacing={1}>
                      <label
                        class="pill-title"
                        label={networkState((net) => net.name)}
                        halign={Gtk.Align.START}
                        ellipsize={3}
                      />
                      <label
                        class="pill-subtitle"
                        label={networkState((net) =>
                          net.connected ? "CONECTADO" : "SIN RED"
                        )}
                        halign={Gtk.Align.START}
                      />
                    </box>
                  </box>
                </button>

                {/* Bluetooth Pill -> Opens Bluetooth Overlay */}
                <button
                  class={bluetoothState((b) =>
                    b.enabled ? "status-pill active" : "status-pill"
                  )}
                  onClicked={() => setActiveOverlay("bt")}
                >
                  <box spacing={8} valign={Gtk.Align.CENTER}>
                    <label
                      class="font-icon pill-icon-bg"
                      label={bluetoothState((b) =>
                        b.enabled ? "bluetooth" : "bluetooth_disabled"
                      )}
                    />
                    <box orientation={Gtk.Orientation.VERTICAL} spacing={1}>
                      <label class="pill-title" label="Bluetooth" halign={Gtk.Align.START} />
                      <label
                        class="pill-subtitle"
                        label={bluetoothState((b) =>
                          b.enabled
                            ? b.connectedDevice || "ENCENDIDO"
                            : "APAGADO"
                        )}
                        halign={Gtk.Align.START}
                        ellipsize={3}
                      />
                    </box>
                  </box>
                </button>

                {/* Audio / Volume Pill -> Drag to change volume, right-click to mute */}
                {(() => {
                  let dragStartVol = 0
                  let isDragging = false

                  return (
                    <box
                      class={volumeState((v) =>
                        !v.muted && v.volume > 0 ? "status-pill audio-pill active" : "status-pill audio-pill"
                      )}
                      cursor={Gdk.Cursor.new_from_name("ew-resize", null) as any}
                      $={(self) => {
                        // ── Drag gesture: adjust volume only on genuine movement ──
                        const drag = new Gtk.GestureDrag()
                        drag.connect("drag-begin", () => {
                          dragStartVol = volumeState.peek().volume
                          isDragging = false
                        })
                        drag.connect("drag-update", (_g: any, dx: number) => {
                          if (!isDragging && Math.abs(dx) < 6) return
                          isDragging = true
                          const delta = Math.round((dx / 140) * 100)
                          const next = Math.max(0, Math.min(100, dragStartVol + delta))
                          setSystemVolume(next)
                        })
                        drag.connect("drag-end", () => {
                          isDragging = false
                        })
                        self.add_controller(drag)

                        // ── Click gesture: toggle mute on normal click ──
                        const click = new Gtk.GestureClick()
                        click.set_button(1)
                        click.connect("released", () => {
                          if (!isDragging) {
                            toggleSystemMute()
                          }
                        })
                        self.add_controller(click)

                        // ── Mouse scroll: finely adjust volume ──
                        const scroll = new Gtk.EventControllerScroll()
                        scroll.set_flags(Gtk.EventControllerScrollFlags.VERTICAL)
                        scroll.connect("scroll", (_c, _dx, dy) => {
                          const cur = volumeState.peek().volume
                          const next = dy < 0 ? Math.min(100, cur + 2) : Math.max(0, cur - 2)
                          setSystemVolume(next)
                          return true
                        })
                        self.add_controller(scroll)
                      }}
                    >
                      <box spacing={8} valign={Gtk.Align.CENTER} hexpand>
                        <label
                          class="font-icon pill-icon-bg"
                          label={volumeState((v) => (v.muted || v.volume === 0 ? "volume_off" : "volume_up"))}
                        />
                        <box orientation={Gtk.Orientation.VERTICAL} spacing={1} hexpand>
                          <label
                            class="pill-title font-dots"
                            label={volumeState((v) => `${v.volume}%`)}
                            halign={Gtk.Align.START}
                          />
                          <label
                            class="pill-subtitle"
                            label={volumeState((v) => (v.muted || v.volume === 0 ? "MUTED" : "VOLUMEN"))}
                            halign={Gtk.Align.START}
                          />
                        </box>
                        {/* Inline volume bar — driven directly by volumeState */}
                        <box class="audio-pill-track" valign={Gtk.Align.CENTER}>
                          <box
                            class="audio-pill-fill"
                            css={volumeState((v) =>
                              `min-width: ${Math.max(2, Math.round(v.volume * 0.44))}px;`
                            )}
                          />
                        </box>
                      </box>
                    </box>
                  )
                })()}
              </box>

              {/* ── 3. Media Player Card (1:1 with Waveform & Timestamps) ── */}
              <MediaCard />

              {/* ── 4. Recording & Meters Row (CPU, RAM, GPU) ── */}
              <box class="meters-row" spacing={8}>
                {/* Screen Recording Card with Audio Toggles */}
                <box
                  class={recordingState((r) => (r.isRecording ? "rec-card recording" : "rec-card"))}
                  spacing={6}
                  valign={Gtk.Align.CENTER}
                >
                  {/* Main screen recording action button */}
                  <button
                    class="rec-main-action"
                    onClicked={toggleRecording}
                    cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
                  >
                    <box spacing={8} valign={Gtk.Align.CENTER}>
                      <box class="rec-badge" valign={Gtk.Align.CENTER}>
                        <label
                          class="font-icon rec-icon"
                          label={recordingState((r) => (r.isRecording ? "stop" : "fiber_manual_record"))}
                        />
                      </box>
                      <box orientation={Gtk.Orientation.VERTICAL} spacing={1} valign={Gtk.Align.CENTER}>
                        <label class="rec-title" label="GRABACIÓN" halign={Gtk.Align.START} />
                        <label
                          class="rec-time font-dots"
                          label={recordingState((r) =>
                            r.isRecording ? r.formattedDuration || "REC • ON" : "00:00"
                          )}
                          halign={Gtk.Align.START}
                        />
                      </box>
                    </box>
                  </button>

                  {/* Vertical divider */}
                  <box class="rec-divider" valign={Gtk.Align.FILL} />

                  {/* Audio toggles: System audio & Microphone */}
                  <box
                    class="rec-toggles"
                    orientation={Gtk.Orientation.VERTICAL}
                    spacing={3}
                    valign={Gtk.Align.CENTER}
                  >
                    {/* System Audio Toggle */}
                    <button
                      class={recordingState((r) =>
                        r.systemAudio ? "rec-toggle-btn active" : "rec-toggle-btn"
                      )}
                      tooltipText="Sonido del sistema"
                      onClicked={toggleSystemAudio}
                      cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
                    >
                      <label
                        class="font-icon"
                        label={recordingState((r) => (r.systemAudio ? "volume_up" : "volume_off"))}
                      />
                    </button>

                    {/* Microphone Toggle */}
                    <button
                      class={recordingState((r) =>
                        r.micAudio ? "rec-toggle-btn active" : "rec-toggle-btn"
                      )}
                      tooltipText="Micrófono"
                      onClicked={toggleMicAudio}
                      cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
                    >
                      <label
                        class="font-icon"
                        label={recordingState((r) => (r.micAudio ? "mic" : "mic_off"))}
                      />
                    </button>
                  </box>
                </box>

                {/* CPU, RAM, GPU Progress Meters (StatusTraySystem) */}
                <StatusTraySystem />
              </box>

              {/* ── 5. Quick Actions Row (Coffee Mode + Lock, Apps, Power) ── */}
              <box class="quick-actions-row" spacing={8} valign={Gtk.Align.CENTER}>
                {/* Coffee Mode Pill */}
                <button
                  class={coffeeMode((active) =>
                    active ? "coffee-pill active" : "coffee-pill"
                  )}
                  hexpand
                  onClicked={toggleCoffee}
                >
                  <box spacing={8} valign={Gtk.Align.CENTER}>
                    <label class="font-icon coffee-icon" label="coffee" />
                    <label class="coffee-label" label="MODO CAFÉ" />
                    <box hexpand />
                    <box class={coffeeMode((c) => (c ? "m3-switch active" : "m3-switch"))}>
                      <box class="m3-handle" />
                    </box>
                  </box>
                </button>

                {/* Lock Screen Action */}
                <button class="action-btn" onClicked={openLockScreen}>
                  <label class="font-icon" label="lock" />
                </button>

                {/* System Notifications Action */}
                <button
                  class={notifications((list) =>
                    list.length > 0 ? "action-btn has-unread" : "action-btn"
                  )}
                  onClicked={() => setActiveOverlay("notifications")}
                >
                  <label
                    class="font-icon"
                    label={notifications((list) =>
                      list.length > 0 ? "notifications_active" : "notifications"
                    )}
                  />
                </button>

                {/* Power Menu Action */}
                <button class="action-btn danger" onClicked={openPowerMenu}>
                  <label class="font-icon" label="power_settings_new" />
                </button>
              </box>
            </box>
          )
        }}
      </With>
    </box>
  )
}
