{ pkgs, ... }:
let
  selfSigned = pkgs.runCommand "nginx-selfsigned-default"
    { buildInputs = [ pkgs.openssl ]; }
    ''
      mkdir -p $out
      openssl req -x509 -newkey ed25519 -keyout $out/key.pem -out $out/cert.pem \
        -days 3650 -nodes -subj "/CN=localhost" -addext "subjectAltName=DNS:localhost"
    '';
in
{
  services = {
    nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;

      virtualHosts = {
        # catch-all: drop everything that doesn't match a known Host header
        "_" = {
          listen = [
            { addr = "0.0.0.0"; port = 80; extraParameters = [ "default_server" ]; }
            { addr = "[::0]"; port = 80; extraParameters = [ "default_server" ]; }
            { addr = "0.0.0.0"; port = 443; ssl = true; extraParameters = [ "default_server" ]; }
            { addr = "[::0]"; port = 443; ssl = true; extraParameters = [ "default_server" ]; }
          ];
          extraConfig = ''
            ssl_certificate ${selfSigned}/cert.pem;
            ssl_certificate_key ${selfSigned}/key.pem;
            return 444;
          '';
        };

        "justalternate.com" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:8923";
          };
        };
        "loicw.com" = {
          enableACME = true;
          forceSSL = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:8923";
          };
        };
      };
    };
  };
  security.acme = {
    acceptTerms = true;
    useRoot = true;
    defaults = {
      email = "loicw@justalternate.com";
      reloadServices = [
        "nginx.service"
        "dovecot2.service"
        "postfix.service"
      ];
      extraLegoRenewFlags = [ "--ari-disable" ];
    };
  };
}
