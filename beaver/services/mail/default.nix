_: {

  imports = [
    (builtins.fetchTarball {
      # Pick a release version you are interested in and set its hash, e.g.
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-25.11/nixos-mailserver-nixos-25.11.tar.gz";
      sha256 = "sha256:0pqc7bay9v360x2b7irqaz4ly63gp4z859cgg5c04imknv0pwjqw";
    })
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
        hashedPasswordFile = /run/secrets/HASHED_PASSWORD;
        aliases = [
          "postmaster@justalternate.com"
        ];
      };
    };
    certificateScheme = "acme-nginx";
  };
}
