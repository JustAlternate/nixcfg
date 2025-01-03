{ pkgs, lib, ... }:
{
  programs.nixvim = {
    plugins.conform-nvim = {
      enable = true;
      settings = {
        formatters_by_ft = {
          tex = [ "latexindent" ];

          # Use the "_" filetype to run formatters on filetypes that don't have other formatters configured.
          "_" = [
            "squeeze_blanks"
            "trim_whitespace"
            "trim_newlines"
          ];
        };
        formatters = {
          _ = {
            command = "${pkgs.gawk}/bin/gawk";
          };
          squeeze_blanks = {
            command = lib.getExe' pkgs.coreutils "cat";
          };
        };

        format_on_save = {
          lspFallback = true;
          timeoutMs = 500;
        };
      };
    };

    keymaps = [
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>cf";
        action = "<cmd>lua require('conform').format()<cr>";
        options = {
          silent = true;
          desc = "Format";
        };
      }
    ];
  };
}
