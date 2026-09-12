import { createPoll } from "ags/time"
import { execAsync } from "ags/process"
import { createState } from "ags"
import { readFile } from "ags/file"
import GLib from "gi://GLib?version=2.0"
import Gio from "gi://Gio?version=2.0"

// 1. Clock Service (HH:MM, SS, formatted date in Spanish uppercase)
export const clock = createPoll(
  { time: "00:00", sec: "00", date: "LUNES, 1 ENERO", dateShort: "LUN 1 ENE" },
  1000,
  () => {
    const now = new Date()
    const hours = String(now.getHours()).padStart(2, "0")
    const minutes = String(now.getMinutes()).padStart(2, "0")
    const seconds = String(now.getSeconds()).padStart(2, "0")

    const dateOptions: Intl.DateTimeFormatOptions = {
      weekday: "long",
      day: "numeric",
      month: "long",
    }
    const shortOptions: Intl.DateTimeFormatOptions = {
      weekday: "short",
      day: "numeric",
      month: "short",
    }

    return {
      time: `${hours}:${minutes}`,
      sec: seconds,
      date: now.toLocaleDateString("es-ES", dateOptions).toUpperCase(),
      dateShort: now.toLocaleDateString("es-ES", shortOptions).toUpperCase(),
    }
  }
)

// 2. Hyprland Workspaces Service
export const activeWorkspace = createPoll(1, 500, async () => {
  try {
    const out = await execAsync("hyprctl activeworkspace -j")
    const json = JSON.parse(out)
    return Number(json.id) || 1
  } catch {
    return 1
  }
})

// 3. Audio Volume Service — reactivo vía pactl subscribe con fallback wpctl
export interface VolumeState {
  volume: number
  muted: boolean
}

export const [volumeState, setVolumeState] = createState<VolumeState>({ volume: 50, muted: false })

export async function fetchVolume() {
  // 1. Prioridad: wpctl (usado directamente por Hyprland en este sistema)
  try {
    const out = await execAsync("wpctl get-volume @DEFAULT_AUDIO_SINK@")
    const muted = out.includes("[MUTED]")
    const match = out.match(/Volume:\s*([0-9.]+)/)
    if (match) {
      const volume = Math.min(100, Math.max(0, Math.round(parseFloat(match[1]) * 100)))
      setVolumeState({ volume, muted })
      return
    }
  } catch {}

  // 2. Fallback: pamixer
  try {
    const out = await execAsync("pamixer --get-volume --get-mute")
    const parts = out.trim().split(/\s+/)
    if (parts.length >= 2) {
      const muted = parts[0] === "true"
      const volume = parseInt(parts[1], 10) || 0
      setVolumeState({ volume, muted })
      return
    }
  } catch {}
}

export function setSystemVolume(percent: number) {
  const clamped = Math.max(0, Math.min(100, Math.round(percent)))
  setVolumeState({ ...volumeState.peek(), volume: clamped })
  const frac = (clamped / 100).toFixed(2)
  execAsync(`wpctl set-volume @DEFAULT_AUDIO_SINK@ ${frac}`).catch(() => {
    execAsync(`pamixer --set-volume ${clamped}`).catch(() => {})
  })
}

export function toggleSystemMute() {
  const next = !volumeState.peek().muted
  setVolumeState({ ...volumeState.peek(), muted: next })
  execAsync("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle").catch(() => {
    execAsync("pamixer -t").catch(() => {})
  })
}

let volDebounce: number | null = null
function queueVolumeFetch() {
  if (volDebounce !== null) GLib.source_remove(volDebounce)
  volDebounce = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 40, () => {
    volDebounce = null
    fetchVolume()
    return GLib.SOURCE_REMOVE
  })
}

