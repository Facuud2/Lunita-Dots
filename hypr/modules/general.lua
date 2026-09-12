local M = {}

function M.setup()
    -- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
    hl.config({
        general = {
            gaps_in  = 5,
            gaps_out = 20,

            border_size = 2,

            col = {
                active_border   = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
                inactive_border = "rgba(ffffff18)",
            },

            -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
            resize_on_border = false,

            -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
            allow_tearing = false,

            layout = "dwindle",
        },

        decoration = {
            rounding       = 12,
            rounding_power = 2,

            -- Transparencia global:
            --   · Ventana activa al 88% para permitir ver widgets oscuros al fondo manteniendo legibilidad
            --   · Ventanas inactivas al 75% para jerarquía y profundidad
            active_opacity   = 0.88,
            inactive_opacity = 0.75,

            -- Sombras profundas tipo macOS (suaves y difusas)
            shadow = {
                enabled        = true,
                range          = 30,
                render_power   = 4,
                color          = "rgba(00000055)",
                color_inactive = "rgba(00000033)",
                offset         = { 0, 8 },
                scale          = 0.97,
            },

            -- Blur calibrado:
            --   · passes=2 y size=4 para mantener estética frosted glass
            --     sin difuminar por completo el widget de eww o cava en el fondo
            blur = {
                enabled           = true,
                size              = 4,
                passes            = 2,
                vibrancy          = 0.25,
                vibrancy_darkness = 0.5,
                noise             = 0.02,
                contrast          = 0.9,
                brightness        = 0.85,
                xray              = false,
                new_optimizations = true,
            },
        },
    })

    -- Layouts
    -- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
    hl.config({
        dwindle = {
            preserve_split = true, -- You probably want this
        },
    })

    -- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
    hl.config({
        master = {
            new_status = "master",
        },
    })

    -- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
    hl.config({
        scrolling = {
            fullscreen_on_one_column = true,
        },
    })

    -- Misc
    hl.config({
        misc = {
            force_default_wallpaper = -1,    -- Set to 0 or 1 to disable the anime mascot wallpapers
            disable_hyprland_logo   = false, -- If true disables the random hyprland logo / anime girl background. :(
        },
    })

    -- Input
    hl.config({
        input = {
            kb_layout  = "us",
            kb_variant = "",
            kb_model   = "",
            kb_options = "",
            kb_rules   = "",

            follow_mouse = 1,

            sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

            touchpad = {
                natural_scroll = false,
            },
        },
    })

    hl.gesture({
        fingers = 3,
        direction = "horizontal",
        action = "workspace",
    })

    -- Example per-device config
    -- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
    hl.device({
        name        = "epic-mouse-v1",
        sensitivity = -0.5,
    })
end

return M
