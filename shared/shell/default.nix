{
  pkgs,
  inputs,
  config,
  ...
}:
{
  imports = [
    ./zsh.nix
    inputs.sops-nix.homeManagerModules.sops
  ];

  home.packages = with pkgs; [
    unrar
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
    kubectl
    kubernetes-helm
    k9s

    ## Monitoring
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
    sops
    pandoc
    asciiquarium

    ## Show-off
    cmatrix
    cava
    cbonsai

    # Text editors
    vim
    inputs.justnixvim.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.mistral-vibe.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  xdg.configFile."io.datasette.llm/aliases.json".source = ./aliases.json;
  home.file = {
    ".vibe/instructions.md".source = ./vibe/instructions.md;
  };
  sops.templates."vibe-env" = {
    path = "${config.home.homeDirectory}/.vibe/.env";
    content = ''
      			MISTRAL_API_KEY='${config.sops.placeholder.MISTRAL_API_KEY}'
      			OPENROUTER_API_KEY='${config.sops.placeholder.OPENROUTER_API_KEY}'
      		'';
  };
}
