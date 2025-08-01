{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchNpmDeps,
  nix-update-script,
}:
buildNpmPackage (finalAttrs: {
  pname = "qwen-code";
  version = "unstable-2025-07-24";
  src = fetchFromGitHub {
    owner = "sid115";
    repo = "qwen-code";
    rev = "e082e301bf2e779435237aab56927b204ead5d2e";
    hash = "sha256-qX2ssemIt3Ijl9GxCgurcXg5B5ZC2D6cRjGqD9G8Ksg=";
  };
  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-zzF/9V+g3uxZxCGmIIHplDX8IRd2txbLj9lco+pkkWg=";
  };
  buildPhase = ''
    runHook preBuild
    npm run generate
    npm run bundle
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp -r bundle/* $out/
    substituteInPlace $out/gemini.js --replace '/usr/bin/env node' "$(type -p node)"
    ln -s $out/gemini.js $out/bin/qwen-code
    runHook postInstall
  '';
  passthru.updateScript = nix-update-script { };
  meta = {
    description = "Qwen-code is a coding agent that lives in digital world";
    homepage = "https://github.com/QwenLM/qwen-code";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "qwen-code";
    platforms = lib.platforms.all;
  };
})
