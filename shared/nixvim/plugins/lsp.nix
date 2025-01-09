_: {
  programs.nixvim = {
    plugins = {
      lsp-signature.enable = true;
      lint.enable = true;
      lsp = {
        enable = true;
        keymaps.lspBuf = {
          "<c-k>" = "signature_help";
          "gi" = "implementation";
        };
        servers = {
          #grammarly.enable = true;
          #ltex = {
          #  enable = true;
          #  settings.language = "fr";
          #};
          html.enable = true;
          cssls.enable = true;
          java_language_server.enable = true;
          bashls.enable = true;
        };
      };
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>cl";
        action = "<cmd>LspInfo<cr>";
        options.desc = "Lsp Info";
      }
    ];
  };
}
