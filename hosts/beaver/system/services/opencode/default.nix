{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Basic auth + provider credentials for the mobile agent.
  sops.templates."opencode-env" = {
    path = "/run/secrets/opencode-env";
    owner = "root";
    mode = "0400";
    content = ''
      OPENCODE_SERVER_USERNAME=opencode
      OPENCODE_SERVER_PASSWORD=${config.sops.placeholder."OPENCODE/SERVER_PASSWORD"}
      OPENROUTER_API_KEY=${config.sops.placeholder.OPENROUTER_API_KEY}
    '';
  };

  systemd.services.opencode = {
    description = "opencode server for the phone agent";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-online.target"
      "sops-install-secrets.service"
    ];
    wants = [
      "network-online.target"
      "sops-install-secrets.service"
    ];

    environment = {
      HOME = "/root";
      PATH = lib.mkForce "/run/current-system/sw/bin:/run/wrappers/bin:/etc/profiles/per-user/root/bin";
      OPENCODE_DISABLE_AUTOUPDATE = "1";
    };

    serviceConfig = {
      Type = "simple";
      User = "root";
      WorkingDirectory = "/root/agent";
      EnvironmentFile = config.sops.templates."opencode-env".path;

      # 0.0.0.0 is deliberate: the agent is reachable from the tailnet only.
      # tailscale0 is in networking.firewall.trustedInterfaces, public
      # interfaces drop 4096. Never expose this port through nginx.
      ExecStart = "${pkgs.unstable.opencode}/bin/opencode serve --hostname 0.0.0.0 --port 4096";

      Restart = "always";
      RestartSec = "3s";
      TimeoutStopSec = "10s";
      UMask = "0077";

      # No hardening: this process is the user's root agent and must be able to
      # run nixos-rebuild, read /root, and manage every service. The security
      # boundary is the tailnet + Basic auth, not systemd sandboxing.
    };
  };

  # The service listens on all interfaces but the firewall only trusts
  # tailscale0; no extra port opening is needed or wanted.
}
