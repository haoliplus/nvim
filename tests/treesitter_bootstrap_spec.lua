-- Network/compiler integration test with an empty temporary parser directory:
-- nvim --headless -u NONE -i NONE -l tests/treesitter_bootstrap_spec.lua
local root = vim.fn.getcwd()
local plugin = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter"
assert(vim.fn.isdirectory(plugin) == 1, "install the locked nvim-treesitter plugin first")
local install_dir = vim.fn.tempname()
vim.opt.runtimepath = { root, vim.env.VIMRUNTIME, plugin }
require("nvim-treesitter").setup({ install_dir = install_dir })
vim.cmd("filetype on")
local specs = dofile(root .. "/lua/plugins/theme.lua")
for _, spec in ipairs(specs) do
  if spec[1] == "nvim-treesitter/nvim-treesitter" then
    spec.config()
  end
end
vim.cmd.edit(root .. "/tests/fixtures/javascript_highlight.js")
local bufnr = vim.api.nvim_get_current_buf()
assert(vim.wait(180000, function()
  return vim.treesitter.highlighter.active[bufnr] ~= nil
end, 100), "fresh installation should enable highlighting in the already open buffer")
dofile(root .. "/tests/treesitter_spec.lua")
vim.fn.delete(install_dir, "rf")
print("treesitter bootstrap spec passed")
