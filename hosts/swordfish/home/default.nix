{ pkgs, ... }:
let
  llama-cpp = pkgs.unstable.llama-cpp.override { rocmSupport = true; };

  qwen38 = pkgs.writeShellApplication {
    name = "qwen38";
    runtimeInputs = [ llama-cpp ];
    text = ''
      # Qwen3.8-27B dense Q2_K_XL (10.18 GB weights) on stock nixpkgs llama-cpp.
      # Measured swordfish stats at these defaults (-c 200000 -ngl 99 -fa on
      # -ctk/-ctv q4_0 -t 6):
      #   VRAM   : 14.9 GiB / 16.4 GiB after load+first gen
      #   RAM    : ~1.2 GB process RSS
      #   prefill: ~79 tok/s warm on cached prompt; 25-28 t/s typical small prompts
      #   decode : ~21.3-21.5 tok/s (matches the measured dense bandwidth wall:
      #            ~220 GB/s effective on the RX 6800 -- no quant/config change
      #            fixes this; see agent-log.md "dense-wall math")
      model="''${QWEN38_MODEL:-$HOME/Projects/local-llm-inference/models/qwen3.8/Qwen3.8-27B-UD-Q2_K_XL.gguf}"
      ctx="''${QWEN38_CTX:-200000}"
      port="''${QWEN38_PORT:-8080}"
      ngl="''${QWEN38_NGLS:-99}"
      threads="''${QWEN38_THREADS:-6}"

      exec llama-server \
        --model "$model" \
        --host 127.0.0.1 --port "$port" \
        --n-gpu-layers "$ngl" \
        --threads "$threads" \
        --parallel 1 \
        --ctx-size "$ctx" \
        --n-predict -1 \
        --flash-attn on \
        --cache-type-k q4_0 --cache-type-v q4_0 \
        --temp 0.7 --top-p 0.8 --top-k 20 --min-p 0.0 --presence-penalty 1.5
    '';
  };

  ornith15 = pkgs.writeShellApplication {
    name = "ornith15";
    runtimeInputs = [
      llama-cpp
      pkgs.rocmPackages.clr
      pkgs.rocmPackages.hipblas
      pkgs.rocmPackages.rocblas
      pkgs.rocmPackages.hipblaslt
    ];
    text = ''
      # Ornith-1.5-35B-A3B IQ3_S (16.15 GB weights) on patched b10408 llama.cpp,
      # RX 6800 16GB (17.16 GiB total). Measured swordfish stats at these
      # defaults (-c 200000 -ngl 99 -ncmoe 4 -fa on -ctk/-ctv q4_0 -t 6):
      #   VRAM   : 15.4 GiB / 16.4 GiB after load+first gen (max seen 16.62)
      #   RAM    : ~2.6 GB process RSS (model loaded via mmap)
      #   prefill: ~150 tok/s warm (20-21 t/s cold first run); prompt t/s @32k: 50-61
      #   decode : ~30-32 tok/s @200k (150-token greedy runs: 32.33/30.12/30.39/30.98)
      #            @32k full-offload reference was 67.6 tok/s
      export LD_LIBRARY_PATH="${pkgs.rocmPackages.clr}/lib:${pkgs.rocmPackages.hipblas}/lib:${pkgs.rocmPackages.rocblas}/lib:${pkgs.rocmPackages.hipblaslt}/lib:''${LD_LIBRARY_PATH:-}"

      model="''${ORNITH15_MODEL:-$HOME/Projects/local-llm-inference/models/ornith-1.5/Ornith-1.5-35B-IQ3_S.gguf}"
      ctx="''${ORNITH15_CTX:-200000}"
      port="''${ORNITH15_PORT:-8080}"
      ngl="''${ORNITH15_NGLS:-99}"
      cpumoe="''${ORNITH15_CPU_MOE:-4}"
      threads="''${ORNITH15_THREADS:-6}"

      exec /home/justalternate/Projects/local-llm-inference/llamacpp-b10408/build/bin/llama-server \
        --model "$model" \
        --host 127.0.0.1 --port "$port" \
        --n-gpu-layers "$ngl" \
        --n-cpu-moe "$cpumoe" \
        --threads "$threads" \
        --parallel 1 \
        --ctx-size "$ctx" \
        --n-predict -1 \
        --flash-attn on \
        --cache-type-k q4_0 --cache-type-v q4_0 \
        --temp 0.7 --top-p 0.8 --top-k 20 --min-p 0.0 --presence-penalty 1.5
    '';
  };

  qwen36agent = pkgs.writeShellApplication {
    name = "qwen36agent";
    runtimeInputs = [
      pkgs.rocmPackages.clr
      pkgs.rocmPackages.hipblas
      pkgs.rocmPackages.rocblas
      pkgs.rocmPackages.hipblaslt
    ];
    text = ''
      # Qwen3.6-35B-A3B-DSV4Pro-SFT-GPT56Sol-RL-Agent LynnStyle-Q3_16G mixed quant
      # (nerkyor; agent-RL fine-tune, full 256 experts, REAP-guided precision mix),
      # 14.28 GB -> fits fully in VRAM incl. 200k ctx KV but with ZERO headroom.
      # Measured swordfish stats (-c 200000 -ngl 99 -fa on -ctk/-ctv q4_0 -t 6):
      #   VRAM   : 15.7 GiB / 16.4 GiB -- if OOM on long ctx, raise ORNITH-style:
      #            add --n-cpu-moe 2 or drop ctx via QWEN36AGENT_CTX=180000
      #   RAM    : ~1.0 GB process RSS
      #   prefill: 46-82 tok/s
      #   decode : ~66.2 tok/s steady (no embedded MTP in this file)
      #   quality: Nix probe correct
      # Durable ROCm fix: pin current nixpkgs ROCm libs (stale RUNPATH).
      export LD_LIBRARY_PATH="${pkgs.rocmPackages.clr}/lib:${pkgs.rocmPackages.hipblas}/lib:${pkgs.rocmPackages.rocblas}/lib:${pkgs.rocmPackages.hipblaslt}/lib:''${LD_LIBRARY_PATH:-}"

      model="''${QWEN36AGENT_MODEL:-$HOME/Projects/local-llm-inference/models/qwen36-agent/Qwen3.6-35B-A3B-DSV4Pro-SFT-GPT56Sol-RL-Agent-LynnStyle-Q3_16G-LynnStyle-imatrix.gguf}"
      ctx="''${QWEN36AGENT_CTX:-200000}"
      port="''${QWEN36AGENT_PORT:-8080}"
      ngl="''${QWEN36AGENT_NGLS:-99}"
      threads="''${QWEN36AGENT_THREADS:-6}"

      exec /home/justalternate/Projects/local-llm-inference/llamacpp-b10408/build/bin/llama-server \
        --model "$model" \
        --host 127.0.0.1 --port "$port" \
        --n-gpu-layers "$ngl" \
        --threads "$threads" \
        --parallel 1 \
        --ctx-size "$ctx" \
        --n-predict -1 \
        --flash-attn on \
        --cache-type-k q4_0 --cache-type-v q4_0 \
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

    packages =
      with pkgs;
      [
        gparted
        appimage-run
        bubblewrap
        opentabletdriver
        openlinkhub
        lego
        nvtopPackages.amd
        headsetcontrol
      ]
      ++ [
        llama-cpp
        qwen38
        ornith15
        qwen36agent
      ];
  };
}
