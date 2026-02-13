{ inputs, config, ... }:

{
  imports = [
    inputs.nixos-mailserver.nixosModule
  ];

  services.nginx.virtualHosts."mail.justalternate.com" = {
    enableACME = true;
    forceSSL = true;
  };

  services.dovecot2.sieve.extensions = [ "fileinto" ];

  mailserver = {
    stateVersion = 3;
    enable = true;
    fqdn = "mail.justalternate.com";
    domains = [
      "justalternate.com"
    ];

    loginAccounts = {
      "loicw@justalternate.com" = {
        hashedPasswordFile = config.sops.secrets."HASHED_PASSWORD".path;
        aliases = [
          "postmaster@justalternate.com"
        ];
      };
    };
    certificateScheme = "acme-nginx";
  };
}
