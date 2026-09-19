import { createState } from "ags"
import { execAsync } from "ags/process"
import GLib from "gi://GLib?version=2.0"

export interface RecordingState {
  isRecording: boolean
  duration: number
  formattedDuration: string
  systemAudio: boolean
  micAudio: boolean
}

const CONFIG_FILE = `${GLib.get_user_config_dir()}/ags/recording_config.json`

function loadConfig(): { systemAudio: boolean; micAudio: boolean } {
  try {
    if (GLib.file_test(CONFIG_FILE, GLib.FileTest.EXISTS)) {
      const [ok, bytes] = GLib.file_get_contents(CONFIG_FILE)
      if (ok) {
        const text = new TextDecoder().decode(bytes)
        const parsed = JSON.parse(text)
        return {
          systemAudio: Boolean(parsed.systemAudio),
          micAudio: Boolean(parsed.micAudio),
        }
      }
    }
  } catch {}
  return { systemAudio: false, micAudio: false }
}

function saveConfig(systemAudio: boolean, micAudio: boolean) {
  try {
    const data = JSON.stringify({ systemAudio, micAudio }, null, 2)
    GLib.file_set_contents(CONFIG_FILE, data)
  } catch (err) {
    console.error("[RecordingService] Failed to save config:", err)
  }
}

function formatSeconds(sec: number): string {
  const m = Math.floor(sec / 60)
  const s = sec % 60
  return `${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}`
}

const initialConfig = loadConfig()

export const [recordingState, setRecordingState] = createState<RecordingState>({
  isRecording: false,
  duration: 0,
  formattedDuration: "00:00",
  systemAudio: initialConfig.systemAudio,
  micAudio: initialConfig.micAudio,
})

let recordingStartTime: number | null = null

export async function checkRecordingStatus() {
  let active = false
  try {
    const out = await execAsync("pgrep -x wf-recorder")
    if (out.trim()) {
      active = true
    }
  } catch {
    active = false
  }

  const cur = recordingState.peek()

  if (active) {
    if (!recordingStartTime) {
      recordingStartTime = Date.now()
    }
    const elapsedSec = Math.max(1, Math.floor((Date.now() - recordingStartTime) / 1000))
    setRecordingState({
      ...cur,
      isRecording: true,
      duration: elapsedSec,
      formattedDuration: formatSeconds(elapsedSec),
    })
  } else {
    recordingStartTime = null
    if (cur.isRecording || cur.duration !== 0) {
      setRecordingState({
        ...cur,
        isRecording: false,
        duration: 0,
        formattedDuration: "00:00",
      })
    }
  }
}

// Initial check
checkRecordingStatus().catch(() => {})

// Background poller
GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1000, () => {
  checkRecordingStatus().catch(() => {})
  return GLib.SOURCE_CONTINUE
})

export function toggleSystemAudio() {
  const cur = recordingState.peek()
  const next = !cur.systemAudio
  setRecordingState({
    ...cur,
    systemAudio: next,
  })
  saveConfig(next, cur.micAudio)
}

export function toggleMicAudio() {
  const cur = recordingState.peek()
  const next = !cur.micAudio
  setRecordingState({
    ...cur,
    micAudio: next,
  })
  saveConfig(cur.systemAudio, next)
}

export async function toggleRecording() {
  const cur = recordingState.peek()
  const scriptPath = `${GLib.get_home_dir()}/.config/hypr/scripts/record.sh`

  if (cur.isRecording) {
    // Stop recording
    setRecordingState({
      ...cur,
      isRecording: false,
      duration: 0,
      formattedDuration: "00:00",
    })
    recordingStartTime = null
    try {
      await execAsync(["bash", "-c", `"${scriptPath}" stop`])
    } catch (e) {
      console.error("[RecordingService] Error stopping recording:", e)
    }
  } else {
    // Start screen recording with chosen audio flags
    const flags: string[] = []
    flags.push(cur.systemAudio ? "--sound" : "--no-sound")
    flags.push(cur.micAudio ? "--mic" : "--no-mic")

    recordingStartTime = Date.now()
    setRecordingState({
      ...cur,
      isRecording: true,
      duration: 0,
      formattedDuration: "00:00",
    })

    try {
      await execAsync(["bash", "-c", `"${scriptPath}" screen ${flags.join(" ")}`])
    } catch (e) {
      console.error("[RecordingService] Error starting recording:", e)
    }
  }
}
