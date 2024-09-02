{ pkgs
, ...
}:
{
  imports = [
    ./fastfetch
    ./zsh.nix
    ../../shared/nvim
    ../../shared/ssh.nix
    ../../shared/git.nix
  ];

  home = {
    username = "root";
    homeDirectory = "/root";

    stateVersion = "24.05";

    packages = with pkgs;
      [
        # Cli tools
        ## Utility
        unzip
        wget
        ripgrep
        socat
        jq
        lazygit
        sops

        ## Monitoring
        htop
      ];

    # For env var
    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  nixpkgs.config.allowUnfree = true;

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
