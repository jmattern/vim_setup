function! VimSetupFindFileInParents(name, directory) abort
    return findfile(a:name, escape(a:directory, " ,;\\") . ';')
endfunction

function! VimSetupSandboxMarker(buffer) abort
    let l:file = bufname(a:buffer)
    if empty(l:file)
        return ''
    endif
    return VimSetupFindFileInParents('.sandbox', fnamemodify(fnamemodify(l:file, ':p'), ':h'))
endfunction

function! VimSetupSandboxHost(buffer) abort
    let l:marker = VimSetupSandboxMarker(a:buffer)
    if empty(l:marker) || !filereadable(l:marker)
        return ''
    endif
    let l:lines = readfile(l:marker, '', 1)
    let l:host = empty(l:lines) ? '' : substitute(l:lines[0], '^\s\+\|\s\+$', '', 'g')
    " A marker is one SSH config host alias, never a command or credential.
    return l:host =~# '^[A-Za-z0-9_][A-Za-z0-9_.@-]*$' ? l:host : ''
endfunction

function! VimSetupSandboxCommand(buffer, mode) abort
    if index(['pylint', 'doc'], a:mode) < 0
        return ''
    endif
    let l:host = VimSetupSandboxHost(a:buffer)
    let l:marker = VimSetupSandboxMarker(a:buffer)
    if empty(l:host) || empty(l:marker)
        return ''
    endif

    let l:file = fnamemodify(bufname(a:buffer), ':p')
    let l:project_root = fnamemodify(l:marker, ':h')
    let l:default_local_root = isdirectory(l:project_root . '/src/shining_software')
    \   ? l:project_root . '/src/shining_software'
    \   : l:project_root
    let l:local_root = get(g:, 'vim_sandbox_local_root', l:default_local_root)
    let l:local_root = substitute(fnamemodify(l:local_root, ':p'), '/$', '', '')
    let l:prefix = l:local_root . '/'
    if stridx(l:file, l:prefix) != 0
        return ''
    endif
    let l:relative = strpart(l:file, strlen(l:prefix))
    let l:remote_root = substitute(get(g:, 'vim_sandbox_remote_root', '/opt/shining_software/shining_software'), '/$', '', '')
    let l:remote_file = l:remote_root . '/' . l:relative
    let l:remote_command = '/opt/shining_software/run_test ' . a:mode . ' ' . shellescape(l:remote_file)
    return 'ssh ' . shellescape(l:host) . ' ' . shellescape(l:remote_command)
endfunction

function! VimSetupSandboxHandle(buffer, lines) abort
    let l:pattern = '^\([A-Z]\):\s\?\(\d\+\),\s\?\(\d\+\): \(.*\) (\([^)]\+\))$'
    let l:output = []
    for l:line in a:lines
        let l:match = matchlist(l:line, l:pattern)
        if empty(l:match)
            continue
        endif
        call add(l:output, {
        \   'lnum': str2nr(l:match[2]),
        \   'col': str2nr(l:match[3]) + 1,
        \   'text': l:match[4],
        \   'code': l:match[5],
        \   'type': l:match[1],
        \})
    endfor
    return l:output
endfunction
