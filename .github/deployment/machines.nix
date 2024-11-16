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

  "beaver" = import ../../Beaver/configuration.nix;
}
