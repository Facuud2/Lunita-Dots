import { Gtk, Gdk } from "ags/gtk4"
import { With } from "ags"
import { execAsync } from "ags/process"
import { mediaState, setOptimisticPosition } from "./services"

function drawPill(cr: any, x: number, y: number, w: number, h: number) {
  const r = Math.max(0.5, Math.min(w / 2, h / 2))
  const xLeft = x + r
  const xRight = Math.max(xLeft, x + w - r)
  const yTop = y + r
  const yBottom = Math.max(yTop, y + h - r)

  cr.newSubPath()
  cr.arc(xLeft, yTop, r, Math.PI, 1.5 * Math.PI)
  cr.arc(xRight, yTop, r, 1.5 * Math.PI, 2 * Math.PI)
  cr.arc(xRight, yBottom, r, 0, 0.5 * Math.PI)
  cr.arc(xLeft, yBottom, r, 0.5 * Math.PI, Math.PI)
  cr.closePath()
}

function WaveformVisualizer() {
  const area = new Gtk.DrawingArea()
  area.set_content_height(30)
  area.set_hexpand(true)

  const seekPosition = (ratio: number) => {
    const cur = mediaState.peek()
    if (cur.length > 0) {
      const targetSec = Math.round(ratio * cur.length)
      setOptimisticPosition(targetSec)
      const p = cur.playerInstance ? `-p '${cur.playerInstance}'` : ""
      execAsync(`playerctl ${p} position ${targetSec}`).catch(() => {
        const diff = targetSec - cur.position
        if (diff > 0) {
          execAsync(`playerctl ${p} position ${diff}+`).catch(() => {})
        } else {
          execAsync(`playerctl ${p} position ${Math.abs(diff)}-`).catch(() => {})
        }
      })
    }
  }

  // Controlador de dibujo con Cairo (64 barras en 2 pasadas ultra-eficientes)
  area.set_draw_func((_area, cr, w, h) => {
    if (w <= 0 || h <= 0) return

    const m = mediaState.peek()
    const barCount = 64
    const stepX = w / barCount
    const barW = Math.max(2, Math.min(5, stepX - 2.5))
    const yCenter = h / 2
    const maxBarH = Math.max(4, h - 4)

    const pattern = m.waveform && m.waveform.length === barCount ? m.waveform : null
    const progress = m.active ? Math.max(0, Math.min(1, m.progress)) : 0

    // Pasada 1: Barras reproducidas (Blanco sólido #FFFFFF)
    let hasPlayed = false
    for (let i = 0; i < barCount; i++) {
      if (m.active && progress > 0 && i / barCount <= progress) {
        hasPlayed = true
        const x = i * stepX + (stepX - barW) / 2
        const normalizedH = pattern ? pattern[i] : 0.25
        const barH = Math.max(3, Math.round(maxBarH * normalizedH))
        const y = yCenter - barH / 2
        drawPill(cr, x, y, barW, barH)
      }
    }
    if (hasPlayed) {
      cr.setSourceRGBA(1.0, 1.0, 1.0, 1.0)
      cr.fill()
    }

    // Pasada 2: Barras restantes no reproducidas (Gris translúcido)
    let hasUnplayed = false
    for (let i = 0; i < barCount; i++) {
      if (!m.active || progress <= 0 || i / barCount > progress) {
        hasUnplayed = true
        const x = i * stepX + (stepX - barW) / 2
        const normalizedH = pattern ? pattern[i] : 0.25
        const barH = Math.max(3, Math.round(maxBarH * normalizedH))
        const y = yCenter - barH / 2
        drawPill(cr, x, y, barW, barH)
      }
    }
    if (hasUnplayed) {
      cr.setSourceRGBA(1.0, 1.0, 1.0, 0.18)
      cr.fill()
    }
  })

  // Redibujar inmediatamente al cambiar mediaState
  mediaState.subscribe(() => {
    area.queue_draw()
  })

  // Interacción de seek mediante Clic
  const click = new Gtk.GestureClick()
  click.set_button(1)
  click.connect("pressed", (_g, _n, x, _y) => {
    const w = area.get_allocated_width()
    if (w > 0) {
      const ratio = Math.max(0, Math.min(1, x / w))
      seekPosition(ratio)
    }
  })
  area.add_controller(click)

  // Interacción de seek mediante Arrastre (Drag)
  let lastSeekTime = 0
  const drag = new Gtk.GestureDrag()
  drag.connect("drag-update", (_g, dx, _dy) => {
    const [startX] = drag.get_start_point()
    const w = area.get_allocated_width()
    if (w > 0) {
      const currentX = startX + dx
      const ratio = Math.max(0, Math.min(1, currentX / w))
      const now = Date.now()
      if (now - lastSeekTime >= 80) {
        lastSeekTime = now
        seekPosition(ratio)
      }
    }
  })
  drag.connect("drag-end", (_g, dx, _dy) => {
    const [startX] = drag.get_start_point()
    const w = area.get_allocated_width()
    if (w > 0) {
      const currentX = startX + dx
      const ratio = Math.max(0, Math.min(1, currentX / w))
      seekPosition(ratio)
    }
  })
  area.add_controller(drag)

  return (
    <box
      class="waveform-container"
      cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
      hexpand
      $={(self) => {
        self.append(area)
      }}
    />
  )
}

