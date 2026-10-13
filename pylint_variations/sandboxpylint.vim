" Compatibility wrapper: the maintained ALE linter lives under .vim/ale_linters.
let s:vim_runtime = fnamemodify(expand('<sfile>:p'), ':h:h') . '/.vim'
execute 'set runtimepath^=' . fnameescape(s:vim_runtime)
execute 'source ' . fnameescape(s:vim_runtime . '/ale_linters/python/sandboxpylint.vim')
