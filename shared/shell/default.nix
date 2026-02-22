{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./zsh.nix
    ./LLM
    ./fastfetch.nix
    inputs.sops-nix.homeManagerModules.sops
  ];

  home.packages = with pkgs; [
    ffmpeg
    bemoji
    yazi
    marp-cli
    zip
    sshpass
    compose2nix
    zoxide
    eza
    fzf
    lazygit
    # Development
    openssh
    git
    gcc
    lua
    go
    cmake
    gnumake
    opentofu
    awscli2
    devenv
    pre-commit
    gh
    statix # Lints and suggestions for the nix programming language
    deadnix # Find and remove unused code in .nix source files
    nixfmt-rfc-style # Nix Code Formatter
    kubectl
    kubernetes-helm
    k9s
    # Monitoring
    htop
    # Cli tools
    direnv
    ## Utility
    xdg-utils
    unzip
    wget
    wl-clipboard
    wl-clipboard-x11
    cliphist
    ripgrep
    pamixer
    fzf
    socat
    jq
    ani-cli
    sshfs
    sops
    pandoc
    mermaid-filter
    pandoc-katex
    asciiquarium
    ## Show-off
    cmatrix
    cava
    cbonsai
    # Text editors
    vim
    inputs.justnixvim.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