export default function MediaCard() {
  const getPlayerArg = () => {
    const cur = mediaState.peek()
    return cur.playerInstance ? `-p '${cur.playerInstance}'` : ""
  }

  const togglePlayPause = () => {
    const p = getPlayerArg()
    execAsync(`playerctl ${p} play-pause`).catch(() => {
      execAsync("playerctl play-pause").catch(() => {})
    })
  }

  const playNext = () => {
    const p = getPlayerArg()
    execAsync(`playerctl ${p} next`).catch(() => {
      execAsync("playerctl next").catch(() => {})
    })
  }

  const playPrev = () => {
    const p = getPlayerArg()
    execAsync(`playerctl ${p} previous`).catch(() => {
      execAsync("playerctl previous").catch(() => {})
    })
  }

  return (
    <box orientation={Gtk.Orientation.VERTICAL} class="media-card" spacing={8}>
      {/* ── Fila Superior: Carátula + Título/Artista + Controles ── */}
      <box spacing={12} valign={Gtk.Align.CENTER}>
        {/* Carátula del Álbum (46x46 con bordes redondeados) */}
        <box class="media-art-box" valign={Gtk.Align.CENTER}>
          <With value={mediaState((m) => m.coverPath)}>
            {(cover) =>
              cover ? (
                <image class="media-art-img" file={cover} pixelSize={46} />
              ) : (
                <box
                  class="media-art-placeholder"
                  halign={Gtk.Align.CENTER}
                  valign={Gtk.Align.CENTER}
                >
                  <label class="font-icon media-art-icon" label="music_note" />
                </box>
              )
            }
          </With>
        </box>

        {/* Información de Pista (Título y Artista) */}
        <box
          orientation={Gtk.Orientation.VERTICAL}
          spacing={2}
          hexpand
          valign={Gtk.Align.CENTER}
        >
          <label
            class="media-title"
            label={mediaState((m) => (m.active && m.title ? m.title : "Sin reproducción"))}
            halign={Gtk.Align.START}
            ellipsize={3}
          />
          <label
            class="media-artist"
            label={mediaState((m) =>
              m.active && m.artist ? m.artist : "Reproductor inactivo"
            )}
            halign={Gtk.Align.START}
            ellipsize={3}
          />
        </box>

        {/* Controles de Transporte: Prev, Play/Pause Invertido (40px blanco), Next */}
        <box spacing={4} valign={Gtk.Align.CENTER} halign={Gtk.Align.END}>
          {/* Botón Pista Anterior */}
          <button
            class="media-small-btn"
            onClicked={playPrev}
            cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
          >
            <label class="font-icon" label="skip_previous" />
          </button>

          {/* Botón Play / Pause Circular Blanco */}
          <button
            class="media-main-btn"
            onClicked={togglePlayPause}
            cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
          >
            <label
              class="font-icon"
              label={mediaState((m) =>
                m.status === "Playing" ? "pause" : "play_arrow"
              )}
            />
          </button>

          {/* Botón Pista Siguiente */}
          <button
            class="media-small-btn"
            onClicked={playNext}
            cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
          >
            <label class="font-icon" label="skip_next" />
          </button>
        </box>
      </box>

      {/* ── Visualizador de Onda (64 barras reactivas a la posición) ── */}
      <WaveformVisualizer />

      {/* ── Marcas de Tiempo: Posición Transcurrida y Duración (Tipografía NDOT) ── */}
      <box class="waveform-time-row" valign={Gtk.Align.CENTER}>
        <label
          class="time-label font-dots"
          label={mediaState((m) => m.positionStr || "0:00")}
        />
        <box hexpand />
        <label
          class="time-label font-dots"
          label={mediaState((m) => (m.active ? m.lengthStr : "0:00"))}
        />
      </box>
    </box>
  )
}
