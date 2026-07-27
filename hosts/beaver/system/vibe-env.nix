{
  config,
  ...
}:
{
  sops.templates."vibe-env" = {
    path = "/root/.vibe/.env";
    content = ''
      MISTRAL_API_KEY='${config.sops.placeholder.MISTRAL_API_KEY}'
      OPENROUTER_API_KEY='${config.sops.placeholder.OPENROUTER_API_KEY}'
    '';
  };
}
