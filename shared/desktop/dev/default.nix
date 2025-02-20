{ pkgs, ... }:
{
  imports = [
    # ./R
    ./python
    # ./Ocaml
    ./latex
    ./java
  ];

  home = {
    packages = with pkgs; [
      # Development
      # nodePackages.node2nix
      openssh
      # scdoc
      git
      gcc
      lua
      go
      cmake
      gnumake
      duckdb
      dbt
      # framac
      terraform
      awscli2
      github-markdown-toc-go

      devenv
      pre-commit
    ];
  };
}
