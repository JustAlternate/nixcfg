require("config.lazy")
local pywal16 = require("pywal16")
pywal16.setup()
local lualine = require("lualine")
lualine.setup({
	options = {
		theme = "pywal16-nvim",
	},
})
