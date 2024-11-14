_: {
  network = {
    description = "Beaver";
  };
  "Beaver" = _: { imports = [ ../../Beaver/configuration.nix ]; };
}
