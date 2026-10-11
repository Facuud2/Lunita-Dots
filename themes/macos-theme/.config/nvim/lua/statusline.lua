-- Neovim StatusLine Footer
-- Inspired by the pill-based aesthetic and dynamic Matugen palette

local M = {}

local mode_names = {
    ["n"]  = "NORMAL",
    ["no"] = "N-OP",
    ["v"]  = "VISUAL",
    ["V"]  = "V-LINE",
    ["\22"]= "V-BLOCK",
    ["s"]  = "SELECT",
    ["S"]  = "S-LINE",
    ["\19"]= "S-BLOCK",
    ["i"]  = "INSERT",
    ["ic"] = "INS-COMP",
    ["R"]  = "REPLACE",
    ["Rv"] = "V-REPLACE",
    ["c"]  = "COMMAND",
    ["cv"] = "VIM-EX",
    ["ce"] = "EX",
    ["r"]  = "PROMPT",
    ["rm"] = "MORE",
    ["r?"] = "CONFIRM",
    ["!"]  = "SHELL",
    ["t"]  = "TERMINAL",
}

local mode_hl = {
    ["NORMAL"]   = "StatusModeNormal",
    ["N-OP"]     = "StatusModeNormal",
    ["INSERT"]   = "StatusModeInsert",
    ["INS-COMP"] = "StatusModeInsert",
    ["VISUAL"]   = "StatusModeVisual",
    ["V-LINE"]   = "StatusModeVisual",
    ["V-BLOCK"]  = "StatusModeVisual",
    ["COMMAND"]  = "StatusModeCommand",
    ["REPLACE"]  = "StatusModeReplace",
    ["V-REPLACE"]= "StatusModeReplace",
    ["TERMINAL"] = "StatusModeCommand",
}

local file_icons = {
    ["lua"]  = "",
    ["py"]   = "",
    ["c"]    = "",
    ["cpp"]  = "",
    ["h"]    = "",
    ["rs"]   = "",
    ["go"]   = "",
    ["js"]   = "",
    ["ts"]   = "",
    ["jsx"]  = "",
    ["tsx"]  = "",
    ["html"] = "",
    ["css"]  = "",
    ["scss"] = "",
    ["json"] = "",
    ["yaml"] = "",
    ["yml"]  = "",
    ["toml"] = "",
    ["conf"] = "",
    ["rasi"] = "",
    ["sh"]   = "",
    ["zsh"]  = "",
    ["bash"] = "",
    ["md"]   = "",
    ["txt"]  = "",
}

local function get_file_icon(ext)
    return file_icons[ext] or ""
end

local function get_git_branch()
    -- Check buffer-local cache first
    local b = vim.b.statusline_git_branch
    if b ~= nil then
        return b
    end

    -- Query git in current file directory
    local branch = vim.fn.system("git rev-parse --abbrev-ref HEAD 2>/dev/null"):gsub("\n", "")
    if branch and #branch > 0 and not branch:match("fatal") then
        vim.b.statusline_git_branch = branch
        return branch
    end

    -- Fallback to current folder name
    local folder = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
    vim.b.statusline_git_branch = folder
    return folder
end

function M.render()
    -- 1. Mode Pill
    local m = vim.fn.mode()
    local mode_name = mode_names[m] or "NORMAL"
    local hl_group = mode_hl[mode_name] or "StatusModeNormal"
    local cap_group = hl_group .. "Cap"

    local mode_pill = string.format("%%#%s#%%#%s# %s %%#%s#%%*", cap_group, hl_group, mode_name, cap_group)

    -- 2. File Name & Icon
    local fname = vim.fn.expand("%:t")
    if #fname == 0 then
        fname = "[No Name]"
    end
    local ext = vim.fn.expand("%:e")
    local icon = get_file_icon(ext)

    local mod_flag = ""
    if vim.bo.modified then
        mod_flag = " %#[StatusFileModified]#[+]%*"
    elseif vim.bo.readonly then
        mod_flag = " %#[StatusFileModified]#[-]%*"
    end

    local file_segment = string.format(" %%#StatusFile#%s %s%%*%s", icon, fname, mod_flag)

    -- 3. Right Side: Directory or Git branch
    local branch_or_dir = get_git_branch()
    local dir_pill = string.format("%%#StatusDirCap#%%#StatusDir#  %s %%#StatusDirCap#%%*", branch_or_dir)

    -- 4. Right Side: Percentage / Position
    local pct_pill = "%#StatusPercentCap#%#StatusPercent# 󰈚 %p%% %#StatusPercentCap#%*"

    return string.format("%s%s %%= %s  %s ", mode_pill, file_segment, dir_pill, pct_pill)
end

function M.setup()
    vim.opt.statusline = "%!v:lua.require('statusline').render()"

    -- Invalidate cached git branch on buffer enter or write
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
        pattern = "*",
        callback = function()
            vim.b.statusline_git_branch = nil
        end,
    })
end

return M
