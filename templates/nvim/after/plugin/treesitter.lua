require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "lua", "vim", "help", "query", "javascript", "typescript", "go", "rust", "toml", "yaml", "json" },
  sync_install = false,
  auto_install = true,

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = { enable = true }, -- type '=' operator to fix indentation

  autotag = {
    enable = true,
  },
  rainbow = {enable = true}
}
