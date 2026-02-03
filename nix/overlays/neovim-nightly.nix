# Local overlay for Neovim nightly (build from source).
# Source is provided by flake input (github:neovim/neovim/nightly).
{ neovim-src }:
final: prev:
let
  overrides = {
    inherit (prev) tree-sitter;
  };
  unwrapped =
    (prev.neovim-unwrapped.override overrides).overrideAttrs
      (oa: {
        # Must match what the binary prints (v0.12.0-nix); installCheckPhase greps for this
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
  neovim = prev.neovim.override { neovim-unwrapped = unwrapped; };
}
