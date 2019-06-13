" Description: Docstring checker with pylint on sandbox

call ale#Set('python_pylint_executable', 'doclint')
call ale#Set('python_pylint_options', '')
call ale#Set('python_pylint_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('python_pylint_change_directory', 1)
call ale#Set('python_pylint_auto_pipenv', 0)

function! ale_linters#python#doclint#GetCommand(buffer) abort
    let l:local_path = expand('#' . a:buffer . ':p')
    let l:remote_path =  substitute(l:local_path, '^.*shining_software/src/shining_software/','/opt/shining_software/shining_software/', '')
    return 'sshpass -p brain ssh -o StrictHostKeyChecking=no brain@sandbox'
    \   . ' "/opt/shining_software/run_test doc ' . l:remote_path . '"'
endfunction

function! ale_linters#python#doclint#Handle(buffer, lines) abort
    " Matches patterns like the following:
    "
    " test.py:4:4: W0101 (unreachable) Unreachable code
    let l:pattern = '\v^([a-zA-Z]): ?(\d+), ?(\d+): (.+) \((.+)\)$'
    let l:output = []
    for l:match in ale#util#GetMatches(a:lines, l:pattern)
	echo l:match
        call add(l:output, {
        \   'lnum': l:match[2] + 0,
        \   'col': l:match[3] + 1,
        \   'text': l:match[4],
        \   'code': l:match[5],
        \   'type': l:match[1],
        \})
    endfor
    return l:output
endfunction


call ale#linter#Define('python', {
\   'name': 'doclint',
\   'executable': '/bin/bash',
\   'command_callback': 'ale_linters#python#doclint#GetCommand',
\   'callback': 'ale_linters#python#doclint#Handle',
\   'lint_file': 1,
\})
