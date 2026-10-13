# Dependencies

The dotfile installer itself uses Bash, Git, and Vim provided by the host
system. Its default installer can install these plus optional search and
Python tools with Debian or Ubuntu packages. Those operating-system package
versions are not locked by this repository.

The optional Vim plugin bundle is third-party software. Vundle fetches plugin
repositories listed in `.vim/plugins.vim`; those entries currently follow
upstream revisions and have no checked-in revision lock. `:PluginUpdate` also
fetches current upstream revisions. Plugin installation therefore does not
reproduce a fixed dependency set. Review and pin plugin revisions before using
the bundle where repeatable plugin versions are required.

The pinned npm lockfile under `linters/` supplies the Markdown linter used by
the standards workflow. ShellCheck, shfmt, and yamllint are external lint
tools whose versions are recorded in `TOOLCHAINS.md` and installed in CI.

Because optional Vundle plugins are not locked, the dependency set as a whole
is not reproducible. The common-standards CS-007 check should continue to fail
until the plugin revisions and their update/install path are locked.
