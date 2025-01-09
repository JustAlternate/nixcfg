_: {
  programs.nixvim = {
    plugins.gitsigns = {
      enable = true;
      settings = {
        trouble = false;
        current_line_blame = false;
      };
    };

    keymaps = [
      {
        mode = [
          "n"
          "v"
        ];
        key = "<leader>gh";
        action = "gitsigns";
        options = {
          silent = true;
          desc = "+hunks";
        };
      }
      {
        mode = "n";
        key = "<leader>ghb";
        action = ":Gitsigns blame_line<CR>";
        options = {
          silent = true;
          desc = "Blame line";
        };
      }
      {
        mode = "n";
        key = "<leader>ghd";
        action = ":Gitsigns diffthis<CR>";
        options = {
          silent = true;
          desc = "Diff This";
        };
      }
    ];
  };
}
