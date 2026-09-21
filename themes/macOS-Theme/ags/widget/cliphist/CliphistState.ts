import { createState } from "ags"
import { execAsync } from "ags/process"
import { readFile } from "ags/file"

export interface ClipItem {
  id: string
  type: "text" | "code" | "link" | "image"
  preview: string
  detail: string
  rawLine: string
  timestamp: string
}

export const [cliphistOpen, setCliphistOpen] = createState(false)
export const [activeCliphistMonitor, setActiveCliphistMonitor] = createState<string | null>(null)
export const [cursorCoords, setCursorCoords] = createState({
  x: 100,
  y: 100,
  originX: "left" as "left" | "right",
  originY: "top" as "top" | "bottom",
})
export const [clipItems, setClipItems] = createState<ClipItem[]>([])
export const [filteredItems, setFilteredItems] = createState<ClipItem[]>([])
export const [searchQuery, setSearchQuery] = createState("")
export const [selectedIndex, setSelectedIndex] = createState(0)
export const [panelAnimClass, setPanelAnimClass] = createState("cliphist-panel cliphist-open-left-top")

let isClosing = false
let closeTimeoutId: any = null
let lastOpenTime = 0
let lastFocusedWindow: string | null = null
let lastFocusedClass: string | null = null

export const isCliphistClosing = () => isClosing
export const getCliphistOpenTime = () => lastOpenTime

// Formateador de fecha y hora
function formatTimestamp(epochSec?: number): string {
  if (!epochSec || isNaN(epochSec)) {
    const d = new Date()
    const timeStr = d.toLocaleTimeString("es-ES", { hour: "2-digit", minute: "2-digit" })
    return `Hoy, ${timeStr}`
  }

  const date = new Date(epochSec * 1000)
  const now = new Date()
  const isToday = date.toDateString() === now.toDateString()
  const timeStr = date.toLocaleTimeString("es-ES", { hour: "2-digit", minute: "2-digit" })

  if (isToday) {
    return `Hoy, ${timeStr}`
  }

  const day = String(date.getDate()).padStart(2, "0")
  const month = String(date.getMonth() + 1).padStart(2, "0")
  return `${day}/${month}, ${timeStr}`
}

// Cargar mapa de timestamps desde el archivo tsv
function loadTimestampsMap(): Map<string, number> {
  const map = new Map<string, number>()
  try {
    const cacheDir = GLib.get_user_cache_dir()
    const content = readFile(`${cacheDir}/cliphist/timestamps.tsv`)
    for (const line of content.split("\n")) {
      const parts = line.split("\t")
      if (parts.length >= 2) {
        const id = parts[0].trim()
        const ts = parseInt(parts[1].trim(), 10)
        if (id && !isNaN(ts)) {
          map.set(id, ts)
        }
      }
    }
  } catch (err) {
    // Si no existe aún o falla lectura, se continúa
  }
  return map
}

// Parser para las líneas de cliphist list
function parseCliphistLine(line: string, tsMap: Map<string, number>): ClipItem | null {
  if (!line || !line.trim()) return null
  const tabIndex = line.indexOf("\t")
  if (tabIndex === -1) return null

  const id = line.substring(0, tabIndex).trim()
  const content = line.substring(tabIndex + 1)
  const epochSec = tsMap.get(id)
  const timestamp = formatTimestamp(epochSec)

  // Detección de imágenes binarias
  const binMatch = content.match(/^\[\[\s*binary data\s+([^\]]+)\]\]/i)
  if (binMatch) {
    const meta = binMatch[1].trim()
    return {
      id,
      type: "image",
      preview: `Captura / Imagen (${meta})`,
      detail: "Imagen binaria guardada en portapapeles",
      rawLine: line,
      timestamp,
    }
  }

  // Detección de URL
  if (/^https?:\/\/[^\s]+/i.test(content.trim())) {
    return {
      id,
      type: "link",
      preview: content.trim(),
      detail: "Enlace Web URL",
      rawLine: line,
      timestamp,
    }
  }

  // Detección de fragmentos de código o comandos
  if (
    /^(curl|wget|git|sudo|pacman|systemctl|docker|ssh|cat|grep|npm|cargo|pip|hyprctl|echo|export)\s/i.test(content.trim()) ||
    /(\{|\}|\(\)|=>|function\s|const\s|let\s|import\s|class\s|def\s|SELECT\s|return\s)/i.test(content)
  ) {
    return {
      id,
      type: "code",
      preview: content.trim(),
      detail: "Comando o bloque de código",
      rawLine: line,
      timestamp,
    }
  }

  return {
    id,
    type: "text",
    preview: content.trim(),
    detail: "Texto plano copiado",
    rawLine: line,
    timestamp,
  }
}

