--------------------------------------------------------------------------------
-- HYPRLAND MAIN CONFIGURATION
--------------------------------------------------------------------------------

-- Ensure ~/.config/hypr is in package.path so modules resolve anywhere
local config_dir = os.getenv("HOME") .. "/.config/hypr"
package.path = config_dir .. "/?.lua;" .. config_dir .. "/?/init.lua;" .. package.path

-- Invalidate cached modules so hyprctl reload picks up color and config changes
for k, _ in pairs(package.loaded) do
    if k:match("^modules%.") then
        package.loaded[k] = nil
    end
end

---------------------
---- MY PROGRAMS ----
---------------------
local programs = {
    terminal    = "kitty",
    fileManager = "dolphin",
    menu        = "rofi -show drun",
    browser     = "zen-browser",
    ide         = "antigravity",
    music       = "spotify",
}

-----------------
---- MODULES ----
-----------------
local function safe_setup(mod_name, ...)
    local ok, mod = pcall(require, mod_name)
    if ok and type(mod) == "table" and type(mod.setup) == "function" then
        mod.setup(...)
    else
        if mod_name == "modules.monitors" then
            -- Fallback seguro para monitores si el módulo está ausente o vacío
            hl.monitor({
                output   = "",
                mode     = "preferred",
                position = "auto",
                scale    = "1",
            })
        end
    end
end

safe_setup("modules.env", programs)
safe_setup("modules.monitors")
safe_setup("modules.general")
safe_setup("modules.animations")
safe_setup("modules.rules")
safe_setup("modules.autostart")

local ok_key, keybinds = pcall(require, "modules.keybinds")
if ok_key and type(keybinds) == "table" and type(keybinds.setup) == "function" then
    keybinds.setup(programs)
end
