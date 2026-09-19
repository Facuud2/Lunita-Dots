import { createState } from "ags"
import Gio from "gi://Gio?version=2.0"
import GLib from "gi://GLib?version=2.0"

export interface NotificationAction {
  id: string
  label: string
}

export interface NotificationItem {
  id: number
  appName: string
  appIcon: string
  summary: string
  body: string
  actions: NotificationAction[]
  urgency: "low" | "normal" | "critical"
  timestamp: number
  timeFormatted: string
}

export interface NotificationPopupItem extends NotificationItem {
  timeoutSourceId?: number
}

export const [notifications, setNotifications] = createState<NotificationItem[]>([])
export const [activePopups, setActivePopups] = createState<NotificationPopupItem[]>([])
export const [dndEnabled, setDndEnabled] = createState<boolean>(false)

function syncNotificationsToFile(list: NotificationItem[]) {
  try {
    const data = JSON.stringify(list, null, 2)
    GLib.file_set_contents("/tmp/notifications_cache.json", data)
  } catch (e) {
    // ignore
  }
}

// ── Internal State ────────────────────────────────────────────────────────────
let nextNotifId = 1
let dbusConnection: Gio.DBusConnection | null = null
let dbusRegistrationId = 0

const NOTIF_IFACE_XML = `
<node>
  <interface name="org.freedesktop.Notifications">
    <method name="GetCapabilities">
      <arg type="as" name="capabilities" direction="out"/>
    </method>
    <method name="Notify">
      <arg type="s" name="app_name" direction="in"/>
      <arg type="u" name="replaces_id" direction="in"/>
      <arg type="s" name="app_icon" direction="in"/>
      <arg type="s" name="summary" direction="in"/>
      <arg type="s" name="body" direction="in"/>
      <arg type="as" name="actions" direction="in"/>
      <arg type="a{sv}" name="hints" direction="in"/>
      <arg type="i" name="expire_timeout" direction="in"/>
      <arg type="u" name="id" direction="out"/>
    </method>
    <method name="CloseNotification">
      <arg type="u" name="id" direction="in"/>
    </method>
    <method name="GetServerInformation">
      <arg type="s" name="name" direction="out"/>
      <arg type="s" name="vendor" direction="out"/>
      <arg type="s" name="version" direction="out"/>
      <arg type="s" name="spec_version" direction="out"/>
    </method>
    <signal name="NotificationClosed">
      <arg type="u" name="id"/>
      <arg type="u" name="reason"/>
    </signal>
    <signal name="ActionInvoked">
      <arg type="u" name="id"/>
      <arg type="s" name="action_key"/>
    </signal>
  </interface>
</node>
`

function formatTimeNow(): string {
  const d = new Date()
  const hh = String(d.getHours()).padStart(2, "0")
  const mm = String(d.getMinutes()).padStart(2, "0")
  return `${hh}:${mm}`
}

export function formatRelativeTime(timestamp: number): string {
  const diffSec = Math.floor((Date.now() - timestamp) / 1000)
  if (diffSec < 60) return "Ahora"
  const diffMin = Math.floor(diffSec / 60)
  if (diffMin < 60) return `hace ${diffMin}m`
  const diffHours = Math.floor(diffMin / 60)
  if (diffHours < 24) return `hace ${diffHours}h`
  return formatTimeNow()
}

// ── Notification Actions & Dismissal ──────────────────────────────────────────

export function dismissPopup(id: number, reason = 2) {
  const current = activePopups.peek()
  const target = current.find((p) => p.id === id)
  if (target?.timeoutSourceId) {
    GLib.source_remove(target.timeoutSourceId)
  }
  setActivePopups(current.filter((p) => p.id !== id))

  // Emit NotificationClosed if not already in history dismissal
  emitSignal("NotificationClosed", new GLib.Variant("(uu)", [id, reason]))
}

export function dismissNotification(id: number) {
  dismissPopup(id, 2)
  const remaining = notifications.peek().filter((n) => n.id !== id)
  setNotifications(remaining)
  syncNotificationsToFile(remaining)
}

export function clearAllNotifications() {
  const popups = activePopups.peek()
  for (const p of popups) {
    if (p.timeoutSourceId) GLib.source_remove(p.timeoutSourceId)
  }
  setActivePopups([])
  setNotifications([])
  syncNotificationsToFile([])
}

export function toggleDnd() {
  setDndEnabled(!dndEnabled.peek())
}

export function invokeNotificationAction(id: number, actionKey: string) {
  emitSignal("ActionInvoked", new GLib.Variant("(us)", [id, actionKey]))
  dismissPopup(id, 2)
}

function emitSignal(signalName: string, parameters: GLib.Variant) {
  if (!dbusConnection) return
  try {
    dbusConnection.emit_signal(
      null,
      "/org/freedesktop/Notifications",
      "org.freedesktop.Notifications",
      signalName,
      parameters
    )
  } catch (err) {
    console.warn(`[NotificationService] Error emitting signal ${signalName}:`, err)
  }
}

// ── DBus Method Handling ─────────────────────────────────────────────────────

