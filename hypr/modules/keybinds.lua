local M = {}

function M.setup(opts_or_terminal, fileManager, menu, browser, ide, mainMod)
    local opts = {}
    if type(opts_or_terminal) == "table" then
        opts = opts_or_terminal
    else
        opts = {
            terminal    = opts_or_terminal,
            fileManager = fileManager,
            menu        = menu,
            browser     = browser,
            ide         = ide,
            mainMod     = mainMod,
        }
    end

    local terminal    = opts.terminal    or "kitty"
    local fileManager = opts.fileManager or "dolphin"
    local menu        = opts.menu        or "rofi -show run"
    local browser     = opts.browser     or "zen-browser"
    local ide         = opts.ide         or "antigravity"
    local mod         = opts.mainMod     or "SUPER"

    -- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
    hl.bind(mod .. " + SPACE", hl.dsp.exec_cmd("ags request toggle-island"))
    hl.bind(mod .. " + Q", hl.dsp.exec_cmd(terminal))
    local closeWindowBind = hl.bind(mod .. " + C", hl.dsp.window.close())
    -- closeWindowBind:set_enabled(false)
    hl.bind(mod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
    hl.bind(mod .. " + E", hl.dsp.exec_cmd(fileManager))
    hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
    hl.bind(mod .. " + R", hl.dsp.exec_cmd(menu))
    hl.bind(mod .. " + P", hl.dsp.window.pseudo())
    hl.bind(mod .. " + J", hl.dsp.layout("togglesplit"))    -- dwindle only

    -- Tabbed windows / Grupos de pestañas
    hl.bind(mod .. " + G",           hl.dsp.group.toggle())
    hl.bind(mod .. " + TAB",         hl.dsp.group.next())
    hl.bind(mod .. " + SHIFT + TAB", hl.dsp.group.prev())
    hl.bind(mod .. " + CTRL + G",    hl.dsp.group.lock_active())
    hl.bind(mod .. " + B", hl.dsp.exec_cmd(browser))
    hl.bind(mod .. " + SHIFT + B", hl.dsp.exec_cmd(browser .. " --private-window"))
    hl.bind(mod .. " + X", hl.dsp.exec_cmd(ide))
    hl.bind("Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))

    -- Move focus with mod + arrow keys
    hl.bind(mod .. " + left",  hl.dsp.focus({ direction = "left" }))
    hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
    hl.bind(mod .. " + up",    hl.dsp.focus({ direction = "up" }))
    hl.bind(mod .. " + down",  hl.dsp.focus({ direction = "down" }))

    -- Switch workspaces with mod + [0-9]
    -- Move active window to a workspace with mod + SHIFT + [0-9]
    for i = 1, 10 do
        local key = i % 10 -- 10 maps to key 0
        hl.bind(mod .. " + " .. key,             hl.dsp.focus({ workspace = i }))
        hl.bind(mod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
    end

    -- Example special workspace (scratchpad)
    hl.bind(mod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
    hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

    -- Scroll through existing workspaces with mod + scroll
    hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
    hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

    -- Move/resize windows with mod + LMB/RMB and dragging
    hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
    hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

    -- Laptop multimedia keys for volume and LCD brightness
    hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
    hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
    hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
    hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
    hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
    hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

    -- Requires playerctl
    hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
    hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
    hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
    hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
end

return M
