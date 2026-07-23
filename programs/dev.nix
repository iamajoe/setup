{ config, pkgs, lib, userConfig, ... }:

let
  isDarwin = userConfig.platform == "darwin";
  isLinux = userConfig.platform == "linux";
in
{
  environment.systemPackages = with pkgs; [
    # Nix tooling
    nixpkgs-fmt

    # General CLI tools
    ripgrep    # improved grep
    sd         # better sed
    pkg-config # wrapper script for allowing packages to get info on others
    fzf        # fuzzy finder
    zoxide     # smarter cd

    # C/C++
    gcc

    # Rust
    rustc
    cargo
    rust-analyzer

    # Go
    go
    gopls

    # Python
    python3

    # Lua
    lua-language-server

    # Node / JS / TS
    nodejs
    typescript-language-server
    eslint
    prettier
    vscode-langservers-extracted

    # Zig
    zig

    # Static site generator
    zola

    # Java
    jdk

    # Docker CLI
    docker

    # Git TUI
    lazygit

    # JSON/YAML/data tools
    jq
    yq-go
  ];
}
