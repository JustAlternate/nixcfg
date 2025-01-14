{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      jdk17
      maven

      sbt
      sbt-extras
      scala
      scalafmt
      scalafix
    ];
  };
}
