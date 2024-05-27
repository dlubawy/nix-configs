-- Backup Config {{{
vim.opt.backupdir = vim.fn.stdpath("cache") .. "/backup"
vim.opt.backup = true
vim.opt.backupskip = "/tmp/*,/private/tmp/*"
vim.opt.writebackup = true
-- }}}

-- Spaces and Tabs {{{
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.g.html_indent_inctags = "html,body,head,tbody"
-- }}}

-- UI Config {{{
vim.opt.number = true
vim.opt.cursorline = true
vim.cmd("hi CursorLine cterm=none ctermbg=0 ctermfg=none")
vim.opt.encoding = "utf-8"
vim.opt.showtabline = 2
-- }}}

-- Folding {{{
vim.opt.foldenable = true
vim.opt.foldlevelstart = 10
vim.opt.foldnestmax = 10
vim.opt.foldmethod = "indent"
-- }}}

-- Key Bindings {{{
function map(mode, shortcut, command)
	vim.api.nvim_set_keymap(mode, shortcut, command, { noremap = true, silent = true })
end
function nmap(shortcut, command)
	map("n", shortcut, command)
end
function imap(shortcut, command)
	map("i", shortcut, command)
end

vim.g.mapleader = ","
vim.g.maplocalleader = "\\"
imap("jk", "<esc>")
nmap("<C-j>", "<cmd>lua vim.diagnostic.goto_next()<CR>")
nmap("<C-k>", "<cmd>lua vim.diagnostic.goto_prev()<CR>")
nmap("<space>", "za")
nmap("B", "^")
nmap("E", "$")
nmap("$", "<nop>")
nmap("^", "<nop>")
nmap("<leader><space>", "<cmd>nohlsearch<CR>")
-- }}}

-- Plugin Manager (lazy.nvim) {{{
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup("plugins")
-- }}}

-- vim:foldmethod=marker:foldlevel=0
