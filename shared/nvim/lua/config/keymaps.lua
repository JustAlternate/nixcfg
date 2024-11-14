-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.api.nvim_set_keymap("n", "U", "<C-r>", {
	desc = "Redo last change",
	noremap = true,
})

vim.api.nvim_set_keymap("n", "<leader>cgt", "<cmd>GoTestFile<CR>", {
	desc = "GoTestFile -F",
})
