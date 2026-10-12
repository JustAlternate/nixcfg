{ pkgs }:
let
  version = "2026.921.0";

  # Official AppImage (keeps multiplayer + score submission), same asset nixpkgs' osu-lazer-bin uses.
  src = pkgs.fetchurl {
    url = "https://github.com/ppy/osu/releases/download/${version}-lazer/osu.AppImage";
    hash = "sha256-3O2UY7UBAJyV2+2JGr0vCswu+4TuQzb1scw7fASl/H0=";
  };

  contents = pkgs.appimageTools.extract {
    pname = "osu-lazer-bin";
    inherit version src;
    # flip the one flag that disables .NET startup hooks
    postExtract = ''
      ${pkgs.jq}/bin/jq '.runtimeOptions.configProperties["System.StartupHookProvider.IsSupported"] = true' \
        "$out/usr/bin/osu!.runtimeconfig.json" > "$out/usr/bin/osu!.runtimeconfig.json.new"
      mv "$out/usr/bin/osu!.runtimeconfig.json.new" "$out/usr/bin/osu!.runtimeconfig.json"
    '';
  };

  app = pkgs.appimageTools.wrapAppImage {
    name = "osu-lazer-telemetry-unwrapped";
    src = contents;
    extraPkgs = p: [ p.icu ];
    extraBwrapArgs = [ "--ro-bind-try /etc/egl/egl_external_platform.d /etc/egl/egl_external_platform.d" ];
  };

  harmony = pkgs.fetchurl {
    url = "https://www.nuget.org/api/v2/package/Lib.Harmony/2.4.2";
    hash = "sha256-1kWS5TCQRkVZ/OSGEsnKfI3HMROEE3a3qjRV9G/F1Xk=";
  };

  sdk = pkgs.dotnetCorePackages.sdk_10_0 or pkgs.unstable.dotnetCorePackages.sdk_10_0;

  hook = pkgs.stdenvNoCC.mkDerivation {
    pname = "osu-telemetry-hook";
    version = "1.0.0";
    src = ./hook;
    nativeBuildInputs = [ sdk ];

    buildPhase = ''
      runHook preBuild
      export HOME=$TMPDIR
      export DOTNET_CLI_TELEMETRY_OPTOUT=1
      export DOTNET_CLI_HOME=$TMPDIR/dotnet
      export NUGET_PACKAGES=$TMPDIR/nuget
      cp ${harmony} harmony.nupkg
      ${pkgs.unzip}/bin/unzip -q harmony.nupkg 'lib/net10.0/0Harmony.dll' -d harmony
      cp harmony/lib/net10.0/0Harmony.dll .
      dotnet build OsuTelemetryHook.csproj -c Release -o out
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      install -Dm444 out/OsuTelemetryHook.dll $out/lib/osu-telemetry/OsuTelemetryHook.dll
      install -Dm444 0Harmony.dll $out/lib/osu-telemetry/0Harmony.dll
      runHook postInstall
    '';
  };
in
pkgs.runCommand "osu-lazer-telemetry"
{
  nativeBuildInputs = [ pkgs.makeWrapper ];
  meta.mainProgram = "osu!";
}
''
  mkdir -p $out/bin $out/share
  makeWrapper ${app}/bin/osu-lazer-telemetry-unwrapped $out/bin/osu! \
    --set OSU_EXTERNAL_UPDATE_PROVIDER 1 \
    --set DOTNET_STARTUP_HOOKS ${hook}/lib/osu-telemetry/OsuTelemetryHook.dll \
    --set mesa_glthread true

  cp -r ${app}/share/. $out/share/ 2>/dev/null || true
  install -m 444 -D ${contents}/osu!.desktop -t $out/share/applications
  for i in 16 32 48 64 96 128 256 512 1024; do
    install -D ${contents}/osu.png $out/share/icons/hicolor/''${i}x$i/apps/osu.png
  done
''
