_: {

  imports = [
    (builtins.fetchTarball {
      # Pick a release version you are interested in and set its hash, e.g.
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-25.11/nixos-mailserver-nixos-25.11.tar.gz";
      # To get the sha256 of the nixos-mailserver tarball, we can use the nix-prefetch-url command:
      # release="nixos-23.05"; nix-prefetch-url "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz" --unpack
      sha256 = "sha256:16kanlk74xnj7xgmjsj7pahy31hlxqcbv76xnsg8qbh54b0hwxgq";
      # sha256 = "sha256:1qn5fg0h62r82q7xw54ib9wcpflakix2db2mahbicx540562la1y";
      # sha256 = "sha256:0la8v8d9vzhwrnxmmyz3xnb6vm76kihccjyidhfg6qfi3143fiwq";
    })
  ];

  services.nginx.virtualHosts."mail.justalternate.fr" = {
    enableACME = true;
    forceSSL = true;
  };

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
      "justalternate.fr"
      "justalternate.com"
    ];

    loginAccounts = {
      "loicw@justalternate.com" = {
        hashedPasswordFile = /run/secrets/HASHED_PASSWORD;
        aliases = [
          "loicw@justalternate.fr"
          "postmaster@justalternate.com"
        ];
      };
    };
    certificateScheme = "acme-nginx";
  };
}
