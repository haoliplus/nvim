# TypeScript language server troubleshooting

If Neovim reports that `typescript-language-server --stdio` cannot be spawned,
run `:MasonInstall typescript-language-server`, wait for installation to finish,
then reopen the JavaScript/TypeScript buffer or restart Neovim. Node.js and npm
must be available to Neovim. Check `:Mason` for installation status and
`:MasonLog` if installation fails.

`ts_ls` is enabled in this configuration, but enabling an LSP does not install its
executable. `:SetupInit` includes this package when initializing a new machine;
the command above installs just this server. Mason adds its executable directory
to Neovim's PATH, so a global npm installation is unnecessary.
