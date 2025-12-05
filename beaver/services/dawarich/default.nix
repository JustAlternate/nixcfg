_: {
  imports = [
    ./definition.nix
  ];
  services.dawarich = {
    enable = true;
    localDomain = "geo.justalternate.com";
    webPort = 3001;
  };
}
