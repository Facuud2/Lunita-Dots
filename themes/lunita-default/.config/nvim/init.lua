-- Neovim Configuration Entry Point
-- Integrated with Kitty, Hyprland, and Matugen-bin

-- 1. General Options
require("options")

-- 2. Theme & Highlight Engine
local theme = require("theme")
theme.setup()

-- 3. Statusline Footer
local statusline = require("statusline")
statusline.setup()

-- 4. Real-time Matugen Color Watcher
-- Watches ~/.config/nvim/lua/colors.lua for changes and live-reloads highlights
local uv = vim.uv or vim.loop
local colors_path = vim.fn.stdpath("config") .. "/lua/colors.lua"

local function reload_theme()
    vim.schedule(function()
        package.loaded["colors"] = nil
        package.loaded["theme"] = nil
        local t = require("theme")
        t.setup()
        vim.cmd("redrawstatus")
        vim.cmd("redraw!")
    end)
end

if uv and uv.new_fs_event then
    local fs_event = uv.new_fs_event()
    if fs_event then
        fs_event:start(colors_path, {}, function(err, filename, events)
            if not err and events.change then
                reload_theme()
            end
        end)
    end
end

-- Fallback reload on focus gained
vim.api.nvim_create_autocmd("FocusGained", {
    callback = function()
        reload_theme()
    end,
})
