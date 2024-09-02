{ pkgs, ... }: {

  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/nix/sops/age/keys.txt";
    secrets = {
      test-pass = { };
      "EMAIL" = { owner = "justalternate"; };
      "OWNCLOUD/OWNCLOUD_ADMIN_PASSWORD" = { };
      "PLANKA/SECRET_KEY" = { };
      "TIANJI/POSTGRES_PASSWORD" = { };
      "TIANJI/JWT_SECRET" = { };
    };
  };

  environment = {
    systemPackages = with pkgs; [
      sops
    ];
  };


}
