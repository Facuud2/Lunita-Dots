import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { expanded, toggleExpand, collapse } from "./islandState"
import CompactPill from "./island/CompactPill"
import ExpandedPanel from "./island/ExpandedPanel"

export default function DynamicIsland(gdkmonitor: Gdk.Monitor) {
  const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor

  // ── 1. Fullscreen Transparent Backdrop (visible only when expanded) ──
  const _backdrop = (
    <window
      name="island-backdrop"
      class="island-backdrop-window"
      gdkmonitor={gdkmonitor}
      anchor={TOP | BOTTOM | LEFT | RIGHT}
      exclusivity={Astal.Exclusivity.IGNORE}
      layer={Astal.Layer.TOP}
      application={app}
      visible={expanded((exp) => exp)}
    >
      <button
        class="backdrop-btn"
        onClicked={collapse}
        cursor={Gdk.Cursor.new_from_name("default", null) as any}
      />
    </window>
  )

  // ── 2. Expanded Panel Popup Window (unmapped completely when collapsed) ──
  const _popup = (
    <window
      name="dynamic-island-popup"
      class="dynamic-island-popup"
      gdkmonitor={gdkmonitor}
      anchor={TOP}
      exclusivity={Astal.Exclusivity.IGNORE}
      layer={Astal.Layer.OVERLAY}
      application={app}
      marginTop={8}
      visible={expanded((exp) => exp)}
    >
      <box orientation={Gtk.Orientation.VERTICAL} class="island-shell expanded">
        {/* Top Header / Pill trigger to collapse */}
        <button
          class="compact-trigger"
          onClicked={collapse}
          cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
        >
          <CompactPill />
        </button>

        {/* Full Expanded Panel content */}
        <ExpandedPanel onClose={collapse} />
      </box>
    </window>
  )

  // ── 3. Compact Pill Bar Window (always 36px, never resizes or leaves black boxes) ──
  return (
    <window
      visible
      name="dynamic-island-pill"
      class="dynamic-island-pill"
      gdkmonitor={gdkmonitor}
      anchor={TOP}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      layer={Astal.Layer.TOP}
      application={app}
      marginTop={8}
    >
      <box class="island-shell compact">
        <button
          class="compact-trigger"
          onClicked={toggleExpand}
          cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
        >
          <CompactPill />
        </button>
      </box>
    </window>
  )
}
