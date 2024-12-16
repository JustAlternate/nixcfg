{ config, lib, ... }:
{
  imports = [ ./default.nix ];

  options.custom.neovim.pywal16.enable = lib.mkEnableOption "Enable pywal16 for neovim config";

  config = lib.mkIf config.custom.neovim.pywal16.enable {
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
  };
}
