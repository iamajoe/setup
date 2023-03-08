vim.cmd [[highlight IndentBlanklineIndent1 guifg=#333333 gui=nocombine]]
vim.cmd [[highlight IndentBlanklineIndent2 guifg=#444444 gui=nocombine]]
vim.cmd [[highlight IndentBlanklineContextChar guifg=#ff5555 gui=nocombine]]

require("indent_blankline").setup {
    show_end_of_line = true,
    char_highlight_list = {
        "IndentBlanklineIndent1",
        "IndentBlanklineIndent2",
    },
    show_current_context = true,
    show_current_context_start = true,
}
