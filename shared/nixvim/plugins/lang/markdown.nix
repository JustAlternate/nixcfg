{ pkgs, ... }:
{
  programs.nixvim = {
    extraPackages = with pkgs; [
      marksman
    ];

    plugins = {
      clipboard-image = {
        enable = true;
        clipboardPackage = pkgs.wl-clipboard;
      };

      markdown-preview = {
        enable = true;
      };

      lsp.servers = {
        marksman.enable = true;

        ltex = {
          enable = true;
          filetypes = [
            "markdown"
            "text"
          ];

          settings.completionEnabled = true;

          extraOptions = {
            checkFrequency = "save";
            language = "en-GB";
          };
        };
      };

      lint = {
        lintersByFt.md = [ "markdownlint-cli2" ];
        linters.markdownlint-cli2.cmd = "${pkgs.markdownlint-cli2}/bin/markdownlint-cli2";
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>m";
        action = "<cmd>MarkdownPreviewToggle<cr>";
        options = {
          silent = true;
          desc = "Toggle markdown preview";
        };
      }
    ];
  };
}
