return {
	"huggingface/llm.nvim",
	opts = {
		model = "codellama:7b", -- the model ID, behavior depends on backend
		backend = "ollama", -- backend ID, "huggingface" | "ollama" | "openai" | "tgi"
		url = "http://localhost:11434/api/generate", -- the http url of the backend
		-- parameters that are added to the request body, values are arbitrary, you can set any field:value pair here it will be passed as is to the backend
		request_body = {
			parameters = {
				temperature = 0.2,
				top_p = 0.95,
			},
		},
		context_window = 400, -- send less context for faster reply
		enable_suggestions_on_startup = true,
		enable_suggestions_on_files = "*", -- pattern matching syntax to enable suggestions on specific files, either a string or a list of strings
		lsp = {
			bin_path = "/nix/store/ldjkasc7lmla0n2q00gjkazgn919spfr-llm-ls-0.5.2/bin/",
		},
	},
}