// Watcher reactivo: pactl subscribe emite una línea por cada evento de audio
;(function startVolumeWatcher() {
  try {
    const proc = Gio.Subprocess.new(
      ["pactl", "subscribe"],
      Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_SILENCE
    )
    const stdout = proc.get_stdout_pipe()!
    const stream = new Gio.DataInputStream({ base_stream: stdout })

    function readNextLine() {
      stream.read_line_async(GLib.PRIORITY_DEFAULT, null, (_s, res) => {
        try {
          const [line] = stream.read_line_finish_utf8(res)
          if (line !== null) {
            if (
              line.includes("'change' on sink") ||
              line.includes("'change' on source") ||
              line.includes("'change' on server")
            ) {
              queueVolumeFetch()
            }
            readNextLine()
          } else {
            GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1500, () => {
              startVolumeWatcher()
              return GLib.SOURCE_REMOVE
            })
          }
        } catch {
          GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1500, () => {
            startVolumeWatcher()
            return GLib.SOURCE_REMOVE
          })
        }
      })
    }

    readNextLine()
  } catch {
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1000, () => {
      fetchVolume()
      return GLib.SOURCE_CONTINUE
    })
  }
})()

// Lectura inicial
fetchVolume()

// Resincronización periódica cada 2 segundos
GLib.timeout_add(GLib.PRIORITY_DEFAULT, 2000, () => {
  fetchVolume()
  return GLib.SOURCE_CONTINUE
})

// 4. Network Service
export interface WifiNetwork {
  ssid: string
  signal: number
  security: string
  connected: boolean
}

export interface NetworkState {
  connected: boolean
  isWifi: boolean
  isEthernet: boolean
  wifiEnabled: boolean
  ethernetConnected: boolean
  name: string
  signal: number
  ip: string
}

export const [networkState, setNetworkState] = createState<NetworkState>({
  connected: true,
  isWifi: false,
  isEthernet: true,
  wifiEnabled: true,
  ethernetConnected: true,
  name: "Ethernet",
  signal: 100,
  ip: "127.0.0.1",
})

export const [wifiNetworks, setWifiNetworks] = createState<WifiNetwork[]>([])

export async function fetchWifiNetworks() {
  try {
    const out = await execAsync(
      "nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list"
    ).catch(() => "")
    const seen = new Set<string>()
    const list: WifiNetwork[] = []

    for (const line of out.split("\n")) {
      const parts = line.split(":")
      if (parts.length >= 4 && parts[1] && !seen.has(parts[1])) {
        seen.add(parts[1])
        list.push({
          ssid: parts[1],
          signal: parseInt(parts[2], 10) || 0,
          security: parts[3] || "Open",
          connected: parts[0] === "*",
        })
      }
    }
    setWifiNetworks(list)
  } catch {
    setWifiNetworks([])
  }
}

export async function fetchNetwork() {
  try {
    const devOutput = await execAsync(
      "nmcli -t -f TYPE,STATE,CONNECTION device"
    ).catch(() => "")
    const radioOutput = await execAsync("nmcli radio wifi").catch(() => "enabled")
    const wifiEnabled = radioOutput.trim().toLowerCase() === "enabled"

    let connected = false
    let isWifi = false
    let isEthernet = false
    let name = "Sin red"
    let ethernetConnected = false

    for (const line of devOutput.split("\n")) {
      const parts = line.split(":")
      if (parts.length >= 2 && parts[1] === "connected") {
        connected = true
        if (parts[0] === "ethernet") {
          ethernetConnected = true
          if (!isWifi) {
            isEthernet = true
            name = parts[2] || "Ethernet"
          }
        } else if (parts[0] === "wifi") {
          isWifi = true
          isEthernet = false
          name = parts[2] || "Wi-Fi"
        }
      }
    }

    let signal = 80
    if (isWifi) {
      const sigStr = await execAsync(
        `bash -c "nmcli -t -f active,signal dev wifi 2>/dev/null | grep '^yes:' | cut -d: -f2 | head -n1"`
      ).catch(() => "80")
      signal = parseInt(sigStr.trim(), 10) || 80
    }

    setNetworkState({
      connected,
      isWifi,
      isEthernet,
      wifiEnabled,
      ethernetConnected,
      name: connected ? name : "Sin red",
      signal,
      ip: "Conectado",
    })
  } catch {
    // Mantener estado si hay error puntual
  }
}

// Actualización optimista hiperreactiva de Wi-Fi (0ms)
export async function toggleWifi() {
  const current = networkState.peek()
  const next = !current.wifiEnabled

  // Reflejo visual inmediato a 0ms
  setNetworkState({
    ...current,
    wifiEnabled: next,
    isWifi: next ? current.isWifi : false,
    connected: next ? current.connected : current.ethernetConnected,
    name: !next && current.ethernetConnected ? "Ethernet" : next ? current.name : "Sin red",
  })

  try {
    await execAsync(`nmcli radio wifi ${next ? "on" : "off"}`)
  } catch {}

  fetchNetwork()
  if (next) {
    fetchWifiNetworks()
  } else {
    setWifiNetworks([])
  }
}

