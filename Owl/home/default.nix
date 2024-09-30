{ pkgs, ... }: {
  imports = [
    ./zsh.nix
    ../../shared/nvim
    # ../../shared/sops.nix
    ../../shared/ssh.nix
    ../../shared/git.nix
    ./git.nix
    ./ssh.nix
  ];

  home = {
    stateVersion = "24.05";
    packages = with pkgs; [
      cmatrix
    ];
  };

  xdg.enable = true;
  programs.home-manager.enable = true;
}
