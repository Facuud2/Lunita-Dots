import { Gtk } from "ags/gtk4"
import { With } from "ags"
import DockItem from "./DockItem"
import {
  pinnedApps,
  RIGHT_STACK_APPS,
  clients,
  getRunningUnpinnedApps,
  trashCount,
  openTrash,
  openDownloads,
  openAddAppModal,
  type PinnedApp,
  type RunningApp,
} from "./DockState"

export default function Platter() {
  const unpinnedRunning = clients((cList) => getRunningUnpinnedApps(pinnedApps.peek(), cList))

  return (
    <box class="dock-platter" spacing={0} valign={Gtk.Align.CENTER} halign={Gtk.Align.CENTER}>
      {/* ── Pinned Applications (Dynamic & Persistent) ── */}
      <With value={pinnedApps}>
        {(apps: PinnedApp[]) => (
          <box spacing={0} valign={Gtk.Align.CENTER}>
            {apps.map((app) => (
              <DockItem app={app} />
            ))}
          </box>
        )}
      </With>

      {/* ── Dynamic Running Unpinned Apps (if any) ── */}
      <With value={unpinnedRunning}>
        {(runningApps: RunningApp[]) => (
          <box spacing={0} valign={Gtk.Align.CENTER}>
            {runningApps.map((running) => (
              <DockItem runningApp={running} />
            ))}
          </box>
        )}
      </With>

      {/* ── Add App to Dock (+) Button ── */}
      <DockItem isAdd onAddClick={openAddAppModal} />

      {/* ── Divider between Pinned Apps and Utility Stacks ── */}
      <box class="dock-divider" />

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
        {(count: number) => (
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
