import { Gtk, Gdk } from "ags/gtk4"
import { execAsync } from "ags/process"
import { mediaState } from "../island/services"
import { getDefaultCover } from "./PowerMenuState"

export default function MusicCard() {
  const defaultCover = getDefaultCover()

  const openPlayer = () => {
    execAsync("playerctl play-pause").catch(() => {})
  }

  const prevTrack = () => {
    execAsync("playerctl previous").catch(() => {})
  }

  const nextTrack = () => {
    execAsync("playerctl next").catch(() => {})
  }

  return (
    <box class="pm-card pm-music-card" orientation={Gtk.Orientation.VERTICAL} spacing={10}>
      {/* Carátula del Álbum */}
      <box class="pm-music-cover-box" halign={Gtk.Align.CENTER} valign={Gtk.Align.CENTER}>
        <image
          class="pm-music-cover"
          file={mediaState((m) => m.coverPath || defaultCover)}
          pixelSize={132}
        />
      </box>

      {/* Información del Tema / Artista */}
      <box class="pm-music-info" orientation={Gtk.Orientation.VERTICAL} spacing={2} halign={Gtk.Align.CENTER}>
        <label
          class="pm-music-title font-dots"
          label={mediaState((m) => (m.active && m.title ? `- ${m.title}` : "- No Music"))}
          ellipsize={3}
          maxWidthChars={16}
          halign={Gtk.Align.CENTER}
        />
        <label
          class="pm-music-artist"
          label={mediaState((m) => (m.active && m.artist ? m.artist : "Desconectado"))}
          ellipsize={3}
          maxWidthChars={18}
          halign={Gtk.Align.CENTER}
          visible={mediaState((m) => m.active && !!m.artist)}
        />
      </box>

      {/* Controles de Transporte: Prev, Play/Pause, Next */}
      <box class="pm-music-controls" spacing={14} halign={Gtk.Align.CENTER} valign={Gtk.Align.CENTER}>
        {/* Previous */}
        <button
          class="pm-music-btn"
          onClicked={prevTrack}
          cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
        >
          <label class="font-icon" label="skip_previous" />
        </button>

        {/* Play/Pause (Botón verde de acento como en la referencia) */}
        <button
          class="pm-music-play-btn"
          onClicked={openPlayer}
          cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
        >
          <label
            class="font-icon"
            label={mediaState((m) => (m.status === "Playing" ? "pause" : "play_arrow"))}
          />
        </button>

        {/* Next */}
        <button
          class="pm-music-btn"
          onClicked={nextTrack}
          cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
        >
          <label class="font-icon" label="skip_next" />
        </button>
      </box>

      {/* Barra de Progreso con Indicador */}
      <box
        class="pm-music-progress-container"
        halign={Gtk.Align.CENTER}
        cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
        $={(self) => {
          const click = new Gtk.GestureClick()
          click.connect("pressed", (_g, _n, x, _y) => {
            const width = self.get_allocated_width()
            if (width > 0) {
              const fraction = Math.max(0, Math.min(1, x / width))
              const len = mediaState.peek().length
              if (len > 0) {
                const targetSec = Math.round(fraction * len)
                execAsync(`playerctl position ${targetSec}`).catch(() => {})
              }
            }
          })
          self.add_controller(click)
        }}
      >
        <box class="pm-music-track" valign={Gtk.Align.CENTER} hexpand>
          <box
            class="pm-music-fill"
            css={mediaState((m) => `min-width: ${Math.max(4, Math.round(m.progress * 130))}px;`)}
          />
        </box>
      </box>
    </box>
  )
}
