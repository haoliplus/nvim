# NVIM CONFIG

## FONT
1. nvim-config/resources/JetBrainsMonoNLRegularNerdFontComplete.ttf

### REQUIRE

1. node, npm
2. python3, python3-venv, python3-pip, black, pyright
3. Neovim 0.12+, Git, curl, tar, a C compiler, and download/extraction tools required by Mason (including gzip and unzip).

### First-time initialization

After placing this configuration directory, run `:SetupInit` in Neovim, or run:

```sh
bash ~/.config/nvim/tools/setup_init.sh
```

Requires Neovim 0.12+, Bash, Git, curl, tar, gzip, unzip, make, a C compiler,
Node.js/npm, Python 3 with pip/venv/ensurepip, and Go (for gofumpt). Install these
system dependencies first; the initializer reports missing prerequisites.

The command restores plugins using `lazy-lock.json`, installs missing Mason tools
and Tree-sitter CLI, installs common language parsers with their queries, updates
parser revisions to match nvim-treesitter, and validates queries in a new process.
The repository lockfile is preserved. The parser list and tool list are in
`lua/setup_init.lua`; these steps only run when explicitly requested.

Repeated runs reuse installed tools and matching parsers, and repair incomplete
parser/query installations. Concurrent runs are rejected using
`stdpath('data')/setup-init.lock`. Failures return a nonzero exit code and can be
retried after resolving the reported error. If the process was forcibly killed,
check the PID in `setup-init.lock/pid` before manually removing the stale lock.
The lock coordinates SetupInit runs; avoid running other plugin/package updates
at the same time. Restart Neovim after completion to unload old plugin/parser code.

### JavaScript highlighting on a new machine

At startup the configuration checks whether `tree-sitter --version` works and is
at least 0.26.1. If it is missing, broken, or too old, Mason installs
`tree-sitter-cli` and adds its executable directory to Neovim's PATH. Once the CLI
is ready, nvim-treesitter installs missing `javascript`, `jsdoc`, and `regex`
parsers and queries. Installation runs asynchronously and enables highlighting in
already open JS/JSX buffers on completion. Existing dependencies are reused.

No mise, Cargo, or manual shell PATH setup is required for Mason's supported
platforms. The first installation needs network access, download/extraction tools,
and a C compiler for the parsers. Generated files live in Neovim's data directory;
copying this repository to a new machine repeats the dependency checks.

On failure, inspect `:MasonLog` (CLI) or `:messages` (parsers). To retry manually,
run `:MasonInstall tree-sitter-cli`, wait for completion, then run
`:TSInstall javascript jsdoc regex` and restart Neovim. For diagnostics use
`:checkhealth mason` and `:checkhealth nvim-treesitter`.

## INSTALL

```bash
git clone git@github.com:haoliplus/nvim-config.git ~/.config/nvim
# installs NVM (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
# download and install Node.js
# nvm install 20
nvim install --lts
# verifies the right Node.js version is in the environment
node -v # should print `v20.12.0`
# verifies the right NPM version is in the environment
npm -v # should print `10.5.0`
sudo  apt install python3-pip python3-venv
```

| Column 1      | Column 2      |
| ------------- | ------------- |
| Cell 1, Row 1 | Cell 2, Row 1 |
| Cell 1, Row 2 | Cell 1, Row 2 |


<!-- curl -s -L https://raw.githubusercontent.com/haoliplus/nvim-config/master/tools/install.sh | bash -->
<!-- wget -O - -o https://raw.githubusercontent.com/haoliplus/nvim-config/master/tools/install.sh | bash  -->
<!---->

## quick move
this_is_a_long_word

`cf<symbol>`: delete until next symbol(include symbol)
`ct<symbol>`: delete until next symbol(not include symbol)
`ciw`: delete current word