// Watcher reactivo de NetworkManager con nmcli monitor
let netDebounce: number | null = null
function queueNetworkFetch() {
  if (netDebounce !== null) GLib.source_remove(netDebounce)
  netDebounce = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 150, () => {
    netDebounce = null
    fetchNetwork()
    if (networkState.peek().wifiEnabled) {
      fetchWifiNetworks()
    }
    return GLib.SOURCE_REMOVE
  })
}

;(function startNetworkWatcher() {
  try {
    const proc = Gio.Subprocess.new(
      ["nmcli", "monitor"],
      Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_SILENCE
    )
    const stdout = proc.get_stdout_pipe()!
    const stream = new Gio.DataInputStream({ base_stream: stdout })

    function readNextLine() {
      stream.read_line_async(GLib.PRIORITY_DEFAULT, null, (_s, res) => {
        try {
          const [line] = stream.read_line_finish_utf8(res)
          if (line !== null) {
            queueNetworkFetch()
            readNextLine()
          } else {
            GLib.timeout_add(GLib.PRIORITY_DEFAULT, 2000, () => {
              startNetworkWatcher()
              return GLib.SOURCE_REMOVE
            })
          }
        } catch {
          GLib.timeout_add(GLib.PRIORITY_DEFAULT, 2000, () => {
            startNetworkWatcher()
            return GLib.SOURCE_REMOVE
          })
        }
      })
    }

    readNextLine()
  } catch {
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 3000, () => {
      fetchNetwork()
      return GLib.SOURCE_CONTINUE
    })
  }
})()

// Lecturas iniciales de red
fetchNetwork()
fetchWifiNetworks()

// Resincronización periódica de red (cada 5s)
GLib.timeout_add(GLib.PRIORITY_DEFAULT, 5000, () => {
  fetchNetwork()
  if (networkState.peek().wifiEnabled) {
    fetchWifiNetworks()
  }
  return GLib.SOURCE_CONTINUE
})

// 5. Bluetooth Service
export interface BluetoothDevice {
  mac: string
  name: string
  connected: boolean
  paired: boolean
}

export interface BluetoothState {
  enabled: boolean
  connectedDevice: string | null
  devices: BluetoothDevice[]
}

export const [bluetoothState, setBluetoothState] = createState<BluetoothState>({
  enabled: false,
  connectedDevice: null,
  devices: [],
})

export async function fetchBluetooth() {
  try {
    const showOut = await execAsync("bluetoothctl show").catch(() => "")
    const enabled = /Powered:\s*yes/i.test(showOut)

    const pairedOut = await execAsync("bluetoothctl devices Paired").catch(() => "")
    const connOut = await execAsync("bluetoothctl devices Connected").catch(() => "")

    const connMacs = new Set<string>()
    for (const line of connOut.split("\n")) {
      const m = line.match(/^Device\s+([0-9A-F:]+)/i)
      if (m) connMacs.add(m[1])
    }

    let connectedDevice: string | null = null
    const devices: BluetoothDevice[] = []

    for (const line of pairedOut.split("\n")) {
      const m = line.match(/^Device\s+([0-9A-F:]+)\s+(.*)$/i)
      if (m) {
        const isConn = connMacs.has(m[1])
        const name = m[2] || m[1]
        if (isConn && !connectedDevice) {
          connectedDevice = name
        }
        devices.push({ mac: m[1], name, connected: isConn, paired: true })
      }
    }

    setBluetoothState({ enabled, connectedDevice, devices })
  } catch {
    setBluetoothState({ enabled: false, connectedDevice: null, devices: [] })
  }
}

// Acción optimista hiperreactiva de Bluetooth (0ms)
export async function toggleBluetooth() {
  const current = bluetoothState.peek()
  const next = !current.enabled

  // Reflejo visual inmediato a 0ms
  setBluetoothState({
    ...current,
    enabled: next,
    connectedDevice: next ? current.connectedDevice : null,
  })

  try {
    await execAsync(`bluetoothctl power ${next ? "on" : "off"}`)
  } catch {}

  fetchBluetooth()
}

