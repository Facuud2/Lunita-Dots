import { createState } from "ags"

// Shared reactive state for the Dynamic Island
// Used by DynamicIsland.tsx (UI), ExpandedPanel.tsx, and app.ts
export const [expanded, setExpanded] = createState(false)
export const [activeOverlayState, setActiveOverlayState] = createState<"none" | "wifi" | "bt" | "notifications">("none")

export const toggleExpand = () => {
  const next = !expanded.peek()
  setExpanded(next)
  if (!next) setActiveOverlayState("none")
}

export const collapse = () => {
  setExpanded(false)
  setActiveOverlayState("none")
}

export const toggleNotificationsMenu = () => {
  if (!expanded.peek()) {
    setActiveOverlayState("notifications")
    setExpanded(true)
  } else if (activeOverlayState.peek() === "notifications") {
    collapse()
  } else {
    setActiveOverlayState("notifications")
  }
}
