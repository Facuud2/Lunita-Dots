import { Gtk } from "ags/gtk4"
import { createPoll } from "ags/time"

const bottomClockPoll = createPoll(
  { timeStr: "12 : 00 AM", dateStr: "Jan 01, 2026" },
  1000,
  () => {
    const now = new Date()
    const rawH = now.getHours()
    const ampm = rawH >= 12 ? "PM" : "AM"
    const h12 = rawH % 12 || 12
    const min = String(now.getMinutes()).padStart(2, "0")
    const timeStr = `${String(h12).padStart(2, "0")} : ${min} ${ampm}`

    const monthStr = now.toLocaleDateString("en-US", { month: "short" })
    const dayStr = String(now.getDate()).padStart(2, "0")
    const yearStr = now.getFullYear()
    const dateStr = `${monthStr} ${dayStr}, ${yearStr}`

    return { timeStr, dateStr }
  }
)

export default function BottomClock() {
  return (
    <box class="pm-bottom-clock" orientation={Gtk.Orientation.VERTICAL} spacing={4} halign={Gtk.Align.END} valign={Gtk.Align.END}>
      <label
        class="pm-bottom-time font-dots"
        label={bottomClockPoll((b) => b.timeStr)}
        halign={Gtk.Align.END}
      />
      <label
        class="pm-bottom-date font-dots"
        label={bottomClockPoll((b) => b.dateStr)}
        halign={Gtk.Align.END}
      />
    </box>
  )
}
