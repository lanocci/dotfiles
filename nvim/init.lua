require "plugins"
require('lualine').setup()

-- keymaps
vim.g.mapleader = ' '

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "plugins.lua" },
  command = "PackerCompile",
})

vim.opt.laststatus = 3

vim.cmd("colorscheme nightfox")

-- Terminal
local keyset = vim.api.nvim_set_keymap
local user_command = vim.api.nvim_create_user_command

-- TerminalをVSCodeのように現在のウィンドウの下に開く
vim.api.nvim_create_autocmd({'TermOpen'}, {
  command = 'startinsert ',
})
-- Terminalの行番号を非表示
vim.api.nvim_create_autocmd({'TermOpen'}, {
  command = 'setlocal nonumber norelativenumber',
})

vim.api.nvim_create_autocmd({'BufNew'}, {
    command = [[
        set nocompatible              " be iMproved, required
        filetype off                  " required
        nnoremap Y y$
        filetype plugin indent on
        syntax on
        set nowrap
        set hlsearch
        set ignorecase
        set smartcase
        set autoindent
        set ruler
        set number
        set relativenumber
        set list
        set listchars=tab:»-,trail:-,eol:↲,extends:»,precedes:«,nbsp:%
        set wildmenu
        set showcmd
        set shiftwidth=4
        set softtabstop=4
        set expandtab
        set tabstop=4
        set smarttab
        let g:go_fmt_command = "goimports"
    ]]
})

-- 常にインサートモードでTerminalを開く（水平分割）
user_command('T', 'sp | wincmd j | resize 20 | terminal <args>', { nargs = '*' })
keyset('n', 'T', ':T <cr>', { noremap = true })

-- 常にインサートモードでTerminalを開く（垂直分割）
user_command('TS', 'vs | wincmd j | resize 100 | terminal <args>', { nargs = '*' })
keyset('n', 'TS', ':TS <cr>', { noremap = true })
--
-- インサートモードからの離脱をspace + qにマッピング
keyset('t', '<Space>q', '<C-\\><C-n>', { silent = true })

-- Share clipboard with register
vim.opt.clipboard:append({ "unnamedplus" })

require("telescope").load_extension "file_browser"
vim.api.nvim_set_keymap(
  "n",
  "<space>ff",
  ":Telescope file_browser<CR>",
  { noremap = true }
)

require("telescope").setup{
  pickers = {
    find_files = {
      find_command = { "rg", "--files", "--hidden", "-g", "!.git" },
    }
  }
}

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>p', builtin.find_files, {})
vim.keymap.set('n', '<leader>f', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- directory pane
require ('nvim_tree')
-- 私は、leaderはSpaceキーを当てています。下の割当だと、Spaceキーとeを同時押しすることで、ファイルツリーが表示されます。leaderキーの設定方法は後述します。
vim.api.nvim_set_keymap('n', '<leader>e', ':NvimTreeToggle<CR>', {silent=true})

-- ウィンドウを移動する
vim.keymap.set('n', '<C-l>', '<C-w>l')
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')

vim.cmd([[
    set nocompatible              " be iMproved, required
    filetype off                  " required
    nnoremap Y y$

    filetype plugin indent on
    syntax on

    set nowrap
    set hlsearch
    set ignorecase
    set smartcase
    set autoindent
    set ruler
    set number
    set relativenumber
    set list
    set listchars=tab:»-,trail:-,eol:↲,extends:»,precedes:«,nbsp:%
    set wildmenu
    set showcmd
    set shiftwidth=4
    set softtabstop=4
    set expandtab
    set tabstop=4
    set smarttab
    let g:go_fmt_command = "goimports"
    "set laststatus=2
    " UI
    call ddc#custom#patch_global('ui', 'native')
    
    " SOURCE
    call ddc#custom#patch_global('sources', ['around', 'dictionary'])
    
    " SOURCE OPTION    (filterはここで指定)
    call ddc#custom#patch_global('sourceOptions', {
        \ 'around': {'mark': '[Around]'},
        \ 'dictionary': {'mark': '[Dict]'},
        \ '_': {
        \ 'matchers': ['matcher_fuzzy'],
        \ 'sorters': ['sorter_fuzzy'],
        \ 'converters': ['converter_fuzzy'],
        \ 'isVolatile': v:false
        \ }
        \ })
    "   isVolatileがv:trueだとdictionaryに含まれていない補完候補も登場したので v:falseにしました
    
    "call ddc#custom#patch_global('sourceParams', {
    "    \ 'dictionary': {'dictPaths':
    "    \ ['C:\Users\hoge\Documents\hogehoge\koten',
    "    \  'C:\Users\hoge\Documents\hogehoge\kanbun'],
    "    \ 'showMenu': v:false
    "    \ }
    "    \ })
    "   この例では2つの辞書（kotenとkanbun）を指定している
    "   showMenu を v:true にすると補完候補の供給元である辞書ファイル名が表示される
    
    " ddc.vimを有効化する
    call ddc#enable()
]])
