vim.g.mapleader = " "

-- Open the file tree
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, { desc = "open file tree" })

-- Move lines up and down 
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "move line down in visual" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "move line up in visual" })

-- Join lines
vim.keymap.set("n", "J", "mzJ`z", { desc = "join lines" })

-- Keep cursor in the middle when jumping
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Copy without losing last yield
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "copy without losing last yield" })

-- Copy to system clipboard
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Quick fix navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- Search and replace highlighted word
vim.keymap.set("n", "<leader>sw", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "search and replace cursor word" })
vim.keymap.set("n", "<leader>s", [[:%s/<C-r><C-w>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "search and replace cursor word term" })

-- Show keymaps
vim.keymap.set("n", "<leader>km", ":Telescope keymaps<CR>")

-- Fix all eslint
vim.keymap.set("n", "<leader>fa", ":EslintFixAll<CR>")
