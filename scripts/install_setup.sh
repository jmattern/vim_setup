#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd -P)"
MODE_ARGS=()
TARGET_DIR=${HOME}
INSTALL_PLUGINS=false
INSTALL_SYSTEM_DEPS=false

usage() {
    cat <<EOF
Usage: ${0##*/} [--copy] [--target-dir DIR] [--plugins] [--install-system-deps]

Install dotfiles from this checkout. Symlinks are used by default; existing
targets are moved to timestamped backups. The default run is local and does
not contact the network or install system packages.

  --copy                 Copy files instead of creating symlinks
  --target-dir DIR       Install into DIR instead of the current user's home
  --plugins              Bootstrap Vundle and install configured Vim plugins
  --install-system-deps  Install git and Vim with apt-get (requires sudo)
EOF
}

while (($#)); do
    case "$1" in
        --copy) MODE_ARGS+=(--copy) ;;
        --target-dir)
            shift
            (($#)) || { printf '%s\n' '--target-dir requires a directory' >&2; exit 2; }
            MODE_ARGS+=(--target-dir "$1")
            TARGET_DIR=$1
            ;;
        --plugins) INSTALL_PLUGINS=true ;;
        --install-system-deps) INSTALL_SYSTEM_DEPS=true ;;
        -h|--help) usage; exit 0 ;;
        *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
    esac
    shift
done

mkdir -p -- "$TARGET_DIR"
TARGET_DIR=$(cd -- "$TARGET_DIR" && pwd -P)
case "$TARGET_DIR/" in
    "$REPO_DIR/"|"$REPO_DIR/"*)
        printf '%s\n' 'Target directory must not be inside the source checkout.' >&2
        exit 2
        ;;
esac

if [[ "$INSTALL_SYSTEM_DEPS" == true ]]; then
    command -v apt-get >/dev/null 2>&1 || { printf '%s\n' 'apt-get is required for --install-system-deps' >&2; exit 1; }
    command -v sudo >/dev/null 2>&1 || { printf '%s\n' 'sudo is required for --install-system-deps' >&2; exit 1; }
    sudo apt-get update
    sudo apt-get install -y git vim
fi

if [[ "$INSTALL_PLUGINS" == true ]]; then
    command -v git >/dev/null 2>&1 || { printf '%s\n' 'git is required for --plugins' >&2; exit 1; }
    command -v vim >/dev/null 2>&1 || { printf '%s\n' 'vim is required for --plugins' >&2; exit 1; }
fi

"$SCRIPT_DIR/unpack_setup.sh" "${MODE_ARGS[@]}"

if [[ "$INSTALL_PLUGINS" == true ]]; then
    "$REPO_DIR/.vim/download_plugins" --target-dir "$TARGET_DIR"
fi

printf 'Setup installed in %s\n' "$TARGET_DIR"
