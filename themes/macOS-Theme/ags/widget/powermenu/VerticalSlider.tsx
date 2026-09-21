import { Gtk, Gdk } from "ags/gtk4"
import { Accessor } from "ags"

interface VerticalSliderProps {
  value: number | Accessor<number>
  onChange: (val: number) => void
  color: string // Hex color string: e.g. "#dcd3be" (mic), "#7eb88a" (volume)
  tooltipText?: string | Accessor<string>
  width?: number
  height?: number
  borderRadius?: number
}

function hexToRgb(hex: string): [number, number, number] {
  const clean = hex.replace("#", "").trim()
  if (clean.length === 3) {
    const r = parseInt(clean[0] + clean[0], 16) / 255
    const g = parseInt(clean[1] + clean[1], 16) / 255
    const b = parseInt(clean[2] + clean[2], 16) / 255
    return [r, g, b]
  }
  const r = parseInt(clean.substring(0, 2), 16) / 255
  const g = parseInt(clean.substring(2, 4), 16) / 255
  const b = parseInt(clean.substring(4, 6), 16) / 255
  return [r, g, b]
}

function drawPill(cr: any, x: number, y: number, w: number, h: number, r: number) {
  cr.newSubPath()
  cr.arc(x + r, y + r, r, Math.PI, 1.5 * Math.PI)
  cr.arc(x + w - r, y + r, r, 1.5 * Math.PI, 2 * Math.PI)
  cr.arc(x + w - r, y + h - r, r, 0, 0.5 * Math.PI)
  cr.arc(x + r, y + h - r, r, 0.5 * Math.PI, Math.PI)
  cr.closePath()
}

export default function VerticalSlider({
  value,
  onChange,
  color,
  tooltipText,
  width = 26,
  height = 148,
  borderRadius = 13,
}: VerticalSliderProps) {
  const [fgR, fgG, fgB] = hexToRgb(color)

  const area = new Gtk.DrawingArea()
  area.set_content_width(width)
  area.set_content_height(height)

  area.set_draw_func((_area, cr, w, h) => {
    const r = Math.min(borderRadius, w / 2, h / 2)

    // 1. Fondo de la pista (Track oscuro translúcido)
    drawPill(cr, 0, 0, w, h, r)
    cr.setSourceRGBA(1, 1, 1, 0.08)
    cr.fill()

    // 2. Relleno activo recortado a la silueta de la píldora
    const rawVal = typeof value === "function" ? (value as any)() : value
    const numVal = typeof rawVal === "number" ? rawVal : parseFloat(rawVal) || 0
    const clamped = Math.max(0, Math.min(100, numVal))

    if (clamped > 0) {
      cr.save()
      drawPill(cr, 0, 0, w, h, r)
      cr.clip()

      const fillH = (clamped / 100) * h
      cr.rectangle(0, h - fillH, w, fillH)
      cr.setSourceRGB(fgR, fgG, fgB)
      cr.fill()
      cr.restore()
    }
  })

  // Reactividad: re-dibujar cuando cambie el valor
  if (typeof value === "function" && "subscribe" in value) {
    ;(value as any).subscribe(() => {
      area.queue_draw()
    })
  }

  // Interacción 1: Drag vertical continuo
  let isDragging = false
  let dragStartY = 0
  let dragStartVal = 0

  const drag = new Gtk.GestureDrag()
  drag.connect("drag-begin", (_g, _x, y) => {
    isDragging = true
    dragStartY = y
    const rawVal = typeof value === "function" ? (value as any)() : value
    dragStartVal = typeof rawVal === "number" ? rawVal : parseFloat(rawVal) || 0
  })
  drag.connect("drag-update", (_g, _dx, dy) => {
    const h = area.get_allocated_height() || height
    if (h > 0) {
      // Arrastrar hacia arriba (dy < 0) aumenta el volumen
      const deltaPerc = (-dy / h) * 100
      const nextVal = Math.max(0, Math.min(100, Math.round(dragStartVal + deltaPerc)))
      onChange(nextVal)
    }
  })
  drag.connect("drag-end", () => {
    isDragging = false
  })
  area.add_controller(drag)

  // Interacción 2: Click directo para saltar al porcentaje
  const click = new Gtk.GestureClick()
  click.connect("pressed", (_g, _n, _x, y) => {
    const h = area.get_allocated_height() || height
    if (h > 0) {
      const frac = Math.max(0, Math.min(1, (h - y) / h))
      onChange(Math.round(frac * 100))
    }
  })
  area.add_controller(click)

  // Interacción 3: Rueda de desplazamiento (Scroll)
  const scroll = new Gtk.EventControllerScroll()
  scroll.set_flags(Gtk.EventControllerScrollFlags.VERTICAL)
  scroll.connect("scroll", (_c, _dx, dy) => {
    const rawVal = typeof value === "function" ? (value as any)() : value
    const cur = typeof rawVal === "number" ? rawVal : parseFloat(rawVal) || 0
    const next = dy < 0 ? Math.min(100, cur + 3) : Math.max(0, cur - 3)
    onChange(next)
    return true
  })
  area.add_controller(scroll)

  return (
    <box
      class="pm-vertical-slider-container"
      cursor={Gdk.Cursor.new_from_name("ns-resize", null) as any}
      tooltipText={tooltipText as any}
      valign={Gtk.Align.CENTER}
      halign={Gtk.Align.CENTER}
      $={(self) => {
        self.append(area)
      }}
    />
  )
}
