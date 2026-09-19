import { Gtk } from "ags/gtk4"
import { createPoll } from "ags/time"

const timeDayPoll = createPoll(
  { timeStr: "12 : 00 AM", dayStr: "Friday" },
  1000,
  () => {
    const now = new Date()
    const rawH = now.getHours()
    const ampm = rawH >= 12 ? "PM" : "AM"
    const h12 = rawH % 12 || 12
    const min = String(now.getMinutes()).padStart(2, "0")
    const timeStr = `${String(h12).padStart(2, "0")} : ${min} ${ampm}`
    const dayStr = now.toLocaleDateString("en-US", { weekday: "long" })
    return { timeStr, dayStr }
  }
)

export default function TimeCard() {
  return (
    <box class="pm-card pm-time-card" orientation={Gtk.Orientation.VERTICAL} spacing={4} halign={Gtk.Align.CENTER}>
      <label
        class="pm-time-clock font-dots"
        label={timeDayPoll((t) => t.timeStr)}
        halign={Gtk.Align.CENTER}
      />
      <label
        class="pm-time-day font-dots"
        label={timeDayPoll((t) => t.dayStr)}
        halign={Gtk.Align.CENTER}
      />
    </box>
  )
}
