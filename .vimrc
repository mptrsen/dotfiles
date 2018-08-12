"--------------------------------------------------
" Maps
"-------------------------------------------------- 
map <c-n>   :bn<cr>
map <c-p>   :bp<cr>
map <F2>    :WMToggle<cr>
map <F3>    :Tlist<cr>
map <F4>    :TMiniBufExplorer<cr>
map <F8>    :set paste!<CR>
map <F9>    :call SwitchColorscheme()<cr>
map <F10>   :set wrap!<cr>
map <Space> :noh<cr>
map :ss     :mksession! ~/.vim/Session.vim<cr>
map :wbd    :w<cr>:bd<cr>

"--------------------------------------------------
" Options
"-------------------------------------------------- 
" disable folding for now
"set expandtab	" insert spaces for tabs
"set foldlevelstart=20
"set foldmethod=manual
"set foldminlines=2	"display 2 lines for a closed fold
"set foldnestmax=3
set autoindent
set backupdir=.,~/tmp,/var/tmp,/tmp	" where to backup files
set bg=dark
set bs=indent,eol,start " Allow backspacing over everything in insert mode
set cursorline
set diffopt=vertical
set directory=.,~/tmp,/var/tmp,/tmp	" where to save swap files
set encoding=utf-8
set fileformat=unix     " file mode is unix, displays that ^M with dos files
set guioptions=t " need only tabs and menubar in gvim
set hidden	" allow switching to buffers without saving; also preserves undo list
set ignorecase	"ignore case while searching - sucks, I like it that way
set incsearch	" incremental search
set iskeyword+=_
set laststatus=2
set lazyredraw          " no redraws in macros
set magic " change the way backslashes are used in search patterns
set nofoldenable
set paste 	"paste without auto-indent breaking stuff
set printfont=courier:h8
set printoptions=paper:a4,left:10mm,right:10mm,top:10mm,bottom:10mm,number:y,syntax:n
set scrolloff=2 " scrolling offset top/bottom
set shiftwidth=2
set smartcase  " but become case sensitive if you type uppercase chars
set smartindent " smart auto-indent
set softtabstop=2
set t_Co=256
set tabstop=2
set viewoptions=cursor
set wildmenu  " completion menu
set wildmode=longest,list,full " cool tab completion
set winaltkeys=no	" disable menu shortcuts in gvim
"
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
set statusline+=%{fugitive#statusline()} "git branch
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
colorscheme vexorian

" for latex-suite
let g:tex_flavor='latex'
"let Tex_FoldedSections=""
"let Tex_FoldedEnvironments=""
"let Tex_FoldedMisc=""
autocmd Filetype tex setlocal nofoldenable
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

" Colorscheme switching function
function! SwitchColorscheme()
	if exists('g:colors_name')
		if g:colors_name != 'vexorian'
			:colorscheme vexorian
		else
			:colorscheme gentooish
		endif
	else
		:colorscheme vexorian
	endif
endfunction
" other nice light colorschemes:
" satori
" delphi
" other nice dark colorschemes:
" desert256
" oceanblack
" darkburn
" zmrok

" Templates
autocmd! BufNewFile * silent! 0r ~/.vim/skel/template.%:e

" Syntax highlighting
au! BufNewFile,BufRead *.fasta,*.fas,*.fa setf fasta
au! BufNewFile,BufRead *.md set filetype=markdown
au! BufNewFile,BufRead *.md call matchadd('Todo', 'TODO')
