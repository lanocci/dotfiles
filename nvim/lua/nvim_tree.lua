-- nvim-tree https://docs.rockylinux.org/books/nvchad/nvchad_ui/nvimtree/
require('nvim-tree').setup({
  sort_by = 'case_sensitive',
  view = {
    adaptive_size = true,
    --mappings = {
    --  list = {
    --    { key = 'u', action = 'dir_up' },
    --  },
    --},
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
  git = {
    enable = true,
  },
  renderer = {
    highlight_git = true,
    icons = {
        show = {
            git = true,
        },
    },
  },
})

-- start neovim with open nvim-tree
require("nvim-tree.api").tree.toggle(false, true)
