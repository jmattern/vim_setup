#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"

for script in "${REPO_DIR}/install.sh" "${REPO_DIR}"/scripts/*.sh; do
    bash -n "${script}"
done
for script in "${REPO_DIR}/.vim/download_plugins" "${REPO_DIR}/.vim/update_vim"; do
    bash -n "${script}"
done
