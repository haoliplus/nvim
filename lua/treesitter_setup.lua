local M = { pending = false }
local languages = { "javascript", "jsdoc", "regex" }

local function fail(message)
  M.pending = false
  vim.notify("Tree-sitter: " .. message, vim.log.levels.WARN)
end

local function check_cli(callback)
  if vim.fn.executable("tree-sitter") ~= 1 then
    callback(false)
    return
  end
  local ok = pcall(vim.system, { "tree-sitter", "--version" }, { text = true, timeout = 5000 },
    vim.schedule_wrap(function(result)
      local version = vim.version.parse(result.stdout or "")
      callback(result.code == 0 and version ~= nil and vim.version.ge(version, { 0, 26, 1 }))
    end))
  if not ok then
    callback(false)
  end
end

local function install_parsers()
  require("nvim-treesitter").install(languages):await(function(err, success)
    vim.schedule(function()
      M.pending = false
      if err or success == false then
        fail("Parser installation failed. Check :messages; retry with :TSInstall javascript jsdoc regex.")
        return
      end
      -- Newly created runtime directories may not be in Neovim's lookup cache.
      vim.o.runtimepath = vim.o.runtimepath
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].filetype:match("^javascript") then
          local ok, start_err = pcall(vim.treesitter.start, bufnr)
          if not ok then
            fail(tostring(start_err))
          end
        end
      end
    end)
  end)
end

function M.setup()
  if M.pending then
    return
  end
  M.pending = true
  check_cli(function(available)
    if available then
      install_parsers()
      return
    end
    local registry = require("mason-registry")
    registry.refresh(vim.schedule_wrap(function(success)
      if not success then
        fail("Mason registry refresh failed. Check :MasonLog and retry after restarting Neovim.")
        return
      end
      local ok, pkg = pcall(registry.get_package, "tree-sitter-cli")
      if not ok then
        fail("tree-sitter-cli is missing from the registry. Run :MasonUpdate and restart Neovim.")
        return
      end
      local finished = vim.schedule_wrap(function(installed)
        if not installed then
          fail("CLI installation failed. Check :MasonLog; retry with :MasonInstall tree-sitter-cli.")
          return
        end
        check_cli(function(ready)
          if ready then
            install_parsers()
          else
            fail("CLI is still unavailable or older than 0.26.1. Check :checkhealth mason and Neovim's PATH.")
          end
        end)
      end)
      if pkg:is_installing() then
        pkg:once("install:success", function() finished(true) end)
        pkg:once("install:failed", function() finished(false) end)
      else
        -- Also repairs a broken or outdated Mason installation.
        pkg:install({}, finished)
      end
    end))
  end)
end

return M
