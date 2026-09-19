import { Gtk, Gdk } from "ags/gtk4"
import { createState, For } from "ags"
import { execAsync } from "ags/process"
import {
  networkState,
  wifiNetworks,
  WifiNetwork,
  toggleWifi,
  fetchWifiNetworks,
} from "./services"

export default function NetworkOverlay({ onClose }: { onClose: () => void }) {
  const [activeTab, setActiveTab] = createState<"wifi" | "ethernet">("wifi")
  const [scanning, setScanning] = createState(false)
  const pointerCursor = Gdk.Cursor.new_from_name("pointer", null)

  const toggleWifiRadio = () => {
    toggleWifi()
  }

  const rescanWifi = () => {
    setScanning(true)
    execAsync("nmcli dev wifi list --rescan yes")
      .then(() => {
        setScanning(false)
        fetchWifiNetworks()
      })
      .catch(() => {
        setScanning(false)
        fetchWifiNetworks()
      })
  }

  const connectToWifi = (ssid: string) => {
    execAsync(`nmcli dev wifi connect "${ssid}"`).catch(() => {
      execAsync(`nm-connection-editor`).catch(() => {})
    })
  }

  const openConnectionEditor = () => {
    execAsync("nm-connection-editor").catch(() => {})
  }

  return (
    <box orientation={Gtk.Orientation.VERTICAL} class="island-overlay-card" spacing={12}>
      {/* ── Title Bar ── */}
      <box class="overlay-header" valign={Gtk.Align.CENTER}>
        <label class="overlay-title" label="RED Y CONECTIVIDAD" />
        <box hexpand />
        <button class="overlay-close-btn" onClicked={onClose} cursor={pointerCursor as any}>
          <label class="font-icon" label="close" />
        </button>
      </box>

      {/* ── Tabs: Wi-Fi & Ethernet ── */}
      <box class="overlay-tabs" spacing={8} homogeneous>
        <button
          class={activeTab((t) => (t === "wifi" ? "overlay-tab active" : "overlay-tab"))}
          onClicked={() => setActiveTab("wifi")}
          cursor={pointerCursor as any}
        >
          <box spacing={6} halign={Gtk.Align.CENTER} valign={Gtk.Align.CENTER}>
            <label class="font-icon" label="wifi" />
            <label label="WI-FI" class="label-uppercase" />
          </box>
        </button>

        <button
          class={activeTab((t) => (t === "ethernet" ? "overlay-tab active" : "overlay-tab"))}
          onClicked={() => setActiveTab("ethernet")}
          cursor={pointerCursor as any}
        >
          <box spacing={6} halign={Gtk.Align.CENTER} valign={Gtk.Align.CENTER}>
            <label class="font-icon" label="lan" />
            <label label="ETHERNET" class="label-uppercase" />
          </box>
        </button>
      </box>

      {/* ── Tab Content: Wi-Fi ── */}
      <box
        orientation={Gtk.Orientation.VERTICAL}
        spacing={10}
        visible={activeTab((t) => t === "wifi")}
      >
        {/* Toggle Switch Card */}
        <button
          class="overlay-toggle-card"
          valign={Gtk.Align.CENTER}
          onClicked={toggleWifiRadio}
          cursor={pointerCursor as any}
        >
          <box spacing={8} valign={Gtk.Align.CENTER}>
            <label
              class="font-icon pill-icon-bg"
              label={networkState((n) => (n.wifiEnabled ? "wifi" : "wifi_off"))}
            />
            <box orientation={Gtk.Orientation.VERTICAL} spacing={1}>
              <label class="pill-title" label="Wi-Fi" halign={Gtk.Align.START} />
              <label
                class="pill-subtitle"
                label={networkState((n) => (n.wifiEnabled ? "HABILITADO" : "DESHABILITADO"))}
                halign={Gtk.Align.START}
              />
            </box>
            <box hexpand />
            <box
              class={networkState((n) => (n.wifiEnabled ? "m3-switch active" : "m3-switch"))}
            >
              <box class="m3-handle" />
            </box>
          </box>
        </button>

        {/* Scan & Actions Header */}
        <box spacing={8} valign={Gtk.Align.CENTER}>
          <label class="section-label" label="REDES DISPONIBLES" halign={Gtk.Align.START} />
          <box hexpand />
          <button class="overlay-mini-btn" onClicked={rescanWifi} cursor={pointerCursor as any}>
            <label class="font-icon" label="refresh" />
          </button>
          <button class="overlay-mini-btn" onClicked={openConnectionEditor} cursor={pointerCursor as any}>
            <label class="font-icon" label="settings" />
          </button>
        </box>

        {/* Networks List (Scrolled) */}
        <scrolledwindow minContentHeight={160} maxContentHeight={220} hscrollbarPolicy={Gtk.PolicyType.NEVER}>
          <box orientation={Gtk.Orientation.VERTICAL} spacing={4} class="device-list">
            <For each={wifiNetworks}>
              {(net: WifiNetwork) => (
                <button
                  class={net.connected ? "device-row active" : "device-row"}
                  onClicked={() => connectToWifi(net.ssid)}
                  cursor={pointerCursor as any}
                >
                  <box spacing={8} valign={Gtk.Align.CENTER}>
                    <label class="font-icon" label={net.connected ? "check_circle" : "wifi"} />
                    <box orientation={Gtk.Orientation.VERTICAL} spacing={1} hexpand>
                      <label class="device-name" label={net.ssid} halign={Gtk.Align.START} />
                      <label
                        class="device-detail"
                        label={net.connected ? "Conectado" : `${net.security} • ${net.signal}%`}
                        halign={Gtk.Align.START}
                      />
                    </box>
                    <label class="font-dots device-signal" label={`${net.signal}%`} />
                  </box>
                </button>
              )}
            </For>
          </box>
        </scrolledwindow>
      </box>

      {/* ── Tab Content: Ethernet ── */}
      <box
        orientation={Gtk.Orientation.VERTICAL}
        spacing={10}
        visible={activeTab((t) => t === "ethernet")}
      >
        <box class="overlay-toggle-card" valign={Gtk.Align.CENTER}>
          <box spacing={8} valign={Gtk.Align.CENTER}>
            <label
              class="font-icon pill-icon-bg"
              label={networkState((n) => (n.ethernetConnected ? "lan" : "link_off"))}
            />
            <box orientation={Gtk.Orientation.VERTICAL} spacing={1}>
              <label class="pill-title" label="Conexión Cableada" halign={Gtk.Align.START} />
              <label
                class="pill-subtitle"
                label={networkState((n) =>
                  n.ethernetConnected ? "CABLE CONECTADO (1 Gbps)" : "DESCONECTADO"
                )}
                halign={Gtk.Align.START}
              />
            </box>
          </box>
        </box>

        <box class="ethernet-info-card" orientation={Gtk.Orientation.VERTICAL} spacing={8}>
          <box valign={Gtk.Align.CENTER}>
            <label class="stat-label" label="ESTADO:" />
            <box hexpand />
            <label
              class="device-name font-dots"
              label={networkState((n) => (n.ethernetConnected ? "ONLINE" : "OFFLINE"))}
            />
          </box>
          <box valign={Gtk.Align.CENTER}>
            <label class="stat-label" label="INTERFAZ:" />
            <box hexpand />
            <label
              class="device-name"
              label={networkState((n) => (n.isEthernet ? n.name : "eth0"))}
            />
          </box>
        </box>

        <button
          class="overlay-action-btn"
          onClicked={openConnectionEditor}
          cursor={pointerCursor as any}
        >
          <box spacing={8} halign={Gtk.Align.CENTER} valign={Gtk.Align.CENTER}>
            <label class="font-icon" label="tune" />
            <label label="ABRIR CONFIGURACIÓN DE RED (NM-APPLET)" class="label-uppercase" />
          </box>
        </button>
      </box>
    </box>
  )
}
