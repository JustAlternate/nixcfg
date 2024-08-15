{ pkgs
, ...
}:
{
  home = {
    packages = with pkgs; [
      (
        python3.withPackages (ps:
          with ps; [
            flask
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
        )
      )
    ];
  };
}
