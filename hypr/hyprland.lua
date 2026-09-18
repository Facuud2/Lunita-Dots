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
require("modules.env").setup(programs)
require("modules.monitors").setup()
require("modules.general").setup()
require("modules.animations").setup()
require("modules.rules").setup()
require("modules.autostart").setup()

local keybinds = require("modules.keybinds")
keybinds.setup(programs)
