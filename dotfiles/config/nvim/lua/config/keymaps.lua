local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

keymap("n", "<leader>h", ":nohlsearch<CR>", opts)

keymap("n", "<leader>w", ":write<CR>", opts)
keymap("n", "<leader>q", ":quit<CR>", opts)
keymap("n", "<leader>x", ":x<CR>", opts)

keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

keymap("n", "<C-Up>", ":resize -2<CR>", opts)
keymap("n", "<C-Down>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)

keymap("v", "J", ":m '>+1<CR>gv=gv", opts)
keymap("v", "K", ":m '<-2<CR>gv=gv", opts)

keymap("x", "<leader>p", [["_dP]], opts)
keymap({ "n", "v" }, "<leader>y", [["+y]], opts)
keymap("n", "<leader>Y", [["+Y]], opts)
keymap({ "n", "v" }, "<leader>d", [["_d]], opts)

keymap("n", "<leader>e", ":Ex<CR>", opts)
keymap("t", "<Esc><Esc>", [[<C-\><C-n>]], opts)

keymap("n", "<leader>f", function()
  require("conform").format({ lsp_fallback = true, async = false, timeout_ms = 1000 })
end, { desc = "Format buffer" })

keymap("n", "K", vim.lsp.buf.hover, { desc = "LSP Hover" })
keymap("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
keymap("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
keymap("n", "gi", vim.lsp.buf.implementation, { desc = "Go to implementation" })
keymap("n", "gr", vim.lsp.buf.references, { desc = "References" })
keymap("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
keymap("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })