import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import Platter from "./dock/Platter"

export default function Dock(gdkmonitor: Gdk.Monitor) {
  const { BOTTOM } = Astal.WindowAnchor

  return (
    <window
      visible
      name="macos-dock"
      namespace="macos-dock"
      class="macos-dock-window"
      gdkmonitor={gdkmonitor}
      anchor={BOTTOM}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      layer={Astal.Layer.TOP}
      application={app}
      marginBottom={10}
    >
      <box halign={Gtk.Align.CENTER} valign={Gtk.Align.END}>
        <Platter />
      </box>
    </window>
  )
}
