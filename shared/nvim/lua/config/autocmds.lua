-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
--
vim.api.nvim_create_augroup("vertical_help", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	group = "vertical_help",
	pattern = "help",
	callback = function()
		vim.bo.bufhidden = "unload"
		vim.cmd("wincmd L")
		vim.cmd("vertical resize 79")
	end,
})
