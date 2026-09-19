import { Gtk, Gdk } from "ags/gtk4"
import {
  closeLauncher,
  selectedIndex,
  registerActionHandler,
  onCellHover,
  onCellLeave,
  launchOnActiveWorkspace,
} from "./LauncherState"
import { getProgram } from "./ConfigResolver"

export const LINKS: { icon: string; label: string; url: string }[] = [
  { icon: "\ue9cc",        label: "Google",     url: "https://www.google.com" },
  { icon: "\uea15",        label: "YouTube",    url: "https://www.youtube.com" },
  { icon: "\uf281",        label: "Reddit",     url: "https://www.reddit.com" },
  { icon: "\ue9f9",        label: "Twitter",    url: "https://www.twitter.com" },
  { icon: "\ue976",        label: "GitHub",     url: "https://www.github.com" },
  { icon: "\ue97c",        label: "SoundCloud", url: "https://www.soundcloud.com" },
]

export function launchLink(index: number) {
  const link = LINKS[index]
  if (link) {
    const browser = getProgram("browser")
    launchOnActiveWorkspace(`${browser} '${link.url}'`)
    closeLauncher()
  }
}

function LinkCell(link: (typeof LINKS)[number], index: number) {
  return (
    <button
      class={selectedIndex((sel) => (sel === index ? "al-cell selected" : "al-cell"))}
      canFocus={false}
      focusable={false}
      cursor={Gdk.Cursor.new_from_name("pointer", null) as any}
      onClicked={() => launchLink(index)}
      tooltipText={link.label}
      $={(self) => {
        const motion = new Gtk.EventControllerMotion()
        motion.connect("enter", () => {
          onCellHover(index)
        })
        motion.connect("leave", () => {
          onCellLeave(index)
        })
        self.add_controller(motion)
      }}
    >
      <box
        orientation={Gtk.Orientation.VERTICAL}
        spacing={8}
        halign={Gtk.Align.CENTER}
        valign={Gtk.Align.CENTER}
      >
        <label class="al-cell-icon" label={link.icon} />
        <label class="al-cell-label" label={link.label} />
      </box>
    </button>
  )
}

export default function QuickLinksTab() {
  registerActionHandler(launchLink)

  return (
    <box class="al-grid" spacing={12} homogeneous>
      {LINKS.map((link, i) => LinkCell(link, i))}
    </box>
  )
}
