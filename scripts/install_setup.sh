#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
MODE_ARGS=()
TARGET_DIR=${HOME}
INSTALL_PLUGINS=false
INSTALL_SYSTEM_DEPS=true

usage() {
    cat <<EOF
Usage: ${0##*/} [--copy] [--target-dir DIR] [--plugins] [--skip-system-deps]

Install dotfiles from this checkout. Symlinks are used by default; existing
targets are moved to timestamped backups. The default run installs system
dependencies with apt-get and requires sudo. Use --skip-system-deps to opt out.

  --copy                 Copy files instead of creating symlinks
  --target-dir DIR       Install into DIR instead of the current user's home
  --plugins              Bootstrap Vundle and install configured Vim plugins
  --install-system-deps  Install git, Vim, ag, fzf, flake8, and autopep8
                         with apt-get (default; requires sudo)
  --skip-system-deps     Skip system package installation
EOF
}

while (($#)); do
    case "$1" in
    --copy) MODE_ARGS+=(--copy) ;;
    --target-dir)
        shift
        (($#)) || {
            printf '%s\n' '--target-dir requires a directory' >&2
            exit 2
        }
        MODE_ARGS+=(--target-dir "$1")
        TARGET_DIR=$1
        ;;
    --plugins) INSTALL_PLUGINS=true ;;
    --install-system-deps) INSTALL_SYSTEM_DEPS=true ;;
    --skip-system-deps) INSTALL_SYSTEM_DEPS=false ;;
    -h | --help)
        usage
        exit 0
        ;;
    *)
        printf 'Unknown option: %s\n' "$1" >&2
        usage >&2
        exit 2
        ;;
    esac
    shift
done

mkdir -p -- "${TARGET_DIR}"
TARGET_DIR=$(cd -- "${TARGET_DIR}" && pwd -P)
case "${TARGET_DIR}/" in
"${REPO_DIR}/" | "${REPO_DIR}/"*)
    printf '%s\n' 'Target directory must not be inside the source checkout.' >&2
    exit 2
    ;;
*) ;;
esac

if [[ "${INSTALL_SYSTEM_DEPS}" == true ]]; then
    command -v apt-get >/dev/null 2>&1 || {
        printf '%s\n' 'apt-get is required for default system dependency installation; use --skip-system-deps to skip it.' >&2
        exit 1
    }
    command -v sudo >/dev/null 2>&1 || {
        printf '%s\n' 'sudo is required for default system dependency installation; use --skip-system-deps to skip it.' >&2
        exit 1
    }
    sudo apt-get update
    sudo apt-get install -y git vim silversearcher-ag fzf flake8 python3-autopep8
fi

if [[ "${INSTALL_PLUGINS}" == true ]]; then
    command -v git >/dev/null 2>&1 || {
        printf '%s\n' 'git is required for --plugins' >&2
        exit 1
    }
    command -v vim >/dev/null 2>&1 || {
        printf '%s\n' 'vim is required for --plugins' >&2
        exit 1
    }
fi

"${SCRIPT_DIR}/unpack_setup.sh" "${MODE_ARGS[@]}"

if [[ "${INSTALL_PLUGINS}" == true ]]; then
    DOWNLOAD_ARGS=(--target-dir "${TARGET_DIR}")
    if [[ "${INSTALL_SYSTEM_DEPS}" != true ]]; then
        DOWNLOAD_ARGS+=(--skip-system-deps)
    fi
    "${REPO_DIR}/.vim/download_plugins" "${DOWNLOAD_ARGS[@]}"
fi

printf 'Setup installed in %s\n' "${TARGET_DIR}"
