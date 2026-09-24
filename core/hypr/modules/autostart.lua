local M = {}

function M.setup()
    -- See https://wiki.hypr.land/Configuring/Basics/Autostart/

    -- Autostart necessary processes (like notifications daemons, status bars, etc.)
    hl.on("hyprland.start", function ()
        local home = os.getenv("HOME")

        -- Autoinicio de componentes críticos del sistema
        -- 1. Sincronizar el entorno de Wayland con D-Bus y systemd
        hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
        hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

        -- 2. Iniciar el agente de Polkit
        -- Nota: si tu instalación no usa el servicio de systemd, la ruta directa suele ser "/usr/lib/hyprpolkitagent"
        hl.exec_cmd("systemctl --user start hyprpolkitagent")

        hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 40")
        hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'")
        hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 40")
        hl.exec_cmd("pgrep -x awww-daemon >/dev/null || awww-daemon")
        hl.exec_cmd("[ -d " .. home .. "/.config/quickshell/dock ] && quickshell -d -n -c dock")
        hl.exec_cmd("[ -d " .. home .. "/.config/ags ] && env PATH=" .. home .. "/.local/bin:$PATH ags run")
        hl.exec_cmd("[ -x " .. home .. "/.config/eww/scripts/launch.sh ] && " .. home .. "/.config/eww/scripts/launch.sh")
        hl.exec_cmd(home .. "/.config/hypr/scripts/virtual_keyboard.sh daemon")
        hl.exec_cmd("systemctl --user start cliphist")
        hl.exec_cmd("hyprpm reload -n")
    end)
end

return M
