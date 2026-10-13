# vim_setup

Vim and tmux configuration with optional plugins and project-specific Python
sandbox linting.

## Install

Run from any directory, using the path to your checkout:

```bash
/path/to/vim_setup/install.sh
```

By default, installation uses `sudo apt-get` to install Git, Vim, ag, fzf, flake8,
and autopep8, then links the checkout's Vim, tmux, and flake8 configuration into
your home directory. Existing targets move to timestamped `.backup.*` paths;
rerunning installation leaves matching links alone. Changes in this checkout
immediately apply to linked configurations. Keep the checkout in place. Other
files in `~/.config` are preserved.

```bash
# Copy configuration instead of linking it.
./install.sh --copy

# Try installation in an isolated directory.
./install.sh --skip-system-deps --target-dir /tmp/vim-setup-demo

# Also install plugins (requires network access, Git, and Vim).
./install.sh --plugins

# Install only configuration, without system packages or plugin downloads.
./install.sh --skip-system-deps
```

Default installation requires Debian/Ubuntu's `apt-get`, sudo, and network access.
Use `--skip-system-deps` to install configuration on other systems or when tools
are already installed. With that flag and without `--plugins`, installation runs
offline using Bash and standard filesystem tools. `scripts/unpack_setup.sh` also
provides configuration installation without dependency or plugin downloads.
The `--install-system-deps` flag remains supported for compatibility.

To roll back, move the installed target aside and move its printed backup path
back to the original location. For example, move `~/.vimrc` to `~/.vimrc.disabled`,
then move `~/.vimrc.backup.TIMESTAMP` to `~/.vimrc`. Repeat for each target you want
to restore. Keep any new plugin files you want before restoring a Vim directory.

## Plugins and tools

The downloader bootstraps Vundle, then lets Vundle evaluate `.vim/plugins.vim`
and install its plugins. Vim starts without downloaded plugins; plugin commands
become available after installation.
Before downloading, it checks for CMake and Python 3 and uses `sudo apt-get` to
install missing tools (`cmake` and `python3`). An existing `python` command is
accepted when it runs Python 3. Use `--skip-system-deps` to disable these package
installs; the required tools must already be available.

```bash
./.vim/download_plugins

# Use existing build tools without installing system packages.
./.vim/download_plugins --skip-system-deps
```

Use `:PluginUpdate` inside Vim to update plugins deliberately. YouCompleteMe also
needs compilation and build dependencies; consult the installed plugin's README
before running its `install.py` with your intended interpreter and completers.
Setup does not change your system compiler or compile it automatically.
With a linked Vim directory, downloaded plugins live in this checkout's
`.vim/bundle/`, which Git ignores.

Search uses `ag` (the Silver Searcher); fuzzy search requires the `fzf` executable.
Python linting and formatting use `flake8` and `autopep8`. Install Python tools in
your project environment and activate it before launching Vim; see
[virtual environment tips](docs/virtual_env_tips.txt).

System dependency installation on Debian/Ubuntu installs
`silversearcher-ag`, `fzf`, `flake8`, and `python3-autopep8` alongside Git and Vim.
For project-specific Python tool versions, install `flake8` and `autopep8` in
the project's virtual environment instead.

## Keybindings

The leader key is comma: `,f` searches files, `,a` starts text search, and `,n`
toggles the file tree. Vim's `.`, `s`, and `;` keep their built-in behavior. Python F5 saves
the current file and runs it using a project environment's interpreter when
available, falling back to `python3`. Python F9 toggles sandbox docstring linting
and requests a fresh ALE check. Filetype-specific mappings apply only to their
buffers.

## Sandbox linting

Ordinary Python files use flake8. Sandbox linting is opt-in: put an SSH host alias
on the first line of a `.sandbox` file in your project root. Configure the alias
and authentication in `~/.ssh/config`; passwords are not embedded in commands.
Custom ALE linters live in `.vim/ale_linters/python/`, outside the ALE checkout.

The remote sandbox must provide `/opt/shining_software/run_test`. Configure
`g:vim_sandbox_local_root` and `g:vim_sandbox_remote_root` when your local/remote
source layout differs from the Shining Software defaults. F9 requires ALE and a
configured sandbox; it does not probe or start a remote sandbox.

The local root defaults to `src/shining_software` under the marker's directory
when that directory exists, otherwise to the marker's directory. The remote root
defaults to `/opt/shining_software/shining_software`.

To load an SSH key into an existing or newly started agent in your current shell:

```bash
source ./scripts/start_ssh_agent.sh ~/.ssh/id_ed25519
```

## Check changes

The standards workflow uses the common-standards checkout pinned at
`1bdfb52e0c72b37c5c2acca5db2e8a87b43f87c5` in a sibling directory. To prepare
that checkout and the local lint tools:

```bash
git clone git@github.com:jmattern/common-standards.git ../common-standards
git -C ../common-standards checkout 1bdfb52e0c72b37c5c2acca5db2e8a87b43f87c5
python3 -m pip install -r ../common-standards/requirements.txt
python3 -m pip install yamllint==1.38.0
npm ci --prefix linters
```

Install ShellCheck 0.9.0 and shfmt 3.8.0 with your system package manager.
Run the same lint artifact handoff used by CI, followed by the standards
checks:

```bash
python3 ../common-standards/tools/standards.py --repo . --lint-only --lint-output /tmp/vim-setup-lint.json
shellcheck --rcfile=linters/.shellcheckrc .vim/download_plugins .vim/update_vim
python3 ../common-standards/tools/standards.py --repo . --lint-report /tmp/vim-setup-lint.json
```

The lint job runs ShellCheck, Markdown, and YAML linters and uploads their
result. The always-run standards job consumes that result and runs the setup
checks, Vim startup validation, and shell formatting check. CS-007 remains
failing while optional Vundle plugin revisions are mutable; see
`DEPENDENCIES.md`.

```bash
./scripts/check_setup.sh
```

Checks run offline using temporary directories and headless Vim. They cover
shell syntax, installation behavior, startup without plugins, and buffer-local
editor behavior. The same checks run in GitHub Actions.
