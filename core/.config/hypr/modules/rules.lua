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
        name         = "wvkbd-blur",
        match        = { namespace = "^wvkbd$" },
        blur         = true,
        ignore_alpha = 0.05,
    })

    -- Layer blur rules
    hl.layer_rule({
        name  = "gtk4-layer-blur",
        match = { namespace = "^(gtk4-layer-shell)$" },
        blur  = true,
    })

    hl.layer_rule({
        name  = "macos-quickshell-blur",
        match = { namespace = "^(macos-notifications|macos-osd)$" },
        blur  = true,
        ignore_alpha = 0.01,
    })

    hl.layer_rule({
        name  = "win11-dock-blur",
        match = { namespace = "^(win11-dock.*)$" },
        blur  = true,
        ignore_alpha = 0.01,
    })

    hl.layer_rule({
        name  = "win11-edge-blur",
        match = { namespace = "^(win11-sound-edge|win11-brightness-edge)$" },
        blur  = true,
        ignore_alpha = 0.05,
    })

    hl.layer_rule({
        name  = "macos-spotlight-blur",
        match = { namespace = "^macos-spotlight$" },
        blur  = true,
        ignore_alpha = 0.05,
    })

    hl.layer_rule({
        name  = "launcher-blur",
        match = { namespace = "^(macos-launcher|win11-launcher|lunita-app-launcher)$" },
        blur  = true,
        ignore_alpha = 0.05,
        no_anim = true,
    })

    hl.layer_rule({
        name  = "macos-clipboard-blur",
        match = { namespace = "^(macos-clipboard|lunita-clipboard)$" },
        blur  = true,
        ignore_alpha = 0.05,
        no_anim = true,
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

    -- Dolphin File Manager Client Styling (Windows 11 Frosted Liquid Acrylic Glass)
    hl.window_rule({
        name             = "dolphin-styling",
        match            = { class = "^(org\\.kde\\.dolphin|dolphin)$" },
        opacity          = "0.78 override 0.70 override",
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

    -- Lunita GUI Tools (Theme Selector & Widgets Manager: Opaque & Elevated)
    hl.window_rule({
        name             = "lunita-gui-tools",
        match            = {
            class = "^(io\\.lunita\\.ThemeSelector|org\\.lunita\\.ThemeSelector|org\\.lunita\\.WidgetsManager|Theme Selector|Gestor de Widgets)$",
        },
        float            = true,
        center           = true,
        opacity          = "1.0 override 1.0 override",
        rounding         = 16,
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

    -- Widgets Manager GUI (Flotante y centrado)
    hl.window_rule({
        name      = "lunita-widgets-manager",
        match     = { class = "^(org\\.lunita\\.WidgetsManager)$" },
        float     = true,
        center    = true,
        size      = "960 700",
    })

    ------------------------------------
    ---- TOKRI (Canasta drag & drop) ----
    ------------------------------------
    -- Tokri corre bajo XWayland (fuerza xcb). Todas sus ventanas flotan.
    hl.window_rule({
        name      = "tokri-float",
        match     = { class = "^(Tokri)$" },
        float     = true,
    })

    -- Panel principal: estilo Dropover/Yoink de macOS. Visible en cualquier
    -- workspace (pin), sin borde, esquinas 16px y Liquid Glass (blur global).
    -- Tokri se posiciona solo junto al cursor al "sacudir" un arrastre.
    hl.window_rule({
        name        = "tokri-panel",
        match       = { class = "^(Tokri)$", title = "^(Tokri)$" },
        pin         = true,
        border_size = 0,
        rounding    = 16,
        opacity     = "0.90 override 0.84 override",
    })

    -- Regla de arranque (deshabilitada): `lunita-tokri start` la activa
    -- durante el primer mapeo para ocultar el destello inicial de la ventana
    -- y la vuelve a desactivar en cuanto Tokri se minimiza a la bandeja.
    _G.lunita_tokri_boot = hl.window_rule({
        name             = "tokri-boot-hidden",
        match            = { class = "^(Tokri)$" },
        opacity          = "0.0 override 0.0 override",
        no_anim          = true,
        no_initial_focus = true,
        no_shadow        = true,
    })
    _G.lunita_tokri_boot:set_enabled(false)
end

return M
