let
  pkgs = import (import ./nixpkgs.nix) { };
in
{
  network = {
    inherit pkgs;
    description = "simple hosts";
    ordering = {
      tags = [ "beaver" ];
    };
  };

  "beaver" = _: {
    deployment.tags = [ "beaver" ];
    imports = [ ../../Beaver/configuration.nix ];
  };
}
