_: {
  imports = [
    (builtins.fetchTarball {
      # Pick a release version you are interested in and set its hash, e.g.
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-23.05/nixos-mailserver-nixos-23.05.tar.gz";
      # To get the sha256 of the nixos-mailserver tarball, we can use the nix-prefetch-url command:
      # release="nixos-23.05"; nix-prefetch-url "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz" --unpack
      sha256 = "1ngil2shzkf61qxiqw11awyl81cr7ks2kv3r3k243zz7v2xakm5c";
    })
  ];

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
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "loicw@justalternate.fr";
}
