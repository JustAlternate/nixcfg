{ pkgs, ... }:
{
  imports = [
    ./keymaps.nix
		./neotree.nix
		./conform.nix
  ];

  home.packages = with pkgs; [
    ripgrep
    fzf
    fd
    gnused
  ];

  programs.nixvim = {
    luaLoader.enable = true;

    clipboard = {
      register = "unnamedplus";
      providers.wl-copy.enable = true;
    };

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
      undofile = true;

      # Better splitting
      splitbelow = true;
      splitright = true;
    };

    plugins = {
      lazy.enable = true;
      flash.enable = true;
			web-devicons.enable = true;
      mini.enable = true;
      which-key.enable = true;
      lualine.enable = true;
      toggleterm.enable = true;
    };
  };
}
