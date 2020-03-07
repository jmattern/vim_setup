" this is mostly a matter of taste. but LaTeX looks good with just a bit
" of indentation.
set sw=2 textwidth=78

"Turn on auto-formatting for paragraphs (q stands for equation, t stands for text)
nnoremap <leader>q :set formatoptions=<CR>
nnoremap <leader>t :set formatoptions=atcql<CR>

"Mapping to reformat current paragraph
noremap R gqap

" TIP: if you write your \label's as \label{fig:something}, then if you
" type in \ref{fig: and press <C-n> you will automatically cycle through
" all the figure labels. Very useful!
"set iskeyword+=: <--- This aint working
"Instead we use:
let g:tex_isk = '48-57,a-z,A-Z,192-255,:,_'

let Tex_FoldedSections = "part,chapter,section"

"Compile pdf by dvi->ps->pdf
let g:Tex_FormatDependency_pdf = 'dvi,ps,pdf'

"let g:Tex_MultipleCompileFormats = 'dvi,pdf'
let g:Tex_CompileRule_pdf = 'ps2pdf $*.ps'
let g:Tex_CompileRule_ps = 'dvips -Ppdf -t letter -o $*.ps $*.dvi'

"Add a ,la mapping to compile (,ll) latex code and view it (,lv)
"nmap <leader>la <leader>ll <Bar> <leader>lv
"nmap <leader>la <leader>lv && :echo "hello WTF"<CR>

"Turn auto-formatting of long lines off
set formatoptions+=l

"Filter stuck float warning
let g:Tex_IgnoredWarnings = 
\"Underfull\n".
\"Overfull\n".
\"specifier changed to\n".
\"You have requested\n".
\"Missing number, treated as zero.\n".
\"There were undefined references\n".
\"Citation %.%# undefined\n".
\"float is stuck"

let g:Tex_IgnoreLevel = 8