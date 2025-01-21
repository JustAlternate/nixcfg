{ pkgs, inputs, ... }:
{
  imports = [
    ./zsh.nix
    ../../shared/ssh.nix
    ../../shared/git.nix
    ./git.nix
    ./ssh.nix
  ];

  home = {
    stateVersion = "24.05";
    packages = with pkgs; [
      postgresql
      unstable.go
      inputs.justnixvim.packages.${system}.default
    ];

    # For env var
    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  xdg.enable = true;
  programs.home-manager.enable = true;
}
