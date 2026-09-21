local M = {}

function M.setup()
    hl.config({
        animations = {
            enabled = true,
        },
    })

    -- ─────────────────────────────────────────────────────────────────────────────
    -- CURVAS Y RESORTES ESTILO macOS
    -- Basadas en las físicas de SwiftUI / Core Animation y gestos táctiles de Apple
    -- ─────────────────────────────────────────────────────────────────────────────

    -- macEaseOut: sale rápido y frena con gracia. Ventanas emergentes, tooltips, menús.
    hl.curve("macEaseOut",      { type = "bezier", points = { {0.16, 1}, {0.3, 1} } })

    -- macEaseInOut: aceleración y frenado simétricamente suaves. Cambios de workspace.
    hl.curve("macEaseInOut",    { type = "bezier", points = { {0.45, 0}, {0.15, 1} } })

    -- macSpring: aproximación bezier con leve rebote (overshoot)
    hl.curve("macSpring",       { type = "bezier", points = { {0.2, 1.1}, {0.4, 1} } })

    -- macSubtle: para transiciones discretas (bordes, opacidad). Sin overshoot.
    hl.curve("macSubtle",       { type = "bezier", points = { {0.25, 0.1}, {0.25, 1} } })

    -- linear: para efectos continuos (rotación de bordes)
    hl.curve("linear",          { type = "bezier", points = { {0, 0}, {1, 1} } })

    -- ── RESORTES FÍSICOS NATIVOS (Springs) ──────────────────────────────────
    -- macMoveSpring: Para mover, arrastrar y reordenar ventanas.
    --   Stiffness 210 y Dampening 23 da respuesta instantánea al ratón
    --   con un asentamiento elástico muy sutil y gomoso (sensación macOS).
    hl.curve("macMoveSpring",   { type = "spring", mass = 1, stiffness = 210, dampening = 23 })

    -- macWindowSpring: Para apertura de ventanas. Leve rebote de bienvenida.
    hl.curve("macWindowSpring", { type = "spring", mass = 1, stiffness = 195, dampening = 20 })


    -- ─────────────────────────────────────────────────────────────────────────────
    -- ANIMACIONES
    -- Inspiradas en las transiciones de macOS Sonoma / Sequoia
    -- ─────────────────────────────────────────────────────────────────────────────

    -- Global: base para todos los no especificados
    hl.animation({ leaf = "global",        enabled = true,  speed = 8,   bezier = "macSubtle" })

    -- Bordes: transición suave de color al enfocar/desenfocar
    hl.animation({ leaf = "border",        enabled = true,  speed = 5,   bezier = "macSubtle" })
    hl.animation({ leaf = "borderangle",   enabled = true,  speed = 8,   bezier = "linear" })

    -- ── Ventanas ─────────────────────────────────────────────────────────────────
    -- Open: aparece desde el 85% con rebote elástico orgánico (macWindowSpring)
    -- Close: sale con shrink elegante hacia el 90%
    -- Move/Resize/Drag: física de resorte fluido (sigue al ratón y se asienta suave)
    hl.animation({ leaf = "windows",       enabled = true,  speed = 4.8, spring = "macWindowSpring" })
    hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.2, spring = "macWindowSpring", style = "popin 85%" })
    hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 3,   bezier = "macEaseOut",      style = "popin 90%" })
    hl.animation({ leaf = "windowsMove",   enabled = true,  speed = 5,   spring = "macMoveSpring" })

    -- ── Fades (opacidad) ─────────────────────────────────────────────────────────
    -- fadeSwitch: entre ventanas al cambiar foco
    -- fadeIn/Out: aparición y desaparición suave
    hl.animation({ leaf = "fade",          enabled = true,  speed = 4,  bezier = "macEaseOut" })
    hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 4,  bezier = "macEaseOut" })
    hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 3,  bezier = "macEaseOut" })
    hl.animation({ leaf = "fadeSwitch",    enabled = true,  speed = 5,  bezier = "macSubtle" })
    hl.animation({ leaf = "fadeShadow",    enabled = true,  speed = 5,  bezier = "macSubtle" })
    hl.animation({ leaf = "fadeDim",       enabled = true,  speed = 5,  bezier = "macSubtle" })

    -- ── Capas (Waybar, Rofi, notificaciones, lockscreen) ─────────────────────────
    -- Aparecen con fade puro para que no compitan visualmente con las ventanas
    hl.animation({ leaf = "layers",        enabled = true,  speed = 4,  bezier = "macEaseOut" })
    hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,  bezier = "macEaseOut",   style = "fade" })
    hl.animation({ leaf = "layersOut",     enabled = true,  speed = 3,  bezier = "macEaseOut",   style = "fade" })
    hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 4,  bezier = "macEaseOut" })
    hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 3,  bezier = "macEaseOut" })

    -- ── Workspaces ───────────────────────────────────────────────────────────────
    -- Slide horizontal, idéntico al gesto de 3 dedos entre Spaces de macOS.
    -- La velocidad 6 con macEaseInOut da esa sensación de "física" que tiene macOS.
    hl.animation({ leaf = "workspaces",    enabled = true,  speed = 6,  bezier = "macEaseInOut", style = "slide" })
    hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 6,  bezier = "macEaseInOut", style = "slide" })
    hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 6,  bezier = "macEaseInOut", style = "slide" })
    hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5, spring = "macWindowSpring", style = "slidevert" })

    -- ── Zoom ─────────────────────────────────────────────────────────────────────
    hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 4,  bezier = "macEaseOut" })
end

return M
