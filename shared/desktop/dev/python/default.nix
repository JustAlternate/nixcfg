{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      poetry
      SDL2
      SDL2_image
      (python3.withPackages (
        ps: with ps; [
          flask
          pygame
          pygame-sdl2
          psutil
          matplotlib
          numpy
          opencv4
          pandas
          pillow
          pip
          pipenv
          plotly
          pytorch
          requests
          scipy
          seaborn
          transformers
          virtualenv
        ]
      ))
    ];
  };
}
