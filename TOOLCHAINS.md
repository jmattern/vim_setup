# Toolchains

- Supported shell runtime: Bash 4 or newer; configuration installation also uses
  POSIX shell and standard filesystem tools.
- Vim: Vim 8 or newer for the configured editor features.
- Standards CI runs on Ubuntu 24.04.
- Python 3.12.11 runs the vendored standards checker. `requirements.txt` pins
  jsonschema 4.26.0 and its full Python dependency set; Ruff 0.17.0 and yamllint
  1.38.0 are pinned for repeatable project checks.
- Node.js 24.21.0 and npm 11.19.0 run markdownlint-cli2 0.17.2. Its complete
  dependency tree is pinned in `.standards/linters/package-lock.json`.
- ShellCheck 0.10.0-1 and shfmt 3.6.0-1 are installed from the Ubuntu 24.04
  package archive using exact package versions.
- GitHub Actions use checkout 7.0.1, setup-python 7.0.0, setup-node 4.4.0,
  upload-artifact 7.0.1, and download-artifact 8.0.1.
- The baseline catalog and checker come from common-standards commit
  `1bdfb52e0c72b37c5c2acca5db2e8a87b43f87c5`; see
  `.standards/VENDORED_FROM.md` for the vendored file list and local profile.
