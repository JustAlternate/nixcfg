_: {
  # ============================================
  # GitHub Actions Runner Configuration
  # ============================================

  # SOPS secrets for CI/CD
  sops.secrets.github-token-beaver-ci = {
    sopsFile = ../../../secrets/secrets.yaml;
    key = "GITHUB_TOKEN_BEAVER_CI";
    owner = "root";
    group = "root";
    mode = "0400";
  };

  sops.secrets.cachix-auth-token = {
    sopsFile = ../../../secrets/secrets.yaml;
    key = "CACHIX_AUTH_TOKEN";
    owner = "root";
    group = "root";
    mode = "0400";
  };

  services.github-runners.beaver = {
    enable = true;
    name = "beaver-aarch64";
    url = "https://github.com/JustAlternate/nixcfg";
    tokenFile = config.sops.secrets.github-token-beaver-ci.path;

    # Use the mounted 40GB volume
    workDir = "/var/lib/github-runner";

    # Labels to target this runner
    extraLabels = [
      "beaver"
      "aarch64-linux"
      "nixcfg"
    ];

    # Replace existing runner with same name
    replace = true;

    # Additional packages available to runner
    extraPackages = with pkgs; [
      git
      cachix
      sops
    ];

    # Environment variables
    extraEnvironment = {
      # Cachix auth token for pushing builds
      CACHIX_AUTH_TOKEN_FILE = config.sops.secrets.cachix-auth-token.path;
      # Ensure nix can find the flake
      NIX_PATH = "nixpkgs=${pkgs.path}";
    };

    # Service overrides for resource limits
    serviceOverrides = {
      # Limit resources to prevent impacting services
      MemoryMax = "8G";
      CPUQuota = "80%";
    };
  };
}
