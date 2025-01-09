_: {
  programs.nixvim = {
    plugins.dap = {
      enable = true;
      extensions.dap-go.enable = true;
    };
  };
}
