{ pkgs, lib, ... }:
let
  inherit (lib) mkForce;
in
{
  programs.git = {
    enable = true;
    userName = mkForce "JustAlternateIDZ";
    userEmail = mkForce "loic.weber@iadvize.com";
  };
}
