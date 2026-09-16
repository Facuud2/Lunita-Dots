import { Gtk, Gdk } from "ags/gtk4"
import { For } from "ags"
import {
  notifications,
  dndEnabled,
  toggleDnd,
  clearAllNotifications,
  dismissNotification,
  invokeNotificationAction,
  formatRelativeTime,
  NotificationItem,
} from "./NotificationService"

export default function NotificationOverlay({ onClose }: { onClose: () => void }) {
  // Helper to choose an icon for the notification
  const getNotificationIcon = (n: NotificationItem) => {
    const text = `${n.appName} ${n.summary} ${n.body}`.toLowerCase()
    if (text.includes("done") || text.includes("complet") || text.includes("actualiz") || text.includes("update")) {
      return { icon: "check_circle", className: "notif-icon-done" }
    }
    if (text.includes("warn") || text.includes("alerta") || n.urgency === "critical") {
      return { icon: "warning", className: "notif-icon-warn" }
    }
    if (text.includes("record") || text.includes("grab")) {
      return { icon: "fiber_manual_record", className: "notif-icon-rec" }
    }
    if (text.includes("music") || text.includes("spotify") || text.includes("audio")) {
      return { icon: "music_note", className: "notif-icon-media" }
    }
    return { icon: "notifications", className: "notif-icon-default" }
  }

  return (
    <box orientation={Gtk.Orientation.VERTICAL} class="island-overlay-card notification-overlay" spacing={12}>
      {/* ── 1. Title Bar with Back / Close Button ── */}
      <box class="overlay-header" valign={Gtk.Align.CENTER}>
        <box spacing={8} valign={Gtk.Align.CENTER}>
          <label class="font-icon overlay-title-icon" label="notifications" />
          <label class="overlay-title" label="CENTRO DE NOTIFICACIONES" />
        </box>
        <box hexpand />
        <button
          class="overlay-close-btn"
          onClicked={onClose}
          cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
        >
          <label class="font-icon" label="close" />
        </button>
      </box>

      {/* ── 2. Top Control Bar (Notifications Header + Clear All) ── */}
      <box class="notif-controls-header" valign={Gtk.Align.CENTER}>
        <label class="section-label" label="NOTIFICACIONES" halign={Gtk.Align.START} />
        <box hexpand />
        <button
          class="clear-all-btn"
          onClicked={clearAllNotifications}
          visible={notifications((list) => list.length > 0)}
          cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
        >
          <box spacing={6} valign={Gtk.Align.CENTER}>
            <label class="font-icon" label="clear_all" />
            <label class="btn-label" label="Borrar todo" />
          </box>
        </button>
      </box>

      {/* ── 3. Do Not Disturb Switch Row (Style Image 1) ── */}
      <box class="notif-dnd-card" valign={Gtk.Align.CENTER}>
        <box spacing={8} valign={Gtk.Align.CENTER}>
          <label
            class="font-icon pill-icon-bg"
            label={dndEnabled((d) => (d ? "do_not_disturb_on" : "notifications_active"))}
          />
          <box orientation={Gtk.Orientation.VERTICAL} spacing={1}>
            <label class="pill-title" label="Do Not Disturb" halign={Gtk.Align.START} />
            <label
              class="pill-subtitle"
              label={dndEnabled((d) => (d ? "MODO SILENCIOSO ACTIVO" : "NOTIFICACIONES HABILITADAS"))}
              halign={Gtk.Align.START}
            />
          </box>
        </box>
        <box hexpand />
        <button
          class={dndEnabled((d) => (d ? "m3-switch active" : "m3-switch"))}
          onClicked={toggleDnd}
          cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
        >
          <box class="m3-handle" />
        </button>
      </box>

      {/* ── 4. Notifications List (Style Image 1) ── */}
      <box orientation={Gtk.Orientation.VERTICAL} spacing={8}>
        {/* Empty State */}
        <box
          class="notif-empty-state"
          orientation={Gtk.Orientation.VERTICAL}
          spacing={8}
          halign={Gtk.Align.CENTER}
          valign={Gtk.Align.CENTER}
          visible={notifications((list) => list.length === 0)}
        >
          <label class="font-icon empty-icon" label="notifications_none" />
          <label class="empty-title font-dots" label="SIN NOTIFICACIONES" />
          <label class="empty-desc" label="Todo el sistema está al día" />
        </box>

        {/* Scrolled list when notifications exist */}
        <scrolledwindow
          minContentHeight={220}
          maxContentHeight={320}
          hscrollbarPolicy={Gtk.PolicyType.NEVER}
          visible={notifications((list) => list.length > 0)}
        >
          <box orientation={Gtk.Orientation.VERTICAL} spacing={6} class="notif-list-box">
            <For each={notifications}>
              {(notif: NotificationItem) => {
                const iconInfo = getNotificationIcon(notif)
                return (
                  <box class="notification-card" orientation={Gtk.Orientation.VERTICAL} spacing={6}>
                    <box spacing={10} valign={Gtk.Align.CENTER}>
                      {/* Left Circular Badge (Style Image 1) */}
                      <box class={`notif-badge ${iconInfo.className}`} valign={Gtk.Align.CENTER} halign={Gtk.Align.CENTER}>
                        <label class="font-icon notif-badge-icon" label={iconInfo.icon} />
                      </box>

                      {/* Content: Title & Subtitle */}
                      <box orientation={Gtk.Orientation.VERTICAL} spacing={2} hexpand>
                        <box spacing={6} valign={Gtk.Align.CENTER}>
                          <label
                            class="notif-card-title"
                            label={notif.summary || notif.appName}
                            halign={Gtk.Align.START}
                            ellipsize={3}
                          />
                          {notif.appName && notif.summary && notif.appName !== notif.summary && notif.appName.toLowerCase() !== "notify-send" ? (
                            <label
                              class="notif-card-app-badge"
                              label={notif.appName.toUpperCase()}
                              halign={Gtk.Align.START}
                            />
                          ) : null}
                        </box>

                        {notif.body ? (
                          <label
                            class="notif-card-body"
                            label={notif.body}
                            halign={Gtk.Align.START}
                            wrap
                            wrapMode={2}
                          />
                        ) : null}
                      </box>

                      {/* Right: Timestamp & Close Button */}
                      <box spacing={8} valign={Gtk.Align.CENTER}>
                        <label
                          class="notif-card-time font-dots"
                          label={formatRelativeTime(notif.timestamp)}
                        />
                        <button
                          class="notif-card-close-btn"
                          onClicked={() => dismissNotification(notif.id)}
                          cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
                        >
                          <label class="font-icon" label="close" />
                        </button>
                      </box>
                    </box>

                    {/* Action buttons if present */}
                    {notif.actions && notif.actions.length > 0 ? (
                      <box class="notif-actions-row" spacing={6}>
                        {notif.actions.map((act) => (
                          <button
                            class="notif-action-pill"
                            onClicked={() => invokeNotificationAction(notif.id, act.id)}
                            cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
                          >
                            <label class="notif-action-label" label={act.label} />
                          </button>
                        ))}
                      </box>
                    ) : null}
                  </box>
                )
              }}
            </For>
          </box>
        </scrolledwindow>
      </box>
    </box>
  )
}
