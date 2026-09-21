import { Gtk, Gdk } from "ags/gtk4"
import GObject from "gi://GObject"
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
  openAddAppModal,
  reorderPinnedApp,
} from "./DockState"
import { createDockContextMenu } from "./DockContextMenu"

interface DockItemProps {
  app?: PinnedApp
  runningApp?: RunningApp
  isTrash?: boolean
  isFolder?: boolean
  isAdd?: boolean
  trashCount?: number
  onTrashClick?: () => void
  onFolderClick?: () => void
  onAddClick?: () => void
}

export default function DockItem({
  app,
  runningApp,
  isTrash,
  isFolder,
  isAdd,
  trashCount = 0,
  onTrashClick,
  onFolderClick,
  onAddClick,
}: DockItemProps) {
  const id = isTrash
    ? "trash"
    : isFolder
    ? "folder-downloads"
    : isAdd
    ? "dock-add"
    : app?.id || runningApp?.id || "dock-item"

  const name = isTrash
    ? trashCount > 0
      ? `Papelera (${trashCount})`
      : "Papelera"
    : isFolder
    ? "Descargas"
    : isAdd
    ? "Añadir aplicación al Dock"
    : app?.name || runningApp?.name || ""

  let iconFile: string | undefined = undefined
  let fallbackIcon = "application-x-executable"

  if (isTrash) {
    iconFile = getIconAssetPath(trashCount > 0 ? "trash-full.svg" : "trash-empty.svg")
  } else if (isFolder) {
    iconFile = getIconAssetPath("folder.svg")
  } else if (isAdd) {
    iconFile = getIconAssetPath("add.svg")
  } else if (app?.iconFile) {
    iconFile = getIconAssetPath(app.iconFile)
  } else if (runningApp?.iconFile) {
    iconFile = runningApp.iconFile
  } else {
    fallbackIcon = runningApp?.icon || app?.fallbackIcon || "application-x-executable"
  }

  const handleClick = () => {
    if (isAdd) {
      if (onAddClick) onAddClick()
      else openAddAppModal()
      return
    }
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

  let popoverInstance: Gtk.Popover | null = null

  return (
    <button
      class="dock-item-btn"
      canFocus={false}
      focusable={false}
      cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
      tooltipText={name}
      onClicked={handleClick}
      $={(self) => {
        // Hover motion controller
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

        // Drag & Drop Reordering for Pinned Apps
        if (app) {
          try {
            const dragSource = new Gtk.DragSource({
              actions: Gdk.DragAction.MOVE,
            })
            dragSource.connect("prepare", () => {
              const val = new GObject.Value()
              val.init(GObject.TYPE_STRING)
              val.set_string(app.id)
              return Gdk.ContentProvider.new_for_value(val)
            })
            self.add_controller(dragSource)

            const dropTarget = Gtk.DropTarget.new(GObject.TYPE_STRING, Gdk.DragAction.MOVE)
            dropTarget.connect("drop", (_target, value) => {
              if (typeof value === "string" && value !== app.id) {
                reorderPinnedApp(value, app.id)
                return true
              }
              return false
            })
            self.add_controller(dropTarget)
          } catch (e) {
            console.warn("[DockItem] Error al registrar DnD:", e)
          }
        }

        // Right-click context menu gesture (except for '+' button)
        if (!isAdd) {
          const clickGesture = new Gtk.GestureClick()
          clickGesture.set_button(3) // Secondary / Right-click
          clickGesture.connect("pressed", (_gesture, _n, _x, _y) => {
            if (popoverInstance) {
              popoverInstance.unparent()
              popoverInstance = null
            }
            popoverInstance = createDockContextMenu({
              app,
              runningApp,
              isTrash,
              isFolder,
              parentWidget: self,
            })
            popoverInstance.popup()
          })
          self.add_controller(clickGesture)
        }
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
              pixelSize={54}
              halign={Gtk.Align.CENTER}
              valign={Gtk.Align.CENTER}
            />
          ) : (
            <image
              class="dock-app-icon"
              iconName={fallbackIcon}
              pixelSize={54}
              halign={Gtk.Align.CENTER}
              valign={Gtk.Align.CENTER}
            />
          )}
        </box>

        {/* Status Indicator Dot (glowing white dot centered underneath) */}
        {isTrash || isFolder || isAdd ? (
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
