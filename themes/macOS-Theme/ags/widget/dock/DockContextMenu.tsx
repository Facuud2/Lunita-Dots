import { Gtk, Gdk } from "ags/gtk4"
import {
  type PinnedApp,
  type RunningApp,
  isAppPinned,
  pinApp,
  unpinApp,
  pinRunningApp,
  focusOrLaunchApp,
  launchNewInstance,
  closeAppWindows,
  focusWindow,
  openDownloads,
  openTrash,
  emptyTrash,
  getMatchingClients,
  trashCount,
} from "./DockState"

interface DockContextMenuProps {
  app?: PinnedApp
  runningApp?: RunningApp
  isTrash?: boolean
  isFolder?: boolean
  parentWidget: Gtk.Widget
}

export function createDockContextMenu({
  app,
  runningApp,
  isTrash,
  isFolder,
  parentWidget,
}: DockContextMenuProps): Gtk.Popover {
  const popover = new Gtk.Popover({
    position: Gtk.PositionType.TOP,
    hasArrow: true,
    autohide: true,
  })
  popover.add_css_class("dock-popover-menu")
  popover.set_parent(parentWidget)

  const menuBox = new Gtk.Box({
    orientation: Gtk.Orientation.VERTICAL,
    spacing: 2,
  })
  menuBox.add_css_class("dock-menu-box")

  const pointerCursor = Gdk.Cursor.new_from_name("pointer", null)

  const createMenuItem = (label: string, iconName?: string, onClick?: () => void, destructive = false) => {
    const btn = new Gtk.Button({
      canFocus: false,
      focusable: false,
      cursor: pointerCursor as any,
    })
    btn.add_css_class("dock-menu-item")
    if (destructive) btn.add_css_class("destructive")

    const row = new Gtk.Box({
      orientation: Gtk.Orientation.HORIZONTAL,
      spacing: 10,
      halign: Gtk.Align.FILL,
      hexpand: true,
    })

    const lbl = new Gtk.Label({
      label,
      halign: Gtk.Align.START,
      hexpand: true,
      xalign: 0,
    })
    lbl.add_css_class("dock-menu-label")
    row.append(lbl)

    if (iconName) {
      const icon = new Gtk.Image({
        iconName,
        pixelSize: 14,
        halign: Gtk.Align.END,
      })
      icon.add_css_class("dock-menu-icon")
      row.append(icon)
    }

    btn.set_child(row)
    btn.connect("clicked", () => {
      popover.popdown()
      if (onClick) onClick()
    })
    return btn
  }

  const createSeparator = () => {
    const sep = new Gtk.Box()
    sep.add_css_class("dock-menu-separator")
    return sep
  }

  // ── 1. Trash Menu ──
  if (isTrash) {
    const count = trashCount.peek()
    menuBox.append(
      createMenuItem("Abrir Papelera", "folder-open-symbolic", () => {
        openTrash()
      })
    )
    if (count > 0) {
      menuBox.append(createSeparator())
      menuBox.append(
        createMenuItem(
          `Vaciar Papelera (${count})`,
          "user-trash-symbolic",
          () => {
            emptyTrash()
          },
          true
        )
      )
    }
    popover.set_child(menuBox)
    return popover
  }

  // ── 2. Downloads / Folder Menu ──
  if (isFolder) {
    menuBox.append(
      createMenuItem("Abrir «Descargas»", "folder-download-symbolic", () => {
        openDownloads()
      })
    )
    menuBox.append(
      createMenuItem("Mostrar en el gestor de archivos", "system-file-manager-symbolic", () => {
        openDownloads()
      })
    )
    popover.set_child(menuBox)
    return popover
  }

  // ── 3. App Menu (Pinned or Running) ──
  const matchingClients = app ? getMatchingClients(app) : []
  const isRunning = matchingClients.length > 0 || !!runningApp

  // Window list if multiple
  if (matchingClients.length > 1) {
    for (const c of matchingClients) {
      const title = c.title ? c.title.slice(0, 32) : "Ventana"
      menuBox.append(
        createMenuItem(title, "window-new-symbolic", () => {
          focusWindow(c.address)
        })
      )
    }
    menuBox.append(createSeparator())
  }

  // Primary action: Open / Focus
  if (app) {
    menuBox.append(
      createMenuItem(isRunning ? "Traer al frente" : "Abrir", "media-playback-start-symbolic", () => {
        focusOrLaunchApp(app)
      })
    )
    if (isRunning) {
      menuBox.append(
        createMenuItem("Nueva ventana", "window-new-symbolic", () => {
          launchNewInstance(app)
        })
      )
    }
  } else if (runningApp) {
    menuBox.append(
      createMenuItem("Traer al frente", "media-playback-start-symbolic", () => {
        focusWindow(runningApp.address)
      })
    )
  }

  menuBox.append(createSeparator())

  // Options section: Pin / Unpin
  if (app) {
    menuBox.append(
      createMenuItem("Quitar del Dock", "list-remove-symbolic", () => {
        unpinApp(app.id)
      })
    )
  } else if (runningApp) {
    const pinned = isAppPinned(runningApp.class.toLowerCase().replace(/[^a-z0-9_-]/g, "-"))
    if (pinned) {
      menuBox.append(
        createMenuItem("Quitar del Dock", "list-remove-symbolic", () => {
          unpinApp(runningApp.class.toLowerCase().replace(/[^a-z0-9_-]/g, "-"))
        })
      )
    } else {
      menuBox.append(
        createMenuItem("Mantener en el Dock", "pin-symbolic", () => {
          pinRunningApp(runningApp)
        })
      )
    }
  }

  // Quit / Close if running
  if (isRunning) {
    menuBox.append(createSeparator())
    menuBox.append(
      createMenuItem(
        "Cerrar",
        "application-exit-symbolic",
        () => {
          if (app) {
            closeAppWindows(app)
          } else if (runningApp) {
            closeAppWindows(undefined, runningApp.address)
          }
        },
        true
      )
    )
  }

  popover.set_child(menuBox)
  return popover
}
