{ pkgs, ... }:
let
  llama-cpp = pkgs.unstable.llama-cpp.override { rocmSupport = true; };

  qwen38 = pkgs.writeShellApplication {
    name = "qwen38";
    runtimeInputs = [ llama-cpp ];
    text = ''
      model="''${QWEN38_MODEL:-$HOME/models/qwen3.8/Qwen3.8-27B-UD-Q3_K_XL.gguf}"
      ctx="''${QWEN38_CTX:-100000}"
      port="''${QWEN38_PORT:-8080}"
      ngl="''${QWEN38_NGLS:-40}"

      exec llama-server \
        --model "$model" \
        --host 127.0.0.1 --port "$port" \
        --n-gpu-layers "$ngl" \
        --ctx-size "$ctx" \
        --n-predict -1 \
        --flash-attn on \
        --cache-type-k q8_0 --cache-type-v q8_0 \
        --temp 0.7 --top-p 0.8 --top-k 20 --min-p 0.0 --presence-penalty 1.5
    '';
  };

  qwen36 = pkgs.writeShellApplication {
    name = "qwen36";
    runtimeInputs = [ llama-cpp ];
    text = ''
      model="''${QWEN36_MODEL:-$HOME/models/qwen3.6/Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf}"
      ctx="''${QWEN36_CTX:-100000}"
      port="''${QWEN36_PORT:-8080}"
      ngl="''${QWEN36_NGLS:-25}"

      exec llama-server \
        --model "$model" \
        --host 127.0.0.1 --port "$port" \
        --n-gpu-layers "$ngl" \
        --n-cpu-moe 40 \
        --ctx-size "$ctx" \
        --n-predict -1 \
        --flash-attn on \
        --cache-type-k q8_0 --cache-type-v q8_0 \
        --temp 0.7 --top-p 0.8 --top-k 20 --min-p 0.0 --presence-penalty 1.5
    '';
  };
in
{
  imports = [
    ../../../home
  ];

  zsh.hyprlandAutostart.enable = true;

  home = {
    sessionPath = [
      "$HOME/go/bin"
    ];

    stateVersion = "24.11";

    packages = with pkgs; [
      gparted
      appimage-run
      bubblewrap
      opentabletdriver
      openlinkhub
      lego
      nvtopPackages.amd
      headsetcontrol
    ] ++ [ llama-cpp qwen38 qwen36 ];
  };
}
