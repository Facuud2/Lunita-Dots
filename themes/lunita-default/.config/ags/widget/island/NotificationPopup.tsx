import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { For } from "ags"
import {
  activePopups,
  dismissPopup,
  invokeNotificationAction,
  NotificationPopupItem,
} from "./NotificationService"
import { NotificationAppIcon, getPastelStatus, getCleanAppName } from "./NotificationOverlay"

export default function NotificationPopup(gdkmonitor: Gdk.Monitor) {
  const { TOP } = Astal.WindowAnchor

  return (
    <window
      name="notification-popup-window"
      class="notification-popup-window"
      gdkmonitor={gdkmonitor}
      anchor={TOP}
      exclusivity={Astal.Exclusivity.IGNORE}
      layer={Astal.Layer.OVERLAY}
      application={app}
      marginTop={52}
      visible={activePopups((popups) => popups.length > 0)}
    >
      <box orientation={Gtk.Orientation.VERTICAL} spacing={8} class="notif-popup-container">
        <For each={activePopups}>
          {(popup: NotificationPopupItem) => {
            const statusInfo = getPastelStatus(popup)
            return (
              <button
                class="notif-popup-card-btn"
                onClicked={() => {
                  // If it has actions, invoke the first one, otherwise dismiss
                  if (popup.actions && popup.actions.length > 0) {
                    invokeNotificationAction(popup.id, popup.actions[0].id)
                  } else {
                    dismissPopup(popup.id, 2)
                  }
                }}
                cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
              >
                <box class="notif-popup-card" orientation={Gtk.Orientation.VERTICAL} spacing={4}>
                  <box spacing={10} valign={Gtk.Align.CENTER}>
                    {/* Left: Outline App Icon (fondo gris oscuro, reborde blanco) */}
                    <NotificationAppIcon notif={popup} size={32} />

                    {/* Middle / Right: Content */}
                    <box orientation={Gtk.Orientation.VERTICAL} spacing={2} hexpand>
                      {/* Top Line: App Name + Flat Pastel Icon + Close Button */}
                      <box valign={Gtk.Align.CENTER} spacing={6}>
                        <label
                          class="notif-popup-app font-dots"
                          label={getCleanAppName(popup.appName)}
                          halign={Gtk.Align.START}
                        />

                        {/* Flat Pastel Status Icon (sin pill ni contenedor con bordes) */}
                        {statusInfo.icon ? (
                          <label
                            class={`font-icon notif-flat-icon ${statusInfo.className}`}
                            label={statusInfo.icon}
                            valign={Gtk.Align.CENTER}
                            halign={Gtk.Align.CENTER}
                            xalign={0.5}
                            yalign={0.5}
                          />
                        ) : null}

                        <box hexpand />

                        <button
                          class="notif-popup-close"
                          onClicked={(e: any) => {
                            e?.stopPropagation?.()
                            dismissPopup(popup.id, 2)
                          }}
                          cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
                        >
                          <label
                            class="font-icon"
                            label="close"
                            valign={Gtk.Align.CENTER}
                            halign={Gtk.Align.CENTER}
                            xalign={0.5}
                            yalign={0.5}
                          />
                        </button>
                      </box>

                      {/* Summary / Title */}
                      {popup.summary ? (
                        <label
                          class="notif-popup-summary font-ui"
                          label={popup.summary}
                          halign={Gtk.Align.START}
                          ellipsize={3}
                        />
                      ) : null}

                      {/* Body text */}
                      {popup.body ? (
                        <label
                          class="notif-popup-body font-ui"
                          label={popup.body}
                          halign={Gtk.Align.START}
                          wrap
                          wrapMode={2}
                        />
                      ) : null}
                    </box>
                  </box>

                  {/* Action Pills if provided */}
                  {popup.actions && popup.actions.length > 0 ? (
                    <box spacing={6} class="notif-popup-actions" marginTop={2}>
                      {popup.actions.map((act) => (
                        <button
                          class="notif-popup-action-btn"
                          onClicked={(e: any) => {
                            e?.stopPropagation?.()
                            invokeNotificationAction(popup.id, act.id)
                          }}
                          cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
                        >
                          <label class="font-ui" label={act.label} />
                        </button>
                      ))}
                    </box>
                  ) : null}
                </box>
              </button>
            )
          }}
        </For>
      </box>
    </window>
  )
}
