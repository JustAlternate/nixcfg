{
  config,
  inputs,
  ...
}:
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    secrets = {
      "AWS/ACCESS_KEY_ID" = { };
      "AWS/SECRET_ACCESS_KEY" = { };
    };

    templates."aws-credentials" = {
      path = "${config.home.homeDirectory}/.aws/credentials";
      mode = "0600";
      content = ''
        [default]
        aws_access_key_id = ${config.sops.placeholder."AWS/ACCESS_KEY_ID"}
        aws_secret_access_key = ${config.sops.placeholder."AWS/SECRET_ACCESS_KEY"}
      '';
    };

    templates."aws-config" = {
      path = "${config.home.homeDirectory}/.aws/config";
      mode = "0600";
      content = ''
        [default]
        region = eu-west-3
      '';
    };
  };
}
