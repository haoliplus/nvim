return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    keys = {
      -- { "\\", "<cmd>Neotree reveal<cr>", mode = "n", noremap = true, silent = true, desc = "exit" },
      -- {
      --   "<F5>",
      --   function()
      --     require("neo-tree.command").execute({ toggle = true, position = "left", dir = vim.uv.cwd() })
      --   end,
      --   desc = "Explorer NeoTree (cwd)",
      -- },
      { "<leader>ef", ":Neotree toggle left<CR>", desc = "Explorer NeoTree (root dir)", remap = true },
      { "<leader>eb", ":Neotree buffers<CR>", desc = "Explorer Buffers (root dir)", remap = true },
      { "<leader>eg", ":Neotree git_status<CR>", desc = "Explorer NeoTree (cwd)", remap = true },
      { "<leader>ed", ":Neotree document_symbols<CR>", desc = "Explorer NeoTree (cwd)", remap = true },
    },
    enabled = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- 'mengelbrecht/lightline-bufferline',
      "akinsho/bufferline.nvim",
      -- "3rd/image.nvim",
      "folke/edgy.nvim"
    },
    deactivate = function()
      vim.cmd([[Neotree close]])
    end,
    init = function()
      vim.api.nvim_create_autocmd("QuitPre", {
        group = vim.api.nvim_create_augroup("NeoTreeEmptyDirectoryQuit", { clear = true }),
        desc = "Quit a directory tree and its untouched empty editing window together",
        callback = function()
          if #vim.api.nvim_list_tabpages() ~= 1 then
            return
          end
          local wins = vim.tbl_filter(function(win)
            return vim.api.nvim_win_get_config(win).relative == ""
          end, vim.api.nvim_tabpage_list_wins(0))
          if #wins ~= 2 then
            return
          end
          local tree_win, empty_win
          for _, win in ipairs(wins) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "neo-tree" then
              tree_win = win
            elseif vim.bo[buf].buftype == ""
              and vim.api.nvim_buf_get_name(buf) == ""
              and not vim.bo[buf].modified
              and vim.api.nvim_buf_line_count(buf) == 1
              and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ""
            then
              empty_win = win
            end
          end
          if not tree_win or not empty_win then
            return
          end
          local empty_buf = vim.api.nvim_win_get_buf(empty_win)
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.bo[buf].modified or (vim.bo[buf].buflisted and buf ~= empty_buf) then
              return
            end
          end
          local current = vim.api.nvim_get_current_win()
          if current == tree_win or current == empty_win then
            vim.api.nvim_win_close(current == tree_win and empty_win or tree_win, false)
          end
        end,
      })
      if vim.fn.argc() == 1 then
        local stat = vim.uv.fs_stat(tostring(vim.fn.argv(0)))
        if stat and stat.type == "directory" then
          require("neo-tree")
        end
      end
      -- Unless you are still migrating, remove the deprecated commands from v1.x
      vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
      -- If you want icons for diagnostic errors, you'll need to define them somewhere:
      vim.fn.sign_define("DiagnosticSignError", { text = " ", texthl = "DiagnosticSignError" })
      vim.fn.sign_define("DiagnosticSignWarn", { text = " ", texthl = "DiagnosticSignWarn" })
      vim.fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "DiagnosticSignInfo" })
      vim.fn.sign_define("DiagnosticSignHint", { text = "", texthl = "DiagnosticSignHint" })
      -- NOTE: this is changed from v1.x, which used the old style of highlight groups
      -- in the form "LspDiagnosticsSignWarning"
    end,
    opts = {
      hide_root_node = true,
      event_handlers = {
        {
          event = "file_opened",
          handler = function()
            -- Neo-tree's buffer switch leaves the empty directory placeholder listed.
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_is_loaded(buf)
                and vim.bo[buf].buflisted
                and vim.bo[buf].buftype == ""
                and vim.api.nvim_buf_get_name(buf) == ""
                and not vim.bo[buf].modified
                and #vim.fn.win_findbuf(buf) == 0
                and vim.api.nvim_buf_line_count(buf) == 1
                and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ""
              then
                vim.api.nvim_buf_delete(buf, { force = false })
              end
            end
          end,
        },
      },
      popup_border_style = "rounded",
      animate = {enabled = false},
      sources = {
        "filesystem",
        "buffers",
        "git_status",
        "document_symbols",
      },
      source_selector = {
        winbar = false,
        statusline = false,
        sources = {
          { source = "filesystem" },
          { source = "git_status" },
          { source = "buffers" },
          { source = "document_symbols" },
        },
      },
      -- open_files_do_not_replace_types = { "terminal", "Trouble", "qf", "Outline" }, -- 此处会造车edgy产生问题，但不清楚原因
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = false, -- when true, they will just be displayed differently than normal items
          hide_dotfiles = true,
          hide_gitignored = false,
          hide_hidden = true, -- only works on Windows for hidden files/directories
          hide_by_name = {
            "node_modules",
            "__pycache__",
            ".pytest_cache",
            ".mypy_cache",
            ".ruff_cache",
            ".tox",
            ".nox",
            "htmlcov",
            ".venv",
            "dist",
            "build",
            ".cache",
          },
          hide_by_pattern = { -- uses glob style patterns
            --"*.meta",
            --"*/src/*/tsconfig.json",
            "*.pyc",
            "*.egg-info",
            "*.egg_info",
            "bazel-*",
          },
          always_show = { -- remains visible even if other settings would normally hide it
            ".gitignored",
            ".gitignore",
            ".dotfiles",
            ".zshrc",
            ".zshenv",
            ".config",
            ".kube",
            ".ssh",
          },
          always_show_by_pattern = { -- uses glob style patterns
            ".env*",
          },
          never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
            ".DS_Store",
            "thumbs.db",
          },
          never_show_by_pattern = { -- uses glob style patterns
            --".null-ls_*",
          },
        },
      },
      buffers = {
        follow_current_file = { enabled = true }, -- This will find and focus the file in the active buffer every
      },
      window = {
        mappings = {
          ["<space>"] = "none",
          ["e"] = nil,
        },
        width = 30,
        -- auto_expand_width = true,
      },
      default_component_configs = {
        container = {
          enable_character_fade = true,
        },
        indent = {
          indent_size = 2,
          padding = 1, -- extra padding on left hand side
          -- indent guides
          with_markers = true,
          indent_marker = "│",
          last_indent_marker = "└",
          highlight = "NeoTreeIndentMarker",
          -- expander config, needed for nesting files
          with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
        icon = {
          folder_closed = "",
          folder_open = "",
          folder_empty = "",
          -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
          -- then these will never be used.
          -- default = "*",
          default = "",
          highlight = "NeoTreeFileIcon",
        },
        modified = {
          symbol = "[+]",
          highlight = "NeoTreeModified",
        },
        name = {
          trailing_slash = false,
          use_git_status_colors = true,
          highlight = "NeoTreeFileName",
        },
        git_status = {
          symbols = {
            -- Change type
            added = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
            modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
            deleted = "x", -- this can only be used in the git_status source
            renamed = "-", -- this can only be used in the git_status source
            -- Status type
            untracked = "?",
            unstaged = "",
            ignored = "",
            staged = "",
            conflict = "",
          },
        },
      },
    }, -- opts
  },
  {
    "folke/trouble.nvim",
    dependencies = {"nvim-tree/nvim-web-devicons", "folke/edgy.nvim"},
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
    keys = {
      { "<F9>", "<cmd>Trouble diagnostics<cr>", mode = "n", silent = true, noremap = true, desc = "TroubleToggle" },
    },
  },
}
