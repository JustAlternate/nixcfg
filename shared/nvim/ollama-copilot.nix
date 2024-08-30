{ lib, buildGoModule, fetchFromGitHub, ... }:
# self: super: {
buildGoModule rec {
  pname = "ollama-copilot";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "bernardo-bruning";
    repo = "ollama-copilot";
    rev = "v${version}";
    hash = "sha256-HjJcGU9Qwady1LKsOcSGkCQei1jID8l1o+mvqpFNjcI=";
  };

  vendorHash = "sha256-6hCgv2/8UIRHw1kCe3nLkxF23zE/7t5RDwEjSzX3pBQ=";

  subPackage = [ "google/uuid" "ollama/ollama" ];

  proxyVendor = true;

  preBuild = ''
    go mod vendor
  '';

  meta = {
    description = "Proxy that allows you to use ollama as a copilot like Github copilot ";
    homepage = "https://github.com/bernardo-bruning/ollama-copilot";
    maintainers = with lib.maintainers; [ bernardo-bruning ];
  };
}
