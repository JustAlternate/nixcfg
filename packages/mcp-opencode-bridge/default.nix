{
  lib,
  buildGoModule,
}:
buildGoModule {
  pname = "mcp-opencode-bridge";
  version = "1.0.0";
  src = lib.cleanSource ./.;
  vendorHash = null;
  env.CGO_ENABLED = 0;
}
