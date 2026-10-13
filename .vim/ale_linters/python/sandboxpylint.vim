runtime autoload/vim_setup/sandbox_linter.vim
call ale#linter#Define('python', {
\   'name': 'sandboxpylint',
\   'executable': 'ssh',
\   'command_callback': 'VimSetupSandboxPylintCommand',
\   'callback': 'VimSetupSandboxHandle',
\   'lint_file': 1,
\})

function! VimSetupSandboxPylintCommand(buffer) abort
    return VimSetupSandboxCommand(a:buffer, 'pylint')
endfunction
