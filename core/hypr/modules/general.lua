local M = {}

function M.setup()
    -- Cargar paleta oficial macOS 27 / Cupertino
    local has_colors, colors = pcall(require, "modules.colors")
    if not has_colors or type(colors) ~= "table" then
        colors = {
            active_border_1          = "rgba(007affcc)",
            active_border_2          = "rgba(5856d6aa)",
            inactive_border          = "rgba(ffffff18)",
            shadow                   = "rgba(00000055)",
            shadow_inactive          = "rgba(00000030)",
            group_border_active      = "rgba(007affee)",
            group_border_inactive    = "rgba(ffffff18)",
            group_border_locked_active   = "rgba(ff9500ee)",
            group_border_locked_inactive = "rgba(ff950033)",
            groupbar_active          = "rgba(007affcc)",
            groupbar_inactive        = "rgba(2c2c2e88)",
            groupbar_locked_active   = "rgba(ff9500cc)",
            groupbar_locked_inactive = "rgba(3a3a3c88)",
            groupbar_text            = "rgba(ffffffff)",
        }
    end

    -- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
    hl.config({
        general = {
            gaps_in  = 6,
            gaps_out = 16,

            border_size = 2,

            col = {
                active_border   = { colors = { colors.active_border_1, colors.active_border_2 }, angle = 45 },
                inactive_border = colors.inactive_border,
            },

            -- Redimensionamiento interactivo en bordes y esquinas
            resize_on_border         = true,
            extend_border_grab_area  = 15,
            hover_icon_on_border     = true,

            -- Snapping magnético entre ventanas flotantes y contra los límites de pantalla
            snap = {
                enabled        = true,
                window_gap     = 10,
                monitor_gap    = 10,
                border_overlap = false,
            },

            -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
            allow_tearing = false,

            layout = "dwindle",
        },

        decoration = {
            rounding       = 16,
            rounding_power = 2,

            -- Transparencia global estilo macOS Frosted Acrylic:
            active_opacity   = 0.92,
            inactive_opacity = 0.80,

            -- Sombras Apple difusas y profundas
            shadow = {
                enabled        = true,
                range          = 35,
                render_power   = 4,
                color          = colors.shadow or "rgba(00000055)",
                color_inactive = colors.shadow_inactive or "rgba(00000030)",
                offset         = { 0, 10 },
                scale          = 0.98,
            },

            -- Efectos de atenuación (dimming)
            dim_inactive = true,
            dim_strength = 0.12,
            dim_special  = 0.30,
            dim_around   = 0.40,

            -- Blur calibrado para Liquid Glass / Frosted Acrylic:
            blur = {
                enabled           = true,
                size              = 6,
                passes            = 3,
                vibrancy          = 0.35,
                vibrancy_darkness = 0.5,
                noise             = 0.015,
                contrast          = 0.95,
                brightness        = 0.90,
                xray              = false,
                new_optimizations = true,
            },
        },

        -- Configuración de ventanas agrupadas / pestañas (Tabbed Windows)
        group = {
            auto_group           = true,
            insert_after_current = true,
            focus_removed_window = true,
            drag_into_group      = 1,
            merge_groups_on_drag = true,

            col = {
                border_active          = { colors = { colors.group_border_active, colors.active_border_2 }, angle = 45 },
                border_inactive        = colors.group_border_inactive,
                border_locked_active   = colors.group_border_locked_active,
                border_locked_inactive = colors.group_border_locked_inactive,
            },

            groupbar = {
                enabled           = true,
                font_family       = "Sans",
                font_size         = 9,
                gradients         = true,
                height            = 16,
                stacked           = false,
                priority          = 3,
                render_titles     = true,
                scrolling         = true,
                text_color        = colors.groupbar_text,
                col = {
                    active          = colors.groupbar_active,
                    inactive        = colors.groupbar_inactive,
                    locked_active   = colors.groupbar_locked_active,
                    locked_inactive = colors.groupbar_locked_inactive,
                },
                indicator_height  = 3,
                round_only_edges  = true,
                gradient_rounding = 2,
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
            force_default_wallpaper      = -1,    -- Set to 0 or 1 to disable the anime mascot wallpapers
            disable_hyprland_logo        = false, -- If true disables the random hyprland logo / anime girl background. :(
            animate_manual_resizes       = true,  -- Transición suave e interpolada al redimensionar manualmente
            animate_mouse_windowdragging = true,  -- Arrastre fluido y elástico que acompaña al cursor
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

    -- Configuración de plugin Hyprgrass (para pantalla táctil / iPad)
--    hl.config({
 --       plugin = {
 --           hyprgrass = {
 --               sensitivity = 4.0,
 --               long_press_delay = 400,
 --               resize_on_border_long_press = false,
 --               edge_margin = 10,
 --           },
 --       },
 --       gestures = {
 --           workspace_swipe_touch = true,
 --       },
 --   })

    -- Example per-device config
    -- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
    hl.device({
        name        = "epic-mouse-v1",
        sensitivity = -0.5,
    })
end

return M
