# NVIM CONFIG

## FONT
1. nvim-config/resources/JetBrainsMonoNLRegularNerdFontComplete.ttf

### REQUIRE

1. node, npm
2. python3, python3-venv, python3-pip, black, pyright
3. Neovim 0.12+, Git, curl, tar, a C compiler, and download/extraction tools required by Mason (including gzip and unzip).

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
