{
  config,
  pkgs,
  lib,
  ...
}:
let
  mcpBridge = pkgs.callPackage ../../../../../packages/mcp-opencode-bridge { };
in
{
  sops.templates."opencode-server-env" = {
    path = "/run/opencode-server-env";
    content = ''
      OPENCODE_SERVER_PASSWORD='${config.sops.placeholder.OPENCODE_SERVER_PASSWORD}'
    '';
  };

  systemd.services.opencode-server = {
    description = "OpenCode headless server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      Type = "simple";
      User = "root";
      WorkingDirectory = "/root/nixcfg";
      ExecStart = "${pkgs.master.opencode}/bin/opencode serve --port 4097 --hostname 127.0.0.1";
      Restart = "on-failure";
      RestartSec = 10;
      EnvironmentFile = "/run/opencode-server-env";
    };
  };

  systemd.services.mcp-opencode-bridge = {
    description = "MCP bridge to OpenCode server";
    wantedBy = [ "multi-user.target" ];
    after = [
      "opencode-server.service"
      "network.target"
    ];
    wants = [ "opencode-server.service" ];

    serviceConfig = {
      Type = "simple";
      User = "root";
      ExecStart = "${mcpBridge}/bin/mcp-opencode-bridge --port 4200 --opencode-url http://127.0.0.1:4097";
      EnvironmentFile = "/run/opencode-server-env";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
