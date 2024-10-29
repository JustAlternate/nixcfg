{ pkgs
, ...
}:
{
  imports = [
    ./R
    ./python
    ./Ocaml
    ./latex
  ];

  home = {
    packages = with pkgs;
      [
        # Developpment
        nodePackages.node2nix
        openssh
        scdoc
        git
        gcc
        lua
        go
        cmake
        gnumake
        # framac
      ];
  };
}
