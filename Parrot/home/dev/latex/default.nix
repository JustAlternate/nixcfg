{ pkgs, ... }:
let
  tex = pkgs.texlive.combine {
    inherit (pkgs.texlive) scheme-medium
      tree-dvips;
  };
in
{
  home.packages = [ tex ];
}
