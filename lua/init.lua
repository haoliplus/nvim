-- init.lua
-- Copyright (C) 2022 lihao <haoliplus@gmail.com>
--
-- Distributed under terms of the MIT license.
--
-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions

---@diagnostic disable: undefined-doc-name
if vim.fn.has("nvim-0.12") == 0 then
  vim.notify("Neovim 0.12 or later is required.", vim.log.levels.ERROR, { title = "init" })
  return
end
vim.g.minut_enabled = false
vim.g.is_win = (vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1)
vim.g.is_linux = (vim.fn.has("unix") == 1 and vim.fn.has("macunix") == 0)
vim.g.is_mac = vim.fn.has("macunix") == 1
if vim.g.is_mac and vim.fn.isdirectory("/Library/Developer/CommandLineTools") == 1 then
  -- Keep the compiler, linker and SDK from the same macOS toolchain.
  vim.env.DEVELOPER_DIR = "/Library/Developer/CommandLineTools"
end
vim.g.logging_level = "info"
-- views can only be fully collapsed with the global statusline
vim.opt.laststatus = 3
-- 文件在外部被修改时，自动加载
vim.opt.autoread = true

vim.g.home_path = vim.env.HOME or vim.fn.expand("~")
vim.g.config_path = vim.env.VIM_CONFIG_DIR
if not vim.g.config_path or vim.fn.isdirectory(vim.g.config_path) == 0 then
  vim.g.config_path = vim.fn.stdpath("config")
end
vim.g.clipboard = {
  name = "myClipboard",
  cache_enabled = 1,
  copy = {
    ["+"] = { "tmux", "load-buffer", "-" },
    ["*"] = { "tmux", "load-buffer", "-" },
  },
  paste = {
    ["+"] = { "tmux", "save-buffer", "-" },
    ["*"] = { "tmux", "save-buffer", "-" },
  },
}
vim.opt.rtp:prepend(vim.g.config_path)

require("setup")
require("custom_filetype")
require("local_template").setup({
  temp_dir = vim.g.config_path .. "/templates",
  author = vim.fn.getenv("NICKNAME"),
  email = vim.fn.getenv("MAIL"),
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath .. "/lua/lazy/init.lua") then
  vim.notify("lazy.nvim loading failed.", vim.log.levels.ERROR, { title = "init" })
  return
end

require("lazy").setup("plugins", {
  git = {
    filter = false,
  },
  ui = {
    border = "rounded",
  },
  performance = {
    rpt = {
      paths = { vim.g.config_path },
    },
  },
})

local function call_requires()
  require("my_utils")
  require("themes")
  require("keymap")
  require("autocommands")
end

local status, ret = pcall(call_requires)

if not status then
  vim.notify("Failed to init:\n" .. ret, vim.log.levels.ERROR, { title = "init" })
  return
end

vim.api.nvim_create_user_command("CheckDeps", function()
  require("check_deps").check()
end, { desc = "Check common external dependencies" })

-------------------------------------
-- Set border for floating windows
local _border = "rounded"
vim.opt.winborder = _border

vim.diagnostic.config({
  float = { border = _border },
})

-----------------------------------------------------------------
