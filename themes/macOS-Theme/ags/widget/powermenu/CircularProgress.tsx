import { Gtk, Gdk } from "ags/gtk4"
import { Accessor } from "ags"
import Pango from "gi://Pango"
import PangoCairo from "gi://PangoCairo"

interface CircularProgressProps {
  value: number | Accessor<number>
  label: string | Accessor<string>
  color: string // Hex color string: e.g. "#D71921", "#FFFFFF", "#8E8E93"
  size?: number
  strokeWidth?: number
  tooltipText?: string | Accessor<string>
  hoverLabel?: string
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

export default function CircularProgress({
  value,
  label,
  color,
  size = 58,
  strokeWidth = 5,
  tooltipText,
  hoverLabel,
}: CircularProgressProps) {
  const [fgR, fgG, fgB] = hexToRgb(color)
  let isHovered = false

  const area = new Gtk.DrawingArea()
  area.set_content_width(size)
  area.set_content_height(size)

  // Controlador de movimiento para detectar hover del cursor
  const motion = new Gtk.EventControllerMotion()
  motion.connect("enter", () => {
    isHovered = true
    area.queue_draw()
  })
  motion.connect("leave", () => {
    isHovered = false
    area.queue_draw()
  })
  area.add_controller(motion)

  area.set_draw_func((_area, cr, w, h) => {
    const xc = w / 2
    const yc = h / 2
    const radius = Math.min(w, h) / 2 - strokeWidth

    if (radius <= 0) return

    // 1. Fondo de la pista (Track)
    cr.setLineWidth(strokeWidth)
    cr.setSourceRGBA(1, 1, 1, isHovered ? 0.12 : 0.08)
    cr.arc(xc, yc, radius, 0, 2 * Math.PI)
    cr.stroke()

    // 2. Arco de progreso activo
    const rawVal = typeof value === "function" ? (value as any)() : value
    const numVal = typeof rawVal === "number" ? rawVal : parseFloat(rawVal) || 0
    const clamped = Math.max(0, Math.min(100, numVal))

    if (clamped > 0) {
      const startAngle = -Math.PI / 2
      const endAngle = startAngle + (clamped / 100) * 2 * Math.PI
      cr.setLineWidth(isHovered ? strokeWidth + 0.8 : strokeWidth)
      cr.setSourceRGB(fgR, fgG, fgB)
      cr.arc(xc, yc, radius, startAngle, endAngle)
      cr.stroke()
    }

    // 3. Texto centrado usando PangoCairo (al hacer hover muestra hoverLabel si existe)
    const textStr = isHovered && hoverLabel ? hoverLabel : String(typeof label === "function" ? (label as any)() : label)
    const layout = PangoCairo.create_layout(cr)
    layout.set_text(textStr, -1)
    const fontDesc = Pango.FontDescription.from_string(textStr.length >= 4 ? "Space Grotesk Bold 8" : "Space Grotesk Bold 9")
    layout.set_font_description(fontDesc)
    const [pWidth, pHeight] = layout.get_pixel_size()

    cr.moveTo(xc - pWidth / 2, yc - pHeight / 2)
    cr.setSourceRGB(1.0, 1.0, 1.0) // #FFFFFF Nothing White
    PangoCairo.show_layout(cr, layout)
  })

  // Reactividad para value (re-dibujar cuando cambie)
  if (typeof value === "function" && "subscribe" in value) {
    ;(value as any).subscribe(() => {
      area.queue_draw()
    })
  }

  // Reactividad para label (re-dibujar cuando cambie el texto)
  if (typeof label === "function" && "subscribe" in label) {
    ;(label as any).subscribe(() => {
      area.queue_draw()
    })
  }

  return (
    <box
      class="circ-progress-meter"
      tooltipText={tooltipText as any}
      cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
      halign={Gtk.Align.CENTER}
      valign={Gtk.Align.CENTER}
      $={(self) => {
        self.append(area)
      }}
    />
  )
}
