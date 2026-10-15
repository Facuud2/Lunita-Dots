-- Neovim Theme Engine with Dynamic Matugen Colors
local M = {}

local fallback_colors = {
    background             = "#1a1112",
    background_alt         = "#271d1e",
    surface                = "#322828",
    surface_container      = "#271d1e",
    surface_container_low  = "#22191a",
    surface_container_high = "#322828",
    foreground             = "#f0dede",
    foreground_alt         = "#d7c1c2",
    primary                = "#ffb2b7",
    on_primary             = "#561d24",
    primary_container      = "#723339",
    on_primary_container   = "#ffdadb",
    secondary              = "#e6bdbe",
    on_secondary           = "#44292b",
    secondary_container    = "#5c3f41",
    on_secondary_container = "#ffdadb",
    tertiary               = "#e7c08e",
    on_tertiary            = "#432c06",
    tertiary_container     = "#5c421a",
    on_tertiary_container  = "#ffddb3",
    error                  = "#ffb4ab",
    on_error               = "#690005",
    error_container        = "#93000a",
    outline                = "#9f8c8d",
    outline_variant        = "#524344",
}

function M.get_colors()
    package.loaded["colors"] = nil
    local ok, c = pcall(require, "colors")
    if ok and type(c) == "table" then
        return c
    end
    return fallback_colors
end

function M.setup()
    local c = M.get_colors()
    local hl = vim.api.nvim_set_hl

    -- Base / Window highlights (Transparent background to let Kitty & Hyprland blur shine)
    hl(0, "Normal",          { fg = c.foreground, bg = "NONE" })
    hl(0, "NormalNC",        { fg = c.foreground_alt, bg = "NONE" })
    hl(0, "NormalFloat",     { fg = c.foreground, bg = c.surface_container_low })
    hl(0, "FloatBorder",     { fg = c.primary, bg = "NONE" })
    hl(0, "FloatTitle",      { fg = c.primary, bold = true, bg = "NONE" })
    hl(0, "SignColumn",      { bg = "NONE" })
    hl(0, "LineNr",          { fg = c.outline, bg = "NONE" })
    hl(0, "CursorLineNr",    { fg = c.primary, bold = true, bg = "NONE" })
    hl(0, "VertSplit",       { fg = c.outline_variant, bg = "NONE" })
    hl(0, "WinSeparator",    { fg = c.outline_variant, bg = "NONE" })
    hl(0, "CursorLine",      { bg = c.surface_container_low })
    hl(0, "ColorColumn",     { bg = c.surface_container_low })
    hl(0, "Visual",          { bg = c.surface_container_high })
    hl(0, "Search",          { fg = c.on_primary, bg = c.primary })
    hl(0, "IncSearch",       { fg = c.on_tertiary, bg = c.tertiary })
    hl(0, "CurSearch",       { fg = c.on_primary, bg = c.primary })

    -- StatusLine
    hl(0, "StatusLine",      { fg = c.foreground, bg = "NONE" })
    hl(0, "StatusLineNC",    { fg = c.outline, bg = "NONE" })

    -- StatusLine Mode Pills (Left)
    -- Normal mode (Warm Beige / Tertiary)
    hl(0, "StatusModeNormal",      { fg = c.on_tertiary, bg = c.tertiary, bold = true })
    hl(0, "StatusModeNormalCap",   { fg = c.tertiary, bg = "NONE" })

    -- Insert mode (Primary)
    hl(0, "StatusModeInsert",      { fg = c.on_primary, bg = c.primary, bold = true })
    hl(0, "StatusModeInsertCap",   { fg = c.primary, bg = "NONE" })

    -- Visual mode (Secondary / Lavender)
    hl(0, "StatusModeVisual",      { fg = c.on_secondary, bg = c.secondary, bold = true })
    hl(0, "StatusModeVisualCap",   { fg = c.secondary, bg = "NONE" })

    -- Command mode (Tertiary container / Amber)
    hl(0, "StatusModeCommand",     { fg = c.on_tertiary_container, bg = c.tertiary_container, bold = true })
    hl(0, "StatusModeCommandCap",  { fg = c.tertiary_container, bg = "NONE" })

    -- Replace / Other
    hl(0, "StatusModeReplace",     { fg = c.on_error, bg = c.error, bold = true })
    hl(0, "StatusModeReplaceCap",  { fg = c.error, bg = "NONE" })

    -- File information
    hl(0, "StatusFile",            { fg = c.foreground, bg = "NONE", bold = true })
    hl(0, "StatusFileModified",    { fg = c.primary, bg = "NONE", bold = true })

    -- Directory / Git Branch Pill (Right 1)
    hl(0, "StatusDir",             { fg = c.on_primary_container, bg = c.primary_container, bold = true })
    hl(0, "StatusDirCap",          { fg = c.primary_container, bg = "NONE" })

    -- Percent / Position Pill (Right 2)
    hl(0, "StatusPercent",         { fg = c.on_tertiary, bg = c.tertiary, bold = true })
    hl(0, "StatusPercentCap",      { fg = c.tertiary, bg = "NONE" })

    -- Syntax Highlighting
    hl(0, "Comment",         { fg = c.outline, italic = true })
    hl(0, "Constant",        { fg = c.tertiary })
    hl(0, "String",          { fg = c.secondary })
    hl(0, "Character",       { fg = c.secondary })
    hl(0, "Number",          { fg = c.tertiary })
    hl(0, "Boolean",         { fg = c.tertiary, bold = true })
    hl(0, "Float",           { fg = c.tertiary })
    hl(0, "Identifier",      { fg = c.foreground })
    hl(0, "Function",        { fg = c.primary, bold = true })
    hl(0, "Statement",       { fg = c.primary })
    hl(0, "Conditional",     { fg = c.primary })
    hl(0, "Repeat",          { fg = c.primary })
    hl(0, "Label",           { fg = c.primary })
    hl(0, "Operator",        { fg = c.outline })
    hl(0, "Keyword",         { fg = c.primary, bold = true })
    hl(0, "Exception",       { fg = c.error })
    hl(0, "PreProc",         { fg = c.tertiary })
    hl(0, "Type",            { fg = c.secondary, bold = true })
    hl(0, "Special",         { fg = c.primary })
    hl(0, "Underlined",      { underline = true })
    hl(0, "Error",           { fg = c.error })
    hl(0, "Todo",            { fg = c.on_primary, bg = c.primary, bold = true })

    -- Popups / Completion menus
    hl(0, "Pmenu",           { fg = c.foreground, bg = c.surface_container })
    hl(0, "PmenuSel",        { fg = c.on_primary, bg = c.primary, bold = true })
    hl(0, "PmenuSbar",       { bg = c.surface_container_low })
    hl(0, "PmenuThumb",      { bg = c.primary })

    -- Diagnostics
    hl(0, "DiagnosticError", { fg = c.error })
    hl(0, "DiagnosticWarn",  { fg = c.tertiary })
    hl(0, "DiagnosticInfo",  { fg = c.secondary })
    hl(0, "DiagnosticHint",  { fg = c.outline })
end

return M
