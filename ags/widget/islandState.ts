import { createState } from "ags"

// Shared reactive state for the Dynamic Island
// Used by DynamicIsland.tsx (UI) and app.ts (request handler)
export const [expanded, setExpanded] = createState(false)

export const toggleExpand = () => setExpanded(!expanded.peek())
export const collapse = () => setExpanded(false)
