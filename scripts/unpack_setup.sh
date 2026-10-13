#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd -P)"
MODE=symlink
TARGET_DIR=${HOME}

usage() {
    printf 'Usage: %s [--copy] [--target-dir DIR]\n' "${0##*/}"
    printf 'Install this checkout\047s dotfiles in your home directory (symlinks by default).\n'
}

while (($#)); do
    case "$1" in
        --copy) MODE=copy ;;
        --target-dir)
            shift
            (($#)) || { printf '%s\n' '--target-dir requires a directory' >&2; exit 2; }
            TARGET_DIR=$1
            ;;
        -h|--help) usage; exit 0 ;;
        *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
    esac
    shift
done
mkdir -p -- "$TARGET_DIR"
TARGET_DIR=$(cd -- "$TARGET_DIR" && pwd -P)

backup_path() {
    local target=$1 stamp candidate suffix=0
    stamp=$(date '+%Y%m%d%H%M%S')
    candidate="${target}.backup.${stamp}"
    while [[ -e "$candidate" || -L "$candidate" ]]; do
        suffix=$((suffix + 1))
        candidate="${target}.backup.${stamp}.${suffix}"
    done
    printf '%s' "$candidate"
}

install_one() {
    local source=$1 target=$2 current
    if [[ "$MODE" == symlink && -L "$target" ]]; then
        current=$(readlink -- "$target")
        if [[ "$current" == "$source" ]]; then
            printf 'Already linked: %s\n' "$target"
            return
        fi
    fi
    if [[ -e "$target" || -L "$target" ]]; then
        local backup
        backup=$(backup_path "$target")
        mv -- "$target" "$backup"
        printf 'Backed up %s to %s\n' "$target" "$backup"
    fi
    if [[ "$MODE" == symlink ]]; then
        ln -s -- "$source" "$target"
    else
        cp -a -- "$source" "$target"
    fi
    printf 'Installed %s\n' "$target"
}

case "$TARGET_DIR/" in
    "$REPO_DIR/"|"$REPO_DIR/"*)
        printf '%s\n' 'Target directory must not be inside the source checkout.' >&2
        exit 2
        ;;
esac

for name in .vim .vimrc .tmux.conf .config/flake8; do
    [[ -e "$REPO_DIR/$name" ]] || continue
    target="$TARGET_DIR/$name"
    mkdir -p -- "$(dirname -- "$target")"
    install_one "$REPO_DIR/$name" "$target"
done
