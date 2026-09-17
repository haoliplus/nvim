---@diagnostic disable: undefined-doc-name
return {
  {
    "folke/noice.nvim",
    enabled = true,
    opts = {
      routes = {
        {
          filter = {
            event = "msg_show",
            kind = "",
            find = "written",
          },
          opts = { skip = true },
        },
        { -- 消息内容包含 "textDocument" 的通知, 跳过不显示:
          filter = {
            event = "notify",
            find = "textDocument",
          },
          opts = { skip = true },
        },
        { -- 消息内容包含 "textDocument" 的通知, 跳过不显示:
          filter = {
            event = "notify",
            find = "Copilot",
          },
          opts = { skip = true },
        },
      }, -- routes
      -- add any options here
      lsp = {
        progress = {
          enabled = true,
          -- Lsp Progress is formatted using the builtins for lsp_progress. See config.format.builtin
          -- See the section on formatting for more details on how to customize.
          --- @type NoiceFormat|string
          format = "lsp_progress",
          --- @type NoiceFormat|string
          format_done = "lsp_progress_done",
          throttle = 1000 / 30, -- frequency to update lsp progress message
          view = "mini",
        },
        override = {
          -- Neovim 0.12 + treesitter markdown rendering can throw conceal_line errors in LSP hovers.
          -- Keep Noice for UI, but let Neovim handle markdown formatting for hover/signature docs.
          ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
          ["vim.lsp.util.stylize_markdown"] = false,
          ["cmp.entry.get_documentation"] = true,
        },
      }, -- lsp
      presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true, -- add a border to hover docs and signature help
      }, -- presets
      notify = {
        -- Noice can be used as `vim.notify` so you can route any notification like other messages
        -- Notification messages have their level and other properties set.
        -- event is always "notify" and kind can be any log level as a string
        -- The default routes will forward notifications to nvim-notify
        -- Benefit of using Noice for this is the routing and consistent history view
        enabled = true,
        view = "notify",
      },
      cmdline = {
        view = "cmdline_popup",
        enabled = true,
        format = {
          -- title: set to anything or empty string to hide
          title = { "cmdline" },
          cmdline = { pattern = "^:", icon = "", lang = "vim" },
          search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
          search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
          filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
          lua = {
            pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" },
            icon = "",
            lang = "lua",
          },
          help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
          input = { view = "cmdline_input", icon = "󰥻 " }, -- Used by input()
        },
      }, -- cmdline
      messages = {
        -- NOTE: If you enable messages, then the cmdline is enabled automatically.
        -- This is a current Neovim limitation.
        enabled = true, -- enables the Noice messages UI
        view = "notify", -- default view for messages
        view_error = "notify", -- view for errors
        view_warn = "notify", -- view for warnings
        view_history = "messages", -- view for :messages
        view_search = "virtualtext", -- view for search count messages. Set to `false` to disable
        format = {
          title = { "messages" },
        },
      }, -- messages
      popupmenu = {
        enabled = true, -- enables the Noice popupmenu UI
        ---@type 'nui'|'cmp'
        backend = "nui", -- backend to use to show regular cmdline completions
        ---@type NoicePopupmenuItemKind|false
        -- Icons for completion item kinds (see defaults at noice.config.icons.kinds)
        kind_icons = {}, -- set to `false` to disable icons
        format = {
          title = { "popupmenu" },
        },
      },
      -- default options for require('noice').redirect
      -- see the section on Command Redirection
      -- redirect = {
      --   view = "popup",
      --   filter = { event = "msg_show" },
      -- },
    }, --- opts
    keys = {
      { "<Esc>", "<cmd>Noice dismiss<cr>", mode = "n", silent = true, desc = "Dismiss messages" },
    },
  }, --- noice
}
