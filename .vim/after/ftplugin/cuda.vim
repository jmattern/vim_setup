setlocal expandtab shiftwidth=4 softtabstop=4
inoremap <buffer> {<CR> {<CR>}<Esc>ko
function! VimSetupCudaUndo() abort
    silent! iunmap <buffer> {<CR>
endfunction
let b:undo_ftplugin = get(b:, 'undo_ftplugin', '') . (empty(get(b:, 'undo_ftplugin', '')) ? '' : ' | ') . 'setlocal expandtab< shiftwidth< softtabstop< | call VimSetupCudaUndo()'
