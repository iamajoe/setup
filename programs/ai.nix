{ config, pkgs, lib, userConfig, ... }:

let
  isX86_64 = userConfig.system == "x86_64-linux";
  # Target machine: GTX 1060 3GB (Pascal, sm_61) + 16GB RAM + i7-7700k.
  useNvidia = isX86_64 && userConfig.gpu == "nvidia";
in
{
  # ─── opencode (AI coding agent in the terminal) ───────────────
  environment.systemPackages = lib.mkIf userConfig.enableAi (with pkgs; [
    opencode
  ]);

  # ─── Ollama (local LLM server) ─────────────────────────────────
  services.ollama = lib.mkIf userConfig.enableAiModel {
    enable = true;

    # NVIDIA Pascal GPU. nixpkgs ships CUDA 12.9 as the default `cudaPackages`
    # (see `nixpkgs.config.cudaCapabilities` below to add the sm_61 kernel).
    package = lib.mkIf useNvidia pkgs.ollama-cuda;

    # Auto-download the model on first boot via `ollama-model-loader.service`.
    # Note: Ollama's qwen3-coder library only ships 30b-a3b (19GB) / 480b —
    # too big for 16GB RAM. qwen2.5-coder:7b-q4_K_M (~4.7GB) is the closest
    # official 7B Q4_K_M coding model that fits this hardware.
    loadModels = [ "qwen2.5-coder:7b-q4_K_M" ];

    # Tuned for 3GB VRAM + 16GB RAM + i7-7700k. llama.cpp auto-fit
    # (LLAMA_ARG_FIT, on by default) already avoids OOMing the 3GB card by
    # offloading only what fits and running the rest on CPU/RAM.
    environmentVariables = {
      # Only one small model fits comfortably; keep a single request at a time.
      OLLAMA_MAX_LOADED_MODELS = "1";
      OLLAMA_NUM_PARALLEL = "1";
      # 8k is a sane coding context; a larger one eats the 16GB RAM.
      OLLAMA_CONTEXT_LENGTH = "8192";
    };
  };

  # CUDA 12.9 dropped Pascal from its default kernel set, so without this the
  # GTX 1060 silently falls back to CPU. `nixpkgs.config.cudaCapabilities`
  # selects which compute capabilities the CUDA packages build for.
  nixpkgs.config.cudaCapabilities = lib.mkIf (userConfig.enableAiModel && useNvidia) [
    "6.1" # Pascal (GTX 1060)
  ];
}