{ pkgs, lib, ... }:
let
  dsh = pkgs.callPackage ../../packages/dsh { };

  # Official DeepSeek whale (GitHub org avatar, 256px).
  dshIcon = ../../assets/icons/deepseek-logo.png;

  # Launcher for the dsh web UI (rofi/desktop entry target). If the server is
  # already up, just open a new browser tab and leave it alone; otherwise
  # start it, wait for it to answer, then open the tab.
  # Named "deepseek-web" — NOT "dsh-*" — so the `pkill -f "dsh.*web"` below
  # cannot self-match this script's own cmdline and kill the launcher.
  deepseek-web = pkgs.writeShellApplication {
    name = "deepseek-web";
    runtimeInputs = [
      dsh
      pkgs.coreutils
      pkgs.curl
      pkgs.procps
      pkgs.xdg-utils
    ];
    text = ''
      # Project dir the web UI opens in; override with DSH_WEB_DIR=...
      cd "''${DSH_WEB_DIR:-$HOME}"

      # Server already up (e.g. started manually in a terminal): don't touch it.
      if curl -fsS -o /dev/null --max-time 2 http://127.0.0.1:3080; then
        exec xdg-open http://127.0.0.1:3080
      fi

      # Server down: clear any stale dsh web process still holding the port.
      pkill -f "dsh.*web" 2>/dev/null || true
      sleep 1

      # Rofi launches bypass zsh, so the API key (sourced in zsh.nix for
      # interactive shells) must be provided here. SOPS-rendered, root-owned.
      if [ -r /run/secrets/llm-env ]; then
        . /run/secrets/llm-env
      fi

      nohup dsh web \
        --host 127.0.0.1 --port 3080 \
        --trusted-host localhost:3080 --trusted-host 127.0.0.1:3080 \
        >"$HOME/.cache/dsh-web.log" 2>&1 &

      for _ in $(seq 1 30); do
        if curl -fsS -o /dev/null --max-time 2 http://127.0.0.1:3080; then
          break
        fi
        sleep 0.5
      done

      exec xdg-open http://127.0.0.1:3080
    '';
  };
in
{
  # DeepSeek Harness (dsh) - https://github.com/deepseek-ai/deepseek-harness
  # Nixpkgs PR #552467 (AlephCasara) - x86_64-linux only, builds from source with pnpm (fetchPnpmDeps), Node 24, no runtime npm install.
  # Run: `dsh web` → http://127.0.0.1:3080, `dsh --help`, `dsh plugin --help`
  # Or launch "DeepSeek Harness" from rofi (`deepseek-web` script above).
  home.packages =
    with pkgs;
    [
      nodejs_24
      pnpm
    ]
    ++ lib.optionals (stdenv.hostPlatform.system == "x86_64-linux") [
      dsh
      deepseek-web
    ];

  xdg = {
    desktopEntries = lib.mkIf (pkgs.stdenv.hostPlatform.system == "x86_64-linux") {
      dsh-web = {
        name = "DeepSeek Harness";
        comment = "dsh web UI on 127.0.0.1:3080";
        exec = "deepseek-web";
        icon = "dsh-web";
        categories = [
          "Development"
          "Network"
        ];
      };
    };

    # Adwaita dropped app icons and Numix isn't in the lookup path — install
    # our own into user hicolor (always searched as the fallback theme).
    dataFile."icons/hicolor/256x256/apps/dsh-web.png".source = dshIcon;
  };
}
