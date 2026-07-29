{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ../../../modules/home/zsh.nix
    ../../../home/shell/llm.nix
    ../../../home/shell/fastfetch.nix
    ../../../home/shell/k9s.nix
    ../../../modules/home/ssh.nix
    ../../../modules/home/git.nix
    inputs.sops-nix.homeManagerModules.sops
  ];

  home = {
    username = "root";
    homeDirectory = "/root";

    stateVersion = "24.05";

    sessionVariables = {
      EDITOR = "nvim";
    };

    packages = with pkgs; [
      ffmpeg
      bemoji
      marp-cli
      compose2nix
      lazygit
      openssh
      gcc
      lua
      go
      unstable.golangci-lint
      cmake
      gnumake
      opentofu
      awscli2
      devenv
      gh
      bat
      eza
      zoxide
      gh-dash
      statix
      deadnix
      nixfmt
      kubectl
      kubernetes-helm
      ani-cli
      vim
      inputs.justnixvim.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.fleettui.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };

  zsh = {
    envVar.enable = false;
    tmuxAutoStart.enable = false;
  };

  programs.home-manager.enable = true;
}
