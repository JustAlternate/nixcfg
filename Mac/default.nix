{ pkgs, ... }: {
  imports = [
    ./nvim
    ./zsh
    ../shared/sops.nix
    ../shared/ssh.nix
  ];

  home = {
    stateVersion = "24.05";
    username = "loicweber";
    homeDirectory = "/Users/loicweber/";
    packages = with pkgs; [
      cmatrix
    ];
  };

  xdg.enable = true;
  programs.home-manager.enable = true;
}
