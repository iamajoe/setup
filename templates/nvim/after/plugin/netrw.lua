vim.g.netrw_browse_split = 0 -- on open, doesnt split buffers
-- vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
vim.g.netrw_sizestyle="H" -- humanized dimensions
vim.g.netrw_preview=1
vim.g.netrw_liststyle=0  -- tree style
-- vim.g.netrw_keepdir = 0 -- keep the current directory the same as the browsing directory
vim.g.netrw_fastbrowse = 0 -- always obtains directory listings
vim.g.netrw_hide = 0 -- show all including hidden files
vim.g.netrw_sort_by = "name" -- sort by name
vim.g.netrw_sort_direction = "normal" -- sort ASC

-- Open the file tree
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "open file tree" })
