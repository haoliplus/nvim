-- nvim --headless -u NONE -i NONE -l tests/treesitter_bootstrap_spec.lua
-- Uses empty Mason/parser directories; requires network and a C compiler.
local root = vim.fn.getcwd()
local plugins = vim.fn.stdpath("data") .. "/lazy/"
local temporary = vim.fn.tempname()
vim.opt.runtimepath = { root, vim.env.VIMRUNTIME, plugins .. "nvim-treesitter", plugins .. "mason.nvim" }
require("mason").setup({ install_root_dir = temporary .. "/mason" })
require("nvim-treesitter").setup({ install_dir = temporary .. "/site" })
vim.cmd("filetype on")
local specs = dofile(root .. "/lua/plugins/theme.lua")
for _, spec in ipairs(specs) do
  if spec[1] == "nvim-treesitter/nvim-treesitter" then
    spec.config()
  end
end
vim.cmd.edit(root .. "/tests/fixtures/javascript_highlight.js")
local bufnr = vim.api.nvim_get_current_buf()
assert(vim.wait(240000, function()
  return not require("treesitter_setup").pending
end, 100), "bootstrap should finish")
assert(vim.fn.executable("tree-sitter") == 1, "CLI should be available")
assert(vim.treesitter.highlighter.active[bufnr], "bootstrap should enable highlighting in the open buffer")
dofile(root .. "/tests/treesitter_spec.lua")
print("CLI used: " .. vim.fn.exepath("tree-sitter"))
vim.fn.delete(temporary, "rf")
print("treesitter bootstrap spec passed")
