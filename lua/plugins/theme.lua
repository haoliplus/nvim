return {
  -- Themes
  -- syntax highlight
  { "jackguo380/vim-lsp-cxx-highlight" },
  { "MunifTanjim/nui.nvim" },
  { -- theme
    "drewtempelmeyer/palenight.vim",
  },
  {
    "folke/tokyonight.nvim",
    opts = {
      -- use the night style
      style = "night",
      -- disable italic for functions
      styles = {
        comments = { italic = true },
        functions = {},
      },
      sidebars = { "qf", "vista_kind", "terminal", "packer" },
      -- Change the "hint" color to the "orange" color, and make the "error" color bright red
      on_colors = function(colors)
        -- colors.hint = colors.orange
        colors.error = colors.orange
      end,
    },
  },
  {
    "norcalli/nvim-colorizer.lua",
    opts = {},
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
    -- enabled = function()
    --  return vim.version().major > 0 or vim.version().minor > 8
    -- end,
    -- enabled = true,
    enabled = vim.version().major > 0 or vim.version().minor > 8,
    config = function()
      local highlight = {
        "RainbowRed",
        "RainbowYellow",
        "RainbowBlue",
        "RainbowOrange",
        "RainbowGreen",
        "RainbowViolet",
        "RainbowCyan",
      }
      local hooks = require("ibl.hooks")

      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
        vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
        vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
        vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
        vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
        vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
        vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
      end)

      vim.g.rainbow_delimiters = { highlight = highlight }

      require("ibl").setup({
        scope = {
          highlight = highlight,
        },
        -- show_current_context = true,
        -- show_current_context_start = false,
        -- show_end_of_line = true,
      })

      hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)

      require("ibl").overwrite({
        exclude = { filetypes = { "help", "terminal", "vimwiki", "dashboard" } },
      })
    end,
    -- init = function()
    --     -- vim.cmd([[highlight IndentBlanklineContextStart guisp=#00FF00 gui=italic cterm=italic]])
    --     vim.g.indent_blankline_filetype_exclude = {'help', 'help', 'terminal', 'vimwiki', 'dashboard'}
    -- end,
    -- config = function()
    --   require("indent_blankline").setup {
    --       -- for example, context is off by default, use this to turn it on
    --       show_current_context = true,
    --       show_current_context_start = false,
    --       show_end_of_line = true,
    --   }
    -- end
  },
  -- {
  --   "IndianBoy42/tree-sitter-just",
  --   opts = {},
  -- },
  { ------ Better syntax highlightingG
    "nvim-treesitter/nvim-treesitter",
    enabled = true,
    -- dependencies = { "IndianBoy42/tree-sitter-just" },
    build = ":TSUpdate",
    lazy = false,
    config = function()
      -- require("nvim-treesitter.configs").setup({
      require("nvim-treesitter").setup({
        modules = {},
        -- A list of parser names, or "all" (the five listed parsers should always be installed)
        ensure_installed = {
          "c",
          "lua",
          "python",
          "vim",
          "query",
          "markdown",
          "markdown_inline",
          "vimdoc",
          "html",
          "javascript",
          "just",
          "css",
          "yaml",
          "json",
          "toml",
          "bash",
          "rust",
          "html",
          "cpp",
          "go",
          "dockerfile"
        },

        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,

        -- Automatically install missing parsers when entering buffer
        -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
        auto_install = true,

        -- List of parsers to ignore installing (for "all")
        ignore_install = { "javascript", "help" },

        ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
        -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

        highlight = {
          enable = true,

          -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
          -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
          -- the name of the parser)
          -- list of language that will be disabled
          disable = {"latex" },
          -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
          -- disable = function(lang, buf)
          --   local max_filesize = 100 * 1024 -- 100 KB
          --   local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          --   if ok and stats and stats.size > max_filesize then
          --     return true
          --   end
          -- end,

          -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
          -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
          -- Using this option may slow down your editor, and you may see some duplicate highlights.
          -- Instead of true it can also be a list of languages
          additional_vim_regex_highlighting = false,
        },
      })
      -- require("nvim-treesitter.parsers").get_parser_configs().just = {
      --   install_info = {
      --     url = "https://github.com/IndianBoy42/tree-sitter-just", -- local path or git repo
      --     files = { "src/parser.c", "src/scanner.c" },
      --     branch = "main",
      --     -- use_makefile = true -- this may be necessary on MacOS (try if you see compiler errors)
      --   },
      --   maintainers = { "@IndianBoy42" },
      -- }
    end,
  },
  {
    "nvim-tree/nvim-web-devicons",
    enabled = true,
    lazy = false,
    -- opts = {
    --   override = {
    --     toml = {
    --       icon = "#",
    --       color = "#428850",
    --       cterm_color = "65",
    --       name = "toml",
    --     },
    --     lua = {
    --       icon = "#",
    --       color = "#428850",
    --       cterm_color = "65",
    --       name = "lua",
    --     },
    --   },
    --   override_by_filename = {
    --     [".gitignore"] = {
    --       icon = "a",
    --       color = "#f1502f",
    --       name = "gitignore",
    --     },
    --     ["a.toml"] = {
    --       icon = "",
    --       color = "#f1502f",
    --       name = "gitignore",
    --     },
    --   },
    --   override_by_extension = {
    --     ["toml"] = {
    --       icon = "",
    --       color = "#f1502f",
    --       name = "gitignore",
    --     },
    --   },
    -- },
    config = function()
      -- require("lualine").setup({})
      require("nvim-web-devicons").setup({
        -- your personnal icons can go here (to override)
        -- you can specify color or cterm_color instead of specifying both of them
        -- DevIcon will be appended to `name`
        override = {
          toml = {
            icon = "",
            color = "#428850",
            cterm_color = "65",
            name = "toml",
          },
          dconf = {
            icon = "",
            name = "dconf",
          },
        },
        override_by_filename = {
          [".gitignore"] = {
            icon = "",
            color = "#f1502f",
            name = "gitignore",
          },
        },
        override_by_extension = {
          ["toml"] = {
            icon = "",
            color = "#f1502f",
            name = "toml",
          },
        },
      })

      require("nvim-web-devicons").set_icon({
        toml = {
          icon = "",
          color = "#6d8086",
          cterm_color = "65",
          name = "toml",
        },
      })
      require("nvim-web-devicons").set_default_icon("", "#6d8086", 65)
    end,
  },
  -- Automatically highlights other instances of the word under your cursor.
  -- This works with LSP, Treesitter, and regexp matching to find the other
  -- instances.
  { -- hightlight word which is same with the word under cursor
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { "lsp" },
      },
    },
    init = function() end,
    config = function(_, opts)
      require("illuminate").configure(opts)
      -- illuminatedWord
      -- bold underline undercurl
      -- underdouble underdotted
      -- underdashed inverse italic
      -- standout nocombine strikethrough

      local function map(key, dir, buffer)
        vim.keymap.set("n", key, function()
          require("illuminate")["goto_" .. dir .. "_reference"](false)
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
      end

      map("]]", "next")
      map("[[", "prev")

      -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          map("]]", "next", buffer)
          map("[[", "prev", buffer)
        end,
      })
    end,
    keys = {
      { "]]", desc = "Next Reference" },
      { "[[", desc = "Prev Reference" },
    },
  },
}
