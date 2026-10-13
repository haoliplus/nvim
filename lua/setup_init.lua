local M = {}
local timeout = 600000
local packages = {
  "tree-sitter-cli", "black", "prettier", "ast-grep", "bash-language-server",
  "clangd", "lua-language-server", "pyright", "ruff", "rust-analyzer",
  "typescript-language-server", "isort", "gofumpt", "stylua",
}
local languages = {
  "bash", "c", "cpp", "lua", "luadoc", "vim", "vimdoc", "query",
  "markdown", "markdown_inline", "python", "javascript", "jsdoc", "regex",
  "typescript", "tsx", "json", "yaml", "toml", "html", "css",
  "go", "rust", "dockerfile",
}

local function wait_for(label, predicate)
  assert(vim.wait(timeout, predicate, 100), label .. " timed out; inspect the output and retry SetupInit")
end

local function cli_ready()
  if vim.fn.executable("tree-sitter") ~= 1 then
    return false
  end
  local result = vim.system({ "tree-sitter", "--version" }, { text = true }):wait(5000)
  local version = vim.version.parse(result.stdout or "")
  return result.code == 0 and version and vim.version.ge(version, { 0, 26, 1 })
end

local stages = {}

local function package_ready(pkg)
  if not pkg:is_installed() or vim.fn.filereadable(pkg:get_receipt_path()) == 0 then
    return false
  end
  local bin = require("mason.settings").current.install_root_dir .. "/bin/"
  for name in pairs(pkg.spec.bin or {}) do
    if vim.fn.executable(bin .. name) ~= 1 then
      return false
    end
  end
  return true
end

function stages.check()
  assert(vim.fn.has("nvim-0.12") == 1, "Neovim 0.12+ is required")
  local missing = {}
  for _, cmd in ipairs({ "git", "curl", "tar", "gzip", "unzip", "make", "node", "npm", "python3", "go" }) do
    if vim.fn.executable(cmd) ~= 1 then
      missing[#missing + 1] = cmd
    end
  end
  if not vim.iter({ "cc", "gcc", "clang" }):any(function(cmd) return vim.fn.executable(cmd) == 1 end) then
    missing[#missing + 1] = "C compiler (cc/gcc/clang)"
  end
  assert(#missing == 0, "Install system dependencies first: " .. table.concat(missing, ", "))
  local python = vim.system({ "python3", "-c", "import pip, venv, ensurepip" }, { text = true }):wait(5000)
  assert(python.code == 0, "Install Python pip/venv support: " .. (python.stderr or ""))
  assert(vim.fn.filereadable(vim.env.VIM_CONFIG_DIR .. "/lazy-lock.json") == 1, "lazy-lock.json is required")
end

function stages.plugins()
  local lazy = require("lazy")
  -- Startup can install missing plugins and rewrite its temporary lockfile.
  -- Always restore against the repository's original, authoritative versions.
  local lock = require("lazy.manage.lock")
  lock.lock = vim.json.decode(table.concat(vim.fn.readfile(vim.g.config_path .. "/lazy-lock.json"), "\n"))
  lock._loaded = true
  lazy.restore({ wait = true, show = false })
  for name, plugin in pairs(require("lazy.core.config").plugins) do
    assert(plugin._.installed, "Plugin missing: " .. name)
    for _, task in ipairs(plugin._.tasks or {}) do
      assert(not task:has_errors(), "Plugin failed: " .. name .. "\n" .. task:output())
    end
  end
end

function stages.tools()
  local registry = require("mason-registry")
  local refreshed
  registry.refresh(function(ok) refreshed = ok end)
  wait_for("Mason registry", function() return refreshed ~= nil end)
  assert(refreshed, "Mason registry refresh failed; see :MasonLog")
  for _, name in ipairs(packages) do
    local pkg = registry.get_package(name)
    wait_for(name, function() return not pkg:is_installing() end)
    local ready = package_ready(pkg)
    if name == "tree-sitter-cli" then
      ready = ready and cli_ready()
    end
    if ready then
      print("Reuse " .. name)
    else
      print("Install " .. name)
      local completed, install_error
      -- Repair stale Mason links left by an interrupted installation as well.
      pkg:install({ force = true }, function(ok, err) completed, install_error = ok, err end)
      wait_for(name, function() return completed ~= nil end)
      assert(completed, name .. " installation failed: " .. tostring(install_error) .. "; see :MasonLog")
    end
  end
  assert(cli_ready(), "tree-sitter CLI must work and be at least 0.26.1; see :MasonLog")
end

function stages.parsers()
  assert(cli_ready(), "tree-sitter CLI is unavailable or older than 0.26.1")
  local ts = require("nvim-treesitter")
  local config = require("nvim-treesitter.config")
  local targets = config.norm_languages(languages)
  local incomplete = {}
  -- install() alone skips languages with only a parser or only queries present.
  for _, lang in ipairs(targets) do
    local parser = config.get_install_dir("parser") .. "/" .. lang .. ".so"
    local query = config.get_install_dir("queries") .. "/" .. lang .. "/highlights.scm"
    local info = require("nvim-treesitter.parsers")[lang].install_info
    if (info and vim.fn.filereadable(parser) == 0) or vim.fn.filereadable(query) == 0 then
      incomplete[#incomplete + 1] = lang
    end
  end
  if #incomplete > 0 then
    assert(ts.install(incomplete, { force = true }):wait(timeout), "Parser installation failed; see :messages")
  end
  assert(ts.update(targets):wait(timeout), "Parser update failed; see :messages")
end

function stages.verify()
  assert(cli_ready(), "tree-sitter CLI check failed")
  for _, name in ipairs(packages) do
    assert(package_ready(require("mason-registry").get_package(name)), "Mason package incomplete: " .. name)
  end
  for _, lang in ipairs(languages) do
    assert(vim.treesitter.language.add(lang), "Parser missing: " .. lang)
    assert(vim.treesitter.query.get(lang, "highlights"), "Highlight queries missing: " .. lang)
    for _, query in ipairs({ "injections", "locals", "folds", "indents" }) do
      vim.treesitter.query.get(lang, query)
    end
  end
  print("Parser and query checks passed for " .. #languages .. " languages")
end

function M.run(stage)
  local ok, err = xpcall(function() assert(stages[stage], "Unknown setup stage")() end, debug.traceback)
  if not ok then
    vim.api.nvim_err_writeln("SetupInit failed (" .. stage .. "):\n" .. err)
    vim.cmd("cquit 1")
  end
end

function M.start()
  if M.job and vim.fn.jobwait({ M.job }, 0)[1] == -1 then
    vim.notify("SetupInit is already running", vim.log.levels.WARN)
    return
  end
  local startup = package.loaded["treesitter_setup"]
  if startup and startup.pending then
    vim.notify("Waiting for the startup Tree-sitter installation before SetupInit")
    wait_for("Startup Tree-sitter installation", function() return not startup.pending end)
  end
  vim.cmd("botright 12new")
  M.job = vim.fn.jobstart({ "bash", vim.g.config_path .. "/tools/setup_init.sh" }, {
    term = true,
    env = { NVIM_BIN = vim.v.progpath },
    on_exit = function(_, code)
      vim.schedule(function()
        vim.notify(code == 0 and "SetupInit complete. Restart Neovim."
          or "SetupInit failed. See the terminal output; fix the error and rerun :SetupInit.",
          code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR)
      end)
    end,
  })
  assert(M.job > 0, "Could not start SetupInit; ensure bash is installed")
end

return M
