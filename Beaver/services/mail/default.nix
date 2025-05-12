_: {

  imports = [
    (builtins.fetchTarball {
      # Pick a release version you are interested in and set its hash, e.g.
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/da66510f688b7eac54e3cac7c75be4b8dd78ce8b/nixos-mailserver-da66510f688b7eac54e3cac7c75be4b8dd78ce8b.tar.gz";
      # To get the sha256 of the nixos-mailserver tarball, we can use the nix-prefetch-url command:
      # release="nixos-23.05"; nix-prefetch-url "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz" --unpack
      sha256 = "sha256:0imxmdbx8z0hn0yvgrhazs0qx788a92w8hgysr1vlqfxwd4qc3gf";
    })
  ];

  services.nginx.virtualHosts."mail.justalternate.fr" = {
    enableACME = true;
    forceSSL = true;
    listen = [
      {
        addr = "0.0.0.0";
        port = 80;
      }
      {
        addr = "0.0.0.0";
        port = 995;
      }
      {
        addr = "0.0.0.0";
        port = 8443;
        ssl = true;
      }
    ];
  };

  services.dovecot2.sieve.extensions = [ "fileinto" ];

  mailserver = {
    enable = true;
    enableImap = false;
    enableImapSsl = true;
    enableSubmission = true;
    enableSubmissionSsl = false;
    fqdn = "mail.justalternate.fr";
    domains = [ "justalternate.fr" ];

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
