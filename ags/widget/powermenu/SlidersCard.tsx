import { Gtk, Gdk } from "ags/gtk4"
import { volumeState, setSystemVolume, toggleSystemMute } from "../island/services"
import { micState, setSystemMicVolume, toggleSystemMicMute } from "./PowerMenuState"
import VerticalSlider from "./VerticalSlider"

export default function SlidersCard() {
  return (
    <box class="pm-card pm-sliders-card" spacing={12} halign={Gtk.Align.CENTER}>
      {/* Slider 1: Micrófono / Control Auxiliar (Nothing Red) */}
      <box orientation={Gtk.Orientation.VERTICAL} spacing={8} halign={Gtk.Align.CENTER}>
        <VerticalSlider
          value={micState((m) => m.volume)}
          onChange={setSystemMicVolume}
          color="#D71921"
          tooltipText={micState((m) => `Micrófono: ${m.volume}%`)}
          width={26}
          height={148}
        />

        {/* Ícono de Micrófono */}
        <button
          class={micState((m) => (m.muted ? "pm-slider-icon-btn muted" : "pm-slider-icon-btn"))}
          onClicked={toggleSystemMicMute}
          cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
        >
          <label class="font-icon" label={micState((m) => (m.muted ? "mic_off" : "mic"))} />
        </button>
      </box>

      {/* Slider 2: Volumen Maestro de Audio (Nothing White) */}
      <box orientation={Gtk.Orientation.VERTICAL} spacing={8} halign={Gtk.Align.CENTER}>
        <VerticalSlider
          value={volumeState((v) => v.volume)}
          onChange={setSystemVolume}
          color="#FFFFFF"
          tooltipText={volumeState((v) => `Volumen: ${v.volume}%`)}
          width={26}
          height={148}
        />

        {/* Ícono de Parlante / Audio */}
        <button
          class={volumeState((v) => (v.muted ? "pm-slider-icon-btn muted" : "pm-slider-icon-btn"))}
          onClicked={toggleSystemMute}
          cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
        >
          <label
            class="font-icon"
            label={volumeState((v) => (v.muted || v.volume === 0 ? "volume_off" : "volume_up"))}
          />
        </button>
      </box>
    </box>
  )
}
