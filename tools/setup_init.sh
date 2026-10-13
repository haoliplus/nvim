#!/usr/bin/env bash
set -euo pipefail

config_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
nvim_bin=${NVIM_BIN:-nvim}
export VIM_CONFIG_DIR="$config_dir"

# Check prerequisites before loading plugins or starting downloads.
"$nvim_bin" --headless -u NONE -i NONE \
  '+lua vim.opt.rtp:prepend(vim.env.VIM_CONFIG_DIR); require("setup_init").run("check")' +qa
data_dir=$("$nvim_bin" --headless -u NONE -i NONE \
  '+lua io.write(vim.fn.stdpath("data"))' +qa)
mkdir -p "$data_dir"
lock_dir="$data_dir/setup-init.lock"
if ! mkdir "$lock_dir" 2>/dev/null; then
  printf 'SetupInit is already running, or a previous run was interrupted: %s\n' "$lock_dir" >&2
  printf 'Only remove this directory after confirming its recorded process has stopped.\n' >&2
  exit 1
fi
cleanup() {
  rm -f "$lock_dir/pid" "$lock_dir/lazy-lock.json"
  rmdir "$lock_dir"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
printf '%s\n' "$$" > "$lock_dir/pid"
export NVIM_SETUP_LOCKFILE="$lock_dir/lazy-lock.json"

# Separate processes reload restored plugin code and newly compiled parsers.
for stage in plugins tools parsers verify; do
  cp "$config_dir/lazy-lock.json" "$NVIM_SETUP_LOCKFILE"
  printf '\nSetupInit: %s\n' "$stage"
  "$nvim_bin" --headless -n -i NONE -u "$config_dir/init.vim" \
    --cmd 'let g:setup_init_running = v:true' \
    "+lua require('setup_init').run('$stage')" +qa
done
printf '\nSetupInit complete. Restart Neovim to load the installed components.\n'
