{ pkgs, ... }:
{
  programs.nixvim.plugins = {
    lsp.servers = {
      terraform_lsp.enable = true;
    };

    lint = {
      lintersByFt = {
        terraform = [ "tflint" ];
      };

      linters = {
        tflint = {
          cmd = "${pkgs.tflint}/bin/tflint";
        };
      };
    };
  };
}
