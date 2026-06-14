# Managed by nix-darwin

# ─── Zoxide ─────────────────────────────────────────────────────────────────

if command -v zoxide >/dev/null 2>&1; then
  case "${SHELL##*/}" in
    zsh)
      eval "$(zoxide init zsh)"
      ;;
    bash)
      eval "$(zoxide init bash)"
      ;;
  esac
fi

# ─── fzf ────────────────────────────────────────────────────────────────────

if command -v fzf-share >/dev/null 2>&1; then
  case "${SHELL##*/}" in
    zsh)
      source "$(fzf-share)/key-bindings.zsh" 2>/dev/null || true
      source "$(fzf-share)/completion.zsh" 2>/dev/null || true
      ;;
    bash)
      source "$(fzf-share)/key-bindings.bash" 2>/dev/null || true
      source "$(fzf-share)/completion.bash" 2>/dev/null || true
      ;;
  esac
fi

# ─── Yazi ───────────────────────────────────────────────────────────────────
# Needs to be a shell function so it can cd in the current shell.

y() {
  local tmp
  tmp="$(mktemp -t yazi-cwd.XXXXXX)"
  yazi "$@" --cwd-file="$tmp"

  local cwd
  cwd="$(cat "$tmp" 2>/dev/null)"
  rm -f "$tmp"

  if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd "$cwd" || return
  fi
}
