{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    (llm.withPlugins {
      llm-openrouter = true;
      llm-cmd = true;
    })

    unstable.opencode
    unstable.rtk
  ];

  xdg.configFile."io.datasette.llm/aliases.json".source = ./llm-aliases.json;
  xdg.configFile."opencode/plugins/rtk.ts".source = ./rtk.ts;

  home.file = {
    ".vibe/instructions.md".source = ./AGENTS.md;
    ".config/opencode/AGENTS.md".source = ./AGENTS.md;
  };
}
