# Open WebUI — see ./RUNBOOK.md for the model-visibility pitfalls and ops.
#
# The Admin -> Models "create/sync" flow writes inactive `base_model_id = NULL`
# override rows that HIDE the matching provider model (utils/models.py
# get_all_models removes it from the list). `owui-models` cleans those up.
{ config, pkgs, ... }:
let
  # On-demand reconciler for the Open WebUI model table (see `owui-models -h`).
  owuiModels = pkgs.callPackage ../../../../../packages/owui-models { };
in
{
  environment.systemPackages = [ owuiModels ];

  services = {
    open-webui = {
      enable = true;
      port = 3040;
      host = "127.0.0.1";
      openFirewall = false;
      environmentFile = config.sops.secrets."OPENWEBUI/ENV".path;
      environment = {
        WEBUI_CORS_ALLOW_ORIGIN = "https://ai.justalternate.com";
        USER_AGENT = "open-webui (beaver; justalternate.com)";
        # The Admin -> Models create/sync flow writes inactive base_model_id=NULL
        # override rows that hide the matching provider model. This instance
        # wants the whole provider catalog usable by every signed-in user, so
        # skip per-model access grants.
        BYPASS_MODEL_ACCESS_CONTROL = "true";
      };
    };

    nginx.virtualHosts."ai.justalternate.com" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3040";
        proxyWebsockets = true;
      };
    };
  };

  systemd = {
    services = {
      open-webui = {
        wants = [ "nginx.service" ];
        after = [ "nginx.service" ];
        bindsTo = [ "nginx.service" ];
        path = [ pkgs.ffmpeg ];
      };
    };
  };
}
