{ inputs, config, ... }:

{
  imports = [
    inputs.nixos-mailserver.nixosModule
  ];

  services.nginx.virtualHosts."mail.justalternate.com" = {
    enableACME = true;
    forceSSL = true;
  };

  mailserver = {
    stateVersion = "5";
    enable = true;
    fqdn = "mail.justalternate.com";
    domains = [
      "justalternate.com"
      "mail.justalternate.com"
    ];

    dkim.defaults = {
      keyLength = 2048;
      selector = "mail2024";
    };

    accounts = {
      "loicw@justalternate.com" = {
        hashedPasswordFile = config.sops.secrets."HASHED_PASSWORD".path;
        aliases = [
          "postmaster@justalternate.com"
          "loicw@mail.justalternate.com"
        ];
      };
      "monitor@justalternate.com" = {
        hashedPasswordFile = config.sops.secrets."MAIL_MONITOR/HASHED_PASSWORD".path;
      };
    };
    x509.useACMEHost = "mail.justalternate.com";
  };

  services.rspamd.locals.greylist.text = ''
    timeout = 90;
  '';
}