export async function connectBluetoothDevice(mac: string, connected: boolean) {
  const current = bluetoothState.peek()
  const target = current.devices.find((d) => d.mac === mac)
  const nextDevices = current.devices.map((d) =>
    d.mac === mac ? { ...d, connected: !connected } : d
  )

  // Reflejo visual inmediato
  setBluetoothState({
    ...current,
    connectedDevice: !connected ? target?.name || mac : null,
    devices: nextDevices,
  })

  try {
    if (connected) {
      await execAsync(`bluetoothctl disconnect ${mac}`)
    } else {
      await execAsync(`bluetoothctl connect ${mac}`)
    }
  } catch {}

  fetchBluetooth()
}

// Watcher reactivo de Bluetooth usando D-Bus del sistema (gdbus monitor org.bluez)
let btDebounce: number | null = null
function queueBluetoothFetch() {
  if (btDebounce !== null) GLib.source_remove(btDebounce)
  btDebounce = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 150, () => {
    btDebounce = null
    fetchBluetooth()
    return GLib.SOURCE_REMOVE
  })
}

;(function startBluetoothWatcher() {
  try {
    const proc = Gio.Subprocess.new(
      ["gdbus", "monitor", "--system", "--dest", "org.bluez"],
      Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_SILENCE
    )
    const stdout = proc.get_stdout_pipe()!
    const stream = new Gio.DataInputStream({ base_stream: stdout })

    function readNextLine() {
      stream.read_line_async(GLib.PRIORITY_DEFAULT, null, (_s, res) => {
        try {
          const [line] = stream.read_line_finish_utf8(res)
          if (line !== null) {
            queueBluetoothFetch()
            readNextLine()
          } else {
            GLib.timeout_add(GLib.PRIORITY_DEFAULT, 2000, () => {
              startBluetoothWatcher()
              return GLib.SOURCE_REMOVE
            })
          }
        } catch {
          GLib.timeout_add(GLib.PRIORITY_DEFAULT, 2000, () => {
            startBluetoothWatcher()
            return GLib.SOURCE_REMOVE
          })
        }
      })
    }

    readNextLine()
  } catch {
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 3000, () => {
      fetchBluetooth()
      return GLib.SOURCE_CONTINUE
    })
  }
})()

// Lectura inicial
fetchBluetooth()

// Resincronización periódica de Bluetooth (cada 5s)
GLib.timeout_add(GLib.PRIORITY_DEFAULT, 5000, () => {
  fetchBluetooth()
  return GLib.SOURCE_CONTINUE
})

// 6. Media Player (MPRIS with Waveform & Position)
export interface MediaInfo {
  active: boolean
  title: string
  artist: string
  status: "Playing" | "Paused" | "Stopped"
  position: number
  length: number
  positionStr: string
  lengthStr: string
  progress: number
  artUrl: string
  waveform: number[]
}

function formatDuration(sec: number): string {
  if (!sec || sec < 0) return "0:00"
  const m = Math.floor(sec / 60)
  const s = Math.floor(sec % 60)
  return `${m}:${s < 10 ? "0" : ""}${s}`
}

function generateWaveform(title: string, barCount = 38): number[] {
  let seed = 0
  for (let i = 0; i < title.length; i++) {
    seed = (seed * 31 + title.charCodeAt(i)) & 0x7fffffff
  }
  if (seed === 0) seed = 12345

  const bars: number[] = []
  for (let b = 0; b < barCount; b++) {
    seed = (seed * 1103515245 + 12345) & 0x7fffffff
    const r = (seed >>> 8) / 0x7fffff
    const env = Math.sin((Math.PI * (b + 0.5)) / barCount)
    const height = Math.round((0.2 + 0.8 * r * (0.4 + 0.6 * env)) * 24)
    bars.push(Math.max(4, height))
  }
  return bars
}

