"source ~/.config/nvim/bv.lua
"source ~/.config/nvim/config/quickload.vim

call plug#begin('~/.vim/plugged')

Plug 'williamboman/nvim-lsp-installer'
Plug 'neovim/nvim-lspconfig'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'morhetz/gruvbox'
Plug 'preservim/nerdtree'
Plug 'nvim-lualine/lualine.nvim'
" If you want to have icons in your statusline choose one of these
Plug 'kyazdani42/nvim-web-devicons'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'andymass/vim-matchup'
Plug 'tpope/vim-repeat'
Plug 'godlygeek/tabular'
Plug 'editorconfig/editorconfig-vim'
Plug 'cespare/vim-toml'
Plug 'preservim/vim-markdown'
Plug 'rust-lang/rust.vim'
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'MaxMEllon/vim-jsx-pretty'
Plug 'peitalin/vim-jsx-typescript'
Plug 'styled-components/vim-styled-components', { 'branch': 'main' }
Plug 'jparise/vim-graphql'
Plug 'christoomey/vim-tmux-navigator'
Plug 'windwp/nvim-autopairs'
Plug 'mfussenegger/nvim-lint'
Plug 'onsails/lspkind.nvim'
Plug 'L3MON4D3/LuaSnip'
Plug 'jikkujose/vim-visincr'
Plug 'christianrondeau/vim-base64'
Plug 'nvim-treesitter/nvim-treesitter'
Plug 'nvim-treesitter/nvim-treesitter-textobjects'

Plug 'github/copilot.vim'

Plug 'NLKNguyen/papercolor-theme'
Plug 'fatih/vim-go'

" Install the fzf plugin that is cloned in from git
Plug '~/.fzf'

" react plugins
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'styled-components/vim-styled-components', { 'branch': 'main' }
Plug 'jparise/vim-graphql'

call plug#end()

"
autocmd BufEnter *.{js,jsx,ts,tsx} :syntax sync fromstart
autocmd BufLeave *.{js,jsx,ts,tsx} :syntax sync clear

set mouse=
set ttymouse=

nnoremap <silent> K :call CocAction('doHover')<CR>
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nnoremap <silent> <space>d :<C-u>CocList diagnostics<cr>
nnoremap <silent> <space>s :<C-u>CocList -I symbols<cr>
nmap <leader>do <Plug>(coc-codeaction)

" vim-tmux-navigator
let g:tmux_navigator_no_mappings = 1
nnoremap <silent> <C-h> :TmuxNavigateLeft<cr>
nnoremap <silent> <C-j> :TmuxNavigateDown<cr>
nnoremap <silent> <C-k> :TmuxNavigateUp<cr>
nnoremap <silent> <C-l> :TmuxNavigateRight<cr>
nnoremap <silent> <C-\> :TmuxNavigatePrevious<cr>
if exists('$TMUX')
    autocmd BufReadPost,FileReadPost,BufNewFile,BufEnter * call system("tmux rename-window " . expand("%:t"))
    autocmd VimLeave * call system("tmux setw automatic-rename")
endif

let g:coc_global_extensions = [
            \ 'coc-css',
            \ 'coc-git',
            \ 'coc-html',
            \ 'coc-json',
            \ 'coc-markdownlint',
            \ 'coc-actions',
            \ 'coc-snippets',
            \ 'coc-spell-checker',
            \ 'coc-stylelint',
            \ 'coc-tag',
            \ 'coc-todolist',
            \ 'coc-tsserver',
            \ 'coc-yaml',
            \ 'coc-yank',
            \ 'coc-eslint',
            \ 'coc-prettier',
            \ 'coc-clangd',
            \ 'coc-rls',
            \ 'coc-tsserver',]


"augroup highlight_yank
"	autocmd!
"	" type :hi to see other higroup options
"	au TextYankPost * silent! lua vim.highlight.on_yank { higroup='IncSearch', timeout=150 }
"augroup END

set undodir=~/.vimdid
set undofile

" syntax on
syntax off
filetype plugin indent on
set hidden
let mapleader=","


" Potential performance improvemenets (scrolling)
set noshowcmd
set lazyredraw

inoremap <silent><expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab
autocmd FileType rust setlocal expandtab
autocmd FileType markdown setlocal textwidth=80 expandtab wrap spell
autocmd FileType proto setlocal ts=2 expandtab

nmap <leader>fm gg=G

autocmd FileType go nnoremap <buffer><leader>g :GoGenerate<CR>
autocmd FileType go nnoremap <buffer><leader>i :GoInstallBinaries<CR>
autocmd FileType go nnoremap <buffer><leader>u :GoUpdateBinaries<CR>
autocmd FileType go nnoremap <buffer><leader>b :GoBuild<CR>
autocmd FileType go nnoremap <buffer><leader>t :GoTest<CR>
autocmd FileType go nnoremap <buffer><leader>tf :GoTestFunc<CR>
autocmd FileType go nnoremap <buffer><leader>l :GoLint<CR>
autocmd FileType go nnoremap <buffer><leader>c :GoCoverage<CR>
autocmd FileType go nnoremap <buffer><leader>dd :GoDoc<CR>
autocmd FileType go nnoremap <buffer>gr :GoReferrers<CR>
autocmd FileType go nnoremap <buffer>gi :GoImplements<CR>
autocmd FileType go nnoremap <buffer>gd :GoDef<CR>

