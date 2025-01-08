{ pkgs, ... }:
{
  programs.nixvim.plugins = {
    lsp.servers = {
      dockerls.enable = true;
      docker_compose_language_service.enable = true;
    };

    lint = {
      lintersByFt = {
        docker = [ "hadolint" ];
      };

      linters = {
        hadolint = {
          cmd = "${pkgs.hadolint}/bin/hadolint";
        };
      };
    };
  };
}