export const mediaState = createPoll(
  {
    active: false,
    title: "Sin reproducción",
    artist: "Nada sonando",
    status: "Stopped",
    position: 0,
    length: 0,
    positionStr: "0:00",
    lengthStr: "0:00",
    progress: 0,
    artUrl: "",
    waveform: generateWaveform(""),
  } as MediaInfo,
  1000,
  async () => {
    try {
      const statusRaw = await execAsync("playerctl status 2>/dev/null").catch(() => "Stopped")
      const status = statusRaw.trim() as "Playing" | "Paused" | "Stopped"

      if (status === "Playing" || status === "Paused") {
        const metadata = await execAsync(
          "playerctl metadata --format '{{title}};;;{{artist}};;;{{position}};;;{{mpris:length}};;;{{mpris:artUrl}}' 2>/dev/null"
        ).catch(() => "")

        const [title = "", artist = "", posMicros = "0", lenMicros = "0", artUrl = ""] =
          metadata.trim().split(";;;")

        const position = Math.round((parseInt(posMicros, 10) || 0) / 1000000)
        const length = Math.round((parseInt(lenMicros, 10) || 0) / 1000000)
        const progress = length > 0 ? Math.min(1, Math.max(0, position / length)) : 0

        return {
          active: true,
          title: title.trim() || "Reproduciendo",
          artist: artist.trim() || "Artista",
          status,
          position,
          length,
          positionStr: formatDuration(position),
          lengthStr: formatDuration(length),
          progress,
          artUrl: artUrl.trim(),
          waveform: generateWaveform(title.trim() || "Audio"),
        }
      }
      return {
        active: false,
        title: "Sin reproducción",
        artist: "Nada sonando",
        status: "Stopped",
        position: 0,
        length: 0,
        positionStr: "0:00",
        lengthStr: "0:00",
        progress: 0,
        artUrl: "",
        waveform: generateWaveform(""),
      }
    } catch {
      return {
        active: false,
        title: "Sin reproducción",
        artist: "Nada sonando",
        status: "Stopped",
        position: 0,
        length: 0,
        positionStr: "0:00",
        lengthStr: "0:00",
        progress: 0,
        artUrl: "",
        waveform: generateWaveform(""),
      }
    }
  }
)

// 7. System Resource Meters (CPU, RAM, GPU, Temps)
export interface SystemMetrics {
  cpu: number
  cpuTemp: number
  ram: number
  gpu: number
  gpuTemp: number
}

// Internal hardware sensor paths discovery
let cpuTempSensorPath: string | null = null
let amdGpuBusyPath: string | null = null
let amdGpuTempPath: string | null = null
let hasNvidia = false
let hwmonInitialized = false

function initHwmonSensors() {
  if (hwmonInitialized) return
  hwmonInitialized = true

  try {
    const dir = Gio.File.new_for_path("/sys/class/hwmon")
    const enumerator = dir.enumerate_children("standard::name", Gio.FileQueryInfoFlags.NONE, null)
    let info: Gio.FileInfo | null
    while ((info = enumerator.next_file(null)) !== null) {
      const name = info.get_name()
      const hwPath = `/sys/class/hwmon/${name}`
      try {
        const sensorName = readFile(`${hwPath}/name`).trim()
        // CPU Temperature sensors (AMD k10temp / zenpower, Intel coretemp)
        if (["k10temp", "coretemp", "zenpower"].includes(sensorName)) {
          if (!cpuTempSensorPath) cpuTempSensorPath = `${hwPath}/temp1_input`
        }
        // AMD GPU sensors
        if (sensorName === "amdgpu") {
          if (!amdGpuTempPath) amdGpuTempPath = `${hwPath}/temp1_input`
          if (!amdGpuBusyPath) amdGpuBusyPath = `${hwPath}/device/gpu_busy_percent`
        }
      } catch {}
    }
  } catch {}

  // Fallbacks
  if (!cpuTempSensorPath) {
    try {
      readFile("/sys/class/thermal/thermal_zone0/temp")
      cpuTempSensorPath = "/sys/class/thermal/thermal_zone0/temp"
    } catch {}
  }

  if (!amdGpuBusyPath) {
    try {
      readFile("/sys/class/drm/card0/device/gpu_busy_percent")
      amdGpuBusyPath = "/sys/class/drm/card0/device/gpu_busy_percent"
    } catch {}
  }

  hasNvidia = GLib.find_program_in_path("nvidia-smi") !== null
}

let prevCpuStats = { idle: 0, total: 0 }

