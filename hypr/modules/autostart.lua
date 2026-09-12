local M = {}

function M.setup()
    -- See https://wiki.hypr.land/Configuring/Basics/Autostart/

    -- Autostart necessary processes (like notifications daemons, status bars, etc.)
    hl.on("hyprland.start", function ()
        hl.exec_cmd("env PATH=$HOME/.local/bin:$PATH ags run")
        hl.exec_cmd("pgrep -x awww-daemon >/dev/null || awww-daemon")
    end)
end

return M