" set so files are not folded when vim starts
set foldlevelstart=99
" folding with treesitter
set foldmethod=expr
"set foldexpr=nvim_treesitter#foldexpr()
"set nofoldenable

" yank to clipboard
set clipboard=unnamed

" do not require scratch/fileless buffers to be saved
set hidden

" indentation settings for using hard tabs for indent. Display tabs as
" four characters wide.
set shiftwidth=4
set tabstop=4

" line numbers on by default
set number
" autocmd InsertEnter * silent! :set norelativenumber
" autocmd InsertLeave,BufNewFile,VimEnter * silent! :set relativenumber
" autocmd FocusLost * :set number
" autocmd FocusGained * :set relativenumber

" ----- BENJI -----
"
"setup color column for max len
set colorcolumn=78

" Settings
set nu

" yank to clipboard
set clipboard=unnamedplus

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Add go bindings 
nmap <leader><tab> :GoImports<CR>
nmap <leader>b :GoBuild<CR>
"au FileType go nmap gr :GoReferrers<CR>

" if hidden is not set, TextEdit might fail.
set hidden
" Better display for messages
set cmdheight=2
" Smaller updatetime for CursorHold & CursorHoldI
set updatetime=300
" don't give |ins-completion-menu| messages.
set shortmess+=c
" always show signcolumns
set signcolumn=yes

" Use <C-k> for jump to previous placeholder, it's default of coc.nvim
let g:coc_snippet_prev = '<c-k>'
"
"" Use <C-j> for both expand and jump (make expand higher priority.)
"imap <C-j> <Plug>(coc-snippets-expand-jump)
"
"inoremap <silent><expr> <TAB>
"      \ pumvisible() ? coc#_select_confirm() :
"      \ coc#expandableOrJumpable() ? "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
"      \ <SID>check_back_space() ? "\<TAB>" :
"      \ coc#refresh()

function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'

" Remap for rename current word
"nmap <leader>rn <Plug>(coc-rename)

" ----- BENJI END -----
" plugin
:nmap \o :set paste!<CR>

" changes j and k to move by row instead of by line
:nmap j gj
:nmap k gk

" https://github.com/neovim/neovim/issues/416 changed the default for Y to y$,
" which is admittedly more sensible but my fingers refuse. double tapping y
" feels worse/slower than shift-y just because of where y is
map Y yy

" search incrementally, emacs style
:set incsearch
" other search options
:set ignorecase
:set smartcase
:set nohlsearch

" swap back and forth between 2 files
nmap <C-e> :e#<CR>

" next/previous buffer
nmap <C-n> :bnext<CR>
nmap <C-m> :bprev<CR>


au BufNewFile,BufRead *.ejs set filetype=html

"nmap <leader>.. :lclose<CR>
nmap <script> <silent> <leader>.. :call ToggleLocationList()<CR>

" autoclose html tags
iabbrev </ </<C-X><C-O>

" remap split switching
map <tab> <c-w>
" map <tab><tab> <c-w><c-w>

" copy clipboard in between "" or '
nmap <leader>" i"<Esc>p
nmap <leader>' i'<Esc>p

"
" misc funcs
"
function! WordFrequency() range
    let all = split(join(getline(a:firstline, a:lastline)), '\A\+')
    let frequencies = {}
    for word in all
        let frequencies[word] = get(frequencies, word, 0) + 1
    endfor
    new
    setlocal buftype=nofile bufhidden=hide noswapfile tabstop=20
    for [key,value] in items(frequencies)
        call append('$', key."\t".value)
    endfor
    sort i
endfunction
command! -range=% WordFrequency <line1>,<line2>call WordFrequency()

" Sorts numbers in ascending order.
" Examples:
" [2, 3, 1, 11, 2] --> [1, 2, 2, 3, 11]
" ['2', '1', '10','-1'] --> [-1, 1, 2, 10]
function! Sorted(list)
    " Make sure the list consists of numbers (and not strings)
    " This also ensures that the original list is not modified
    let nrs = ToNrs(a:list)
    let sortedList = sort(nrs, "NaturalOrder")
    echo sortedList
    return sortedList
endfunction

" Comparator function for natural ordering of numbers
function! NaturalOrder(firstNr, secondNr)
    if a:firstNr < a:secondNr
        return -1
    elseif a:firstNr > a:secondNr
        return 1
    else
        return 0
    endif
endfunction

" Coerces every element of a list to a number. Returns a new list without
" modifying the original list.
function! ToNrs(list)
    let nrs = []
    for elem in a:list
        let nr = 0 + elem
        call add(nrs, nr)
    endfor
    return nrs
