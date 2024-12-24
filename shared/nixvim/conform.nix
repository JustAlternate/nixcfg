{ ... }:
{
  programs.nixvim = {
		plugins.conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            tex = [ "latexindent" ];
            nix = [ "alejandra" ];
            markdown = [ "prettierd" ];
          };
          format_on_save = {
            lsp_format = "fallback";
          };
        };
      };
		};
	}
