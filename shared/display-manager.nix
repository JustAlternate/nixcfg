{ pkgs, ... }:
{
  services.displayManager = {
    sddm = {
      enable = true;
      wayland.enable = true;
      theme = "catppuccin-mocha";
      package = pkgs.kdePackages.sddm;
    };
    autoLogin = {
      enable = true;
      user = "justalternate";
    };
  };

  environment.systemPackages = [
    (
      pkgs.catppuccin-sddm.override {
        flavor = "mocha";
        font = "Noto Sans";
        fontSize = "11";
        background = "${./wallpaper/nix-wallapaper-logo-blue.jpg}";
        loginBackground = true;
      })
  ];
}
