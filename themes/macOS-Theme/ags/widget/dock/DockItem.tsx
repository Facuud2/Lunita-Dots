import { Gtk, Gdk } from "ags/gtk4"
import {
  type PinnedApp,
  type RunningApp,
  clients,
  isAppRunning,
  focusOrLaunchApp,
  focusWindow,
  hoveredAppId,
  setHoveredAppId,
  getIconAssetPath,
} from "./DockState"

interface DockItemProps {
  app?: PinnedApp
  runningApp?: RunningApp
  isTrash?: boolean
  isFolder?: boolean
  trashCount?: number
  onTrashClick?: () => void
  onFolderClick?: () => void
}

export default function DockItem({
  app,
  runningApp,
  isTrash,
  isFolder,
  trashCount = 0,
  onTrashClick,
  onFolderClick,
}: DockItemProps) {
  const id = isTrash
    ? "trash"
    : isFolder
    ? "folder-downloads"
    : app?.id || runningApp?.id || "dock-item"

  const name = isTrash
    ? trashCount > 0
      ? `Papelera (${trashCount})`
      : "Papelera"
    : isFolder
    ? "Descargas"
    : app?.name || runningApp?.name || ""

  let iconFile: string | undefined = undefined
  let fallbackIcon = "application-x-executable"

  if (isTrash) {
    iconFile = getIconAssetPath(trashCount > 0 ? "trash-full.svg" : "trash-empty.svg")
  } else if (isFolder) {
    iconFile = getIconAssetPath("folder.svg")
  } else if (app?.iconFile) {
    iconFile = getIconAssetPath(app.iconFile)
  } else if (runningApp?.iconFile) {
    iconFile = runningApp.iconFile
  } else {
    fallbackIcon = runningApp?.icon || app?.fallbackIcon || "application-x-executable"
  }

  const handleClick = () => {
    if (isTrash) {
      if (onTrashClick) onTrashClick()
      return
    }
    if (isFolder) {
      if (onFolderClick) onFolderClick()
      return
    }
    if (app) {
      focusOrLaunchApp(app)
      return
    }
    if (runningApp) {
      focusWindow(runningApp.address)
      return
    }
  }

  return (
    <button
      class="dock-item-btn"
      canFocus={false}
      focusable={false}
      cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
      tooltipText={name}
      onClicked={handleClick}
      $={(self) => {
        const motion = new Gtk.EventControllerMotion()
        motion.connect("enter", () => {
          setHoveredAppId(id)
        })
        motion.connect("leave", () => {
          if (hoveredAppId.peek() === id) {
            setHoveredAppId(null)
          }
        })
        self.add_controller(motion)
      }}
    >
      <box orientation={Gtk.Orientation.VERTICAL} class="dock-item-container" spacing={0} halign={Gtk.Align.CENTER} valign={Gtk.Align.CENTER}>
        {/* Squircle App Icon Container */}
        <box
          class={hoveredAppId((h) => (h === id ? "dock-squircle hovered" : "dock-squircle"))}
          halign={Gtk.Align.CENTER}
          valign={Gtk.Align.CENTER}
        >
          {iconFile ? (
            <image
              class="dock-app-icon"
              file={iconFile}
              pixelSize={48}
              halign={Gtk.Align.CENTER}
              valign={Gtk.Align.CENTER}
            />
          ) : (
            <image
              class="dock-app-icon"
              iconName={fallbackIcon}
              pixelSize={48}
              halign={Gtk.Align.CENTER}
              valign={Gtk.Align.CENTER}
            />
          )}
        </box>

        {/* Status Indicator Dot (glowing white dot centered underneath) */}
        {isTrash || isFolder ? (
          <box class="dock-status-dot empty" />
        ) : app ? (
          <box
            class={clients((cList) =>
              isAppRunning(app, cList) ? "dock-status-dot active" : "dock-status-dot hidden"
            )}
          />
        ) : (
          <box class="dock-status-dot active" />
        )}
      </box>
    </button>
  )
}