// Función central para actualizar la lista filtrada de forma reactiva
export function updateFiltered() {
  const all = clipItems.peek()
  const q = searchQuery.peek().trim().toLowerCase()
  if (!q) {
    setFilteredItems(all)
  } else {
    setFilteredItems(
      all.filter((item) =>
        item.preview.toLowerCase().includes(q) ||
        item.detail.toLowerCase().includes(q) ||
        item.timestamp.toLowerCase().includes(q)
      )
    )
  }
}

// Sincronizar automáticamente cuando cambia la búsqueda
searchQuery.subscribe(() => {
  updateFiltered()
})

// Cargar elementos desde cliphist list
export async function loadCliphistItems() {
  try {
    const tsMap = loadTimestampsMap()
    const output = await execAsync("cliphist list")
    const lines = output.split("\n")
    const parsed: ClipItem[] = []
    for (const l of lines) {
      const item = parseCliphistLine(l, tsMap)
      if (item) parsed.push(item)
    }
    setClipItems(parsed)
    updateFiltered()
  } catch (err) {
    console.warn("[CliphistState] Error al cargar historial:", err)
    setClipItems([])
    updateFiltered()
  }
}

// Obtener elementos filtrados según la búsqueda (helper directo)
export function getFilteredItems(query: string): ClipItem[] {
  const all = clipItems.peek()
  const q = query.trim().toLowerCase()
  if (!q) return all
  return all.filter((item) =>
    item.preview.toLowerCase().includes(q) ||
    item.detail.toLowerCase().includes(q) ||
    item.timestamp.toLowerCase().includes(q)
  )
}

// Navegar la lista con teclado
export function navigateSelection(delta: number) {
  const filtered = filteredItems.peek()
  if (filtered.length === 0) return
  const current = selectedIndex.peek()
  let next = current + delta
  if (next < 0) next = filtered.length - 1
  if (next >= filtered.length) next = 0
  setSelectedIndex(next)
}

// Copiar un elemento y auto-pegarlo en la ventana activa si había foco
export async function copyItem(item: ClipItem) {
  try {
    await execAsync(["bash", "-c", 'printf "%s" "$1" | cliphist decode | wl-copy', "--", item.rawLine])
  } catch (err) {
    console.warn("[CliphistState] Error al copiar elemento:", err)
  }

  const targetWin = lastFocusedWindow
  const targetClass = lastFocusedClass

  closeCliphist()

  // Auto-pegar automáticamente en la caja de texto activa
  if (targetWin) {
    setTimeout(async () => {
      try {
        await execAsync(`hyprctl dispatch focuswindow address:${targetWin}`)
        const isTerminal = /kitty|terminal|alacritty|foot|xterm/i.test(targetClass || "")
        if (isTerminal) {
          await execAsync("wtype -M ctrl -M shift -k v -m shift -m ctrl")
        } else {
          await execAsync("wtype -M ctrl -k v -m ctrl")
        }
      } catch (e) {
        console.warn("[CliphistState] Error al auto-pegar:", e)
      }
    }, 120)
  }
}

// Eliminar un elemento individual
export async function deleteItem(item: ClipItem) {
  try {
    await execAsync(["bash", "-c", 'printf "%s" "$1" | cliphist delete', "--", item.rawLine])
    const current = clipItems.peek()
    const nextList = current.filter((i) => i.id !== item.id)
    setClipItems(nextList)
    updateFiltered()
    const filtered = filteredItems.peek()
    if (selectedIndex.peek() >= filtered.length) {
      setSelectedIndex(Math.max(0, filtered.length - 1))
    }
  } catch (err) {
    console.warn("[CliphistState] Error al eliminar elemento:", err)
  }
}

// Limpiar todo el historial
export async function clearAllHistory() {
  try {
    await execAsync(["bash", "-c", "cliphist wipe; wl-copy --clear || true"])
    const cacheDir = GLib.get_user_cache_dir()
    await execAsync(["bash", "-c", `rm -f "${cacheDir}/cliphist/timestamps.tsv"`])
  } catch (err) {
    console.warn("[CliphistState] Error al vaciar historial:", err)
  } finally {
    setClipItems([])
    updateFiltered()
    setSelectedIndex(0)
    setSearchQuery("")
  }
}

// Copiar el elemento actualmente seleccionado en el filtro
export async function copyCurrentSelection() {
  const filtered = filteredItems.peek()
  const idx = selectedIndex.peek()
  if (filtered[idx]) {
    await copyItem(filtered[idx])
  }
}

