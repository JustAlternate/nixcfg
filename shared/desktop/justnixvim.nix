{
  pkgs,
  inputs,
  ...
}:
{
  home.packages = with pkgs; [
    inputs.justnixvim.packages.${system}.default
  ];
}
