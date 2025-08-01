_:
# let
#   tex = pkgs.texlive.combine {
#     inherit (pkgs.texlive)
#       scheme-medium
#       tree-dvips
#       xstring
#       totpages
#       environ
#       hyperxmp
#       comment
#       fancyhdr
#       ncctools
#       ifmtarg
#       tocloft
#       pst-tree
#       pstricks
#       listings
#       ;
#   };
# in
{
  home.packages = [
    #tex
    #pkgs.texliveFull
  ];
}
