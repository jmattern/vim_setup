" Author: keith <k@keith.so>
" Description: pylint for python files
"
call ale#Set('python_pylint_executable', 'sandboxpylint')
call ale#Set('python_pylint_options', '')
call ale#Set('python_pylint_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('python_pylint_change_directory', 1)
call ale#Set('python_pylint_auto_pipenv', 0)

function! ale_linters#python#pylint#GetCommand(buffer) abort
    let l:local_path = expand('#' . a:buffer . ':p')
    let l:remote_path =  substitute(l:local_path, '^.*shining_software/src/shining_software/','/opt/shining_software/shining_software/', '')

    return 'sshpass -p brain ssh brain@sandbox'
    \   . ' "source /opt/shining_software/use_repo.sh; pylint --rcfile=/opt/shining_software/pylint_rc --jobs=1 --load-plugins=shining_software.py2to3_fixers.import_builder --disable=all --enable=imports-analysis'
    \   . ' ' . l:remote_path . '"'
endfunction

function! ale_linters#python#pylint#Handle(buffer, lines) abort
    " Matches patterns like the following:
    "
    " test.py:4:4: W0101 (unreachable) Unreachable code
    let l:pattern = '\v^[a-zA-Z]?:?[^:]+:(\d+):(\d+): ([[:alnum:]]+) \(([^(]*)\) (.*)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        "let l:failed = append(0, l:match)
        let l:code = l:match[3]

        if (l:code is# 'C0303')
        \ && !ale#Var(a:buffer, 'warn_about_trailing_whitespace')
            " Skip warnings for trailing whitespace if the option is off.
            continue
        endif

        if l:code is# 'I0011'
            " Skip 'Locally disabling' message
             continue
        endif

        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'col': l:match[2] + 1,
        \   'text': l:match[5],
        \   'code': l:match[4],
        \   'type': l:code[:0] is# 'E' ? 'E' : 'W',
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('python', {
\   'name': 'sandboxpylint',
\   'executable': '/bin/bash',
\   'command_callback': 'ale_linters#python#pylint#GetCommand',
\   'callback': 'ale_linters#python#pylint#Handle',
\   'lint_file': 1,
\})
