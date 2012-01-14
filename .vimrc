"--------------------------------------------------
" Maps
"-------------------------------------------------- 
map <c-n> :bn<cr>
map <c-p> :bp<cr>
map <F2> :WMToggle<cr>
map <F3> :Tlist<cr>
map <F4> :TMiniBufExplorer<cr>
map <f10> :set wrap!<cr>
map <f9>	:syntax on<cr>
map :ss :mksession! ~/.vim/Session.vim<cr>
map :wbd :w<cr>:bd<cr>
map <f11> :call SwitchColorscheme()<cr>
map <Space> :noh<cr>

"--------------------------------------------------
" Options
"-------------------------------------------------- 
set encoding=utf-8
set t_Co=256
set autoindent
set tabstop=2
set softtabstop=2
set shiftwidth=2
set bg=dark
set paste 	"paste without auto-indent breaking stuff
set viewoptions=cursor,folds
set diffopt=vertical
set foldmethod=marker
set foldminlines=2	"display 2 lines for a closed fold
set foldnestmax=3
"set ignorecase	"ignore case while searching - sucks, I like it that way
set hidden	" allow switching to buffers without saving; also preserves undo list
set guioptions=mt " need only tabs and menubar in gvim
set printfont=courier:h8
set printoptions=paper:a4,left:10mm,right:10mm,top:10mm,bottom:10mm,number:y
set laststatus=2
set iskeyword+=_
set incsearch	" incremental search
set winaltkeys=no	" disable menu shortcuts in gvim
set directory=.,~/tmp,/var/tmp,/tmp	" where to save swap files
set backupdir=.,~/tmp,/var/tmp,/tmp	" where to backup files

"--------------------------------------------------
" Status line
"-------------------------------------------------- 
set statusline=%F\      "tail of the filename
set statusline+=%y      "filetype
set statusline+=[%{strlen(&fenc)?&fenc:'none'}, "file encoding
set statusline+=%{&ff}] "file format
set statusline+=%h      "help file flag
set statusline+=%m      "modified flag
set statusline+=%r      "read only flag
set statusline+=%=      "left/right separator
set statusline+=%c,     "cursor column
set statusline+=%l/%L   "cursor line/total lines
set statusline+=\ %P    "percent through file


"--------------------------------------------------
" Other settings
"-------------------------------------------------- 
" invoke plugins on matching files
filetype plugin on

syntax on
syntax match Tab /\t/
colorscheme desert256

" for latex-suite
let g:tex_flavor='latex'
set runtimepath+=/usr/share/vim/addons
set grepprg=grep\ -nH\ $*
set matchpairs=(:),{:},[:]

" let g:winManagerWindowLayout = 'FileExplorer'
let g:miniBufExplMapCTabSwitchBufs = 1

" something to do with the tag list
let Tlist_Inc_Winwidth = 0

" save & restore view
autocmd BufWinLeave *.* mkview
autocmd BufWinEnter *.* silent loadview

" Session management
function! RestoreSession()
  if argc() == 0 "vim called without arguments
    execute 'source ~/.vim/Session.vim'
  end
endfunction
autocmd VimEnter * call RestoreSession()

function! SwitchColorscheme()
	if g:colors_name == 'vexorian'
		:colorscheme desert256
	else
		:colorscheme vexorian
	endif
endfunction
" other nice light colorschemes:
" satori
" delphi
" other nice dark colorschemes:
" desert256
" gentooish
" darkburn
" oceanblack
" zmrok

" Templates
autocmd! BufNewFile * silent! 0r ~/.vim/skel/template.%:e
