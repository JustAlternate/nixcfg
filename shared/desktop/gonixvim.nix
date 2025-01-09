{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    inputs.gonixvim.packages.${system}.default
  ];
}
