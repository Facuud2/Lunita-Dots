import { Gtk } from "ags/gtk4"
import { createState, For } from "ags"
import { execAsync } from "ags/process"
import { bluetoothState, BluetoothDevice } from "./services"

export default function BluetoothOverlay({ onClose }: { onClose: () => void }) {
  const [scanning, setScanning] = createState(false)

  const togglePower = () => {
    const isPowered = bluetoothState.peek().enabled
    execAsync(`bluetoothctl power ${isPowered ? "off" : "on"}`).catch(() => {})
  }

  const rescanDevices = () => {
    setScanning(true)
    execAsync("bluetoothctl --timeout 5 scan on")
      .then(() => setScanning(false))
      .catch(() => setScanning(false))
  }

  const connectDevice = (mac: string, connected: boolean) => {
    if (connected) {
      execAsync(`bluetoothctl disconnect ${mac}`).catch(() => {})
    } else {
      execAsync(`bluetoothctl connect ${mac}`).catch(() => {})
    }
  }

  const openBluemanManager = () => {
    execAsync("blueman-manager || rofi-bluetooth").catch(() => {})
  }

  return (
    <box orientation={Gtk.Orientation.VERTICAL} class="island-overlay-card" spacing={12}>
      {/* ── Title Bar ── */}
      <box class="overlay-header" valign={Gtk.Align.CENTER}>
        <label class="overlay-title" label="DISPOSITIVOS BLUETOOTH" />
        <box hexpand />
        <button class="overlay-close-btn" onClicked={onClose}>
          <label class="font-icon" label="close" />
        </button>
      </box>

      {/* ── Toggle Switch Card ── */}
      <box class="overlay-toggle-card" valign={Gtk.Align.CENTER}>
        <box spacing={8} valign={Gtk.Align.CENTER}>
          <label
            class="font-icon pill-icon-bg"
            label={bluetoothState((b) => (b.enabled ? "bluetooth" : "bluetooth_disabled"))}
          />
          <box orientation={Gtk.Orientation.VERTICAL} spacing={1}>
            <label class="pill-title" label="Bluetooth" halign={Gtk.Align.START} />
            <label
              class="pill-subtitle"
              label={bluetoothState((b) =>
                b.enabled
                  ? b.connectedDevice
                    ? `CONECTADO A ${b.connectedDevice.toUpperCase()}`
                    : "ENCENDIDO"
                  : "APAGADO"
              )}
              halign={Gtk.Align.START}
            />
          </box>
        </box>
        <box hexpand />
        <button
          class={bluetoothState((b) => (b.enabled ? "m3-switch active" : "m3-switch"))}
          onClicked={togglePower}
        >
          <box class="m3-handle" />
        </button>
      </box>

      {/* ── Action buttons & Devices list ── */}
      <box
        orientation={Gtk.Orientation.VERTICAL}
        spacing={10}
        visible={bluetoothState((b) => b.enabled)}
      >
        <box spacing={8} valign={Gtk.Align.CENTER}>
          <label class="section-label" label="DISPOSITIVOS EMPAREJADOS" halign={Gtk.Align.START} />
          <box hexpand />
          <button class="overlay-mini-btn" onClicked={rescanDevices}>
            <label class="font-icon" label="search" />
          </button>
          <button class="overlay-mini-btn" onClicked={openBluemanManager}>
            <label class="font-icon" label="settings" />
          </button>
        </box>

        {/* Devices List (Scrolled) */}
        <scrolledwindow minContentHeight={160} maxContentHeight={220} hscrollbarPolicy={Gtk.PolicyType.NEVER}>
          <box orientation={Gtk.Orientation.VERTICAL} spacing={4} class="device-list">
            <For each={bluetoothState((b) => b.devices)}>
              {(dev: BluetoothDevice) => (
                <button
                  class={dev.connected ? "device-row active" : "device-row"}
                  onClicked={() => connectDevice(dev.mac, dev.connected)}
                >
                  <box spacing={8} valign={Gtk.Align.CENTER}>
                    <label
                      class="font-icon"
                      label={
                        dev.connected
                          ? "headphones"
                          : dev.paired
                          ? "bluetooth"
                          : "bluetooth_searching"
                      }
                    />
                    <box orientation={Gtk.Orientation.VERTICAL} spacing={1} hexpand>
                      <label class="device-name" label={dev.name} halign={Gtk.Align.START} />
                      <label
                        class="device-detail"
                        label={dev.connected ? "Conectado • Clic para desconectar" : "Emparejado • Clic para conectar"}
                        halign={Gtk.Align.START}
                      />
                    </box>
                    <label
                      class={dev.connected ? "device-status-badge active" : "device-status-badge"}
                      label={dev.connected ? "ON" : "OFF"}
                    />
                  </box>
                </button>
              )}
            </For>
          </box>
        </scrolledwindow>

        <button class="overlay-action-btn" onClicked={openBluemanManager}>
          <box spacing={8} halign={Gtk.Align.CENTER} valign={Gtk.Align.CENTER}>
            <label class="font-icon" label="bluetooth_searching" />
            <label label="ABRIR ADMINISTRADOR BLUEMAN" class="label-uppercase" />
          </box>
        </button>
      </box>
    </box>
  )
}
