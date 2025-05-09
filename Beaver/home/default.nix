{ pkgs, inputs, ... }:
{
  imports = [
    ../../shared/fastfetch.nix
    ../../shared/zsh.nix
    ../../shared/ssh.nix
    ../../shared/git.nix
  ];

  home = {
    username = "root";
    homeDirectory = "/root";

    stateVersion = "24.05";

    packages = with pkgs; [
      # Cli tools
      ## Utility
      unzip
      wget
      ripgrep
      socat
      jq
      lazygit
      sops
      zip
      terraform
      awscli2
      compose2nix

      inputs.justnixvim.packages.${system}.default

      ## Monitoring
      htop
    ];

    # For env var
    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
