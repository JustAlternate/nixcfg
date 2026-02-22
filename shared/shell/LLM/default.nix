{
  pkgs,
  inputs,
  config,
  ...
}:
{

  home.packages = with pkgs; [
    (llm.withPlugins {
      llm-openrouter = true;
      llm-cmd = true;
    })

    inputs.mistral-vibe.packages.${pkgs.stdenv.hostPlatform.system}.default
    master.opencode
  ];

  xdg.configFile."io.datasette.llm/aliases.json".source = ./aliases.json;

  home.file = {
    ".vibe/instructions.md".source = ./AGENTS.md;
    ".config/opencode/AGENTS.md".source = ./AGENTS.md;
  };

  sops.templates."vibe-env" = {
    path = "${config.home.homeDirectory}/.vibe/.env";
    content = ''
      			MISTRAL_API_KEY='${config.sops.placeholder.MISTRAL_API_KEY}'
      			OPENROUTER_API_KEY='${config.sops.placeholder.OPENROUTER_API_KEY}'
      		'';
  };
}
