# vim_setup

Vim and tmux configuration with optional plugins and project-specific Python
sandbox linting.

## Install

Run from any directory, using the path to your checkout:

```bash
/path/to/vim_setup/install.sh
```

By default, installation links the checkout's Vim, tmux, and flake8 configuration
into your home directory. Existing targets move to timestamped `.backup.*` paths;
rerunning installation leaves matching links alone. Changes in this checkout
immediately apply to linked configurations. Keep the checkout in place. Other
files in `~/.config` are preserved.

```bash
# Copy configuration instead of linking it.
./install.sh --copy

# Try installation in an isolated directory.
./install.sh --target-dir /tmp/vim-setup-demo

# Also install plugins (requires network access, Git, and Vim).
./install.sh --plugins

# Explicitly install Git and Vim using apt-get and sudo.
./install.sh --install-system-deps
```

Plain installation uses Bash and standard filesystem tools; it does not install
packages or contact the network. `scripts/unpack_setup.sh` provides configuration
installation without the optional dependency/plugin steps.

To roll back, move the installed target aside and move its printed backup path
back to the original location. For example, move `~/.vimrc` to `~/.vimrc.disabled`,
then move `~/.vimrc.backup.TIMESTAMP` to `~/.vimrc`. Repeat for each target you want
to restore. Keep any new plugin files you want before restoring a Vim directory.

## Plugins and tools

The downloader bootstraps Vundle, then lets Vundle evaluate `.vim/plugins.vim`
and install its plugins. Vim starts without downloaded plugins; plugin commands
become available after installation.

```bash
./.vim/download_plugins
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

```bash
./scripts/check_setup.sh
```

Checks run offline using temporary directories and headless Vim. They cover
shell syntax, installation behavior, startup without plugins, and buffer-local
editor behavior. The same checks run in GitHub Actions.
