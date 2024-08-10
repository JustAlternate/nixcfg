return {
	"nvimtools/none-ls.nvim",
	config = function()
		local none_ls = require("none-ls")
		none_ls.setup({
			sources = {
				none_ls.builtins.diagnostics.statix, -- add statix here
			},
		})
	end,
}
