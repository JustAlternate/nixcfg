{ lib, buildGoModule, fetchFromGitHub, ... }: {
  pet = buildGoModule rec {
    pname = "ollama-copilot";
    version = "0.1";

    src = fetchFromGitHub {
      owner = "bernardo-bruning";
      repo = "ollama-copilot";
      rev = "v${version}";
      hash = "sha256-Gjw1dRrgM8D3G7v6WIM2+50r4HmTXvx0Xxme2fH9TlQ=";
    };

    vendorHash = "sha256-ciBIR+a1oaYH+H1PcC8cD8ncfJczk1IiJ8iYNM+R6aA=";

    meta = {
      description = "Proxy that allows you to use ollama as a copilot like Github copilot ";
      homepage = "https://github.com/bernardo-bruning/ollama-copilot";
      maintainers = with lib.maintainers; [ bernardo-bruning ];
    };
  };
}