endfunction

function! WordFrequencySorted() range
    " Words are separated by whitespace or punctuation characters
    let wordSeparators = '[[:blank:][:punct:]]\+'
    let allWords = split(join(getline(a:firstline, a:lastline)), wordSeparators)
    let wordToCount = {}
    for word in allWords
        let wordToCount[word] = get(wordToCount, word, 0) + 1
    endfor

    let countToWords = {}
    for [word,cnt] in items(wordToCount)
        let words = get(countToWords,cnt,"")
        " Append this word to the other words that occur as many times in the text
        let countToWords[cnt] = words . " " . word
    endfor

    " Create a new buffer to show the results in
    new
    setlocal buftype=nofile bufhidden=hide noswapfile tabstop=20

    " List of word counts in ascending order
    let sortedWordCounts = Sorted(keys(countToWords))

    call append("$", "count \t words")
    call append("$", "--------------------------")
    " Show the most frequent words first -> Descending order
    for cnt in reverse(sortedWordCounts)
        let words = countToWords[cnt]
        call append("$", cnt . "\t" . words)
    endfor
endfunction

command! -range=% WordFrequencySorted <line1>,<line2>call WordFrequencySorted()

" nerdtree plugin
map <silent> \e :NERDTreeToggle<CR>
map <silent> \E :NERDTreeFind<CR>
let NERDTreeShowHidden=1

" looks
set background=dark
set termguicolors
let g:gruvbox_contrast_dark = 'hard'
colorscheme gruvbox


"lua << EOF
"source config/plugins/lualine.lua
"EOF

" Copilot settings
imap <silent><script><expr> <c-space> copilot#Accept('\<CR>')
imap <M-[> <Plug>(copilot-dismiss)
imap <M-.> <Plug>(copilot-next)
imap <M-,> <Plug>(copilot-previous)
let g:copilot_no_tab_map = v:true
let g:copilot_assume_mapped = v:true
let g:copilot_filetypes = {
            \ '*': v:true,
            \ 'markdown': v:true,
            \ }

" comment-nvim
"lua << EOF
"require('Comment').setup()
"EOF

" Treesitter
" lua << EOF\n"
"      + builtins.readFile "${root}/nvim/config/treesitter.lua"
"      + "\nEOF";

" nvim-lspconfig
"
"      config = "lua << EOF\n"
"      + builtins.readFile "${root}/nvim/config/lsp.lua"
"      + "\nEOF";

" nvim-autopairs

"lua << EOF
"require('nvim-autopairs').setup({
"  check_ts = true, -- check treesitter
"  disable_in_macro = true,
"})
"EOF

" nvim lint

"      config = "lua << EOF\n"
"      + builtins.readFile "${root}/nvim/config/plugins/nvim-lint.lua"
"      + "\nEOF";


" nvim-cmp 

"      config = "lua << EOF\n"
"      + builtins.readFile "${root}/nvim/config/plugins/nvim-cmp.lua"
"      + "\nEOF";

" fzf-vim


" FZF.vim
" let $FZF_DEFAULT_COMMAND = 'ag --hidden --ignore-dir={dist,target,node_modules,docs,rulepack/xml,experiments,code-coverage-report} --ignore .git -g ""'
" set rtp+=/usr/local/opt/fzf " for fzf to load on start from the brew install
" set rtp+= " for fzf to load on start from the brew install
" let $FZF_DEFAULT_COMMAND = "fd --type f --hidden -E '.git' -E 'target/**'"
let $FZF_DEFAULT_COMMAND = "fd --type f --hidden -E '.git'"
nmap ; :FZF<CR>

" luasnip

"        lua << EOF
"        ${builtins.readFile "${root}/nvim/config/plugins/luasnip.lua"}
"        -- re-enable if i ever want to use the premade snippets from friendly-snippets
"        -- for some reason, lazy_load isn't working
"        -- require("luasnip/loaders/from_vscode").load({ paths = "${friendly-snippets}/share/vim-plugins/friendly-snippets/" })
"        EOF

" vim-base64

" Visual Mode mappings
vnoremap <silent> <leader>B c<c-r>=base64#decode(@")<cr><esc>`[v`]h
vnoremap <silent> <leader>b c<c-r>=base64#encode(@")<cr><esc>`[v`]h

" Regex mappings
nnoremap <leader>b/ :%s/\v()/\=base64#encode(submatch(1))/<home><right><right><right><right><right><right>
nnoremap <leader>B/ :%s/\v()/\=base64#decode(submatch(1))/<home><right><right><right><right><right><right>

" scratch-vim


let g:scratch_insert_autohide = 0
" to change default mappings, turn mapping off and set manually
let g:scratch_no_mappings = 1
let g:scratch_persistence_file = '~/.nvim/scratch'
" nmap gs <Plug>(scratch-insert-reuse)
" xmap gs <Plug>(scratch-selection-reuse)
" nmap gS :ScratchPreview<CR>
