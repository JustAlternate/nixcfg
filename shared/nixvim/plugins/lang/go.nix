_: {
  programs.nixvim.plugins = {
    lsp.servers = {
      gopls.enable = true;
    };
  };
}
