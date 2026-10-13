# Contributor guidance

- Read the README before changing installer behavior. Preserve the default
  system-package install behavior and the documented `--skip-system-deps`
  path unless the change explicitly addresses installation.
- Keep setup checks offline. Run `bash scripts/check_setup.sh` after changes to
  install scripts, Vim startup, or buffer behavior.
- The extensionless `.vim/download_plugins` and `.vim/update_vim` files are
  Bash scripts; check them with Bash and ShellCheck explicitly.
- Do not commit credentials, SSH configuration, or private keys. Sandbox host
  aliases belong in a user's `.sandbox` file and SSH configuration.
- Optional plugins are currently resolved from mutable upstream revisions.
  Do not describe plugin installation as reproducible until revisions have
  been pinned and the lock is enforced.
