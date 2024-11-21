{
  network.description = "simple hosts";

  "beaver" = _: {
    deployment = {
      targetUser = "root";
      targetHost = "justalternate.fr";
    };
    imports = [ ../../Beaver/configuration.nix ];
  };
}
