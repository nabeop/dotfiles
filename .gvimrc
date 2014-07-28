" release autogroup in MyAutoCmd
augroup MyAutoCmd
  autocmd!
augroup END

"------------------------------------------------2014/05/23追記
"------------------------------------------------undo機能のやつ
"testing
set undodir=~/vim/undo
set imdisable
"------------------------------------------------about searching
set ignorecase          " 大文字小文字を区別しない
set smartcase           " 検索文字に大文字がある場合は大文字小文字を区別
set incsearch           " インクリメンタルサーチ
set hlsearch            " 検索マッチテキストをハイライト (2013-07-03 14:30 修正）

" バックスラッシュやクエスチョンを状況に合わせ自動的にエスケープ
cnoremap <expr> / getcmdtype() == '/' ? '\/' : '/'
cnoremap <expr> ? getcmdtype() == '?' ? '\?' : '?'

"------------------------------------------------editing configuration
set shiftround          " '<'や'>'でインデントする際に'shiftwidth'の倍数に丸める
set infercase           " 補完時に大文字小文字を区別しない
set virtualedit=all     " カーソルを文字が存在しない部分でも動けるようにする
set hidden              " バッファを閉じる代わりに隠す（Undo履歴を残すため）
set switchbuf=useopen   " 新しく開く代わりにすでに開いてあるバッファを開く
set showmatch           " 対応する括弧などをハイライト表示する
set matchtime=3         " 対応括弧のハイライト表示を3秒にする

" 対応括弧に'<'と'>'のペアを追加
set matchpairs& matchpairs+=<:>

" バックスペースでなんでも消せるようにする
set backspace=indent,eol,start

" クリップボードをデフォルトのレジスタとして指定。後にYankRingを使うので
" 'unnamedplus'が存在しているかどうかで設定を分ける必要がある
if has('unnamedplus')
    " set clipboard& clipboard+=unnamedplus " 2013-07-03 14:30 unnamed 追加
    set clipboard& clipboard+=unnamedplus,unnamed 
else
    " set clipboard& clipboard+=unnamed,autoselect 2013-06-24 10:00 autoselect 削除
    set clipboard& clipboard+=unnamed
endif

" Swapファイル？Backupファイル？前時代的すぎ
" なので全て無効化する
set nowritebackup
set nobackup
set noswapfile

"------------------------------------------------display configuration
set list                " 不可視文字の可視化
set number              " 行番号の表示
set wrap                " 長いテキストの折り返し
set textwidth=0         " 自動的に改行が入るのを無効化
set colorcolumn=80      " その代わり80文字目にラインを入れる

" 前時代的スクリーンベルを無効化
set t_vb=
set novisualbell

" デフォルト不可視文字は美しくないのでUnicodeで綺麗に
set listchars=tab:»-,trail:-,extends:»,precedes:«,nbsp:%,eol:↲

"------------------------------------------------Macro config
"" 入力モード中に素早くjjと入力した場合はESCとみなす
inoremap jj <Esc>

" ESCを二回押すことでハイライトを消す
nmap <silent> <Esc><Esc> :nohlsearch<CR>

" カーソル下の単語を * で検索
vnoremap <silent> * "vy/\V<C-r>=substitute(escape(@v, '\/'), "\n", '\\n', 'g')<CR><CR>

" 検索後にジャンプした際に検索単語を画面中央に持ってくる
nnoremap n nzz
nnoremap N Nzz
nnoremap * *zz
nnoremap # #zz
nnoremap g* g*zz
nnoremap g# g#zz

" j, k による移動を折り返されたテキストでも自然に振る舞うように変更
nnoremap j gj
nnoremap k gk

" vを二回で行末まで選択
vnoremap v $h

" TABにて対応ペアにジャンプ
nnoremap <Tab> %
vnoremap <Tab> %

