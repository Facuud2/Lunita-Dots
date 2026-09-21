import { Gtk } from "ags/gtk4"
import { With } from "ags"
import DockItem from "./DockItem"
import {
  DEFAULT_PINNED_APPS,
  RIGHT_STACK_APPS,
  clients,
  getRunningUnpinnedApps,
  trashCount,
  openTrash,
  openDownloads,
} from "./DockState"

export default function Platter() {
  const unpinnedRunning = clients((cList) => getRunningUnpinnedApps(DEFAULT_PINNED_APPS, cList))

  return (
    <box class="dock-platter" spacing={0} valign={Gtk.Align.CENTER} halign={Gtk.Align.CENTER}>
      {/* ── Pinned Applications ── */}
      {DEFAULT_PINNED_APPS.map((app) => (
        <DockItem app={app} />
      ))}

      {/* ── Dynamic Running Unpinned Apps (if any) ── */}
      <With value={unpinnedRunning}>
        {(runningApps) => (
          <box spacing={0} valign={Gtk.Align.CENTER}>
            {runningApps.map((running) => (
              <DockItem runningApp={running} />
            ))}
          </box>
        )}
      </With>

      {/* ── Utility Stacks (Shortcuts, Passwords, Downloads) ── */}
      {RIGHT_STACK_APPS.map((app) => (
        <DockItem app={app} />
      ))}
      <DockItem
        isFolder
        onFolderClick={openDownloads}
      />

      {/* ── Trash Can ── */}
      <With value={trashCount}>
        {(count) => (
          <DockItem
            isTrash
            trashCount={count}
            onTrashClick={openTrash}
          />
        )}
      </With>
    </box>
  )
}
