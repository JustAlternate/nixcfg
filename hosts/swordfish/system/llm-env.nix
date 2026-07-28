{ config, ... }:
{
  sops.templates."user-llm-env" = {
    path = "/home/justalternate/.config/secrets/llm.env";
    owner = "justalternate";
    group = "users";
    mode = "0400";
    content = ''
      OPENROUTER_API_KEY='${config.sops.placeholder.OPENROUTER_API_KEY}'
    '';
  };
}
