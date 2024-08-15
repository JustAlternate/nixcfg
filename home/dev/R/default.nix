{ pkgs
, ...
}:
let
  list-packages = with rPackages; [
    ggplot2
    dplyr
    xts
  ];
  r-with-packages = rWrapper.override { packages = list-packages; };
in
{
  home = {
    packages = with pkgs;
      [
        r-with-packages
      ];
  };
}
