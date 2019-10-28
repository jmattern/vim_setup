" Description: pylint on sandbox

call ale#Set('python_pylint_executable', 'sandboxpylint')
call ale#Set('python_pylint_options', '')
call ale#Set('python_pylint_use_global', get(g:, 'ale_use_global_executables', 0))
call ale#Set('python_pylint_change_directory', 1)
call ale#Set('python_pylint_auto_pipenv', 0)

function! ale_linters#python#sandboxpylint#GetCommand(buffer) abort
    let l:local_path = expand('#' . a:buffer . ':p')
    let l:remote_path =  substitute(l:local_path, '^.*shining_software/src/shining_software/','/opt/shining_software/shining_software/', '')
    " Check if .sandbox file exists for multiple sandboxes
    let l:sandboxname = 'sandbox'
    let l:root_path = substitute(l:local_path, 'src/shining_software/.*', '', '')
    let l:sandbox_file_path = l:root_path . '.sandbox'
    if filereadable(l:sandbox_file_path)
        let l:sandboxname = readfile(l:sandbox_file_path)[0]
    endif

    " return 'sshpass -p brain ssh -o StrictHostKeyChecking=no brain@sandbox'
    " \   . ' "source /opt/shining_software/use_repo.sh; pylint --rcfile=/opt/shining_software/pylint_rc'
    " \   . ' --output-format text --reports n'
    " \   . ' ' . l:remote_path . '"'
    " return 'sshpass -p brain ssh -o StrictHostKeyChecking=no brain@sandbox'
    " \   . ' "/opt/shining_software/test_pylint -f' . l:remote_path . '"'
    return 'sshpass -p brain ssh -o StrictHostKeyChecking=no brain@' . l:sandboxname
    \   . ' "/opt/shining_software/run_test pylint ' . l:remote_path . '"'
endfunction

function! ale_linters#python#sandboxpylint#Handle(buffer, lines) abort
    " Matches patterns like the following:
    "
    " test.py:4:4: W0101 (unreachable) Unreachable code
    " let l:pattern = '\v^[a-zA-Z]?:?[^:]+:(\d+):(\d+): ([[:alnum:]]+) \(([^(]*)\) (.*)$'
    let l:pattern = '\v^([a-zA-Z]): ?(\d+), ?(\d+): (.+) \((.+)\)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
	echo l:match
        "let l:failed = append(0, l:match)
        " let l:code = l:match[3]
        " if (l:code is# 'C0303')
        " \ && !ale#Var(a:buffer, 'warn_about_trailing_whitespace')
            " " Skip warnings for trailing whitespace if the option is off.
            " continue
        " endif
        " if l:code is# 'I0011'
            " " Skip 'Locally disabling' message
             " continue
        " endif
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
\   'name': 'sandboxpylint',
\   'executable': '/bin/bash',
\   'command_callback': 'ale_linters#python#sandboxpylint#GetCommand',
\   'callback': 'ale_linters#python#sandboxpylint#Handle',
\   'lint_file': 1,
\})
