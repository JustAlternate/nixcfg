{ pkgs, ... }:
{
  home = {
    packages =
      with pkgs;
      let
        list-packages = with rPackages; [
          ggplot2
          dplyr
          xts
          cluster
        ];
        r-with-packages = rWrapper.override { packages = list-packages; };
      in
      [ r-with-packages ];
  };
}
