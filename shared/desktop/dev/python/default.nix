{ pkgs, ... }:
{
  home = {

    sessionVariables = {
      LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib/"; # fix the problem of dynamic link in python package
    };

    packages = with pkgs; [
      poetry
      SDL2
      SDL2_image
      SDL2_gfx
      (python3.withPackages (
        ps: with ps; [
          jupytext
          notebook
          sentencepiece
          flask
          sklearn-compat
          accelerate
          patool
          einops
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
