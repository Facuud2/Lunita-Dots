local M = {}

function M.setup()
    -- Environment Variables
    -- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
    hl.env("PATH", os.getenv("HOME") .. "/.local/bin:" .. (os.getenv("PATH") or "/usr/local/bin:/usr/bin"))
    hl.env("XCURSOR_SIZE", "24")
    hl.env("HYPRCURSOR_SIZE", "24")

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
