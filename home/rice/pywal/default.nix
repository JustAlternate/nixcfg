{ pkgs, ... }:
let
  pywalfox = pkgs.python39.pkgs.buildPythonPackage rec {
    pname = "pywalfox";
    version = "2.8.0rc1";
    doCheck = false;
    src = pkgs.fetchurl {
      url = "https://test-files.pythonhosted.org/packages/89/a1/8e011e2d325de8e987f7c0a67222448b252fc894634bfa0d3b3728ec6dbf/pywalfox-2.8.0rc1.tar.gz";
      sha256 = "89e0d7a441eb600933440c713cddbfaecda236bde7f3f655db0ec20b0ae12845"; # Replace with the correct SHA256 hash
    };
  };
in {
  home.packages = with pkgs;
    [
      (python39.withPackages (ps:
        with ps; [
          pywalfox
        ]))

      pywal
    ];
}
