_:
{
  imports = [
    ../../../shared/nvim/default.nix
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
}