// Eliminar el elemento actualmente seleccionado
export async function deleteCurrentSelection() {
  const filtered = filteredItems.peek()
  const idx = selectedIndex.peek()
  if (filtered[idx]) {
    await deleteItem(filtered[idx])
  }
}

// Abrir el menú posicionado en el cursor
export async function openCliphist() {
  if (closeTimeoutId !== null) {
    clearTimeout(closeTimeoutId)
    closeTimeoutId = null
  }

  isClosing = false
  lastOpenTime = Date.now()
  setSearchQuery("")
  setSelectedIndex(0)

  // Registrar ventana activa antes de mostrar el overlay para el auto-pegado
  try {
    const actWinStr = await execAsync("hyprctl activewindow -j")
    const actWinObj = JSON.parse(actWinStr)
    if (actWinObj && actWinObj.address) {
      lastFocusedWindow = actWinObj.address
      lastFocusedClass = actWinObj.class || actWinObj.initialClass || ""
    } else {
      lastFocusedWindow = null
      lastFocusedClass = null
    }
  } catch {
    lastFocusedWindow = null
    lastFocusedClass = null
  }

  // Cargar lista actualizada con timestamps
  await loadCliphistItems()

  const CARD_WIDTH = 460
  const CARD_HEIGHT = 480
  const MARGIN = 16

  let targetMonName = "DP-1"
  let monWidth = 1920
  let monHeight = 1080
  let monX = 0
  let monY = 0

  let cursorX = 960
  let cursorY = 540

  try {
    const curJsonStr = await execAsync("hyprctl cursorpos -j")
    const curObj = JSON.parse(curJsonStr)
    if (typeof curObj.x === "number" && typeof curObj.y === "number") {
      cursorX = curObj.x
      cursorY = curObj.y
    }
  } catch (e) {
    console.warn("[CliphistState] No se pudo obtener cursorpos:", e)
  }

  try {
    const monJsonStr = await execAsync("hyprctl monitors -j")
    const monList = JSON.parse(monJsonStr)
    if (Array.isArray(monList)) {
      const matching = monList.find(
        (m: any) =>
          cursorX >= m.x &&
          cursorX < m.x + m.width &&
          cursorY >= m.y &&
          cursorY < m.y + m.height
      )
      const targetMon = matching || monList.find((m: any) => m.focused) || monList[0]
      if (targetMon) {
        targetMonName = targetMon.name || "DP-1"
        monWidth = targetMon.width || 1920
        monHeight = targetMon.height || 1080
        monX = targetMon.x || 0
        monY = targetMon.y || 0
      }
    }
  } catch (e) {
    console.warn("[CliphistState] No se pudieron obtener monitores:", e)
  }

  // Coordenadas relativas al monitor
  const relX = cursorX - monX
  const relY = cursorY - monY

  let posX = relX
  let posY = relY
  let originX: "left" | "right" = "left"
  let originY: "top" | "bottom" = "top"

  // Clamping y dirección horizontal
  if (relX + CARD_WIDTH + MARGIN > monWidth) {
    posX = Math.max(MARGIN, relX - CARD_WIDTH)
    originX = "right"
  } else {
    posX = Math.max(MARGIN, relX)
    originX = "left"
  }

  // Clamping y dirección vertical
  if (relY + CARD_HEIGHT + MARGIN > monHeight) {
    posY = Math.max(MARGIN, relY - CARD_HEIGHT)
    originY = "bottom"
  } else {
    posY = Math.max(MARGIN, relY)
    originY = "top"
  }

  setCursorCoords({
    x: posX,
    y: posY,
    originX,
    originY,
  })

  setPanelAnimClass(`cliphist-panel cliphist-open-${originX}-${originY}`)

  if (activeCliphistMonitor.peek() === targetMonName) {
    setActiveCliphistMonitor(null)
  }
  setActiveCliphistMonitor(targetMonName)
  setCliphistOpen(true)
}

// Cerrar el menú con animación suave estilo macOS
export function closeCliphist() {
  if (isClosing) return
  if (activeCliphistMonitor.peek() === null) return

  isClosing = true
  setPanelAnimClass("cliphist-panel cliphist-closing")

  closeTimeoutId = setTimeout(() => {
    setActiveCliphistMonitor(null)
    setCliphistOpen(false)
    setSearchQuery("")
    setSelectedIndex(0)
    isClosing = false
    closeTimeoutId = null
  }, 160)
}

// Alternar apertura/cierre
export async function toggleCliphist() {
  if (activeCliphistMonitor.peek() !== null && !isClosing) {
    closeCliphist()
  } else {
    await openCliphist()
  }
}

// Carga inicial para tener elementos listos en memoria de inmediato
loadCliphistItems().catch(() => {})

