local M = {}

function M.setup(programs)
    programs = programs or {}
    -- Environment Variables
    -- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
    hl.env("PATH", os.getenv("HOME") .. "/.local/bin:" .. (os.getenv("PATH") or "/usr/local/bin:/usr/bin"))
    
    -- Cursor configuration
    local cursor_theme = "Bibata-Modern-Ice"
    local cursor_size = "40"
    local gtk_file = io.open(os.getenv("HOME") .. "/.config/gtk-3.0/settings.ini", "r")
    if gtk_file then
        for line in gtk_file:lines() do
            local ct = line:match("^gtk%-cursor%-theme%-name=(.+)$")
            local cs = line:match("^gtk%-cursor%-theme%-size=(.+)$")
            if ct then cursor_theme = ct:gsub("%s+", "") end
            if cs then cursor_size = cs:gsub("%s+", "") end
        end
        gtk_file:close()
    end

    hl.env("XCURSOR_THEME", cursor_theme)
    hl.env("XCURSOR_SIZE", cursor_size)
    hl.env("HYPRCURSOR_THEME", cursor_theme)
    hl.env("HYPRCURSOR_SIZE", cursor_size)

    -- Qt Styling & Wayland Integration (Lunita Rice)
    hl.env("QT_QPA_PLATFORM", "wayland;xcb")
    hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
    hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
    hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
    hl.env("QT_PLUGIN_PATH", os.getenv("HOME") .. "/.local/lib/qt6/plugins:/usr/lib/qt6/plugins")
    hl.env("LD_LIBRARY_PATH", os.getenv("HOME") .. "/.local/lib:" .. (os.getenv("LD_LIBRARY_PATH") or ""))




    -- Export user programs as environment variables
    if programs.terminal then
        hl.env("terminal", programs.terminal)
        hl.env("TERMINAL", programs.terminal)
    end
    if programs.fileManager then
        hl.env("fileManager", programs.fileManager)
        hl.env("FILEMANAGER", programs.fileManager)
    end
    if programs.browser then
        hl.env("browser", programs.browser)
        hl.env("BROWSER", programs.browser)
    end
    if programs.ide then
        hl.env("ide", programs.ide)
        hl.env("IDE", programs.ide)
        hl.env("editor", programs.ide)
        hl.env("EDITOR", programs.ide)
    end
    if programs.music then
        hl.env("music", programs.music)
        hl.env("MUSIC", programs.music)
    end
    if programs.menu then
        hl.env("menu", programs.menu)
        hl.env("MENU", programs.menu)
    end

    -- Permissions
    -- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
    -- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
    -- for security reasons
    -- hl.config({
    --   ecosystem = {
    --     enforce_permissions = true,
    --   },
    -- })
    -- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
    -- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
    -- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")
    hl.permission("/usr/bin/ags", "plugin", "allow")
end

return M
