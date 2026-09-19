-- Neovim Options
-- Configured for seamless Kitty + Hyprland + Matugen workflow

local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = false

-- Colors & UI
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = false
opt.fillchars = {
    eob = " ",        -- Hide tildes (~) at the end of buffer
    stl = " ",
    stlnc = " ",
    vert = "│",
}

-- Statusline and footer layout
opt.laststatus = 3    -- Global statusline across all windows
opt.cmdheight = 1     -- Clean message area under the statusline
opt.showmode = false  -- Statusline already displays the active mode
opt.ruler = false     -- Statusline already displays file position

-- Tabs & Indentation
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true

-- Behavior & UX
opt.wrap = false
opt.splitbelow = true
opt.splitright = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.updatetime = 250
opt.timeoutlen = 300
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.ignorecase = true
opt.smartcase = true
