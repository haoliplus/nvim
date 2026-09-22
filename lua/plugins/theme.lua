local function start_treesitter(bufnr)
  if vim.bo[bufnr].filetype == "just" then
    -- The Just parser cannot parse attributes on imports, e.g. [unix].
    vim.treesitter.stop(bufnr)
    vim.bo[bufnr].syntax = "just"
    return
  end
  local ok, err = pcall(vim.treesitter.start, bufnr)
  if not ok and not require("treesitter_setup").pending and vim.bo[bufnr].filetype:match("^javascript") then
    vim.notify_once(
      "JavaScript Tree-sitter highlighting failed. Run :TSInstall javascript jsdoc regex\n" .. tostring(err),
      vim.log.levels.WARN
    )
  end
end

local function setup_builtin_treesitter()
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("UserTreesitterStart", { clear = true }),
    callback = function(args)
      start_treesitter(args.buf)
    end,
  })
end

setup_builtin_treesitter()

return {
  -- Themes
  -- syntax highlight
  { "jackguo380/vim-lsp-cxx-highlight" },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    dependencies = { "mason-org/mason.nvim" },
    build = ":TSUpdate",
    config = function()
      require("treesitter_setup").setup()
    end,
  },
  {
    "phelipetls/jsonpath.nvim",
    ft = { "json" },
    opts = {
      show_on_winbar = true,
    },
    config = function(_, opts)
      require("jsonpath").setup(opts)

      local function enable_jsonpath()
        local bufnr = vim.api.nvim_get_current_buf()
        vim.schedule(function()
          pcall(vim.treesitter.start, bufnr)
          pcall(function()
            vim.treesitter.get_parser(bufnr):parse()
          end)
        end)
        vim.opt_local.winbar = "%{%v:lua.require'jsonpath'.get()%}"
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("JsonpathWinbar", { clear = true }),
        pattern = "json",
        callback = enable_jsonpath,
      })

      -- lazy.nvim loads this plugin after the FileType event that triggered it.
      if vim.bo.filetype == "json" then
        enable_jsonpath()
      end
    end,
  },
  {
    "romus204/tree-sitter-manager.nvim",
    -- `main` currently passes Git's unsupported `--no-advice` option.
    commit = "f1a322c76ce799d14659d70389c41ebd3136c3ff",
    enabled = false,
    dependencies = {}, -- tree-sitter CLI must be installed system-wide
    config = function()
      require("tree-sitter-manager").setup({
        -- Default Options
        -- ensure_installed = {}, -- list of parsers to install at the start of a neovim session. If set to "all", install all parsers.
        -- border = nil, -- border style for the window (e.g. "rounded", "single"), if nil, use the default border style defined by 'vim.o.winborder'. See :h 'winborder' for more info.
        -- auto_install = false, -- if enabled, install missing parsers when editing a new file
        -- highlight = true, -- treesitter highlighting is enabled by default
        -- languages = {}, -- override or add new parser sources
      })
    end
  },
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
    "catgoose/nvim-colorizer.lua",
    main = "colorizer",
    opts = {},
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
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
  {
    "nvim-tree/nvim-web-devicons",
    lazy = false,
    config = function()
      require("nvim-web-devicons").setup({
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
          ["yaml"] = {
            icon = "",
            color = "#6d8086",
            cterm_color = "66",
            name = "yaml",
          },
          ["yml"] = {
            icon = "",
            color = "#6d8086",
            cterm_color = "66",
            name = "yml",
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
      providers = { "lsp", "regex" },
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
