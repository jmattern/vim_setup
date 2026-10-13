runtime autoload/vim_setup/sandbox_linter.vim
call ale#linter#Define('python', {
\   'name': 'doclint',
\   'executable': 'ssh',
\   'command_callback': 'VimSetupDocLintCommand',
\   'callback': 'VimSetupSandboxHandle',
\   'lint_file': 1,
\})

function! VimSetupDocLintCommand(buffer) abort
    return VimSetupSandboxCommand(a:buffer, 'doc')
endfunction
