# Repository Guidelines

## Project Structure & Module Organization
- `init.vim` and `lua/init.lua` are the entrypoints for the Neovim configuration.
- `lua/` holds Lua modules; `lua/plugins/` contains per-plugin setup files.
- `docs/` is for usage notes, `resources/` stores formatter/linter configs, and `snips/` plus `templates/` hold snippets and starter files.
- `scripts/` and `tools/` include maintenance and setup scripts; `archive/` is legacy material.

## Build, Test, and Development Commands
- `just --list` shows available helper tasks from `justfile`.
- `just prepare_deps` and `just install` are optional setup helpers for OS-specific dependencies.
- `nvim` launches the config locally; use it to validate changes interactively.
- Utility scripts live in `tools/` (for example, `bash tools/upgrade_config.sh`); review a script before running.

## Coding Style & Naming Conventions
- Lua code uses 2-space indentation in this repo; follow existing module patterns (e.g., `my_utils.lua`, `custom_filetype.lua`).
- Prefer descriptive, lowercase filenames with underscores for Lua modules.
- Language formatter presets are stored in `resources/` (e.g., `resources/clang-format`, `resources/yapf/style`, `resources/pycodestyle`) and should guide formatting for templates/snippets.

## Testing Guidelines
- Verify changes by launching `nvim` and exercising the affected workflows.
- JavaScript highlighting regression: `nvim --headless -i NONE "+luafile tests/treesitter_spec.lua" +qa` (uses the normal config; requires `:TSInstall javascript jsdoc regex`).
- Just highlighting regression: `nvim --headless -i NONE "+luafile tests/just_highlight_spec.lua" +qa` (checks attributes on imports and subsequent recipe/comment highlighting using built-in syntax).
- Fresh dependency installation regression: `nvim --headless -u NONE -i NONE -l tests/treesitter_bootstrap_spec.lua` (requires installed Mason/nvim-treesitter plugins, network access, and a C compiler; uses temporary Mason/parser directories).
- If you add tests in the future, place them under a top-level `tests/` directory and document how to run them here.

## Commit & Pull Request Guidelines
- Recent commits use short, imperative messages like "Update treesitter and neo-tree"; follow this style.
- PRs should include: a concise summary, rationale for config changes, and screenshots or gifs for UI/theme updates.

## Environment & Dependencies
- Node.js and Python tooling are expected for language servers/formatters; see `README.md` for required versions.
