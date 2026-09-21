import { Gtk, Gdk } from "ags/gtk4"
import { execAsync } from "ags/process"
import { systemMeters } from "../island/services"
import { diskUsageState } from "./PowerMenuState"
import CircularProgress from "./CircularProgress"

export default function StatsCard() {
  const openUrl = (url: string) => {
    execAsync(`xdg-open "${url}"`).catch(() => {})
  }

  return (
    <box class="pm-card pm-stats-card" orientation={Gtk.Orientation.VERTICAL} spacing={14} halign={Gtk.Align.CENTER}>
      {/* Cuadrícula 2x2 de Medidores Circulares */}
      <box class="pm-gauges-grid" orientation={Gtk.Orientation.VERTICAL} spacing={12} halign={Gtk.Align.CENTER}>
        {/* Fila 1: CPU y RAM */}
        <box spacing={14} halign={Gtk.Align.CENTER}>
          {/* CPU Ring (Nothing Red) */}
          <CircularProgress
            value={systemMeters((m) => m.cpu)}
            label={systemMeters((m) => `${m.cpu}%`)}
            hoverLabel="CPU"
            tooltipText={systemMeters((m) => `CPU: ${m.cpu}%`)}
            color="#D71921"
            size={56}
            strokeWidth={5}
          />

          {/* RAM Ring (Nothing White) */}
          <CircularProgress
            value={systemMeters((m) => m.ram)}
            label={systemMeters((m) => `${m.ram}%`)}
            hoverLabel="RAM"
            tooltipText={systemMeters((m) => `RAM: ${m.ram}%`)}
            color="#FFFFFF"
            size={56}
            strokeWidth={5}
          />
        </box>

        {/* Fila 2: Temperatura y Disco */}
        <box spacing={14} halign={Gtk.Align.CENTER}>
          {/* CPU Temperature Ring (Nothing Red) */}
          <CircularProgress
            value={systemMeters((m) => Math.min(100, Math.max(0, m.cpuTemp)))}
            label={systemMeters((m) => `${m.cpuTemp > 0 ? m.cpuTemp : 45}°C`)}
            hoverLabel="TEMP"
            tooltipText={systemMeters((m) => `Temperatura: ${m.cpuTemp > 0 ? m.cpuTemp : 45}°C`)}
            color="#D71921"
            size={56}
            strokeWidth={5}
          />

          {/* Root Disk / Ring (Nothing Steel Gray) */}
          <CircularProgress
            value={diskUsageState((d) => d.usedPerc)}
            label="/"
            hoverLabel="DISK"
            tooltipText={diskUsageState((d) => `Disco (/): ${d.usedPerc}% (${d.usedGb}GB / ${d.totalGb}GB)`)}
            color="#8E8E93"
            size={56}
            strokeWidth={5}
          />
        </box>
      </box>

      {/* Fila de Sitios Web / Accesos Rápidos: GitHub, Reddit, Mail */}
      <box class="pm-sites-row" spacing={8} halign={Gtk.Align.CENTER}>
        {/* GitHub */}
        <button
          class="pm-site-btn"
          tooltipText="GitHub"
          onClicked={() => openUrl("https://github.com")}
          cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
        >
          <label class="pm-site-icon" label="" />
        </button>

        {/* Reddit */}
        <button
          class="pm-site-btn"
          tooltipText="Reddit"
          onClicked={() => openUrl("https://reddit.com")}
          cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
        >
          <label class="pm-site-icon" label="" />
        </button>

        {/* Gmail / Correo */}
        <button
          class="pm-site-btn"
          tooltipText="Gmail"
          onClicked={() => openUrl("https://mail.google.com")}
          cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
        >
          <label class="pm-site-icon" label="󰊫" />
        </button>
      </box>
    </box>
  )
}
