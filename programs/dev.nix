{ config, pkgs, lib, userConfig, ... }:

{
  environment.systemPackages = with pkgs; [
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