" Ctrl + hjkl でウィンドウ間を移動
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Shift + 矢印でウィンドウサイズを変更
nnoremap <S-Left>  <C-w><<CR>
nnoremap <S-Right> <C-w>><CR>
nnoremap <S-Up>    <C-w>-<CR>
nnoremap <S-Down>  <C-w>+<CR>

" T + ? で各種設定をトグル
nnoremap [toggle] <Nop>
nmap T [toggle]
nnoremap <silent> [toggle]s :setl spell!<CR>:setl spell?<CR>
nnoremap <silent> [toggle]l :setl list!<CR>:setl list?<CR>
nnoremap <silent> [toggle]t :setl expandtab!<CR>:setl expandtab?<CR>
nnoremap <silent> [toggle]w :setl wrap!<CR>:setl wrap?<CR>

" make, grep などのコマンド後に自動的にQuickFixを開く
autocmd MyAutoCmd QuickfixCmdPost make,grep,grepadd,vimgrep copen

" QuickFixおよびHelpでは q でバッファを閉じる
autocmd MyAutoCmd FileType help,qf nnoremap <buffer> q <C-w>c

" w!! でスーパーユーザーとして保存（sudoが使える環境限定）
cmap w!! w !sudo tee > /dev/null %

" :e などでファイルを開く際にフォルダが存在しない場合は自動作成
function! s:mkdir(dir, force)
  if !isdirectory(a:dir) && (a:force ||
        \ input(printf('"%s" does not exist. Create? [y/N]', a:dir)) =~? '^y\%[es]$')
    call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
  endif
endfunction
autocmd MyAutoCmd BufWritePre * call s:mkdir(expand('<afile>:p:h'), v:cmdbang)

" vim 起動時のみカレントディレクトリを開いたファイルの親ディレクトリに指定
autocmd MyAutoCmd VimEnter * call s:ChangeCurrentDir('', '')
function! s:ChangeCurrentDir(directory, bang)
    if a:directory == ''
        lcd %:p:h
    else
        execute 'lcd' . a:directory
    endif

    if a:bang == ''
        pwd
    endif
endfunction

" ~/.vimrc.localが存在する場合のみ設定を読み込む
let s:local_vimrc = expand('~/.vimrc.local')
if filereadable(s:local_vimrc)
    execute 'source ' . s:local_vimrc
endif

"----------------------------------------------2014/06/11追記 透過設定
if has('gui_macvim')
	set transparency=30
	set guioptions-=T
endif
"-----------------------------------------------2014/07/17追記 C++関係
" default : ""
let $VIM_CPP_STDLIB = "/usr/include/c++/4.2.1"
" default : ""
let $VIM_CPP_INCLUDE_DIR = "/usr/local/include"  

"------------------------------------------------NeoBundle configuration
if has('vim_starting')
   set nocompatible               " Be iMproved

   " Required:
   set runtimepath+=~/.vim/bundle/neobundle.vim/
 endif

 " Required:
 call neobundle#begin(expand('~/.vim/bundle/'))

 " Let NeoBundle manage NeoBundle
 " Required:
 NeoBundleFetch 'Shougo/neobundle.vim'

 " My Bundles here:
 
 NeoBundle 'Shougo/neosnippet-snippets'
 NeoBundle 'tpope/vim-fugitive'
 NeoBundle 'kien/ctrlp.vim'
 NeoBundle 'flazz/vim-colorschemes'
 NeoBundle 'altercation/vim-colors-solarized'
 NeoBundle 'Shougo/unite.vim'
 NeoBundle 'git://git.code.sf.net/p/vim-latex/vim-latex'


" 次に説明するがInsertモードに入るまではneocompleteはロードされない
NeoBundleLazy 'Shougo/neocomplete.vim', {
    \ "autoload": {"insert": 1}}
" neocompleteのhooksを取得
let s:hooks = neobundle#get_hooks("neocomplete.vim")
" neocomplete用の設定関数を定義。下記関数はneocompleteロード時に実行される
function! s:hooks.on_source(bundle)
    let g:acp_enableAtStartup = 0
    let g:neocomplete#enable_smart_case = 1
    " NeoCompleteを有効化

