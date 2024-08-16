return {
	"huggingface/llm.nvim",
	opts = {
		model = "codellama:7b", -- the model ID, behavior depends on backend
		backend = "ollama", -- backend ID, "huggingface" | "ollama" | "openai" | "tgi"
		url = "http://localhost:11434", -- the http url of the backend
		-- parameters that are added to the request body, values are arbitrary, you can set any field:value pair here it will be passed as is to the backend
		request_body = {
			parameters = {
				temperature = 0.2,
				top_p = 0.95,
			},
		},
		enable_suggestions_on_startup = true,
		enable_suggestions_on_files = "*", -- pattern matching syntax to enable suggestions on specific files, either a string or a list of strings
	},
}
