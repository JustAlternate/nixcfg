{ pkgs, ... }: {
  imports = [
    ./zsh.nix
    ../shared/nvim
    ../shared/sops.nix
    ../shared/ssh.nix
    ../shared/git.nix
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
