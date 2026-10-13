#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"

for script in "$REPO_DIR/install.sh" "$REPO_DIR"/scripts/*.sh; do
    bash -n "$script"
done
for script in "$REPO_DIR/.vim/download_plugins" "$REPO_DIR/.vim/update_vim"; do
    bash -n "$script"
done
bash "$REPO_DIR/.vim/download_plugins" --help >/dev/null
if command -v shellcheck >/dev/null 2>&1; then
    shellcheck "$REPO_DIR/install.sh" "$REPO_DIR"/scripts/*.sh "$REPO_DIR/.vim/download_plugins" "$REPO_DIR/.vim/update_vim"
fi

command -v vim >/dev/null 2>&1 || {
    printf '%s\n' 'vim is required for setup checks' >&2
    exit 1
}

work_dir=$(mktemp -d)
trap 'rm -rf -- "$work_dir"' EXIT
outside_dir="$work_dir/unrelated-cwd"
target_dir="$work_dir/symlink-target"
copy_dir="$work_dir/copy-target"
mkdir -p -- "$outside_dir" "$target_dir" "$copy_dir"
mkdir -p -- "$target_dir/.config"
printf 'keep this file\n' > "$target_dir/.config/unmanaged"

(
    cd -- "$outside_dir"
    "$REPO_DIR/install.sh" --target-dir "$target_dir"
)

for name in .vim .vimrc .tmux.conf; do
    if [[ -e "$REPO_DIR/$name" ]]; then
        [[ -L "$target_dir/$name" ]] || { printf 'Expected symlink: %s\n' "$name" >&2; exit 1; }
        [[ "$(readlink -- "$target_dir/$name")" == "$REPO_DIR/$name" ]] || {
            printf 'Symlink points to wrong source: %s\n' "$name" >&2
            exit 1
        }
    fi
done
if [[ -e "$REPO_DIR/.config/flake8" ]]; then
    [[ -L "$target_dir/.config/flake8" ]] || { printf '%s\n' 'Expected .config/flake8 symlink' >&2; exit 1; }
    [[ "$(readlink -- "$target_dir/.config/flake8")" == "$REPO_DIR/.config/flake8" ]]
fi
[[ "$(cat "$target_dir/.config/unmanaged")" == 'keep this file' ]]

# A second run must preserve the existing installation without making backups.
backup_count=$(find "$target_dir" -maxdepth 1 -name '*.backup.*' -print | wc -l)
"$REPO_DIR/install.sh" --target-dir "$target_dir" >/dev/null
[[ "$(find "$target_dir" -maxdepth 1 -name '*.backup.*' -print | wc -l)" == "$backup_count" ]]

# Existing files are preserved before replacement, including a dangling symlink.
rm -- "$target_dir/.tmux.conf"
printf 'user data\n' > "$target_dir/.tmux.conf"
rm -- "$target_dir/.vimrc"
ln -s "$work_dir/missing-target" "$target_dir/.vimrc"
bash "$REPO_DIR/scripts/unpack_setup.sh" --target-dir "$target_dir" >/dev/null
[[ -f "$target_dir/.tmux.conf" && -L "$target_dir/.vimrc" ]]
cmp -s "$target_dir/.tmux.conf" "$REPO_DIR/.tmux.conf"
[[ "$(readlink -- "$target_dir/.vimrc")" == "$REPO_DIR/.vimrc" ]]
tmux_backup=$(find "$target_dir" -maxdepth 1 -name '.tmux.conf.backup.*' -print -quit)
vimrc_backup=$(find "$target_dir" -maxdepth 1 -name '.vimrc.backup.*' -print -quit)
[[ -n "$tmux_backup" && -f "$tmux_backup" ]]
[[ "$(cat "$tmux_backup")" == 'user data' ]]
[[ -n "$vimrc_backup" && -L "$vimrc_backup" ]]
[[ "$(readlink -- "$vimrc_backup")" == "$work_dir/missing-target" ]]

# Copy mode creates independent files and supports a run from another cwd.
(
    cd -- "$outside_dir"
    bash "$REPO_DIR/scripts/unpack_setup.sh" --copy --target-dir "$copy_dir" >/dev/null
)
for name in .vim .vimrc .tmux.conf; do
    if [[ -e "$REPO_DIR/$name" ]]; then
        [[ ! -L "$copy_dir/$name" && -e "$copy_dir/$name" ]] || {
            printf 'Expected copied path: %s\n' "$name" >&2
            exit 1
        }
    fi
done
if [[ -e "$REPO_DIR/.config/flake8" ]]; then
    [[ ! -L "$copy_dir/.config/flake8" && -f "$copy_dir/.config/flake8" ]] || {
        printf '%s\n' 'Expected copied .config/flake8 file' >&2
        exit 1
    }
fi
if [[ -f "$REPO_DIR/.tmux.conf" ]]; then
    printf '\n# local copy check\n' >> "$copy_dir/.tmux.conf"
    ! cmp -s "$REPO_DIR/.tmux.conf" "$copy_dir/.tmux.conf"
fi

# This directory is an independent copy inside the disposable fixture.
# Exclude installed plugins so the smoke check stays offline and reproducible.
rm -rf -- "$copy_dir/.vim/bundle"

# Exercise symlinked source-directory rejection against a disposable checkout.
guard_source="$work_dir/source-checkout"
mkdir -p -- "$guard_source/scripts"
cp -a -- "$REPO_DIR/.vim" "$REPO_DIR/.vimrc" "$REPO_DIR/.tmux.conf" "$REPO_DIR/.config" "$guard_source/"
cp -- "$REPO_DIR/scripts/install_setup.sh" "$REPO_DIR/scripts/unpack_setup.sh" "$guard_source/scripts/"
source_alias="$work_dir/source-alias"
ln -s -- "$guard_source" "$source_alias"
for installer in install_setup.sh unpack_setup.sh; do
    if bash "$guard_source/scripts/$installer" --target-dir "$source_alias" >/dev/null 2>&1; then
        printf 'Expected %s to reject a symlink alias of its source checkout\n' "$installer" >&2
        exit 1
    else
        status=$?
        [[ "$status" == 2 ]] || exit "$status"
    fi
    [[ -d "$guard_source/.vim" && -f "$guard_source/.vimrc" && -f "$guard_source/.tmux.conf" ]]
done

if [[ -f "$REPO_DIR/.vimrc" ]]; then
    # Use an empty runtime environment, so this checks startup without installed plugins.
    sandbox_project="$work_dir/project space's"
    call_log="$work_dir/interpreter call.log"
    mkdir -p -- "$sandbox_project/.venv/bin"
    printf 'test-host\n' > "$sandbox_project/.sandbox"
    cat > "$sandbox_project/.venv/bin/python" <<'SH'
#!/usr/bin/env bash
printf '%s\n' "$0" "$@" > "$SETUP_CALL_LOG"
SH
    chmod +x -- "$sandbox_project/.venv/bin/python"
    cat > "$work_dir/check.vim" <<'VIM'
let s:repo = $SETUP_REPO
let s:sandbox = $SETUP_SANDBOX_PROJECT
let s:target = $SETUP_TARGET
let s:home_prefix = expand('~') . '/'
let &runtimepath = join(filter(split(&runtimepath, ','), 'stridx(v:val, s:home_prefix) != 0'), ',')
execute 'source ' . fnameescape(s:target . '/.vimrc')
if index(split(&runtimepath, ','), s:target . '/.vim') < 0 | cquit 30 | endif
execute 'source ' . fnameescape(s:repo . '/.vim/autoload/vim_setup/sandbox_linter.vim')
let g:setup_ale_calls = 0
command! ALELint let g:setup_ale_calls += 1
enew
set ft=python
if &l:expandtab != 1 | cquit 10 | endif
if &l:shiftwidth != 4 | cquit 11 | endif
if empty(maparg('<F5>', 'n')) | cquit 12 | endif
if empty(maparg('<F9>', 'n')) | cquit 15 | endif
let s:statusline = &statusline
let s:quickfix_autocmds = execute('autocmd vim_setup_quickfix')
execute 'source ' . fnameescape(s:target . '/.vimrc')
if &statusline !=# s:statusline | cquit 16 | endif
if execute('autocmd vim_setup_quickfix') !=# s:quickfix_autocmds | cquit 17 | endif
if !empty(maparg(';', 'n')) || !empty(maparg('s', 'n')) || !empty(maparg('.', 'n')) | cquit 18 | endif
set ft=tex
if &l:shiftwidth != 2 | cquit 13 | endif
if !empty(maparg('<F5>', 'n')) || !empty(maparg('<F9>', 'n')) | cquit 19 | endif
set ft=c
if empty(maparg('{<CR>', 'i')) | cquit 20 | endif
set ft=text
if &l:shiftwidth != &g:shiftwidth | cquit 14 | endif
if !empty(maparg('<F5>', 'n')) || !empty(maparg('<F9>', 'n')) | cquit 21 | endif
if !empty(maparg('{<CR>', 'i')) | cquit 22 | endif
let s:sandbox_buffer = bufadd(s:sandbox . "/file name's.py")
if VimSetupSandboxHost(s:sandbox_buffer) !=# 'test-host' | cquit 23 | endif
let s:remote_file = "/opt/shining_software/shining_software/file name's.py"
let s:remote = '/opt/shining_software/run_test pylint ' . shellescape(s:remote_file)
let s:expected = 'ssh ' . shellescape('test-host') . ' ' . shellescape(s:remote)
if VimSetupSandboxCommand(s:sandbox_buffer, 'pylint') !=# s:expected | cquit 24 | endif
if VimSetupSandboxCommand(s:sandbox_buffer, 'doc') !~# 'run_test doc ' | cquit 25 | endif
call writefile(['-oProxyCommand=bad'], s:sandbox . '/.sandbox')
if !empty(VimSetupSandboxHost(s:sandbox_buffer)) | cquit 26 | endif
if !empty(VimSetupSandboxCommand(s:sandbox_buffer, 'pylint')) | cquit 27 | endif
call delete(s:sandbox . '/.sandbox')
if !empty(VimSetupSandboxHost(s:sandbox_buffer)) | cquit 28 | endif
let s:diagnostics = VimSetupSandboxHandle(s:sandbox_buffer, ['E: 4, 2: Bad thing (E123)', 'noise'])
if len(s:diagnostics) != 1 || s:diagnostics[0].lnum != 4 || s:diagnostics[0].col != 3 | cquit 29 | endif
call writefile(['test-host'], s:sandbox . '/.sandbox')
execute 'buffer ' . s:sandbox_buffer
set ft=python
call setline(1, 'print("saved")')
call VimSetupRunPython()
let s:call_log = readfile($SETUP_CALL_LOG)
if len(s:call_log) != 2 | cquit 31 | endif
if s:call_log[0] !=# s:sandbox . '/.venv/bin/python' | cquit 32 | endif
if s:call_log[1] !=# s:sandbox . "/file name's.py" | cquit 33 | endif
if readfile(s:sandbox . "/file name's.py") !=# ['print("saved")'] | cquit 34 | endif
call VimSetupToggleDocLint()
if index(b:ale_linters, 'doclint') < 0 || g:setup_ale_calls != 1 | cquit 35 | endif
call VimSetupToggleDocLint()
if index(b:ale_linters, 'doclint') >= 0 || g:setup_ale_calls != 2 | cquit 36 | endif
set ft=tex
if !empty(maparg('<F5>', 'n')) || !empty(maparg('<F9>', 'n')) | cquit 37 | endif
qa!
VIM
    if SETUP_REPO="$REPO_DIR" SETUP_TARGET="$copy_dir" SETUP_SANDBOX_PROJECT="$sandbox_project" SETUP_CALL_LOG="$call_log" vim -Nu NONE -i NONE -n -es -V1"$work_dir/vim.log" -S "$work_dir/check.vim"; then
        :
    else
        vim_status=$?
        cat "$work_dir/vim.log" >&2
        printf 'Headless Vim check failed with status %s\n' "$vim_status" >&2
        exit "$vim_status"
    fi
else
    printf '%s\n' '.vimrc is required for headless Vim checks' >&2
    exit 1
fi

printf '%s\n' 'Setup checks passed.'
