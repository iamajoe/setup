# Local overlay for Neovim 0.12.
# Based on nix-community/neovim-nightly-overlay but fixed for current nixpkgs:
# neovim-unwrapped no longer accepts a "lua" override (it uses luajit/lua5_1 directly).
# We only override tree-sitter and use the flake's neovim source (v0.12).
{ neovim-src }:
final: prev:
let
  # Overrides compatible with current nixpkgs neovim-unwrapped (no "lua" argument).
  overrides = {
    inherit (prev) tree-sitter;
    # luajit is already the default on Linux; only pass if you need to pin
    # luajit = prev.luajit;
  };
  unwrapped =
    (prev.neovim-unwrapped.override overrides).overrideAttrs
      (oa: {
        version = "0.12.0";
        src = neovim-src;
        preConfigure = ''
          ${oa.preConfigure or ""}
          substituteInPlace cmake.config/versiondef.h.in \
            --replace-fail '@NVIM_VERSION_PRERELEASE@' '-nix'
        '';
      });
in
{
  neovim-unwrapped = unwrapped;
  # So pkgs.neovim uses our unwrapped build (the wrapper reads neovim-unwrapped from prev)
  neovim = prev.neovim.override { neovim-unwrapped = unwrapped; };
}
