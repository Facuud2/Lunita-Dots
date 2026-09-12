import { createPoll } from "ags/time"
import { execAsync } from "ags/process"

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

// 3. Audio Volume Service
export const volumeState = createPoll({ volume: 50, muted: false }, 300, async () => {
  try {
    const out = await execAsync("pamixer --get-volume --get-mute")
    const [mutedStr, volStr] = out.trim().split(" ")
    return {
      volume: parseInt(volStr, 10) || 0,
      muted: mutedStr === "true",
    }
  } catch {
    return { volume: 50, muted: false }
  }
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

export const networkState = createPoll(
  {
    connected: true,
    isWifi: false,
    isEthernet: true,
    wifiEnabled: true,
    ethernetConnected: true,
    name: "Ethernet",
    signal: 100,
    ip: "127.0.0.1",
  } as NetworkState,
  3000,
  async () => {
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

      return {
        connected,
        isWifi,
        isEthernet,
        wifiEnabled,
        ethernetConnected,
        name: connected ? name : "Sin red",
        signal,
        ip: "Conectado",
      }
    } catch {
      return {
        connected: false,
        isWifi: false,
        isEthernet: false,
        wifiEnabled: true,
        ethernetConnected: false,
        name: "Sin red",
        signal: 0,
        ip: "",
      }
    }
  }
)

export const wifiNetworks = createPoll(
  [] as WifiNetwork[],
  5000,
  async () => {
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
      return list
    } catch {
      return []
    }
  }
)

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

export const bluetoothState = createPoll(
  {
    enabled: true,
    connectedDevice: null,
    devices: [],
  } as BluetoothState,
  3000,
  async () => {
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
          devices.push({
            mac: m[1],
            name,
            connected: isConn,
            paired: true,
          })
        }
      }

      return {
        enabled,
        connectedDevice,
        devices,
      }
    } catch {
      return {
        enabled: false,
        connectedDevice: null,
        devices: [],
      }
    }
  }
)

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

export const systemMeters = createPoll(
  { cpu: 0, cpuTemp: 45, ram: 0, gpu: 0, gpuTemp: 48 } as SystemMetrics,
  2000,
  async () => {
    try {
      const memStr = await execAsync(`bash -c "free -m | awk '/Mem:/ {printf \\"%d\\", $3*100/$2}'"`).catch(() => "0")
      const ram = parseInt(memStr.trim(), 10) || 0

      const loadStr = await execAsync(`bash -c "cat /proc/loadavg | awk '{print $1}'"`).catch(() => "0")
      const load = parseFloat(loadStr.trim()) || 0
      const cpu = Math.min(Math.round(load * 12.5), 100)

      let cpuTemp = 48
      const tempStr = await execAsync(
        `bash -c "cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -n1"`
      ).catch(() => "")
      if (tempStr.trim()) {
        cpuTemp = Math.round((parseInt(tempStr.trim(), 10) || 48000) / 1000)
      }

      let gpu = 24
      let gpuTemp = 50
      const nvidiaOut = await execAsync(
        "nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits 2>/dev/null"
      ).catch(() => "")
      if (nvidiaOut.trim()) {
        const [gVal, gTempVal] = nvidiaOut.trim().split(",")
        gpu = parseInt(gVal, 10) || gpu
        gpuTemp = parseInt(gTempVal, 10) || gpuTemp
      }

      return { cpu, cpuTemp, ram, gpu, gpuTemp }
    } catch {
      return { cpu: 0, cpuTemp: 45, ram: 0, gpu: 0, gpuTemp: 48 }
    }
  }
)

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
