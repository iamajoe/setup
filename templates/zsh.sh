export ZSH="$HOME/.config/zsh/lib"

ZSH_THEME="robbyrussell"
HYPHEN_INSENSITIVE="true"
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time
# zstyle ':omz:update' frequency 30 # frequency for update

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

ZSH_CUSTOM="$HOME/.config/zsh/custom"

# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# plugins=(git colorize aws tmux zsh-autosuggestions fast-syntax-highlighting zsh-autocomplete)
# plugins=(git sudo docker kubectl terraform colorize aws tmux)

source $ZSH/oh-my-zsh.sh

# Fix Home/End keys
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[OH" beginning-of-line
bindkey "^[OF" end-of-line

# Fix Delete key
bindkey "^[[3~" delete-char

# Alt+Left/Right for word jumping
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

# Alternative bindings that might work better in some terminals
bindkey "^[^[[C" forward-word
bindkey "^[^[[D" backward-word

# Ctrl+Left/Right for word jumping (alternative)
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

