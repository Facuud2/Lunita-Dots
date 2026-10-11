local M = {}

function M.setup()
    -- See https://wiki.hypr.land/Configuring/Basics/Autostart/
    local home = os.getenv("HOME")

    -- Autoinicio de componentes críticos del sistema al inicializar Hyprland

    -- 1. Sincronizar el entorno de Wayland con D-Bus y systemd
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP PATH")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP PATH")

    -- 2. Iniciar el agente de Polkit
    hl.exec_cmd("sh -c 'systemctl --user start hyprpolkitagent || /usr/lib/hyprpolkitagent/hyprpolkitagent &'")

    -- 3. Cursor y tema de sistema (dinámico según el tema activo)
    hl.exec_cmd("sh -c 'CT=$(grep -s \"^gtk-cursor-theme-name=\" ~/.config/gtk-3.0/settings.ini | cut -d= -f2 | tr -d \" \"); CS=$(grep -s \"^gtk-cursor-theme-size=\" ~/.config/gtk-3.0/settings.ini | cut -d= -f2 | tr -d \" \"); CT=${CT:-Bibata-Modern-Ice}; CS=${CS:-40}; hyprctl setcursor \"$CT\" \"$CS\"; gsettings set org.gnome.desktop.interface cursor-theme \"$CT\"; gsettings set org.gnome.desktop.interface cursor-size \"$CS\"'")

    -- 4. Demonio de fondo de pantalla (awww)
    hl.exec_cmd("sh -c 'pgrep -x awww-daemon >/dev/null || awww-daemon &'")

    -- 5. Quickshell (Barra Superior, Dock, Notificaciones, OSD, Spotlight, Launcher)
    hl.exec_cmd("sh -c 'sleep 0.5; export PATH=\"" .. home .. "/.local/bin:$PATH\"; lunita-quickshell start'")


    -- 7. Teclado Virtual, Portapapeles y Plugins
    hl.exec_cmd(home .. "/.config/hypr/scripts/virtual_keyboard.sh daemon")
    hl.exec_cmd("sh -c 'systemctl --user start cliphist || bash \"" .. home .. "/.config/cliphist/cliphist-daemon.sh\" start'")
    hl.exec_cmd("hyprpm reload -n")

    -- 8. Tokri (Canasta flotante drag & drop estilo macOS)
    hl.exec_cmd("sh -c 'sleep 1 && command -v lunita-tokri >/dev/null 2>&1 && lunita-tokri start || true'")
end

return M
