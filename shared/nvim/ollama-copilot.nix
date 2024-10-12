{ lib, buildGoModule, fetchFromGitHub, ... }:
buildGoModule rec {
  pname = "ollama-copilot";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "bernardo-bruning";
    repo = "ollama-copilot";
    rev = "v${version}";
    hash = "sha256-HjJcGU9Qwady1LKsOcSGkCQei1jID8l1o+mvqpFNjcI=";
  };

  vendorHash = "sha256-g27MqS3qk67sve/jexd07zZVLR+aZOslXrXKjk9BWtk=";

  meta = with lib; {
    description = "Proxy that allows you to use ollama as a copilot like Github copilot";
    homepage = "https://github.com/bernardo-bruning/ollama-copilot";
    maintainers = with maintainers; [ bernardo-bruning ];
  };
}
