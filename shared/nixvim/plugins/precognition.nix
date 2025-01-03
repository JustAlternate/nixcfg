_: {
  programs.nixvim = {
    plugins.precognition = {
      enable = true;
      settings = {
        startVisible = false;
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>up";
        action.__raw = ''
          function()
            if require("precognition").toggle() then
                vim.notify("Precognition on")
            else
                vim.notify("Precognition off")
            end
          end
        '';

        options = {
          desc = "Precognition Toggle";
          silent = true;
        };
      }
    ];
  };
}
