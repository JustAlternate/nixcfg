{ pkgs, lib, ... }:
{
  # DeepSeek Harness (dsh) - https://github.com/deepseek-ai/deepseek-harness
  # Nixpkgs PR #552467 (AlephCasara) - x86_64-linux only, builds from source with pnpm (fetchPnpmDeps), Node 24, no runtime npm install.
  # Run: `dsh web` → http://127.0.0.1:3080, `dsh --help`, `dsh plugin --help`
  home.packages =
    with pkgs;
    [
      nodejs_24
      pnpm
    ]
    ++ lib.optionals (stdenv.hostPlatform.system == "x86_64-linux") [
      (callPackage ../../packages/dsh { })
    ];
}
