vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.completeopt = "menuone,noselect"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.wrap = false

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.list = true
vim.opt.listchars = {
  tab = "» ",
  trail = "·",
  nbsp = "␣",
}
vim.opt.fillchars = {
  eob = " ",
}

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact", "json", "yaml", "html", "css", "lua" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end,
})