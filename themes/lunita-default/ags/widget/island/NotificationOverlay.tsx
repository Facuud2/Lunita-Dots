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

// Helper to check if an icon exists in the system icon theme
let cachedIconTheme: Gtk.IconTheme | null = null
export function hasSystemIcon(name: string): boolean {
  if (!name) return false
  try {
    if (!cachedIconTheme) {
      const display = Gdk.Display.get_default()
      if (display) cachedIconTheme = Gtk.IconTheme.get_for_display(display)
    }
    return cachedIconTheme ? cachedIconTheme.has_icon(name) : false
  } catch {
    return false
  }
}

// Fallback outline glyph for an app
export function getAppOutlineGlyph(appName: string, summary: string): string {
  const text = `${appName} ${summary}`.toLowerCase()
  if (
    text.includes("term") ||
    text.includes("bash") ||
    text.includes("kitty") ||
    text.includes("alacritty") ||
    text.includes("foot") ||
    text.includes("console") ||
    text.includes("zsh")
  ) {
    return "terminal"
  }
  if (
    text.includes("web") ||
    text.includes("firefox") ||
    text.includes("chrome") ||
    text.includes("brave") ||
    text.includes("browser") ||
    text.includes("zen")
  ) {
    return "language"
  }
  if (
    text.includes("music") ||
    text.includes("spotify") ||
    text.includes("audio") ||
    text.includes("sound") ||
    text.includes("mpv") ||
    text.includes("amberol")
  ) {
    return "music_note"
  }
  if (
    text.includes("code") ||
    text.includes("vsc") ||
    text.includes("git") ||
    text.includes("neovim") ||
    text.includes("editor")
  ) {
    return "code"
  }
  if (
    text.includes("chat") ||
    text.includes("discord") ||
    text.includes("telegram") ||
    text.includes("slack") ||
    text.includes("message") ||
    text.includes("signal")
  ) {
    return "chat_bubble_outline"
  }
  if (text.includes("mail") || text.includes("correo") || text.includes("thunderbird")) {
    return "mail_outline"
  }
  if (
    text.includes("file") ||
    text.includes("archivo") ||
    text.includes("nautilus") ||
    text.includes("thunar") ||
    text.includes("folder")
  ) {
    return "folder_open"
  }
  if (
    text.includes("setting") ||
    text.includes("config") ||
    text.includes("ajuste") ||
    text.includes("control") ||
    text.includes("preferenc")
  ) {
    return "settings"
  }
  if (text.includes("down") || text.includes("descarg")) {
    return "download"
  }
  return "notifications"
}

// Pastel status info: flat pastel green, red, or gray
export interface PastelStatusInfo {
  icon: string | null
  className: string
}

export function getCleanAppName(appName: string): string {
  const raw = (appName || "").trim()
  if (!raw || raw.toLowerCase() === "notify-send") {
    return "NOTIFICACIÓN"
  }
  return raw.toUpperCase()
}

export function getPastelStatus(n: NotificationItem): PastelStatusInfo {
  const text = `${n.appName} ${n.summary} ${n.body}`.toLowerCase()

  // Pastel Red: Critical urgency, warnings, errors, alerts
  if (
    n.urgency === "critical" ||
    text.includes("warn") ||
    text.includes("alerta") ||
    text.includes("error") ||
    text.includes("fall") ||
    text.includes("critical") ||
    text.includes("danger")
  ) {
    return {
      icon: "error",
      className: "pastel-red",
    }
  }

  // Pastel Green: Success, completions, updates, downloads finished
  if (
    text.includes("done") ||
    text.includes("complet") ||
    text.includes("actualiz") ||
    text.includes("update") ||
    text.includes("éxito") ||
    text.includes("success") ||
    text.includes("listo")
  ) {
    return {
      icon: "check_circle",
      className: "pastel-green",
    }
  }

  // Normal / standard messages: null (do not show a phantom empty circle)
  return {
    icon: null,
    className: "",
  }
}

// App Outline Icon component: dark gray background with crisp white outline
export function NotificationAppIcon({ notif, size = 34 }: { notif: NotificationItem; size?: number }) {
  const iconName = notif.appIcon || ""
  const isFilePath = iconName.startsWith("/")
  const hasThemed = !isFilePath && hasSystemIcon(iconName)
  const fallbackGlyph = getAppOutlineGlyph(notif.appName, notif.summary)
  const pixelSize = Math.round(size * 0.54)

  return (
    <box
      class="notif-app-outline-box"
      valign={Gtk.Align.CENTER}
      halign={Gtk.Align.CENTER}
      hexpand={false}
      vexpand={false}
      widthRequest={size}
      heightRequest={size}
    >
      {isFilePath ? (
        <image
          file={iconName}
          pixelSize={pixelSize}
          hexpand
          vexpand
          halign={Gtk.Align.CENTER}
          valign={Gtk.Align.CENTER}
        />
      ) : hasThemed ? (
        <image
          iconName={iconName}
          pixelSize={pixelSize}
          hexpand
          vexpand
          halign={Gtk.Align.CENTER}
          valign={Gtk.Align.CENTER}
        />
      ) : (
        <label
          class="font-icon notif-app-glyph"
          label={fallbackGlyph}
          hexpand
          vexpand
          halign={Gtk.Align.CENTER}
          valign={Gtk.Align.CENTER}
          xalign={0.5}
          yalign={0.5}
        />
      )}
    </box>
  )
}

export default function NotificationOverlay({ onClose }: { onClose: () => void }) {
  return (
    <box orientation={Gtk.Orientation.VERTICAL} class="island-overlay-card notification-overlay" spacing={12}>
      {/* ── 1. Title Bar with Back / Close Button ── */}
      <box class="overlay-header" valign={Gtk.Align.CENTER}>
        <box spacing={8} valign={Gtk.Align.CENTER}>
          <label class="font-icon overlay-title-icon" label="notifications" />
          <label class="overlay-title font-dots" label="CENTRO DE NOTIFICACIONES" />
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
        <label class="section-label font-dots" label="HISTORIAL" halign={Gtk.Align.START} />
        <box hexpand />
        <button
          class="clear-all-btn"
          onClicked={clearAllNotifications}
          visible={notifications((list) => list.length > 0)}
          cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
        >
          <box spacing={6} valign={Gtk.Align.CENTER}>
            <label class="font-icon notif-clear-icon" label="delete_sweep" />
            <label class="btn-label" label="Borrar todo" />
          </box>
        </button>
      </box>

      {/* ── 3. Do Not Disturb Switch Row (Nothing Style) ── */}
      <button
        class="notif-dnd-card"
        valign={Gtk.Align.CENTER}
        onClicked={toggleDnd}
        cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
      >
        <box spacing={10} valign={Gtk.Align.CENTER}>
          <label
            class={dndEnabled((d) =>
              d
                ? "font-icon pill-icon-bg notif-dnd-icon-active"
                : "font-icon pill-icon-bg notif-dnd-icon-idle"
            )}
            label={dndEnabled((d) => (d ? "do_not_disturb_on" : "notifications_active"))}
          />
          <box orientation={Gtk.Orientation.VERTICAL} spacing={1}>
            <label class="pill-title" label="Do Not Disturb" halign={Gtk.Align.START} />
            <label
              class={dndEnabled((d) =>
                d
                  ? "pill-subtitle font-dots notif-dnd-subtitle-active"
                  : "pill-subtitle font-dots notif-dnd-subtitle-idle"
              )}
              label={dndEnabled((d) => (d ? "MODO SILENCIOSO ACTIVO" : "NOTIFICACIONES HABILITADAS"))}
              halign={Gtk.Align.START}
            />
          </box>
          <box hexpand />
          <box
            class={dndEnabled((d) => (d ? "m3-switch active" : "m3-switch"))}
          >
            <box class="m3-handle" />
          </box>
        </box>
      </button>

      {/* ── 4. Notifications List (Nothing Style) ── */}
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
          <box orientation={Gtk.Orientation.VERTICAL} spacing={8} class="notif-list-box" halign={Gtk.Align.CENTER}>
            <For each={notifications}>
              {(notif: NotificationItem) => {
                const statusInfo = getPastelStatus(notif)
                return (
                  <box
                    class="notification-card"
                    orientation={Gtk.Orientation.VERTICAL}
                    spacing={6}
                    widthRequest={420}
                    halign={Gtk.Align.CENTER}
                    hexpand={false}
                  >
                    <box spacing={12} valign={Gtk.Align.CENTER}>
                      {/* Left: Outline App Icon (Fondo gris oscuro, reborde blanco) */}
                      <NotificationAppIcon notif={notif} size={34} />

                      {/* Content: App Name + Status + Title & Body */}
                      <box orientation={Gtk.Orientation.VERTICAL} spacing={3} hexpand>
                        {/* Meta header: App Name, Flat Pastel Icon, Timestamp & Close */}
                        <box spacing={6} valign={Gtk.Align.CENTER}>
                          <label
                            class="notif-card-app-title font-dots"
                            label={getCleanAppName(notif.appName)}
                            halign={Gtk.Align.START}
                          />

                          {/* Flat Pastel Status Icon (sin contenedor ni pill) */}
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

                          <label
                            class="notif-card-time font-dots"
                            label={formatRelativeTime(notif.timestamp)}
                            valign={Gtk.Align.CENTER}
                          />

                          <button
                            class="notif-card-close-btn"
                            onClicked={() => dismissNotification(notif.id)}
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

                        {/* Title / Summary */}
                        {notif.summary ? (
                          <label
                            class="notif-card-title font-ui"
                            label={notif.summary}
                            halign={Gtk.Align.START}
                            ellipsize={3}
                          />
                        ) : null}

                        {/* Body */}
                        {notif.body ? (
                          <label
                            class="notif-card-body font-ui"
                            label={notif.body}
                            halign={Gtk.Align.START}
                            wrap
                            wrapMode={2}
                          />
                        ) : null}
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
                            <label class="notif-action-label font-ui" label={act.label} />
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