function handleMethodCall(
  connection: Gio.DBusConnection,
  _sender: string,
  _objectPath: string,
  _interfaceName: string,
  methodName: string,
  parameters: GLib.Variant,
  invocation: Gio.DBusMethodInvocation
) {
  try {
    if (methodName === "GetCapabilities") {
      invocation.return_value(
        new GLib.Variant("(as)", [["actions", "body", "body-markup", "icon-static", "persistence"]])
      )
      return
    }

    if (methodName === "GetServerInformation") {
      invocation.return_value(
        new GLib.Variant("(ssss)", ["AGS Dynamic Island Notification Server", "Lunita-Dots", "1.0", "1.2"])
      )
      return
    }

    if (methodName === "CloseNotification") {
      const [id] = parameters.deep_unpack() as [number]
      dismissPopup(id, 3)
      invocation.return_value(null)
      return
    }

    if (methodName === "Notify") {
      const [
        appNameRaw,
        replacesId,
        appIconRaw,
        summaryRaw,
        bodyRaw,
        actionsRaw,
        hintsRaw,
        expireTimeoutRaw,
      ] = parameters.deep_unpack() as [
        string,
        number,
        string,
        string,
        string,
        string[],
        Record<string, GLib.Variant>,
        number
      ]

      const id = replacesId > 0 ? replacesId : nextNotifId++
      const appName = appNameRaw?.trim() || "Sistema"
      const appIcon = appIconRaw?.trim() || ""
      const summary = summaryRaw?.trim() || ""
      const body = bodyRaw?.trim() || ""

      // Parse actions: [key1, label1, key2, label2, ...]
      const actions: NotificationAction[] = []
      if (Array.isArray(actionsRaw)) {
        for (let i = 0; i < actionsRaw.length; i += 2) {
          if (actionsRaw[i] && actionsRaw[i + 1]) {
            actions.push({ id: actionsRaw[i], label: actionsRaw[i + 1] })
          }
        }
      }

      // Parse urgency hint
      let urgency: "low" | "normal" | "critical" = "normal"
      if (hintsRaw && typeof hintsRaw === "object") {
        const u = hintsRaw["urgency"]
        const val = u ? (typeof u.deep_unpack === "function" ? u.deep_unpack() : u) : 1
        if (val === 0) urgency = "low"
        else if (val === 2) urgency = "critical"
      }

      const item: NotificationItem = {
        id,
        appName,
        appIcon,
        summary,
        body,
        actions,
        urgency,
        timestamp: Date.now(),
        timeFormatted: formatTimeNow(),
      }

      // 1. Add to Notifications History (most recent on top, max 40 items)
      const currentNotifs = notifications.peek().filter((n) => n.id !== id)
      const updatedNotifs = [item, ...currentNotifs].slice(0, 40)
      setNotifications(updatedNotifs)
      syncNotificationsToFile(updatedNotifs)

      // 2. Add to Popups if DND is disabled OR notification is critical
      const isDnd = dndEnabled.peek()
      if (!isDnd || urgency === "critical") {
        // Calculate timeout (default 5 seconds, min 2s, max 15s)
        let durationMs = 5000
        if (expireTimeoutRaw > 0) {
          durationMs = Math.max(2000, Math.min(15000, expireTimeoutRaw))
        } else if (urgency === "critical") {
          durationMs = 9000
        }

        const sourceId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, durationMs, () => {
          dismissPopup(id, 1) // Reason 1: expired
          return GLib.SOURCE_REMOVE
        })

        const popupItem: NotificationPopupItem = {
          ...item,
          timeoutSourceId: sourceId,
        }

        // Limit concurrent popups to 3
        const currentPopups = activePopups.peek().filter((p) => p.id !== id)
        setActivePopups([popupItem, ...currentPopups].slice(0, 3))
      }

      // Return the notification ID
      invocation.return_value(new GLib.Variant("(u)", [id]))
      return
    }

    invocation.return_error_literal(
      Gio.DBusError,
      Gio.DBusError.UNKNOWN_METHOD,
      `Unknown method: ${methodName}`
    )
  } catch (err: any) {
    console.error(`[NotificationService] Error executing ${methodName}:`, err)
    invocation.return_error_literal(
      Gio.DBusError,
      Gio.DBusError.FAILED,
      `Internal error: ${err?.message || err}`
    )
  }
}

// ── Initialize Daemon ─────────────────────────────────────────────────────────

let isInitialized = false

export function initNotificationDaemon() {
  if (isInitialized) return
  isInitialized = true

  try {
    const nodeInfo = Gio.DBusNodeInfo.new_for_xml(NOTIF_IFACE_XML)
    const ifaceInfo = nodeInfo.interfaces[0]

    Gio.bus_own_name(
      Gio.BusType.SESSION,
      "org.freedesktop.Notifications",
      Gio.BusNameOwnerFlags.REPLACE,
      (connection: Gio.DBusConnection) => {
        dbusConnection = connection
        dbusRegistrationId = connection.register_object(
          "/org/freedesktop/Notifications",
          ifaceInfo,
          (conn, sender, objPath, ifaceName, methodName, params, invocation) => {
            handleMethodCall(conn, sender, objPath, ifaceName, methodName, params, invocation)
          },
          null,
          null
        )
      },
      (_connection: Gio.DBusConnection, name: string) => {
        console.log(`[NotificationService] Demonio de notificaciones adueñó el nombre en DBus: ${name}`)
      },
      (_connection: Gio.DBusConnection, name: string) => {
        console.warn(`[NotificationService] Nombre perdido en DBus: ${name}`)
      }
    )
  } catch (err) {
    console.error("[NotificationService] Falló al iniciar el demonio DBus:", err)
  }
}
