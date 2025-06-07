{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      poetry
      SDL2
      SDL2_image
      SDL2_gfx
      (python3.withPackages (
        ps: with ps; [
          flask
          requests
          mysql-connector
          hypothesis
          pygame
          psutil
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
          jupyterlab
          scikit-image
          ipympl
          boto3
          psycopg2
          pymysql
          rdflib
        ]
      ))
    ];
  };
}
