# Managed by nix-darwin

# ─── Nix ────────────────────────────────────────────────────────────────────

alias nixrebuild='sudo nix run github:nix-darwin/nix-darwin#darwin-rebuild -- switch --flake @flakePath@#@flakeName@'
alias nixclean='nix-collect-garbage -d --delete-older-than 5d'
alias nixupdate='cd @flakePath@ && nix flake update && cd -'

# ─── Better Defaults ────────────────────────────────────────────────────────

alias ls='eza --icons=never'
alias ll='eza -la --icons=never'
alias lt='eza --tree --icons=never'
alias cat='bat'
alias find='fd'
alias vim='nvim'

# ─── Git ────────────────────────────────────────────────────────────────────

alias gs='git status'
alias gd='git diff'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
