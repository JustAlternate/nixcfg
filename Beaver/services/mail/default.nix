_: {

  imports = [
    (builtins.fetchTarball {
      # Pick a release version you are interested in and set its hash, e.g.
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-25.05/nixos-mailserver-nixos-25.05.tar.gz";
      # To get the sha256 of the nixos-mailserver tarball, we can use the nix-prefetch-url command:
      # release="nixos-23.05"; nix-prefetch-url "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz" --unpack
      # sha256 = "sha256:0000000000000000000000000000000000000000000000000000";
      sha256 = "sha256:0jpp086m839dz6xh6kw5r8iq0cm4nd691zixzy6z11c4z2vf8v85";
    })
  ];

  services.nginx.virtualHosts."mail.justalternate.fr" = {
    enableACME = true;
    forceSSL = true;
  };

  services.dovecot2.sieve.extensions = [ "fileinto" ];

  mailserver = {
    # stateVersion = 3;
    enable = true;
    fqdn = "mail.justalternate.fr";
    domains = [
      "justalternate.fr"
      "justalternate.com"
    ];

    # A list of all login accounts. To create the password hashes, use
    # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt'
    loginAccounts = {
      "loicw@justalternate.fr" = {
        hashedPasswordFile = /run/secrets/HASHED_PASSWORD;
        aliases = [ "postmaster@example.com" ];
      };
    };
    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    certificateScheme = "acme-nginx";
  };
}
