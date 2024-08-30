{ pkgs, inputs, ... }: {
  imports = [
    ./nvim
    ./zsh
    ../shared/sops.nix
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops.age.keyFile = "/Users/loicweber/.config/sops/age/keys.txt";

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
