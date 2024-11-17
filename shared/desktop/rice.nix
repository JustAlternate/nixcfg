{ pkgs, ... }:
{
  imports = [
    ../fastfetch
    ./rofi
    ./pywal
    ./kitty.nix
  ];

  # Append to the extra config config only for my laptop
  programs.neovim.extraLuaConfig = ''
    local pywal16 = require('pywal16')
    pywal16.setup()
    local lualine = require('lualine')
    lualine.setup {
      options = {
        theme = 'pywal16-nvim',
      },
    }
  '';

  home.packages = with pkgs; [
    birdtray
    patray
  ];

  services.trayer = {
    enable = true;
    settings.transparent = false;
    settings.tint = "0x282c34";
  };

  home.sessionVariables = {
    XCURSOR_THEME = "Numix-Cursor";
    XCURSOR_SIZE = "24";
    HYPRCURSOR_THEME = "Numix-Cursor";
    HYPRCURSOR_SIZE = "24";
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk2";
    style.name = "gtk2";
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Reversal";
      package = pkgs.reversal-icon-theme;
    };

    cursorTheme = {
      name = "Numix-Cursor";
      package = pkgs.numix-cursor-theme;
    };
  };
}
