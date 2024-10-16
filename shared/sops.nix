{ pkgs, ... }: {

  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/nix/sops/age/keys.txt";
    secrets = {
      "HASHED_PASSWORD" = { };
      "PASSWORD" = { };
      "EMAIL" = { };
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
