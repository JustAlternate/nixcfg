{ pkgs, ... }:
{
  imports = [
    # ./R
    ./python
    # ./Ocaml
    ./latex
  ];

  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = [ "justalternate" ];

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
    ];
  };
}
