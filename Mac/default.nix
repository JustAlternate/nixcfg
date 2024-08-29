{ pkgs, inputs, ... }: {
  imports = [
    ./nvim
    ./zsh
    inputs.sops-nix.homeManagerModules.sops
  ];

  home = {
    stateVersion = "24.05";
    username = "loicweber";
    homeDirectory = "/Users/loicweber/";
    packages = with pkgs; [
      cmatrix
      sops
    ];
  };

  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    defaultSymlinkPath = "/home/loicweber/.config/secrets";
    defaultSecretsMountPoint = "/home/loicweber/.config/secrets.d";
    age.keyFile = "/Users/loicweber/.config/sops/age/keys.txt";
    secrets."test-pass" = { };
  };

  xdg.enable = true;
  programs.home-manager.enable = true;
}
