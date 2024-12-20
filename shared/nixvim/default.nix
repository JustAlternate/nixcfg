_: {
  programs.nixvim = {
    lualoader.enable = true;

    enable = true;
    colorschemes.tokyonight.enable = true;
    opts = {
      number = true;
      relativenumber = true;

      virtualedit = "block";
      cmdheight = 2;
      ignorecase = true;
      smartcase = true;
      updatetime = 50;
      timeoutlen = 250;

      tabstop = 2;
      shiftwidth = 2;
      smartindent = true;

      # Undo stuff from days ago
      swapfile = true;
      backup = true;
      undofile = true;

      # Better splitting
      splitbelow = true;
      splitright = true;
    };

    plugins = {
      lazy.enable = true;
      flash.enable = true;
    };
  };
}
