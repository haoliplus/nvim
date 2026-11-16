-- """"""""""""""""""""""""
-- "" Color
-- """""""""""""""""""""""
vim.cmd("syntax on")
vim.opt.cursorcolumn = true
vim.opt.cursorline = true
vim.opt.colorcolumn = { 80, 120 }

vim.opt.background = "dark"
vim.env.NVIM_TUI_ENABLE_TRUE_COLOR = vim.env.NVIM_TUI_ENABLE_TRUE_COLOR or "1"

-- Change comment in C++ to ///
-- vim.cmd([[autocmd FileType cpp setlocal commentstring=///\ %s]])
-- vim.cmd([[autocmd FileType cuda setlocal commentstring=///\ %s]])
-- Italics for my themes
vim.g.palenight_terminal_italics = 1
-- simily with 'highlight Comment cterm=italic gui=italic'
-- Override cursorline and cursorcolumn

-- vim.cmd([[
-- hi DiagnosticError guifg=White
-- ]])
--
vim.g.palenight_color_overrides = {
  -- cursor_grey = { gui = "#3E4452", cterm = "White", cterm16 = "White" },
  -- cursor_grey = { gui = "#3E4452", cterm = "White", cterm16 = "White" },
  -- dark_red = { gui = "#3E4452", cterm = "White", cterm16 = "White" },
  -- light_red = { gui = "#3E4452", cterm = "White", cterm16 = "White" },
  -- red = { gui = "#3E4452", cterm = "White", cterm16 = "White" },
  -- green = { gui = "#3E4452", cterm = "White", cterm16 = "White" },
  -- yellow = { gui = "#3E4452", cterm = "White", cterm16 = "White" },
  -- dark_yellow = { gui = "#3E4452", cterm = "White", cterm16 = "White" },
  -- blue = { gui = "#3E4452", cterm = "White", cterm16 = "White" },
  -- purple = { gui = "#3E4452", cterm = "White", cterm16 = "White" },
  -- blue_purple = { gui = "#3E4452", cterm = "White", cterm16 = "White" },
  -- cyan = { gui = "#3E4452", cterm = "White", cterm16 = "White" },
  -- white = { gui = "#3E4452", cterm = "White", cterm16 = "White" },
  -- -- black = { gui = "#3E4452", cterm = "White", cterm16 = "White" },
  -- visual_black = { gui = "#3E4452", cterm = "White", cterm16 = "White" },
  comment_grey = { gui = "#3E4452", cterm = "White", cterm16 = "White" },
  -- gutter_fg_grey = { gui = "#3E4452", cterm = "White", cterm16 = "White" },
  -- visual_grey = { gui = "#3E4452", cterm = "White", cterm16 = "White" },
  menu_grey = { gui = "#3E4452", cterm = "White", cterm16 = "White" },
  -- special_grey = { gui = "#3E4452", cterm = "White", cterm16 = "White" },
  -- vertsplit = { gui = "#3E4452", cterm = "White", cterm16 = "White" },
  -- white_mask_1 = { gui = "#3E4452", cterm = "White", cterm16 = "White" },
  -- white_mask_3 = { gui = "#3E4452", cterm = "White", cterm16 = "White" },
  -- white_mask_11 = { gui = "#3E4452", cterm = "White", cterm16 = "White" },
}
vim.cmd([[
hi DiagnosticError guifg=White
]])

-- I do not KNOWN
if vim.fn.exists("+termguicolors") == 1 then
  vim.cmd([[let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"]])
  vim.cmd([[let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"]])
  vim.opt.termguicolors = false
  vim.cmd([[
  set t_Co=256
  ]])
else
  vim.opt.termguicolors = true
  vim.g.palenight_color_overrides = {
    cursor_grey = { gui = "#3E4452", cterm = "White", cterm16 = "White" },
  }
end
-- vim.cmd([[set notermguicolors]])

local call_requires = function()
  vim.cmd("colorscheme tokyonight")
  -- vim.cmd("colorscheme palenight")
end
pcall(call_requires)

-- vim.cmd([[
-- hi DiagnosticError guifg=White
-- ]])
