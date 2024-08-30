{ pkgs, inputs, ... }: {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    secrets = {
      test-pass = { };
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
