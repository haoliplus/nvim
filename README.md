# NVIM CONFIG

## FONT
1. nvim-config/resources/JetBrainsMonoNLRegularNerdFontComplete.ttf

### REQUIRE

1. node, npm
2. python3, python3-venv, python3-pip, black, pyright
3. Neovim 0.12+, Git, curl, tar, a C compiler, and tree-sitter CLI 0.26.1+ (install via a package manager, not npm).

### JavaScript highlighting on a new machine

The configuration automatically installs missing `javascript`, `jsdoc`, and `regex`
Tree-sitter parsers and their highlight queries at startup. The first installation
needs network access and the tools above; it runs in the background and enables
highlighting in already open JS/JSX buffers when finished. Later launches reuse the
installed parsers. Generated files live in Neovim's data directory and do not need
to be copied with this repository.

Verify `tree-sitter --version` works in the shell launching Neovim. If using mise,
install and select a version (for example, `mise use -g tree-sitter@0.26.11`);
having a shim on PATH alone is insufficient. Use `:checkhealth nvim-treesitter`
for diagnostics and `:TSInstall javascript jsdoc regex` to retry a failed install.

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
