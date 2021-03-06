" Make sure we're in nocp mode
set nocompatible

" Pathogen, load all bundles
runtime bundle/pathogen/autoload/pathogen.vim
execute pathogen#infect()

" Built-in plugins
runtime ftplugin/man.vim
runtime macros/matchit.vim

set encoding=utf-8  " Interface encoding
set backspace=2
set history=100     " More history (: commands and / patterns)

" Display options
syntax on
set number
set cursorline
set laststatus=2    " Always show status line
set showcmd         " Show size of visual selection
set listchars=tab:>-,trail:@
set background=dark

" colorscheme
" Solarized8 works with true-color terminals, let's make use of that
set termguicolors
let g:solarized_extra_hi_groups = 1
let g:solarized_term_italics = 1
colorscheme solarized8_custom
" Toggle dark/light BG
call togglebg#map("<F3>")

" gvim options
set guifont=Source\ Code\ Pro\ Medium\ 10
" No toolbar
set guioptions-=T
" Use GTK dark theme if available, graphical headings
set guioptions+=de
" Disable blinking cursor
set guicursor+=a:blinkon0

" Mouse
set mouse=a

" Leader
let mapleader = ","
let maplocalleader = ","

" Filetype plugin/indent autoloading
filetype plugin indent on

" Indentation
set expandtab
set shiftwidth=4 " Since 7.4, sw=0 sets sw to ts, but older plugins are not aware of this
set softtabstop=4
set autoindent
" No indentation for: private/protected/public:, namespace, return type
" Align on opening parentheses, align on case label (regardless of braces)
set cinoptions=g0,N-s,t0,(0,l1

" Formatting
set formatoptions=croqnj

" Configure built-in syntax files
" Enable Doxygen in supported syntax files (see doxygen.vim for the config options)
let g:load_doxygen_syntax = 1
let g:doxygen_javadoc_autobrief = 0
" Highlight bash readline extensions
let g:readline_has_bash = 1
" Use C++ syntax for lex and yacc files
let g:lex_uses_cpp = 1
let g:yacc_uses_cpp = 1

" Ex-mode completion
set wildmode=longest,list,full
" No preview on completion (useless with clang_complete)
set completeopt=menu,menuone,longest

" Search options
set hlsearch
set incsearch
" -nH $* for vim-latex
set grepprg=grep\ --exclude=*.swp\ --exclude=tags\ --exclude=*.taghl\ --exclude-dir=doxygen\ -nH\ $*

" Copy/paste options
set pastetoggle=<F2>
set showmode

" Always diff in vertical splits
set diffopt+=vertical

" Buffer options
set switchbuf=usetab,vsplit

" mksession options
set sessionoptions=curdir,folds,globals,help,options,localoptions,tabpages,winsize

" Swap directory
set directory=~/.vimswp//


" autocmd
augroup vimrc
    autocmd!
    " C-style indentation
    " " <BS>" is a hack to keep the indentation even when immediately
    " followed by <Esc>
    autocmd FileType c,cpp,java,javascript,perl,rust,yacc
                \ setl cindent |
                \ inoremap <buffer> {<CR> {<CR>}<Esc><Up>o <BS>

    " colorcolumn is window-local, so we need to do a bit of magic to set it
    " per language in all windows
    autocmd FileType arm,asm,c,cpp,java,javascript,perl,prolog,python,rust,sh,sparc,verilog,vim,yacc
                \ let b:showcolorcolumn = 1

    autocmd BufWinEnter *
                \ if exists("b:showcolorcolumn") |
                \     if &tw != 0 | setl colorcolumn=+0 | else | setl colorcolumn=80 | endif |
                \ endif

    " Text files
    autocmd FileType tex,markdown
                \ setl linebreak showbreak=-->\  cpoptions+=n
augroup END


" Mappings
" Without this, C-c in insert mode doesn't trigger InsertLeave (useful e.g.
" in visual block insert)
inoremap <C-C>          <Esc>
nnoremap Y              y$
map      Q              gq
nnoremap gb             :bnext<CR>
nnoremap gB             :bprevious<CR>
" Make gt useful when given a count (and consistent with gT...)
nnoremap <silent> gt    :<C-U>exe 'tabnext ' . (((tabpagenr() + v:count1 - 1) % tabpagenr('$')) + 1)<CR>
" Similar to gv, but for the last pasted text
nnoremap gp             `[v`]
" Use range as the man section
nnoremap K              :<C-u>exe "Man " . v:count . " <cword>"<CR>
" Disable annoying Page Down/Up mappings
map <S-Down>            <Nop>
map <S-Up>              <Nop>
" Search in the visual area in Visual mode
xnoremap / /\%V\%V<Left><Left><Left>

" Special mappings to clear new lines (when comments are inserted)
inoremap <S-CR>         <CR><C-u>
nnoremap <Leader>o      o<C-U>
nnoremap <Leader>O      O<C-U>

" Search for selected text, forwards or backwards, in Visual mode.
" http://vim.wikia.com/wiki/Search_for_visually_selected_text
xnoremap <silent> *     :<C-U>
            \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
            \gvy/<C-R><C-R>=substitute(
            \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
            \gV:call setreg('"', old_reg, old_regtype)<CR>
xnoremap <silent> #     :<C-U>
            \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
            \gvy?<C-R><C-R>=substitute(
            \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
            \gV:call setreg('"', old_reg, old_regtype)<CR>

" Leader mappings
nnoremap <Leader>dl     :lcd %:p:h<CR>
nnoremap <Leader>dg     :cd %:p:h<CR>
nnoremap <Leader>sv     :source ~/.vimrc<CR>
nnoremap <Leader>ws     :w !sudo tee %<CR>
nnoremap <Leader>n      :nohl<CR>
nnoremap <Leader>gw     :grep! -Rw '<cword>' .<CR>
nnoremap <Leader>g0w    :grep! -Rw '<cword>' %:p:h<CR>
nnoremap <Leader>g1w    :exe "grep! -Rw '<cword>' " . simplify(expand("%:p:h") . "/..")<CR>
nnoremap <Leader>g2w    :exe "grep! -Rw '<cword>' " . simplify(expand("%:p:h") . "/../..")<CR>
nnoremap <Leader>g3w    :exe "grep! -Rw '<cword>' " . simplify(expand("%:p:h") . "/../../..")<CR>
" gW used for git grep
nnoremap <Leader>ms     :mksession! session.vim<CR>
nnoremap <Leader>dw     :w !diff % -<CR>
nnoremap <Leader>do     :only <Bar> diffoff!<CR>
" Switch header/source
function! SwitchHeader()
    if match(expand("%"), "\\v\\.h(pp)?$") != -1
        let src = substitute(glob(substitute(expand("%"), "\\v\\.h[^.]*$", ".c*", "")),
                    \ "\n", "", "")
        if !empty(src)
            exe "rightb vsp " . src
        else
            echo "No source found"
        endif
    elseif match(expand("%"), "\\v\.c(pp|xx)?$") != -1
        let header = substitute(glob(substitute(expand("%"), "\\v\\.c[^.]*$", ".h*", "")),
                    \ "\n", "", "")
        if !empty(header)
            exe "lefta vsp " . header
        else
            echo "No header found"
        endif
    endif
endfunction

nnoremap <Leader>sh     :call SwitchHeader()<CR>
" Retab and remove trailing whitespaces
nnoremap <Leader>cf     :%retab <Bar> %s/\s\+$//g <Bar> nohl<CR>
nnoremap <Leader>ss     :s/\s\+/\r/g <Bar> nohl<CR>
vnoremap <Leader>ss     :s/\s\+/\r/g <Bar> nohl<CR>
" Show highlight info for the item under the cursor
nnoremap <Leader>hi     :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name")
            \ . '> trans<' . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
            \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>
nnoremap <Leader>;      @:
" Call the last make command
nnoremap <Leader>ml     :make<Up><CR>
nnoremap <Leader>ee     :copen<CR>
nnoremap <Leader>eE     :cclose<CR>
nnoremap <Leader>EE     :cclose<CR>
" Recreate the temporary directory (useful when it gets deleted by the system)
nnoremap <Leader>ft     :call mkdir(fnamemodify(tempname(),':h'),'',0700)<CR>

" Abbreviations
" http://vim.wikia.com/wiki/Replace_a_builtin_command_using_cabbrev
function! CmdCabbr(abbreviation, expansion)
    execute 'cabbr ' . a:abbreviation . ' <c-r>=getcmdpos() == 1 && getcmdtype()
            \ == ":" ? "' . a:expansion . '" : "' . a:abbreviation . '"<CR>'
endfunction

call CmdCabbr('diffs', 'vert diffsplit')
call CmdCabbr('h', 'vert rightb help')
call CmdCabbr('ht', 'tab help')
call CmdCabbr('vsb', 'vert sbuffer')
call CmdCabbr('tsb', 'tab sbuffer')


" Commands
" Original version: http://stackoverflow.com/a/10884567
function! MoveFile(newspec)
    let old = expand('%')
    let new = a:newspec
    if isdirectory(a:newspec)
        let new .= '/' . expand('%:t')
    endif
    try
        exe 'sav' fnameescape(simplify(new))
        call delete(old)
    endtry
endfunction
command! -nargs=1 -complete=file -bar MoveFile call MoveFile('<args>')

" http://stackoverflow.com/a/8459043
function! DeleteHiddenBuffers()
    let tpbl = []
    call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
    for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && index(tpbl, v:val)==-1')
        silent execute 'bdelete' buf
    endfor
endfunction
command! -nargs=0 -bar DeleteHiddenBuffers call DeleteHiddenBuffers()

function! DemangleAllCppSymbols()
    %s/\<_Z\w\+/\=systemlist("c++filt " . submatch(0))[0]/g
endfunction
command! -nargs=0 -bar DemangleAllCppSymbols call DemangleAllCppSymbols()


" Additional highlighting links
hi link markdownCode Underlined
hi link doxygenVerbatimRegion Underlined
hi! link vimIsCommand Identifier
" Override adaSpecial highlighting (mainly highlights delimiters)
hi link adaSpecial Delimiter


" Plugins

" Netrw
let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+'

" TagHighlight
map <Leader>tr :UpdateTypesFile<CR>
if ! exists('g:TagHighlightSettings')
    let g:TagHighlightSettings = {}
endif
let g:TagHighlightSettings['IncludeLocals'] = 1
" Per-project exclude file
let g:TagHighlightSettings['CtagsExtraArguments'] = ['--exclude=@.taghl_exclude']
let g:TagHighlightSettings['LanguageDetectionMethods'] = ['FileType']
" Looks weird otherwise
hi! link CTagsConstant EnumerationValue

" clang_complete
let g:clang_auto_select = 1
let g:clang_complete_auto = 0
let g:clang_complete_copen = 0
let g:clang_complete_hl_errors = 0
let g:clang_snippets = 1
let g:clang_trailing_placeholder = 1
let g:clang_use_library = 1
let g:clang_complete_macros = 1
let g:clang_complete_patterns = 1
nnoremap <Leader>aq :call g:ClangUpdateQuickFix() <bar> cc <bar> clist<CR>

" clang_indexer
nnoremap <Leader>ar :call ClangGetReferences()<CR>
nnoremap <Leader>ad :call ClangGetDeclarations()<CR>
nnoremap <Leader>as :call ClangGetSubclasses()<CR>

" Syntastic
" For setting project paths in vimrc_specific, to use with an autocmd, like:
" au Filetype cpp call AddSyntasticClangPath('cpp', '/path/', 1)
" Pass 1 as the third argument to extract include paths from .clang_complete

function! AddSyntasticClangPath(language, project_path, ...)
    let override_path = a:0 >= 1 ? a:1 : 0
    if stridx(expand('%:p'), a:project_path) == 0
        let config_path = a:project_path . '.clang_complete'
        exe 'let g:syntastic_' . a:language . '_config_file="' . config_path . '"'
        if override_path
            setl path=.
            for line in readfile(config_path)
                if line =~ '^-I'
                    let &l:path .= substitute(line, '^-I', ',', '')
                endif
            endfor
            setl path+=,,
        endif
    endif
endfunction

function! SyntasticToggleDebug()
    if g:syntastic_debug == 0
        let g:syntastic_debug = 1 + 2 + 32
        let g:syntastic_debug_file = '/tmp/syntastic.log'
    else
        let g:syntastic_debug = 0
        unlet! g:syntastic_debug_file
    endif
endfunction
command! -bar SyntasticToggleDebug call SyntasticToggleDebug()

" Default is Todo, too close to Error
hi! link SyntasticWarningSign Underlined
" Default LaTeX checker is a PITA, use chktex instead
let syntastic_tex_checkers = ['chktex']
" Silence:
" - "Command terminated with space.", this is excessively noisy for
"   commands followed by a newline
" - "You should put a space in front of parenthesis.", problematic with
"   function calls
let syntastic_tex_chktex_args='-n 1 -n 36'
" Don't use shellcheck even if available
let syntastic_sh_checkers = ['sh']
" Default C/C++ options
let syntastic_c_check_header = 1
let syntastic_cpp_check_header = 1
let syntastic_c_compiler_options = '-std=gnu99 -Wall -Wextra'
let syntastic_cpp_compiler_options = '-std=c++1y -Wall -Wextra'
" Other checker options
let syntastic_sh_sh_args='-O extglob'

" Supertab
let g:SuperTabDefaultCompletionType = 'context'
let g:SuperTabContextDefaultCompletionType = "<c-n>"
let g:SuperTabCompletionContexts = ['s:ContextDiscover', 's:ContextText']
let g:SuperTabContextDiscoverDiscovery =
            \ ["&omnifunc:<c-x><c-o>", "&completefunc:<c-x><c-u>"]
let g:SuperTabRetainCompletionDuration = 'completion'
let g:SuperTabLongestEnhanced = 1
let g:SuperTabLongestHighlight = 1
let g:SuperTabCrMapping = 0 " Compatbility issue with delimitMate

" Tagbar
let g:tagbar_compact = 1
nnoremap <Leader>tt :TagbarToggle<CR>

" delimitMate
imap <C-f> <Plug>delimitMateS-Tab
imap <C-b> <Plug>delimitMateJumpMany
let delimitMate_expand_space = 1

" NERD commenter
let g:NERDCustomDelimiters = { 'c': { 'left': '//',
                                \ 'leftAlt': '/*', 'rightAlt': '*/' } }
let g:NERDSpaceDelims = 1

" vim-latex
let g:tex_flavor = 'latex'

" Fugitive
nnoremap <Leader>gs :Gstatus <Bar> wincmd K<CR>
nnoremap <Leader>gt :tabe % <Bar> Gstatus <Bar> wincmd K<CR>
nnoremap <Leader>gd :Gdiff<CR>
" gw used for plain grep
nnoremap <Leader>gW :Ggrep! -w '<cword>' .<CR>

" airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_splits = 0
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#tabline#right_sep = ''
let g:airline#extensions#tabline#right_alt_sep = ''
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline#extensions#whitespace#mixed_indent_algo = 1
let g:airline_solarized_normal_green = 1
let g:airline_solarized_dark_inactive_border = 1

" Jedi
let g:jedi#auto_vim_configuration = 0
let g:jedi#popup_on_dot = 0

let g:jedi#completions_command = ''
let g:jedi#goto_assignments_command = '<C-]>'
let g:jedi#goto_definitions_command = '<Leader>jd'
let g:jedi#rename_command = '<Leader>jr'
let g:jedi#usages_command = '<Leader>ju'

" LaTeX Box
let g:LatexBox_Folding = 1
let g:LatexBox_fold_envs = 1
let g:LatexBox_fold_automatic = 0
let g:LatexBox_quickfix = 4
let g:LatexBox_latexmk_preview_continuously = 1
" Must be kept in sync with $out_dir in ~/.latexmkrc
let g:LatexBox_build_dir = './out'

" javacomplete2
" We need to be very explicit if the default SDK is not JDK8
let s:java_home = empty($JAVA_HOME) ? "/usr/lib/jvm/java-8-openjdk" : $JAVA_HOME
let g:java_classpath = s:java_home . "/lib"
let g:JavaComplete_JvmLauncher = s:java_home . "/bin/java"
let g:JavaComplete_JavaCompiler = s:java_home . "/bin/javac"

" logcat
hi! logcatLevelFatal guifg=Red gui=bold ctermfg=Red term=bold

" neoman
let g:neoman_tab_after = 1


" Source specific
if filereadable($HOME . "/.vimrc_specific")
    source $HOME/.vimrc_specific
endif

" vim: set ts=4 sw=4 sts=4 et:
