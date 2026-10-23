_: {
  # Workspace for the opencode server that the user chats with from their
  # phone (hosts/beaver/system/services/opencode). Kept in /root/agent so the
  # server has a stable cwd and its project config applies.
  home.file = {
    "agent/opencode.json".text = ''
      {
        "$schema": "https://opencode.ai/config.json",
        "permission": {
          "edit": "allow",
          "bash": "allow",
          "webfetch": "allow",
          "external_directory": "allow",
          "doom_loop": "allow"
        },
        "share": "disabled",
        "autoupdate": false
      }
    '';

    "agent/AGENTS.md".source = ./agent-AGENTS.md;
  };
}
