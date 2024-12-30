{ ... }:
{
  programs.nixvim = {
    plugins.lsp = {
      enable = true;
      servers = {
        lua_ls = {
          enable = true;
          settings.telemetry.enable = false;
        };
        gopls = {
          enable = true;
        };
        # grammarly.enable = true;
        ltex = {
          enable = true;
          settings.language = "fr";
        };
        html.enable = true;
        cssls.enable = true;
        java_language_server.enable = true;
        bashls.enable = true;
        nil_ls.enable = true;
        statix.enable = true;
        nixd.enable = true;
        pylsp.enable = true;
        pyright.enable = true;
        ruff.enable = true;

        hyprls.enable = true;
        # rust-analyzer = {
        #   enable = true;
        #   installCargo = true;
        # };
      };
    };
  };
}
