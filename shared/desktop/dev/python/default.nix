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
          jupytext
          notebook
          sentencepiece
          flask
          keyboard
          # pyautogui
          python313Packages.torchWithRocm
          python313Packages.torchvision
          # sklearn-compat
          accelerate
          patool
          einops
          requests
          mysql-connector
          hypothesis
          ollama
          # jupyterlab
          pygame
          psutil
          pygame-sdl2
          matplotlib
          numpy
          # opencv4
          pandas
          pillow
          pip
          pipenv
          plotly
          requests
          # scipy
          # seaborn
          transformers
          virtualenv
          # scikit-image
          # ipympl
          # scikit-learn
          # networkx
          boto3
          # pyvis
          # nltk
          psycopg2
          pymysql
          # rdflib
          tkinter
          marimo
          duckdb
          altair
          polars
          pyarrow
          sqlglot
          nbformat
        ]
      ))
    ];
  };
}
