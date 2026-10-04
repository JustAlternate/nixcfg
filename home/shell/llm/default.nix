{
  pkgs,
  ...
}:
let
  recall = pkgs.callPackage ../../../packages/recall { };
in
{
  home.packages = with pkgs; [
    (llm.withPlugins {
      llm-openrouter = true;
      llm-cmd = true;
    })

    unstable.opencode
    unstable.rtk
    recall
  ];

  xdg.configFile = {
    "io.datasette.llm/aliases.json".source = ./llm-aliases.json;
    "opencode/skills/recall/SKILL.md".source = ./SKILL.md;
  };

  home.file = {
    ".config/opencode/AGENTS.md".source = ./AGENTS.md;
  };
}
