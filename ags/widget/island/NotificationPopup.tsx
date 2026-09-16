import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { For } from "ags"
import {
  activePopups,
  dismissPopup,
  invokeNotificationAction,
  NotificationPopupItem,
} from "./NotificationService"

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
          {(popup: NotificationPopupItem) => (
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
                {/* ── Top Line: App Name & Close Button (Style Image 2) ── */}
                {(() => {
                  const isNotifySend = popup.appName.toLowerCase() === "notify-send"
                  const title = isNotifySend
                    ? (popup.summary || "NOTIFICACIÓN")
                    : (popup.appName || popup.summary || "NOTIFICACIÓN")
                  const body = isNotifySend
                    ? popup.body
                    : (popup.body || (popup.summary !== title ? popup.summary : ""))

                  return (
                    <box orientation={Gtk.Orientation.VERTICAL} spacing={4}>
                      <box valign={Gtk.Align.CENTER} spacing={8}>
                        <label
                          class="notif-popup-app"
                          label={title}
                          halign={Gtk.Align.START}
                          hexpand
                        />
                        <button
                          class="notif-popup-close"
                          onClicked={(e: any) => {
                            e?.stopPropagation?.()
                            dismissPopup(popup.id, 2)
                          }}
                          cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
                        >
                          <label class="font-icon" label="close" />
                        </button>
                      </box>

                      {body ? (
                        <label
                          class="notif-popup-body"
                          label={body}
                          halign={Gtk.Align.START}
                          wrap
                          wrapMode={2}
                        />
                      ) : null}
                    </box>
                  )
                })()}

                {/* ── Action Pills if provided ── */}
                {popup.actions && popup.actions.length > 0 ? (
                  <box spacing={6} class="notif-popup-actions" marginTop={4}>
                    {popup.actions.map((act) => (
                      <button
                        class="notif-popup-action-btn"
                        onClicked={(e: any) => {
                          e?.stopPropagation?.()
                          invokeNotificationAction(popup.id, act.id)
                        }}
                      >
                        <label label={act.label} />
                      </button>
                    ))}
                  </box>
                ) : null}
              </box>
            </button>
          )}
        </For>
      </box>
    </window>
  )
}
