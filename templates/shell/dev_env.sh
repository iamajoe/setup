# ─── User bin paths ─────────────────────────────────────────────────────────

path_prepend() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1:$PATH" ;;
  esac
}

# Generic user binaries
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"

# ─── Rust / Cargo ───────────────────────────────────────────────────────────

export CARGO_HOME="$HOME/.cargo"
export RUSTUP_HOME="$HOME/.rustup"
path_prepend "$CARGO_HOME/bin"

# ─── Go ─────────────────────────────────────────────────────────────────────

export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
path_prepend "$GOBIN"

# ─── Node / npm ─────────────────────────────────────────────────────────────

export NPM_CONFIG_PREFIX="$HOME/.npm-global"
path_prepend "$NPM_CONFIG_PREFIX/bin"

# ─── Python user scripts ────────────────────────────────────────────────────
# On macOS, user-installed Python scripts often land under:
# ~/Library/Python/<version>/bin
# This adds existing versioned dirs without relying on a literal wildcard in PATH.

if [ -d "$HOME/Library/Python" ]; then
  for python_bin in "$HOME"/Library/Python/*/bin; do
    [ -d "$python_bin" ] && path_prepend "$python_bin"
  done
fi

# ─── Java ───────────────────────────────────────────────────────────────────

export JAVA_HOME="@jdk@"
path_prepend "$JAVA_HOME/bin"

# ─── Defaults ───────────────────────────────────────────────────────────────

export EDITOR="hx"
export VISUAL="hx"
export PAGER="less"
export LESS="-R"

export PATH
