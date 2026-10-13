setlocal expandtab shiftwidth=4 softtabstop=4
let b:python_space_error_highlight = 0
runtime autoload/vim_setup/sandbox_linter.vim

function! s:PythonSandboxEnabled() abort
    return !empty(VimSetupSandboxHost(bufnr('%')))
endfunction

function! VimSetupRunPython() abort
    if empty(expand('%:p'))
        echoerr 'Save the Python file before running it'
        return
    endif
    update
    let l:file = expand('%:p')
    let l:project_python = VimSetupFindFileInParents('.venv/bin/python', expand('%:p:h'))
    if empty(l:project_python) || !executable(l:project_python)
        let l:project_python = VimSetupFindFileInParents('venv/bin/python', expand('%:p:h'))
    endif
    if empty(l:project_python) || !executable(l:project_python)
        let l:project_python = ''
    endif
    let l:python = !empty(l:project_python) ? l:project_python : 'python3'
    execute '!' . shellescape(l:python) . ' ' . shellescape(l:file)
endfunction

function! VimSetupToggleDocLint() abort
    if exists(':ALELint') != 2
        echo 'ALE is not available'
        return
    endif
    if !s:PythonSandboxEnabled()
        echo 'No .sandbox project marker found'
        return
    endif
    if !exists('b:ale_linters')
        let b:ale_linters = copy(get(get(g:, 'ale_linters', {}), 'python', ['flake8']))
    endif
    let l:index = index(b:ale_linters, 'doclint')
    if l:index < 0
        call add(b:ale_linters, 'doclint')
    else
        call remove(b:ale_linters, l:index)
    endif
    ALELint
endfunction

function! VimSetupPythonUndo() abort
    silent! nunmap <buffer> <F5>
    silent! nunmap <buffer> <F9>
    unlet! b:python_space_error_highlight b:ale_linters
endfunction

if exists(':ALELint') == 2
    let b:ale_linters = copy(get(get(g:, 'ale_linters', {}), 'python', ['flake8']))
    if s:PythonSandboxEnabled()
        call add(b:ale_linters, 'sandboxpylint')
    endif
endif

nnoremap <buffer> <F5> :call VimSetupRunPython()<CR>
nnoremap <buffer> <F9> :call VimSetupToggleDocLint()<CR>
let b:undo_ftplugin = get(b:, 'undo_ftplugin', '') . (empty(get(b:, 'undo_ftplugin', '')) ? '' : ' | ') . 'setlocal expandtab< shiftwidth< softtabstop< | call VimSetupPythonUndo()'
