{ pkgs, ... }:
{
  services = {
    nginx = {
      enable = true;
      package = pkgs.nginxStable.override { openssl = pkgs.libressl; };

      recommendedProxySettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = false;

      virtualHosts = {
        "10.153.25.10" = {
          listen = [
            {
              addr = "0.0.0.0";
              port = 80;
            }
          ];
          root = "/var";
        };
      };
    };
  };
}