function readMetrics(): SystemMetrics {
  initHwmonSensors()

  // 1. RAM Usage from /proc/meminfo
  let ram = 0
  try {
    const meminfo = readFile("/proc/meminfo")
    let total = 0
    let avail = 0
    for (const line of meminfo.split("\n")) {
      if (line.startsWith("MemTotal:")) {
        total = parseInt(line.split(/\s+/)[1], 10) || 0
      } else if (line.startsWith("MemAvailable:")) {
        avail = parseInt(line.split(/\s+/)[1], 10) || 0
      }
      if (total > 0 && avail > 0) break
    }
    if (total > 0) {
      ram = Math.min(100, Math.max(0, Math.round(((total - avail) / total) * 100)))
    }
  } catch {}

  // 2. CPU Usage from /proc/stat delta
  let cpu = 0
  try {
    const stat = readFile("/proc/stat")
    const firstLine = stat.split("\n")[0]
    const parts = firstLine.split(/\s+/).slice(1).map(Number)
    const idle = parts[3] + (parts[4] || 0)
    const total = parts.reduce((a, b) => a + b, 0)

    if (prevCpuStats.total > 0) {
      const dTotal = total - prevCpuStats.total
      const dIdle = idle - prevCpuStats.idle
      if (dTotal > 0) {
        cpu = Math.min(100, Math.max(0, Math.round((100 * (dTotal - dIdle)) / dTotal)))
      }
    }
    prevCpuStats = { idle, total }
  } catch {}

  // 3. CPU Temp
  let cpuTemp = 0
  try {
    if (cpuTempSensorPath) {
      const tempVal = parseInt(readFile(cpuTempSensorPath).trim(), 10)
      if (!isNaN(tempVal)) {
        cpuTemp = Math.round(tempVal / 1000)
      }
    }
  } catch {}

  // 4. GPU Usage & Temp (AMD sysfs priority, or Nvidia if available)
  let gpu = 0
  let gpuTemp = 0

  if (amdGpuBusyPath || amdGpuTempPath) {
    try {
      if (amdGpuBusyPath) {
        const busyVal = parseInt(readFile(amdGpuBusyPath).trim(), 10)
        if (!isNaN(busyVal)) gpu = Math.min(100, Math.max(0, busyVal))
      }
      if (amdGpuTempPath) {
        const tempVal = parseInt(readFile(amdGpuTempPath).trim(), 10)
        if (!isNaN(tempVal)) gpuTemp = Math.round(tempVal / 1000)
      }
    } catch {}
  }

  return { cpu, cpuTemp, ram, gpu, gpuTemp }
}

// Initial reading to prime CPU stats
const initialMetrics = readMetrics()

export const [systemMeters, setSystemMeters] = createState<SystemMetrics>(initialMetrics)
export const statusTraySystem = systemMeters

// Asynchronous update function to also check Nvidia if present without blocking
export async function updateSystemMetrics() {
  const metrics = readMetrics()

  if (hasNvidia && (!amdGpuBusyPath || metrics.gpu === 0)) {
    try {
      const nvidiaOut = await execAsync(
        "nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits"
      ).catch(() => "")
      if (nvidiaOut.trim()) {
        const [gVal, gTempVal] = nvidiaOut.trim().split(",")
        const parsedGpu = parseInt(gVal, 10)
        const parsedTemp = parseInt(gTempVal, 10)
        if (!isNaN(parsedGpu)) metrics.gpu = parsedGpu
        if (!isNaN(parsedTemp)) metrics.gpuTemp = parsedTemp
      }
    } catch {}
  }

  setSystemMeters(metrics)
}

// Continuous 1000ms background ticker (synchronous sysfs read takes < 0.3ms)
GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1000, () => {
  updateSystemMetrics().catch(() => {})
  return GLib.SOURCE_CONTINUE
})

// 8. Battery Service
export const batteryState = createPoll(
  { present: false, percent: 100, charging: false },
  5000,
  async () => {
    try {
      const capStr = await execAsync(
        `bash -c "cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1"`
      ).catch(() => "")
      if (capStr.trim()) {
        const percent = parseInt(capStr.trim(), 10) || 100
        const statStr = await execAsync(
          `bash -c "cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n1"`
        ).catch(() => "")
        return {
          present: true,
          percent,
          charging: statStr.trim().toLowerCase().includes("charging"),
        }
      }
      return { present: false, percent: 100, charging: false }
    } catch {
      return { present: false, percent: 100, charging: false }
    }
  }
)
