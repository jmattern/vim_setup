# Toolchains

- Bash: 5.x; scripts use Bash features and are checked with `bash -n`.
- Vim: 8.0 or newer for ALE integration; headless Vim startup and editor
  behavior are checked with Vim 9.1 in CI.
- Node.js: 24 for the lint workflow.
- markdownlint-cli2: 0.17.2, pinned in `linters/package-lock.json`.
- ShellCheck: 0.9.0; CI installs the Ubuntu 24.04 package.
- yamllint: 1.38.0; CI installs the pinned package with pip.
- shfmt: 3.8.0; CI installs the Ubuntu 24.04 package.
- Python: 3.12 in CI for the common-standards checker.

The setup targets Debian/Ubuntu for automatic package installation. Other
systems can use `--skip-system-deps` and provide compatible tools themselves.
The operating-system package versions used by the install script are not
locked here. Optional Vim plugin revisions are not currently locked; see
`DEPENDENCIES.md`.
