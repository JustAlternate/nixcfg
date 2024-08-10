{
  lib,
  pkgs,
  ...
}: {
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      # LazyVim
      cmake
      stylua
      lazygit
      fd

      # Telescope
      ripgrep

      # LSP stuff
      # Nix
      nil
      statix # Lints and suggestions for the nix programming language
      deadnix # Find and remove unused code in .nix source files
      alejandra # Nix Code Formatter
      lua-language-server
      pyright
      gopls
    ];

    plugins = with pkgs.vimPlugins; [
      lazy-nvim
    ];

    extraLuaConfig = let
      plugins = with pkgs.vimPlugins; [
        # LazyVim
        LazyVim
        bufferline-nvim
        cmp-buffer
        cmp-nvim-lsp
        cmp-path
        cmp_luasnip
        conform-nvim
        dashboard-nvim
        dressing-nvim
        flash-nvim
        friendly-snippets
        gitsigns-nvim
        markdown-preview-nvim
        indent-blankline-nvim
        lualine-nvim
        neodev-nvim
        noice-nvim
        nui-nvim
        nvim-cmp
        nvim-lint
        nvim-lspconfig
        nvim-notify
        nvim-spectre
        nvim-treesitter
        nvim-treesitter-context
        nvim-treesitter-textobjects
        nvim-ts-autotag
        nvim-ts-context-commentstring
        nvim-web-devicons
        persistence-nvim
        plenary-nvim
        telescope-nvim
        todo-comments-nvim
        tokyonight-nvim
        trouble-nvim
        telescope-fzf-native-nvim
        vim-illuminate
        vim-startuptime
        which-key-nvim
        {
          name = "LuaSnip";
          path = luasnip;
        }
        {
          name = "mini.ai";
          path = mini-nvim;
        }
        {
          name = "mini.bufremove";
          path = mini-nvim;
        }
        {
          name = "mini.comment";
          path = mini-nvim;
        }
        {
          name = "mini.indentscope";
          path = mini-nvim;
        }
        {
          name = "mini.pairs";
          path = mini-nvim;
        }
        {
          name = "mini.surround";
          path = mini-nvim;
        }
        nvim-colorizer-lua
        none-ls-nvim
        null-ls-nvim
      ];
      mkEntryFromDrv = drv:
        if lib.isDerivation drv
        then {
          name = "${lib.getName drv}";
          path = drv;
        }
        else drv;
      lazyPath = pkgs.linkFarm "lazy-plugins" (builtins.map mkEntryFromDrv plugins);
    in ''
      require("lazy").setup({
        defaults = {
          lazy = true,
        },
        dev = {
          -- reuse files from pkgs.vimPlugins.*
          path = "${lazyPath}",
          patterns = { "." },
          -- fallback to download
          fallback = true,
        },
        spec = {
          { "LazyVim/LazyVim", import = "lazyvim.plugins" },
          { import = "lazyvim.plugins.extras.lsp.none-ls" },
          { "folke/neoconf.nvim", enabled = false },

          -- The following configs are needed for fixing lazyvim on nix
          -- force enable telescope-fzf-native.nvim
          { "nvim-telescope/telescope-fzf-native.nvim", enabled = true },
          -- disable mason.nvim, use programs.neovim.extraPackages
          { "williamboman/mason-lspconfig.nvim", enabled = false },
          { "williamboman/mason.nvim", enabled = false },

          -- import/override with your plugins
          { import = "plugins" },

          -- treesitter handled by xdg.configFile."nvim/parser", put this line at the end of spec to clear ensure_installed
          { "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = {} } },
        },
      })
      local pywal16 = require('pywal16')
      pywal16.setup()
      local lualine = require('lualine')
      lualine.setup {
        options = {
          theme = 'pywal16-nvim',
        },
      }
      require('colorizer').setup()
    '';
  };

  # https://github.com/nvim-treesitter/nvim-treesitter#i-get-query-error-invalid-node-type-at-position
  xdg.configFile."nvim/parser".source = let
    parsers = pkgs.symlinkJoin {
      name = "treesitter-parsers";
      paths =
        (pkgs.vimPlugins.nvim-treesitter.withPlugins (plugins:
          with plugins; [
            c
            lua
            python
            nix
            css
            java
            json
            javascript
            html
            bash
            ocaml
            latex
            vimdoc
            go
            markdown
            dockerfile
            vim
            sql
            make
          ]))
        .dependencies;
    };
  in "${parsers}/parser";

  # Normal LazyVim config here, see https://github.com/LazyVim/starter/tree/main/lua
  xdg.configFile."nvim/lua".source = ./lua;
}