endfunction

" Insertモードに入るまでロードしない

NeoBundleLazy 'Shougo/neosnippet.vim', {
    \ "autoload": {"insert": 1}}
" 'GundoToggle'が呼ばれるまでロードしない
NeoBundleLazy 'sjl/gundo.vim', {
    \ "autoload": {"commands": ["GundoToggle"]}}
" '<Plug>TaskList'というマッピングが呼ばれるまでロードしない
NeoBundleLazy 'vim-scripts/TaskList.vim', {
    \ "autoload": {"mappings": ['<Plug>TaskList']}}
" HTMLが開かれるまでロードしない
NeoBundleLazy 'mattn/zencoding-vim', {
    \ "autoload": {"filetypes": ['html']}}

NeoBundleLazy "Shougo/vimfiler", {
      \ "depends": ["Shougo/unite.vim"],
      \ "autoload": {
      \   "commands": ["VimFilerTab", "VimFiler", "VimFilerExplorer"],
      \   "mappings": ['<Plug>(vimfiler_switch)'],
      \   "explorer": 1,
      \ }}
nnoremap <Leader>e :VimFilerExplorer<CR>
" close vimfiler automatically when there are only vimfiler open
autocmd MyAutoCmd BufEnter * if (winnr('$') == 1 && &filetype ==# 'vimfiler') | q | endif
let s:hooks = neobundle#get_hooks("vimfiler")
function! s:hooks.on_source(bundle)
  let g:vimfiler_as_default_explorer = 1
  let g:vimfiler_enable_auto_cd = 1
  
  " .から始まるファイルおよび.pycで終わるファイルを不可視パターンに
  " 2013-08-14 追記
  let g:vimfiler_ignore_pattern = "\%(^\..*\|\.pyc$\)"

  " vimfiler specific key mappings
  autocmd MyAutoCmd FileType vimfiler call s:vimfiler_settings()
  function! s:vimfiler_settings()
    " ^^ to go up
    nmap <buffer> ^^ <Plug>(vimfiler_switch_to_parent_directory)
    " use R to refresh
    nmap <buffer> R <Plug>(vimfiler_redraw_screen)
    " overwrite C-l
    nmap <buffer> <C-l> <C-w>l
  endfunction
endfunction

NeoBundle 'tpope/vim-surround'
NeoBundle 'vim-scripts/Align'
NeoBundle 'vim-scripts/YankRing.vim'

" if has('lua') && v:version > 703 && has('patch825') 2013-07-03 14:30 > から >= に修正
" if has('lua') && v:version >= 703 && has('patch825') 2013-07-08 10:00 必要バージョンが885にアップデートされていました
if has('lua') && v:version >= 703 && has('patch885')
    NeoBundleLazy "Shougo/neocomplete.vim", {
        \ "autoload": {
        \   "insert": 1,
        \ }}
    " 2013-07-03 14:30 NeoComplCacheに合わせた
    let g:neocomplete#enable_at_startup = 1
    let s:hooks = neobundle#get_hooks("neocomplete.vim")
    function! s:hooks.on_source(bundle)
        let g:acp_enableAtStartup = 0
        let g:neocomplet#enable_smart_case = 1
        " NeoCompleteを有効化
        " NeoCompleteEnable
    endfunction
else
    NeoBundleLazy "Shougo/neocomplcache.vim", {
        \ "autoload": {
        \   "insert": 1,
        \ }}
    " 2013-07-03 14:30 原因不明だがNeoComplCacheEnableコマンドが見つからないので変更
    let g:neocomplcache_enable_at_startup = 1
    let s:hooks = neobundle#get_hooks("neocomplcache.vim")
    function! s:hooks.on_source(bundle)
        let g:acp_enableAtStartup = 0
        let g:neocomplcache_enable_smart_case = 1
        " NeoComplCacheを有効化
        " NeoComplCacheEnable 
    endfunction
endif

NeoBundle "nathanaelkane/vim-indent-guides"
" let g:indent_guides_enable_on_vim_startup = 1 2013-06-24 10:00 削除
let s:hooks = neobundle#get_hooks("vim-indent-guides")
function! s:hooks.on_source(bundle)
  let g:indent_guides_guide_size = 1
  IndentGuidesEnable " 2013-06-24 10:00 追記
endfunction

NeoBundleLazy "sjl/gundo.vim", {
      \ "autoload": {
      \   "commands": ['GundoToggle'],
      \}}
nnoremap <Leader>g :GundoToggle<CR>

NeoBundleLazy "vim-scripts/TaskList.vim", {
      \ "autoload": {
      \   "mappings": ['<Plug>TaskList'],
      \}}
nmap <Leader>T <plug>TaskList

" Djangoを正しくVimで読み込めるようにする
NeoBundleLazy "lambdalisue/vim-django-support", {
      \ "autoload": {
      \   "filetypes": ["python", "python3", "djangohtml"]
      \ }}
" Vimで正しくvirtualenvを処理できるようにする
NeoBundleLazy "jmcantrell/vim-virtualenv", {
      \ "autoload": {
      \   "filetypes": ["python", "python3", "djangohtml"]
      \ }}


NeoBundleLazy "davidhalter/jedi-vim", {
      \ "autoload": {
      \   "filetypes": ["python", "python3", "djangohtml"],
      \ },
      \ "build": {
      \   "mac": "pip install jedi",
      \   "unix": "pip install jedi",
      \ }}
let s:hooks = neobundle#get_hooks("jedi-vim")
function! s:hooks.on_source(bundle)
  " jediにvimの設定を任せると'completeopt+=preview'するので
  " 自動設定機能をOFFにし手動で設定を行う
  let g:jedi#auto_vim_configuration = 0
  " 補完の最初の項目が選択された状態だと使いにくいためオフにする
  let g:jedi#popup_select_first = 0
  " quickrunと被るため大文字に変更
  let g:jedi#rename_command = '<Leader>R'
  " gundoと被るため大文字に変更 (2013-06-24 10:00 追記）
  let g:jedi#goto_assignments_command = '<Leader>G'
endfunction

NeoBundle "thinca/vim-template"
" テンプレート中に含まれる特定文字列を置き換える
autocmd MyAutoCmd User plugin-template-loaded call s:template_keywords()
function! s:template_keywords()
    silent! %s/<+DATE+>/\=strftime('%Y-%m-%d')/g
    silent! %s/<+FILENAME+>/\=expand('%:r')/g
endfunction
" テンプレート中に含まれる'<+CURSOR+>'にカーソルを移動
autocmd MyAutoCmd User plugin-template-loaded
    \   if search('<+CURSOR+>')
    \ |   silent! execute 'normal! "_da>'
    \ | endif

NeoBundleLazy "thinca/vim-quickrun", {
      \ "autoload": {
      \   "mappings": [['nxo', '<Plug>(quickrun)']]
      \ }}
nmap <Leader>r <Plug>(quickrun)
let s:hooks = neobundle#get_hooks("vim-quickrun")
function! s:hooks.on_source(bundle)
  let g:quickrun_config = {
  \	'tex':{
  \	'command': 'ptex2pdf'
  \	'exec': ['%c -l -u -ot "-synctex=1 -interaction=nonstopmode" %s'. 'open %s:r.pdf']
  \}
      \ "*": {"runner": "remote/vimproc"},
  \ },
endfunction
NeoBundleLazy 'majutsushi/tagbar', {
      \ "autload": {
      \   "commands": ["TagbarToggle"],
      \ },
      \ "build": {
      \   "mac": "brew install ctags",
      \ }}
nmap <Leader>t :TagbarToggle<CR>

"-------------------------------------------2014-07-17 neobundle for cpp
NeoBundleLazy 'vim-jp/cpp-vim',{
	\ "autoload": {"filetypes": ["cpp","h","hpp"]}}

NeoBundleLazy 'tyru/caw.vim',{
			\ "autoload": {"filetypes": ["cpp","h","hpp"]}}

NeoBundleLazy 'osyo-manga/vim-marching',{
			\ "autoload": {"filetypes": ["cpp","h","hpp"]}}

NeoBundleLazy 'rhysd/wandbox-vim',{
			\ "autoload": {"filetypes": ["cpp", "h", "hpp"]}}

NeoBundleLazy 'osyo-manga/shabadou.vim',{
			\ "autoload": {"filetypes": ["cpp", "h", "hpp"]}}

NeoBundle 'jceb/vim-hier'
NeoBundle 'dannyob/quickfixstatus'

NeoBundle 't9md/vim-quickhl'
 
 " You can specify revision/branch/tag.
 NeoBundle 'Shougo/vimshell', { 'rev' : '3787e5' }

 call neobundle#end()

 " Required:
 filetype plugin indent on

 " If there are uninstalled bundles found on startup,
 " this will conveniently prompt you to install them.
 NeoBundleCheck

 syntax enable
 set background=dark
 let g:solarized_termcolors=256
 colorscheme solarized

"---------------------------2014/07/17 c++ plugin config
"
let s:hooks = neobundle#get_hooks("caw.vim")
function! s:hooks.on_source(bundle)
	"mapping for comment out using <leader>+c or C
	nmap <leader>c <Plug>(caw:I:toggle)
	vmap <leader>c <Plug>(caw:I:toggle)

	nmap <leader>C <Plug>(caw:I:uncomment)
	vmap <leader>C <Plug>(caw:I:uncomment)

endfunction

let s:hooks = neobundle#get_hooks("quickfixstatus")
function! s:hooks.on_post_source(bundle)
QuickfixStatusEnable
endfunction

let s:hooks = neobundle#get_hooks("vim-quickhl")
function! s:hooks.on_source(bundle)
	nmap <Space>m <Plug>(quickhl-manual-this)
	xmap <Space>m <Plug>(quickhl-manual-this)
	nmap <Space>M <Plug>(quickhl-manual-reset)
	xmap <Space>M <Plug>(quickhl-manual-reset)
endfunction


" marching.vim
let s:hooks = neobundle#get_hooks("vim-marching")
function! s:hooks.on_post_source(bundle)
if !empty(g:marching_clang_command) && executable(g:marching_clang_command)
" 非同期ではなくて同期処理で補完する
let g:marching_backend = "sync_clang_command"
else
" clang コマンドが実行できなければ wandbox を使用する
let g:marching_backend = "wandbox"
let g:marching_clang_command = ""
endif

" オプションの設定
" これは clang のコマンドに渡される
let g:marching#clang_command#options = {
\ "cpp" : "-std=gnu++1y"
\}


if !neobundle#is_sourced("neocomplete.vim")
return
endif

" neocomplete.vim と併用して使用する場合
" neocomplete.vim を使用すれば自動補完になる
let g:marching_enable_neocomplete = 1

if !exists('g:neocomplete#force_omni_input_patterns')
let g:neocomplete#force_omni_input_patterns = {}
endif

let g:neocomplete#force_omni_input_patterns.cpp =
\ '[^.[:digit:] *\t]\%(\.\|->\)\w*\|\h\w*::\w*'
endfunction
unlet s:hooks

 
"-----------------------------------vim-latex configuration
filetype plugin on
filetype indent on
set shellslash
set grepprg=grep\ -nH\ $*
let g:tex_flavor='latex'
let g:Imap_UsePlaceHolders = 1
let g:Imap_DeleteEmptyPlaceHolders = 1
let g:Imap_StickyPlaceHolders = 0
