import { createState } from "ags"
import GLib from "gi://GLib?version=2.0"

export const [isVolumeOSDVisible, setIsVolumeOSDVisible] = createState(false)
export const [osdAnimClass, setOsdAnimClass] = createState("osd-show")

let hideTimer: number | null = null
let unmapTimer: number | null = null

export function showVolumeOSD(durationMs = 1800) {
  // Cancelar temporizadores pendientes si el usuario sigue cambiando el volumen
  if (hideTimer !== null) {
    GLib.source_remove(hideTimer)
    hideTimer = null
  }
  if (unmapTimer !== null) {
    GLib.source_remove(unmapTimer)
    unmapTimer = null
  }

  setOsdAnimClass("osd-show")
  setIsVolumeOSDVisible(true)

  // Programar desvanecimiento y posterior ocultamiento
  hideTimer = GLib.timeout_add(GLib.PRIORITY_DEFAULT, durationMs, () => {
    hideTimer = null
    setOsdAnimClass("osd-hide")

    // Esperar a que termine la animación de CSS (200ms) antes de desmapear la ventana
    unmapTimer = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 200, () => {
      unmapTimer = null
      setIsVolumeOSDVisible(false)
      return GLib.SOURCE_REMOVE
    })

    return GLib.SOURCE_REMOVE
  })
}

export function hideVolumeOSDImmediately() {
  if (hideTimer !== null) {
    GLib.source_remove(hideTimer)
    hideTimer = null
  }
  if (unmapTimer !== null) {
    GLib.source_remove(unmapTimer)
    unmapTimer = null
  }
  setOsdAnimClass("osd-hide")
  setIsVolumeOSDVisible(false)
}
