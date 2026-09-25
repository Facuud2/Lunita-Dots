-- macOS 27 / Cupertino Color Palette for Hyprland
local colors = {
    -- Base Palette (Apple System Colors)
    primary                = "rgba(007affee)",      -- System Blue
    on_primary             = "rgba(ffffffff)",
    primary_container      = "rgba(007aff33)",
    on_primary_container   = "rgba(007affff)",

    secondary              = "rgba(5856d6ee)",      -- System Indigo
    secondary_container    = "rgba(5856d633)",
    on_secondary_container = "rgba(ffffffff)",

    tertiary               = "rgba(af52deee)",      -- System Purple
    tertiary_container     = "rgba(af52de33)",
    on_tertiary_container  = "rgba(ffffffff)",

    error                  = "rgba(ff3b30ee)",      -- System Red
    error_container        = "rgba(ff3b3033)",

    surface                = "rgba(161618ee)",
    surface_container      = "rgba(222224ee)",
    surface_container_high = "rgba(2c2c2eee)",
    surface_container_low  = "rgba(1c1c1eee)",
    on_surface             = "rgba(f5f5f7ff)",
    on_surface_variant     = "rgba(8e8e93ff)",

    outline                = "rgba(8e8e9388)",
    outline_variant        = "rgba(ffffff1f)",

    -- Shadow colors (Apple signature diffuse ambient shadow)
    shadow                 = "rgba(00000055)",
    shadow_inactive        = "rgba(00000030)",

    -- Liquid Glass / macOS Gradient borders
    active_border_1        = "rgba(007affcc)",
    active_border_2        = "rgba(5856d6aa)",
    inactive_border        = "rgba(ffffff18)",

    -- Tabbed windows / Groups
    group_border_active          = "rgba(007affee)",
    group_border_inactive        = "rgba(ffffff18)",
    group_border_locked_active   = "rgba(ff9500ee)",
    group_border_locked_inactive = "rgba(ff950033)",

    groupbar_active          = "rgba(007affcc)",
    groupbar_inactive        = "rgba(2c2c2e88)",
    groupbar_locked_active   = "rgba(ff9500cc)",
    groupbar_locked_inactive = "rgba(3a3a3c88)",
    groupbar_text            = "rgba(ffffffff)",
}

return colors
