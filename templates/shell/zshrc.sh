# ─── Oh My Zsh ───────────────────────────────────────────────────────────────

export ZSH="@ohMyZsh@/share/oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(
  git
  sudo
  docker
  colorize
  tmux
)

source "$ZSH/oh-my-zsh.sh"

# ─── Zsh Plugins ────────────────────────────────────────────────────────────

source @zshAutosuggestions@/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source @zshSyntaxHighlighting@/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ─── Shared Shell Config ────────────────────────────────────────────────────

[ -f "$HOME/.config/shell/dev-env.sh" ] && source "$HOME/.config/shell/dev-env.sh"
[ -f "$HOME/.config/shell/tool-integrations.sh" ] && source "$HOME/.config/shell/tool-integrations.sh"
[ -f "$HOME/.config/shell/alias.sh" ] && source "$HOME/.config/shell/alias.sh"

# ─── Key Bindings ───────────────────────────────────────────────────────────

bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[OH" beginning-of-line
bindkey "^[OF" end-of-line
bindkey "^[[3~" delete-char
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "^[^[[C" forward-word
bindkey "^[^[[D" backward-word
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# ─── History ────────────────────────────────────────────────────────────────

HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.local/share/zsh/history"

setopt appendhistory
setopt sharehistory
setopt hist_ignore_dups
setopt hist_ignore_space
