{
  inputs,
  ...
}:
{
  imports = [
    ../../modules/home/zsh.nix
    ../../modules/home/tmux.nix
    ./llm
    ./fastfetch.nix
    ./k9s.nix
    ./packages.nix
    ../../modules/home/aws.nix
    inputs.sops-nix.homeManagerModules.sops
  ];
}
