{ config, pkgs, lib, userConfig, ... }:

let
  isDarwin = userConfig.platform == "darwin";
  isLinux = userConfig.platform == "linux";
in
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

    # Miscellaneous
    stripe-cli

    # Additional editors
    # TODO: requires DE and should come as variable
    # code-cursor

    # Database tools
    # TODO: requires DE and should come as variable
    # mongodb-compass
  ]

  # Linux-specific packages
  ++ lib.optionals isLinux [
    # TODO: requires DE and should come as variable
    # sublime-merge
    # sublime4
  ]

  # macOS-specific packages
  ++ lib.optionals isDarwin [
    # TODO: missing these
    # - sublime merge
    # - sublime text
  ];
}
