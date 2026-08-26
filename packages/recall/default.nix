{
  lib,
  buildGoModule,
}:
buildGoModule {
  pname = "recall";
  version = "0.1.0";

  src = ./.;

  vendorHash = "sha256-BAvfNq8jRMtxnNRnCfD4m3N9Yqc7o9dM/v6eVfK0Iag=";

  meta = {
    description = "Search and read past opencode sessions";
    mainProgram = "recall";
    license = lib.licenses.mit;
  };
}
