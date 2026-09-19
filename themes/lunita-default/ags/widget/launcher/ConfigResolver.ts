import GLib from "gi://GLib"

export type ProgramKey = "terminal" | "fileManager" | "ide" | "browser" | "music" | "menu"

const DEFAULTS: Record<ProgramKey, string> = {
  terminal: "kitty",
  fileManager: "dolphin",
  ide: "antigravity",
  browser: "zen-browser",
  music: "spotify",
  menu: "rofi -show drun",
}

const ALIASES: Record<ProgramKey, string[]> = {
  terminal: ["terminal", "TERMINAL"],
  fileManager: ["fileManager", "FILEMANAGER", "file_manager", "FILE_MANAGER", "filemanager"],
  ide: ["ide", "IDE", "editor", "EDITOR", "code"],
  browser: ["browser", "BROWSER"],
  music: ["music", "MUSIC", "musicPlayer", "MUSIC_PLAYER", "music_player"],
  menu: ["menu", "MENU"],
}

// In-memory cache of parsed config variables
let fileVarsCache: Record<string, string> = {}
let lastReadTime = 0
const CACHE_TTL_MS = 1500 // Re-read config files at most every 1.5s so changes are detected immediately

function readFileSafe(path: string): string | null {
  try {
    if (!GLib.file_test(path, GLib.FileTest.EXISTS)) return null
    const [ok, contents] = GLib.file_get_contents(path)
    if (ok && contents) {
      return new TextDecoder().decode(contents as any)
    }
  } catch {}
  return null
}

function parseLuaFile(content: string, vars: Record<string, string>) {
  // Match key = "val" or key = 'val' (only quoted strings)
  const luaRegex = /([a-zA-Z0-9_]+)\s*=\s*["']([^"']+)["']/g
  let m: RegExpExecArray | null
  while ((m = luaRegex.exec(content)) !== null) {
    // Ignore internal lua keywords or function parameters
    const key = m[1]
    const val = m[2].trim()
    if (val && !val.includes("opts_or_") && !val.startsWith("function")) {
      vars[key] = val
    }
  }

  // Match hl.env("key", "val")
  const hlenvRegex = /hl\.env\(\s*["']([^"']+)["']\s*,\s*["']([^"']+)["']\s*\)/g
  while ((m = hlenvRegex.exec(content)) !== null) {
    vars[m[1]] = m[2].trim()
  }
}

function parseConfFile(content: string, vars: Record<string, string>) {
  // Match Hyprland conf: $key = val
  const confRegex = /^\s*\$([a-zA-Z0-9_]+)\s*=\s*([^\n#;]+)/gm
  let m: RegExpExecArray | null
  while ((m = confRegex.exec(content)) !== null) {
    vars[m[1]] = m[2].trim()
  }

  // Match env = KEY,val
  const envRegex = /^\s*env\s*=\s*([a-zA-Z0-9_]+)\s*,\s*([^\n#;]+)/gm
  while ((m = envRegex.exec(content)) !== null) {
    vars[m[1]] = m[2].trim()
  }
}

function parseShellFile(content: string, vars: Record<string, string>) {
  // Match export key="val" or export key=val
  const shellRegex = /^\s*export\s+([a-zA-Z0-9_]+)\s*=\s*["']?([^"'\n#;]+)["']?/gm
  let m: RegExpExecArray | null
  while ((m = shellRegex.exec(content)) !== null) {
    vars[m[1]] = m[2].trim()
  }
}

export function reloadConfig(): Record<string, string> {
  const home = GLib.get_home_dir()
  const vars: Record<string, string> = {}

  // 1. Hyprland lua configurations
  const luaFiles = [
    `${home}/.config/hypr/hyprland.lua`,
    `${home}/.config/hypr/modules/env.lua`,
  ]
  for (const f of luaFiles) {
    const text = readFileSafe(f)
    if (text) parseLuaFile(text, vars)
  }

  // 2. Hyprland standard conf configurations
  const confFiles = [
    `${home}/.config/hypr/hyprland.conf`,
  ]
  for (const f of confFiles) {
    const text = readFileSafe(f)
    if (text) parseConfFile(text, vars)
  }

  // 3. Shell configurations
  const shellFiles = [
    `${home}/.config/environment.d/10-path.conf`,
    `${home}/.profile`,
    `${home}/.zshrc`,
    `${home}/.bashrc`,
  ]
  for (const f of shellFiles) {
    const text = readFileSafe(f)
    if (text) parseShellFile(text, vars)
  }

  fileVarsCache = vars
  lastReadTime = Date.now()
  return vars
}

export function getProgram(key: ProgramKey): string {
  const aliases = ALIASES[key] || [key]

  // 1. Check environment variables first (GLib.getenv)
  for (const alias of aliases) {
    const envVal = GLib.getenv(alias)
    if (envVal && envVal.trim()) {
      return envVal.trim()
    }
  }

  // 2. Check cached file variables (refresh if TTL expired)
  if (Date.now() - lastReadTime > CACHE_TTL_MS) {
    reloadConfig()
  }

  for (const alias of aliases) {
    if (fileVarsCache[alias] && fileVarsCache[alias].trim()) {
      return fileVarsCache[alias].trim()
    }
  }

  // 3. Fallback default
  return DEFAULTS[key] || key
}
