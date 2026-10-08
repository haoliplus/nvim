#! /usr/bin/env lua
-- 检查文件是否存在并读取内容的函数
local function read_os_release()
  local file = io.open("/etc/os-release", "r")
  if not file then
    return nil
  end
  local content = file:read("*all")
  file:close()
  return content
end

-- 检查是否为 Ubuntu 16.04
local function is_ubuntu_1604()
  local content = read_os_release()
  if not content then
    return false
  end
  -- 检查是否包含 Ubuntu 16.04 的特征
  return string.match(content, "Ubuntu") and string.match(content, "16.04")
end

local function get_build_cmd()
  -- 根据系统版本设置变量
  if is_ubuntu_1604() then
    return "cargo build --release"
  else
    return nil
  end
end

return {
  "saghen/blink.cmp",
  ---
  --- curl https://sh.rustup.rs -sSf | sh
  -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
  -- build = 'cargo build --release',
  -- If you use nix, you can build from source using latest nightly rust with:
  -- build = 'nix run .#build-plugin',

  build = get_build_cmd(),
  -- optional: provides snippets for the snippet source
  dependencies = {
    "haoliplus/friendly-snippets",
    "fang2hou/blink-copilot",
    "L3MON4D3/LuaSnip",
    "milanglacier/minuet-ai.nvim",
  },
  submodules = false,
  enabled = function()
    return not vim.tbl_contains({ "lua", "markdown" }, vim.bo.filetype)
      and vim.bo.buftype ~= "prompt"
      and vim.b.completion ~= false
  end,

  -- use a release tag to download pre-built binaries
  version = "*",
  ---@module 'blink.cmp'
  ---@diagnostic disable-next-line: undefined-doc-name
  ---@type blink.cmp.Config
  opts = {
    fuzzy = {
      -- 下载失败时静默回退到 Lua 实现
      implementation = "prefer_rust",
    },
    -- 'default' for mappings similar to built-in completion
    -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
    -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
    -- See the full "keymap" documentation for information on defining your own keymap.
    keymap = {
      preset = "default",
      -- 取消默认的 <Tab> 占用
      ["<Tab>"] = {},
      ["<C-]>"] = { "accept" },
      ["<C-y>"] = { "select_and_accept" },
      ["<C-e>"] = { "hide" },
      ["<C-w>"] = { "show" },
      ["<Up>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      -- ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
      ["<C-p>"] = { "select_prev", "fallback" },
      ["<C-n>"] = { "select_next", "fallback_to_mappings" },
      ["<C-a>"] = {
        function(cmp)
          cmp.show({
            --- Only show copilot suggestion
            providers = { "copilot" },
          })
        end,
      },
      ["<C-s>"] = {
        function(cmp)
          cmp.show({
            --- Only show snippets suggestion
            providers = { "snippets" },
          })
        end,
      },
      ["<A-y>"] = {
        function(cmp)
          cmp.show({ providers = { "minuet" } })
        end,
      },
    },
    signature = {
      -- Enable signature help
      enabled = true,
      window = { border = "single" },
    },
    completion = {
      menu = {
        border = "single",
        draw = {
          columns = {
            { "label", "label_description", gap = 1 },
            { "kind_icon", "kind" },
          },
        },
      },
      documentation = {
        window = { border = "single" },
        auto_show = true,
        auto_show_delay_ms = 500,
      },
      list = {
        selection = {
          preselect = true,
          auto_insert = true,
        },
      },
    },
    cmdline = {
      keymap = {
        -- recommended, as the default keymap will only show and select the next item
        ["<Tab>"] = { "show", "accept" },
      },
      completion = { menu = { auto_show = true } },
    },

    appearance = {
      -- Sets the fallback highlight groups to nvim-cmp's highlight groups
      -- Useful for when your theme doesn't support blink.cmp
      -- Will be removed in a future release
      use_nvim_cmp_as_default = true,
      -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = "mono",
      kind_icons = {
        Copilot = "",
      },
    },
    snippets = {
      preset = "luasnip",
    },
    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      default = {
        "copilot",
        "path",
        "lsp",
        "snippets",
        "buffer",
        "lazydev",
        "minuet",
      },
      providers = {
        copilot = {
          name = "copilot",
          module = "blink-copilot",
          score_offset = 100,
          async = true,
        },
        lazydev = {
          name = "LazyDev",
          module = "lazydev.integrations.blink",
          -- make lazydev completions top priority (see `:h blink.cmp`)
          score_offset = 100,
        },
        minuet = {
          name = "minuet",
          module = "minuet.blink",
          async = true,
          -- Should match minuet.config.request_timeout * 1000.
          timeout_ms = 3000,
          score_offset = 50,
        },
      },
    },
  },
  opts_extend = { "sources.default" },
}
