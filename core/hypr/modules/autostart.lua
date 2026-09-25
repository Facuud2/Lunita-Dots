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
        hl.exec_cmd("systemctl --user start hyprpolkitagent || /usr/lib/hyprpolkitagent/hyprpolkitagent &")

        -- 3. Cursor y tema de sistema
        hl.exec_cmd("hyprctl setcursor Bibata-Modern-Ice 40")
        hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'")
        hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 40")

        -- 4. Demonio de fondo de pantalla y restauración
        hl.exec_cmd("pgrep -x awww-daemon >/dev/null || awww-daemon")
        hl.exec_cmd("sh -c 'sleep 0.5 && if [ -f \"" .. home .. "/.cache/hyprquickpaper/current_wallpaper\" ]; then awww img \"$(cat \"" .. home .. "/.cache/hyprquickpaper/current_wallpaper\")\"; elif [ -f \"" .. home .. "/.config/hypr/current_wallpaper.png\" ]; then awww img \"" .. home .. "/.config/hypr/current_wallpaper.png\"; fi'")

        -- 5. Quickshell Dock y Barra Superior
        hl.exec_cmd("[ -d " .. home .. "/.config/quickshell/dock ] && quickshell -d -n -p " .. home .. "/.config/quickshell/dock")
        hl.exec_cmd("[ -d " .. home .. "/.config/quickshell/bar ] && quickshell -d -n -p " .. home .. "/.config/quickshell/bar")

        -- 6. AGS Dynamic Widgets (si está presente)
        hl.exec_cmd("[ -d " .. home .. "/.config/ags ] && env PATH=" .. home .. "/.local/bin:$PATH ags run")

        -- 7. Teclado Virtual, Portapapeles y Plugins
        hl.exec_cmd(home .. "/.config/hypr/scripts/virtual_keyboard.sh daemon")
        hl.exec_cmd("systemctl --user start cliphist || bash " .. home .. "/.config/cliphist/cliphist-daemon.sh start")
        hl.exec_cmd("hyprpm reload -n")
    end)
end

return M
