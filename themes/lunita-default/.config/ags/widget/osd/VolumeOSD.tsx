import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { isVolumeOSDVisible, osdAnimClass } from "./OSDState"
import { volumeState, currentAudioSink } from "../island/services"

export default function VolumeOSD(gdkmonitor: Gdk.Monitor) {
  const { BOTTOM } = Astal.WindowAnchor
  const connector = gdkmonitor.get_connector() || ""

  return (
    <window
      name={`volume-osd-${connector}`}
      class="volume-osd-window"
      gdkmonitor={gdkmonitor}
      anchor={BOTTOM}
      exclusivity={Astal.Exclusivity.IGNORE}
      layer={Astal.Layer.OVERLAY}
      application={app}
      marginBottom={84}
      visible={isVolumeOSDVisible((v) => v)}
    >
      <box
        class={osdAnimClass((cls) => `volume-osd-card macos-classic ${cls}`)}
        orientation={Gtk.Orientation.VERTICAL}
        spacing={8}
      >
        {/* Icono de Altavoz Centrado (macOS Style) */}
        <box class="osd-icon-container" halign={Gtk.Align.CENTER} valign={Gtk.Align.CENTER}>
          <label
            class={volumeState((v) =>
              v.muted || v.volume === 0 ? "font-icon osd-main-icon muted" : "font-icon osd-main-icon"
            )}
            label={volumeState((v) => {
              if (v.muted || v.volume === 0) return "volume_off"
              if (v.volume < 33) return "volume_mute"
              if (v.volume < 66) return "volume_down"
              return "volume_up"
            })}
          />
        </box>

        {/* Nombre de dispositivo / Salida */}
        <label
          class="osd-device-name"
          label={volumeState((v) => {
            if (v.muted) return "Silenciado"
            return currentAudioSink.get()?.title || currentAudioSink.get()?.name || "Altavoces"
          })}
          ellipsize={3}
          maxWidthChars={20}
          halign={Gtk.Align.CENTER}
        />

        <box vexpand />

        {/* 16 Segmentos Clásicos estilo macOS */}
        <box class="osd-segments-row" spacing={3} halign={Gtk.Align.CENTER}>
          {Array.from({ length: 16 }, (_, i) => (
            <box
              class={volumeState((v) => {
                const activeCount = v.muted ? 0 : Math.min(16, Math.max(0, Math.round((v.volume / 100) * 16)))
                return i < activeCount ? "osd-segment active" : "osd-segment"
              })}
            />
          ))}
        </box>
      </box>
    </window>
  )
}
