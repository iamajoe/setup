vim.g.mapleader = " "

-- Open the file tree
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "Open file tree" })

-- Move lines up and down 
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down in visual" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up in visual" })

-- Join lines
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines" })

-- Keep cursor in the middle when jumping
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Copy without losing last yield
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Copy without losing last yield" })

-- Copy to system clipboard
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Quick fix navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- Search and replace highlighted word
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Search and replace cursor word" })

-- Show keymaps
vim.keymap.set("n", "<leader>km", ":Telescope keymaps<CR>")
