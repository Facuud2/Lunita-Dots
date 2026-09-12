import { Gtk } from "ags/gtk4"
import { execAsync } from "ags/process"
import { mediaState } from "./services"

export default function MediaCard() {
  const togglePlayPause = () => {
    execAsync("playerctl play-pause").catch(() => {})
  }

  const playNext = () => {
    execAsync("playerctl next").catch(() => {})
  }

  const playPrev = () => {
    execAsync("playerctl previous").catch(() => {})
  }

  const seekPosition = (ratio: number) => {
    const curLength = mediaState.peek().length
    if (curLength > 0) {
      const targetSec = Math.round(ratio * curLength)
      execAsync(`playerctl position ${targetSec}`).catch(() => {})
    }
  }

  return (
    <box orientation={Gtk.Orientation.VERTICAL} class="media-card" spacing={8}>
      {/* ── Top Row: Art + Track/Artist + Controls ── */}
      <box spacing={12} valign={Gtk.Align.CENTER}>
        {/* Album Art / Icon */}
        <box class="media-art-box" valign={Gtk.Align.CENTER}>
          <label class="font-icon media-art-icon" label="album" />
        </box>

        {/* Track Title & Artist */}
        <box orientation={Gtk.Orientation.VERTICAL} spacing={2} hexpand valign={Gtk.Align.CENTER}>
          <label
            class="media-title"
            label={mediaState((m) => m.title)}
            halign={Gtk.Align.START}
            ellipsize={3}
          />
          <label
            class="media-artist"
            label={mediaState((m) => m.artist)}
            halign={Gtk.Align.START}
            ellipsize={3}
          />
        </box>

        {/* Controls: Prev, Play/Pause (circular white inverted button), Next */}
        <box spacing={8} valign={Gtk.Align.CENTER}>
          <button class="media-small-btn" onClicked={playPrev}>
            <label class="font-icon" label="skip_previous" />
          </button>

          <button class="media-main-btn" onClicked={togglePlayPause}>
            <label
              class="font-icon"
              label={mediaState((m) =>
                m.status === "Playing" ? "pause" : "play_arrow"
              )}
            />
          </button>

          <button class="media-small-btn" onClicked={playNext}>
            <label class="font-icon" label="skip_next" />
          </button>
        </box>
      </box>

      {/* ── Waveform Visualizer & Progress Bar ── */}
      <box class="waveform-container" orientation={Gtk.Orientation.VERTICAL} spacing={4}>
        {/* Waveform Bars */}
        <box class="waveform-row" spacing={3} halign={Gtk.Align.FILL}>
          {Array.from({ length: 36 }).map((_, idx) => (
            <button
              class="waveform-bar-btn"
              hexpand
              onClicked={() => seekPosition(idx / 36)}
            >
              <box
                class={mediaState((m) =>
                  idx / 36 <= m.progress ? "waveform-bar played" : "waveform-bar"
                )}
                css={mediaState((m) => {
                  const h = m.waveform[idx] || 8
                  return `min-height: ${h}px;`
                })}
              />
            </button>
          ))}
        </box>

        {/* Time Track: Position (1:00) & Duration (3:52) */}
        <box class="waveform-time-row" valign={Gtk.Align.CENTER}>
          <label class="time-label font-dots" label={mediaState((m) => m.positionStr)} />
          <box hexpand />
          <label class="time-label font-dots" label={mediaState((m) => m.lengthStr)} />
        </box>
      </box>
    </box>
  )
}
