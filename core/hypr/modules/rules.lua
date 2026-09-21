local M = {}

function M.setup()
    -- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
    -- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

    -- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
    -- "Smart gaps" / "No gaps when only"
    -- uncomment all if you wish to use that.
    -- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
    -- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
    -- hl.window_rule({
    --     name  = "no-gaps-wtv1",
    --     match = { float = false, workspace = "w[tv1]" },
    --     border_size = 0,
    --     rounding    = 0,
    -- })
    -- hl.window_rule({
    --     name  = "no-gaps-f1",
    --     match = { float = false, workspace = "f[1]" },
    --     border_size = 0,
    --     rounding    = 0,
    -- })

    -- Example window rules that are useful
    local suppressMaximizeRule = hl.window_rule({
        -- Ignore maximize requests from all apps. You'll probably like this.
        name  = "suppress-maximize-events",
        match = { class = ".*" },

        suppress_event = "maximize",
    })
    -- suppressMaximizeRule:set_enabled(false)

    hl.window_rule({
        -- Fix some dragging issues with XWayland
        name  = "fix-xwayland-drags",
        match = {
            class      = "^$",
            title      = "^$",
            xwayland   = true,
            float      = true,
            fullscreen = false,
            pin        = false,
        },

        no_focus = true,
    })

    -- Teclado virtual wvkbd
    hl.layer_rule({
        name  = "wvkbd-blur",
        match = { namespace = "^wvkbd$" },
        blur  = true,
    })

    -- Hyprland-run windowrule
    hl.window_rule({
        name  = "move-hyprland-run",
        match = { class = "hyprland-run" },

        move  = "20 monitor_h-120",
        float = true,
    })

    -- Prelock animation overlay
    hl.window_rule({
        name             = "prelock-overlay",
        match            = { class = "^(Smooth_Prelock)$" },
        float            = true,
        pin              = true,
        move             = "0 0",
        size             = "monitor_w monitor_h",
        border_size      = 0,
        rounding         = 0,
        no_initial_focus = true,
        no_focus         = true,
        no_follow_mouse  = true,
        suppress_event   = "activatefocus maximize fullscreen",
    })

    -- Vesktop (Discord) Client Styling
    hl.window_rule({
        name             = "vesktop-styling",
        match            = { class = "^(vesktop)$" },
        opacity          = "1.0 override 0.98 override",
    })

    -- VS Code Client Styling (Lunita Rice)
    hl.window_rule({
        name             = "vscode-styling",
        match            = { class = "^(Code|code-url-handler)$" },
        opacity          = "0.94 0.84",
    })

    -- Dolphin File Manager Client Styling (Lunita Frosted Glass)
    hl.window_rule({
        name             = "dolphin-styling",
        match            = { class = "^(org\\.kde\\.dolphin|dolphin)$" },
        opacity          = "0.90 0.82",
    })

    -- Dolphin & KDE Dialogs (Floating rules)
    hl.window_rule({
        name             = "dolphin-dialogs-floating",
        match            = {
            class = "^(org\\.kde\\.dolphin|dolphin|kdialog|org\\.kde\\.kdialog)$",
            title = "^(Progress Dialog.*|Copying.*|Moving.*|Properties for.*|File Already Exists.*|Confirm.*|Overwrite.*|Delete.*)$",
        },
        float            = true,
    })

    -- File Chooser / Open Workspace Dialogs (GTK / XDG Desktop Portal)
    hl.window_rule({
        name             = "file-chooser-dialogs",
        match            = {
            class = "^(xdg-desktop-portal-gtk|xdg-desktop-portal)$",
        },
        float            = true,
        size             = "950 620",
        center           = true,
        opacity          = "0.94 0.88",
    })



    ------------------------------------
    ---- REGLAS DE WORKSPACES / APPS ----
    ------------------------------------

    -- Workspace 1: Navegador Web
    hl.window_rule({
        name      = "browser-workspace",
        match     = { class = "^(zen.*|firefox.*|google-chrome.*|chromium.*|brave-browser.*|Brave-browser.*)$" },
        workspace = 1,
    })

    -- Workspace 2: Antigravity IDE
    hl.window_rule({
        name      = "antigravity-workspace",
        match     = { class = "^(antigravity)$" },
        workspace = 2,
    })

    -- Workspace 4: Juegos (Minecraft, Prism Launcher, Steam, etc.)
    hl.window_rule({
        name      = "games-workspace",
        match     = {
            class = "^([Mm]inecraft.*|net-minecraft-client-.*|PrismLauncher|org\\.prismlauncher\\.PrismLauncher|minecraft-launcher|steam_app_.*|lutris|heroic|RetroArch)$",
        },
        workspace = 4,
    })
    hl.window_rule({
        name      = "games-title-workspace",
        match     = { title = "^([Mm]inecraft.*)$" },
        workspace = 4,
    })

    -- Workspace 5: Weylus, Network Manager y Bluetooth
    hl.window_rule({
        name      = "weylus-workspace",
        match     = { class = "^(weylus)$" },
        workspace = 5,
    })

    hl.window_rule({
        name      = "network-manager-workspace",
        match     = { class = "^(nm-connection-editor|nm-applet)$" },
        workspace = 5,
        float     = true,
    })

    hl.window_rule({
        name      = "bluetooth-workspace",
        match     = { class = "^(blueman-manager|blueman-adapters|blueman-assistant|blueberry.*)$" },
        workspace = 5,
        float     = true,
    })

    -- Theme Selector GUI (Flotante y centrado)
    hl.window_rule({
        name      = "lunita-theme-selector",
        match     = { class = "^(io\\.lunita\\.ThemeSelector)$" },
        float     = true,
        center    = true,
        size      = "960 660",
    })
end

return M
