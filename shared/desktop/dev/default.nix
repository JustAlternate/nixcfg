{ pkgs, inputs, ... }:
{
  imports = [
    # ./R
    ./python
    # ./Ocaml
    # ./latex
    ./java
  ];

  home = {
    packages = with pkgs; [
      # Development
      # nodePackages.node2nix
      openssh
      # scdoc
      git
      gcc
      lua
      go
      cmake
      gnumake
      # duckdb
      # dbt
      # framac
      terraform
      awscli2
      github-markdown-toc-go

      devenv
      pre-commit

      nodejs_23
      gh

      typst
      typstyle
      typstfmt
      typst-live

      ## Monitoring
      nvtopPackages.full
      htop
      powertop
      lshw
      acpi
      mission-center

      # Cli tools
      ## Utility
      xdg-utils
      playerctl
      unzip
      wget
      wl-clipboard
      wl-clipboard-x11
      cliphist
      busybox
      ripgrep
      thefuck
      pamixer
      fzf
      socat
      jq
      ani-cli
      sshfs
      pandoc
      lazygit
      statix # Lints and suggestions for the nix programming language
      deadnix # Find and remove unused code in .nix source files
      nixfmt-rfc-style # Nix Code Formatter
      asciinema-agg
      asciinema

      ## Show-off
      cmatrix
      cava
      cbonsai

      # Text editors
      vim
      inputs.justnixvim.packages.${system}.default
      claude-code

    ];
  };
}
