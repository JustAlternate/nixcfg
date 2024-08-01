{pkgs, ...}:
{
  programs.nixvim = {

    opts = {
      fileencoding = "utf-8";
      relativenumber = true;
      autowrite = true;
      expandtab = true;
      cursorline = true;
      confirm = true;
      conceallevel = 2;
      showmode = false;
      smartindent = true;
      spelllang = [ "en" ] ;
    };
    globals = {
      mapleader = " ";
      maplocalleader = "\\";
      autoformat = true;
      deprecation_warnings = false;
      bigfile_size = 1024 * 1024 * 1.5;
      trouble_lualine = true;
    };

    enable = true; 
    viAlias = true;
    vimAlias = true;

    clipboard.register = "unnamedplus";

    plugins = {
      flash.enable = true;
      which-key.enable = true;
      treesitter.enable = true;
      telescope.enable = true;

      spectre.enable = true;

      presence-nvim.enable = true;
      nix.enable = true;
      markdown-preview.enable = true;
      lualine.enable = true;
      bufferline.enable = true;

      lsp.enable = true;
      lsp.servers = {
        nil-ls.enable = true;
      };
    };
    extraPlugins = with pkgs.vimPlugins; [
      pywal-nvim
    ];
    
    extraPackages = with pkgs; [
      git
    ];
    keymaps = [
      # new file
      {
        mode = "n";
        key = "<leader>fn";
        action = "<cmd>enew<cr>";
        options = {
          desc = "Create a new file";
        };
      }
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Ex<cr>";
        options = {
          desc = "Explore";
        };
      }
    ];
  };
}
