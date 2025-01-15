{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      jdk17
      maven

      sbt-extras
      scala
      scalafmt
      scalafix
    ];
  };
}
