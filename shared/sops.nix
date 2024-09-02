{ pkgs, inputs, ... }: {

  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "~/.config/sops/age/keys.txt";
    secrets = {
      test-pass = { };
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
