{ pkgs, ... }: {
  imports = [
    ./nvim
    ./zsh
    ./docker
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
