{ pkgs, lib, ... }:
let
  dsh = pkgs.unstable.deepseek-harness;

  # Official DeepSeek whale (GitHub org avatar, 256px).
  dshIcon = ../../assets/icons/deepseek-logo.png;

  # Profile user layer: route requests through OpenRouter using the sops-managed
  # OPENROUTER_API_KEY already exported by zsh and the launcher, and start new
  # sessions on DeepSeek Flash Latest. No key is written to disk; dsh resolves
  # the env reference at request time.
  dshProfilePatch = pkgs.writeText "dsh-cordis.patch.yml" ''
    - id: llm-pi-ai
      config:
        providers:
          openrouter:
            apiKeyEnv: OPENROUTER_API_KEY
    - id: agent-default-model
      config:
        provider: openrouter
        model: '~deepseek/deepseek-flash-latest'
  '';

  # Launcher for the dsh web UI (rofi/desktop entry target). If the server is
  # already up, just open a new browser tab and leave it alone; otherwise
  # start it and open the tokenized URL it prints, which mints the browser
  # session cookie.
  # Named "deepseek-web" — NOT "dsh-*" — so the `pkill -f "dsh.*web"` below
  # cannot self-match this script's own cmdline and kill the launcher.
  deepseek-web = pkgs.writeShellApplication {
    name = "deepseek-web";
    runtimeInputs = [
      dsh
      pkgs.coreutils
      pkgs.curl
      pkgs.gnused
      pkgs.procps
      pkgs.xdg-utils
    ];
    text = ''
      # Project dir the web UI opens in; override with DSH_WEB_DIR=...
      cd "''${DSH_WEB_DIR:-$HOME}"

      log="$HOME/.cache/dsh-web.log"

      # Server already up (e.g. started manually in a terminal): don't touch it.
      # Unauthenticated probes answer 401, which is still proof it is listening.
      if curl -sS -o /dev/null --max-time 2 http://127.0.0.1:3080; then
        exec xdg-open http://127.0.0.1:3080/
      fi

      # Server down: clear any stale dsh web process still holding the port.
      timeout 10 pkill -f "dsh.*web" 2>/dev/null || true
      sleep 1

      # Rofi launches bypass zsh, so the API key (sourced in zsh.nix for
      # interactive shells) must be provided here. SOPS-rendered, readable.
      if [ -r /run/secrets/llm-env ]; then
        # shellcheck source=/dev/null
        . /run/secrets/llm-env
      fi

      : >"$log"
      nohup dsh web \
        --host 127.0.0.1 --port 3080 --no-open \
        --trusted-host localhost:3080 --trusted-host 127.0.0.1:3080 \
        >"$log" 2>&1 &

      # The browser must hit the launch token once to receive its session cookie.
      url=""
      for _ in $(seq 1 40); do
        url=$(sed -n 's/^dsh web: \(http[^ ]*\)$/\1/p' "$log" | head -n 1)
        [ -n "$url" ] && break
        sleep 0.5
      done

      exec xdg-open "''${url:-http://127.0.0.1:3080/}"
    '';
  };
in
{
  # DeepSeek Harness (dsh) - https://github.com/deepseek-ai/deepseek-harness
  # Packaged in nixpkgs since 0.2.1-rc.3, so take it from unstable (x86_64-linux).
  # The provider route and default model live in the profile's user layer below;
  # the key stays in the launch env (`OPENROUTER_API_KEY`), never in a file.
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

  # Seed the profile's user layer once. The settings UI writes that same file,
  # so once it exists it is user state and a rebuild must not clobber model,
  # provider, or permission edits made there.
  home.activation.dshProfileDefaults = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "$HOME/.dsh/profiles/web/cordis.patch.yml" ]; then
      run mkdir -p "$HOME/.dsh/profiles/web"
      run ${pkgs.coreutils}/bin/install -m 600 ${dshProfilePatch} "$HOME/.dsh/profiles/web/cordis.patch.yml"
    fi
  '';

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
