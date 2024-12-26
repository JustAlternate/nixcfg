_: {
  programs.nixvim.plugins = {
    cmp = {
      enable = true;
      autoEnableSources = false;
    };
    cmp-nvim-lsp.enable = true;
    cmp-path.enable = true;
    cmp-buffer.enable = true;
  };
}
