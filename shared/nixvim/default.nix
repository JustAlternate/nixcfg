{ pkgs, ... }:
{
  imports = [
    ./keymaps.nix
    ./theme.nix
    ./plugins
  ];
  programs.nixvim = {

    extraPackages = with pkgs; [
      ripgrep
      fzf
      fd
      gnused
      cmake
      stylua
      lazygit

      # LSP stuff
      nil
      statix # Lints and suggestions for the nix programming language
      deadnix # Find and remove unused code in .nix source files
      nixfmt-rfc-style # Nix Code Formatter

      # llm-ls
      lua-language-server
      stylua
      shfmt
      pyright
      gopls

      # Latex preview
      mupdf

      (import ./plugins/ollama-copilot.nix { inherit (pkgs) lib buildGoModule fetchFromGitHub; })
      ollama

      # Additional nvim plugins
      vimPlugins.plenary-nvim
    ];

    luaLoader.enable = true;

    clipboard = {
      register = "unnamedplus";
      providers.wl-copy.enable = true;
    };

    enable = true;
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
      trim.enable = true;
      neoscroll.enable = true;
      dressing.enable = true;
      todo-comments.enable = true;
      web-devicons.enable = true;
      lualine.enable = true;
      toggleterm.enable = true;
      snacks.enable = true;
      lazygit.enable = true;
      telescope.enable = true;
      bufferline.enable = true;
      fzf-lua.enable = true;
      markdown-preview.enable = true;
      spectre.enable = true;
      spectre.replacePackage = pkgs.gnused;
      persistence.enable = true;
      treesitter.enable = true;
    };

    extraConfigLuaPre = ''
      vim.fn.sign_define("diagnosticsignerror", { text = " ", texthl = "diagnosticerror", linehl = "", numhl = "" })
      vim.fn.sign_define("diagnosticsignwarn", { text = " ", texthl = "diagnosticwarn", linehl = "", numhl = "" })
      vim.fn.sign_define("diagnosticsignhint", { text = "󰌵", texthl = "diagnostichint", linehl = "", numhl = "" })
      vim.fn.sign_define("diagnosticsigninfo", { text = " ", texthl = "diagnosticinfo", linehl = "", numhl = "" })
    '';

    extraConfigLua = ''
      local opt = vim.opt
      local g = vim.g
      local o = vim.o
        -- Neovide
      if g.neovide then
        -- Neovide options
        g.neovide_fullscreen = false
        g.neovide_hide_mouse_when_typing = false
        g.neovide_refresh_rate = 165
        g.neovide_cursor_vfx_mode = "ripple"
        g.neovide_cursor_animate_command_line = true
        g.neovide_cursor_animate_in_insert_mode = true
        g.neovide_cursor_vfx_particle_lifetime = 5.0
        g.neovide_cursor_vfx_particle_density = 14.0
        g.neovide_cursor_vfx_particle_speed = 12.0
        g.neovide_transparency = 0.8

        -- Neovide Fonts
        o.guifont = "MonoLisa Trial:Medium:h15"
        -- o.guifont = "CommitMono:Medium:h15"
        -- o.guifont = "JetBrainsMono Nerd Font:h14:Medium:i"
        -- o.guifont = "FiraMono Nerd Font:Medium:h14"
        -- o.guifont = "CaskaydiaCove Nerd Font:h14:b:i"
        -- o.guifont = "BlexMono Nerd Font Mono:h14:Medium:i"
        -- o.guifont = "Liga SFMono Nerd Font:b:h15"
      end
    '';
  };
}
