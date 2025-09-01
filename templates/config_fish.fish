if status is-interactive
  # Commands to run in interactive sessions can go here
end

# ---------------------------
# Homebrew (macOS) — no parent shell needed
# ---------------------------
if test (uname) = Darwin
    for p in /opt/homebrew/bin/brew /usr/local/bin/brew
        if test -x $p
            # This prints Fish-friendly `set -gx ...` lines
            eval ($p shellenv)
            # Safety: ensure bin/sbin are in PATH even if shellenv fails
            if type -q fish_add_path
                fish_add_path -m (dirname $p) (dirname $p | string replace /bin /sbin)
            else
                set -gx PATH (dirname $p) (dirname $p | string replace /bin /sbin) $PATH
            end
            break
        end
    end
end

# ---------------------------
# Keyboard: Caps -> Ctrl (non-macOS X11)
# ---------------------------
if test (uname) != Darwin
    if command -q setxkbmap
        setxkbmap -option ctrl:nocaps
    end
end

# ---------------------------
# Go
# ---------------------------
# System Go (common Linux path)
if test -x /usr/local/go/bin/go
    if type -q fish_add_path
        fish_add_path /usr/local/go/bin
    else
        set -gx PATH /usr/local/go/bin $PATH
    end
end

# Workspace Go
set -gx GOPATH $HOME/work
set -gx GOBIN $GOPATH/bin
if type -q fish_add_path
    fish_add_path $GOBIN
else
    set -gx PATH $GOBIN $PATH
end

# ---------------------------
# Rust
# ---------------------------
# Don’t source ~/.cargo/env (POSIX). Just add Cargo bin.
if type -q fish_add_path
    fish_add_path $HOME/.cargo/bin
else
    set -gx PATH $HOME/.cargo/bin $PATH
end

# ---------------------------
# Apps
# ---------------------------
if test (uname) = Darwin
    if type -q fish_add_path
        fish_add_path "/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
        fish_add_path $HOME/Applications
    else
        set -gx PATH $PATH "/Applications/Visual Studio Code.app/Contents/Resources/app/bin" $HOME/Applications
    end
else
    if type -q fish_add_path
        fish_add_path $HOME/Apps
    else
        set -gx PATH $PATH $HOME/Apps
    end
end

# ---------------------------
# Aliases
# ---------------------------

alias sagent='eval (ssh-agent -s); ssh-add'

alias gitlog='git log --graph --format=format:"%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%an%C(reset)%C(bold yellow)%d%C(reset) %C(dim white)- %s%C(reset)" --all'
alias tmuxkill='tmux kill-session; pkill -f tmux'

# ---------------------------
# tmux helpers
# ---------------------------
if set -q TMUX
    alias clear='clear; tmux clear-history'
    alias listsessions='tmux list-sessions -F "#S" | awk \'BEGIN {ORS=" "} {print $1, NR, "\"switch-client -t", $1 "\""}\' | xargs tmux display-menu -T "Switch session"'
end

# ---------------------------
# Neovim
# ---------------------------
if test -f "$HOME/Apps/nvim.appimage"
    alias nvim="$HOME/Apps/nvim.appimage"
end

if test -f "$HOME/bin/nvim-macos-arm64/bin/nvim"
    alias nvim="$HOME/bin/nvim-macos-arm64/bin/nvim"
end

if test -f "$HOME/bin/nvim-macos-x86_64/bin/nvim"
    alias nvim="$HOME/bin/nvim-macos-x86_64/bin/nvim"
end

alias vi='nvim'
alias vim='nvim'
alias neovim='nvim'

# Default editor (Fish way)
set -gx EDITOR (which nvim)

# ---------------------------
# FileZilla
# ---------------------------
if test -d "$HOME/Apps/FileZilla3"
    alias filezilla="$HOME/Apps/FileZilla3/bin/filezilla"
end

# ---------------------------
# Platform-specific apps
# ---------------------------
if test (uname) = Darwin
    alias chrome="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    alias google-chrome-stable="chrome"
    alias code="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
else
    alias audacity="~/Apps/audacity-linux-3.3.3-x64.AppImage"
end

# ---------------------------
# Projects
# ---------------------------
alias iamajoe='cd ~/work/src/github.com/iamajoe'
alias bloggle='cd ~/work/src/github.com/bloggle-app'

# ---------------------------
# SSH
# ---------------------------
alias sshdonkey='ssh donkey@192.168.0.128'

