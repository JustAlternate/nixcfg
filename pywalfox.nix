{ pkgs, ... }:

let

  pywalfox = pkgs.python39.pkgs.buildPythonPackage rec {
    pname = "pywalfox";
    version = "2.7.4";
    doCheck = false;
    src = pkgs.python39.pkgs.fetchPypi {
      inherit pname version;
      sha256 = "0rpdh1k4b37n0gcclr980vz9pw3ihhyy0d0nh3xp959q4xz3vrsr";
    };
  };

in {
  home.packages = with pkgs;
    [
      (python39.withPackages (ps:
        with ps; [
          # Pywall for Firefox
          pywalfox
        ]))
    ];
}
