{
  inputs,
  ...
}:
{
  imports = [
    ../../../modules/home/zsh.nix
    ../../../home/shell/llm
    ../../../home/shell/fastfetch.nix
    ../../../home/shell/k9s.nix
    ../../../home/shell/packages.nix
    ../../../modules/home/ssh.nix
    ../../../modules/home/git.nix
    inputs.sops-nix.homeManagerModules.sops
    ./agent.nix
  ];

  home = {
    username = "root";
    homeDirectory = "/root";

    stateVersion = "24.05";

    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  zsh = {
    tmuxAutoStart.enable = false;
  };

  programs.home-manager.enable = true;
}
