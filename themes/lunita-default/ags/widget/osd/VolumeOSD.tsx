import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { isVolumeOSDVisible, osdAnimClass } from "./OSDState"
import { volumeState, currentAudioSink } from "../island/services"

const BAR_WIDTH = 260

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
      marginBottom={64}
      visible={isVolumeOSDVisible((v) => v)}
    >
      <box
        class={osdAnimClass((cls) => `volume-osd-card ${cls}`)}
        orientation={Gtk.Orientation.VERTICAL}
        spacing={8}
      >
        {/* Fila Superior: Icono de dispositivo + Nombre de salida + Porcentaje */}
        <box class="osd-top-row" spacing={8} valign={Gtk.Align.CENTER}>
          <label
            class="font-icon osd-device-icon"
            label={currentAudioSink((sink) => sink?.icon || "speaker")}
          />
          <label
            class="osd-device-name"
            label={currentAudioSink((sink) => sink?.title || sink?.name || "Salida de audio")}
            ellipsize={3}
            maxWidthChars={26}
            halign={Gtk.Align.START}
          />
          <box hexpand />
          <label
            class={volumeState((v) => (v.muted ? "osd-vol-value muted" : "osd-vol-value"))}
            label={volumeState((v) => (v.muted ? "MUTED" : `${v.volume}%`))}
            halign={Gtk.Align.END}
          />
        </box>

        {/* Fila Inferior: Icono de nivel de volumen + Barra de progreso fluida */}
        <box class="osd-bottom-row" spacing={10} valign={Gtk.Align.CENTER}>
          <label
            class={volumeState((v) =>
              v.muted || v.volume === 0 ? "font-icon osd-vol-icon muted" : "font-icon osd-vol-icon"
            )}
            label={volumeState((v) => {
              if (v.muted || v.volume === 0) return "volume_off"
              if (v.volume < 33) return "volume_mute"
              if (v.volume < 66) return "volume_down"
              return "volume_up"
            })}
          />
          <box class="osd-bar-track" widthRequest={BAR_WIDTH}>
            <box
              class={volumeState((v) => (v.muted ? "osd-bar-fill muted" : "osd-bar-fill"))}
              css={volumeState((v) => {
                if (v.muted || v.volume === 0) return "min-width: 0px;"
                const clamped = Math.max(0, Math.min(100, v.volume))
                const width = Math.max(4, Math.round((clamped / 100) * BAR_WIDTH))
                return `min-width: ${width}px;`
              })}
            />
          </box>
        </box>
      </box>
    </window>
  )
}
