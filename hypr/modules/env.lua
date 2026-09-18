local M = {}

function M.setup(programs)
    programs = programs or {}
    -- Environment Variables
    -- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
    hl.env("PATH", os.getenv("HOME") .. "/.local/bin:" .. (os.getenv("PATH") or "/usr/local/bin:/usr/bin"))
    hl.env("XCURSOR_SIZE", "24")
    hl.env("HYPRCURSOR_SIZE", "24")

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
