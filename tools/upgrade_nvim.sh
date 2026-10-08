#!/bin/sh
# Copyright (C) 2022 lihao <haoliplus@gmail.com>
# Distributed under terms of the MIT license.
set -eu

die() {
  printf '%s\n' "$*" >&2
  exit 1
}

case "$(uname -s)" in
  Linux) OS=linux ;;
  Darwin) OS=macos ;;
  *) die "Unsupported operating system" ;;
esac
case "$(uname -m)" in
  x86_64) ARCH=x86_64 ;;
  aarch64|arm64) ARCH=arm64 ;;
  *) die "Unsupported CPU architecture" ;;
esac

if command -v curl >/dev/null 2>&1; then
  DOWNLOADER=curl
elif command -v wget >/dev/null 2>&1; then
  DOWNLOADER=wget
else
  die "Install curl or wget before running this script"
fi

NVIM_NAME="nvim-${OS}-${ARCH}"
NVIM_DOWNLOAD_URL="https://github.com/neovim/neovim/releases/latest/download/${NVIM_NAME}.tar.gz"
# Override the prefix for a separate installation or an isolated test.
LOCAL_DIR="${NVIM_INSTALL_PREFIX:-${HOME}/.local}"
mkdir -p "$LOCAL_DIR"
LOCK_DIR="$LOCAL_DIR/.nvim-upgrade.lock"
mkdir "$LOCK_DIR" 2>/dev/null || die "Cannot acquire upgrade lock: $LOCK_DIR"

STAGE=
COMMITTED=0

exists() {
  [ -e "$1" ] || [ -L "$1" ]
}

cleanup() {
  result=$?
  trap - 0 HUP INT TERM
  set +e
  keep_stage=0
  if [ -n "$STAGE" ]; then
    if [ "$COMMITTED" -eq 0 ]; then
      # Restore in reverse order, including after a partially completed move.
      for component in share/nvim/runtime lib/nvim bin/nvim; do
        target="$LOCAL_DIR/$component"
        backup="$STAGE/backup/$component"
        if exists "$backup"; then
          if ! { rm -rf "$target" && mv "$backup" "$target"; }; then
            printf 'Failed to restore %s; recovery files: %s\n' "$target" "$STAGE" >&2
            keep_stage=1
            result=1
          fi
        elif [ -f "$STAGE/absent/$component" ]; then
          rm -rf "$target" || result=1
        fi
      done
    elif [ -d "$STAGE/backup" ]; then
      keep_stage=1
      printf 'Previous installation saved in: %s/backup\n' "$STAGE"
    fi
    if [ "$keep_stage" -eq 0 ]; then
      rm -rf "$STAGE"
    elif [ "$COMMITTED" -eq 1 ]; then
      rm -rf "$STAGE/archive.tar.gz" "$STAGE/$NVIM_NAME" "$STAGE/absent"
    fi
  fi
  rmdir "$LOCK_DIR" || result=1
  exit "$result"
}
trap cleanup 0
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM

# Keep staging and backups on the installation filesystem for rename-based moves.
STAGE=$(mktemp -d "$LOCAL_DIR/.nvim-upgrade.XXXXXX")
printf 'Downloading %s\n' "$NVIM_DOWNLOAD_URL"
if [ "$DOWNLOADER" = curl ]; then
  curl -fL --retry 3 -o "$STAGE/archive.tar.gz" "$NVIM_DOWNLOAD_URL"
else
  wget -O "$STAGE/archive.tar.gz" "$NVIM_DOWNLOAD_URL"
fi
tar -xzf "$STAGE/archive.tar.gz" -C "$STAGE"
PACKAGE_DIR="$STAGE/$NVIM_NAME"

[ -x "$PACKAGE_DIR/bin/nvim" ] || die "Archive is missing an executable bin/nvim"
[ -d "$PACKAGE_DIR/lib/nvim" ] || die "Archive is missing lib/nvim"
[ -d "$PACKAGE_DIR/share/nvim/runtime" ] || die "Archive is missing share/nvim/runtime"
# Detect incompatible binaries (for example, an unsupported glibc) before replacement.
"$PACKAGE_DIR/bin/nvim" --version

for component in bin/nvim lib/nvim share/nvim/runtime; do
  target="$LOCAL_DIR/$component"
  parent=${component%/*}
  mkdir -p "$LOCAL_DIR/$parent"
  if exists "$target"; then
    mkdir -p "$STAGE/backup/$parent"
    mv "$target" "$STAGE/backup/$component"
  else
    mkdir -p "$STAGE/absent/$parent"
    : > "$STAGE/absent/$component"
  fi
  mv "$PACKAGE_DIR/$component" "$target"
done

"$LOCAL_DIR/bin/nvim" --version
COMMITTED=1
printf 'Neovim installed in %s\n' "$LOCAL_DIR"
