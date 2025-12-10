{ pkgs, inputs, ... }:
{
  imports = [
    ./zsh.nix
  ];

  home.packages = with pkgs; [
    unrar
    mpv
    ffmpeg
    imagemagick
    bemoji
    yazi
    cpu-x
    marp-cli
    zip
    unzip
    sshpass

    zoxide
    eza
    fzf
    lazygit
    (llm.withPlugins {
      llm-openrouter = true;
      llm-cmd = true;
    })

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
    minikube
    kubectl
    kubernetes-helm
    k9s
    posting

    ## Monitoring
    nvtopPackages.full
    htop
    powertop
    lshw
    acpi

    # Cli tools
    ## Utility
    xdg-utils
    playerctl
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
    pandoc
    asciiquarium

    ## Show-off
    cmatrix
    cava
    cbonsai

    # Text editors
    vim
    inputs.justnixvim.packages.${system}.default
  ];

  xdg.configFile."io.datasette.llm/aliases.json".source = ./aliases.json;
}
