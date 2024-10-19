{ pkgs, ... }:
let
  tex = pkgs.texlive.combine {
    inherit (pkgs.texlive)
      scheme-medium
      tree-dvips
      xstring
      totpages
      environ
      hyperxmp
      comment
      fancyhdr
      ncctools
      ifmtarg
      ;
  };
in
{
  home.packages = [ tex ];
}
