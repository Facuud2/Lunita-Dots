import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import {
  keyboardVisible,
  toggleVirtualKeyboard,
} from "./virtualkeyboard/VirtualKeyboardState"

export default function VirtualKeyboardTrigger(gdkmonitor: Gdk.Monitor) {
  const { TOP, RIGHT } = Astal.WindowAnchor
  const connector = gdkmonitor.get_connector() || ""

  return (
    <window
      visible
      name={`virtual-keyboard-trigger-${connector}`}
      class="vk-trigger-window"
      gdkmonitor={gdkmonitor}
      anchor={TOP | RIGHT}
      exclusivity={Astal.Exclusivity.IGNORE}
      layer={Astal.Layer.OVERLAY}
      application={app}
      marginTop={8}
      marginRight={20}
    >
      <button
        class={keyboardVisible((vis) =>
          vis ? "vk-trigger-btn active" : "vk-trigger-btn"
        )}
        onClicked={toggleVirtualKeyboard}
        cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
        tooltipText="Teclado en pantalla (Super + K)"
      >
        <box spacing={6} valign={Gtk.Align.CENTER} halign={Gtk.Align.CENTER}>
          <label class="font-icon vk-icon" label="keyboard" />
          <box
            class={keyboardVisible((vis) =>
              vis ? "vk-dot active" : "vk-dot"
            )}
            valign={Gtk.Align.CENTER}
          />
        </box>
      </button>
    </window>
  )
}
