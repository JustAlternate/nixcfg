_: {

  imports = [
    (builtins.fetchTarball {
      # Pick a release version you are interested in and set its hash, e.g.
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-25.05/nixos-mailserver-nixos-25.05.tar.gz";
      # To get the sha256 of the nixos-mailserver tarball, we can use the nix-prefetch-url command:
      # release="nixos-23.05"; nix-prefetch-url "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz" --unpack
      # sha256 = "sha256:0000000000000000000000000000000000000000000000000000";
      sha256 = "sha256:1qn5fg0h62r82q7xw54ib9wcpflakix2db2mahbicx540562la1y";
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
    # stateVersion = 3;
    enable = true;
    fqdn = "mail.justalternate.com";
    domains = [
      "justalternate.fr"
      "justalternate.com"
    ];

    # A list of all login accounts. To create the password hashes, use
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    loginAccounts = {
      "loicw@justalternate.com" = {
        hashedPasswordFile = /run/secrets/HASHED_PASSWORD;
        aliases = [
          "loicw@justalternate.fr"
          "postmaster@justalternate.com"
        ];
      };
    };
    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    certificateScheme = "acme-nginx";
  };
}
