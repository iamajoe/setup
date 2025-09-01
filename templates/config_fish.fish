if status is-interactive
  # Commands to run in interactive sessions can go here
end

# ---------------------------
# Prompt
# ---------------------------

function fish_prompt
  set -g last_status $status
  set -l path_full (_col "#74c7ec")(prompt_pwd_full)(_col_res)

  if test $last_status = 0
    set prompt (_col "#fab387" b)" >"(_col_res)' '
  else
    set prompt (_col brred b)" >"(_col_res)' '
  end

  echo -n -s $path_full
  _is_git_folder; and _prompt_git
  echo -n -s $prompt
end

function fish_right_prompt
  if test $last_status -gt 0
    set errorp (_col brred)"$last_status⏎"(_col_res)" "
  end
end

function _col                                     #Set Color 'name b u' bold, underline
  set -l col; set -l bold; set -l under
  if [ -n "$argv[1]" ];       set col   $argv[1]; end
  if [ (count $argv) -gt 1 ]; set bold  "-"(string replace b o $argv[2] 2>/dev/null); end
  if [ (count $argv) -gt 2 ]; set under "-"$argv[3]; end
  set_color $bold $under $argv[1]
end

function _col_res -d "Reset background and foreground colors"
  set_color -b normal
  set_color normal
end

# NOTE: use this instead of full if want smaller path
function prompt_pwd2
  set realhome ~
  set -l _tmp (string replace -r '^'"$realhome"'($|/)' '~$1' $PWD)  #replace $HOME with '~' in path
  set -l _tmp2 (basename (dirname $_tmp))/(basename $_tmp)          #get last two dirs from path
  echo (string trim -l -c=/ (string replace "./~" "~" $_tmp2))      #trim left '/' or './' for special cases
end

function prompt_pwd_full
  set -q fish_prompt_pwd_dir_length; or set -l fish_prompt_pwd_dir_length 1
  if [ $fish_prompt_pwd_dir_length -eq 0 ]
    set -l fish_prompt_pwd_dir_length 99999
  end
  set -l realhome ~
  echo $PWD | sed -e "s|^$realhome|~|" -e 's-\([^/.]{'"$fish_prompt_pwd_dir_length"'}\)[^/]*/-\1/-g'
end

function _prompt_git -a current_dir -d 'Display the actual git state'
  echo -n ' '

  set -l dirty (command git diff --no-ext-diff --quiet --exit-code; or echo -n '')
  set -l flag_fg (_col brgreen)
  if [ "$dirty" -o "$staged" ]                                      # if either dirty or staged
    set flag_fg (_col yellow)
  else if [ "$stashed" ]
    set flag_fg (_col brred)
  end
  echo -n -s $flag_fg(_git_branch)(_git_status)(_col_res)

  echo -n ''
end

function _git_status -d 'Check git status'
  set -l git_status (command git status --porcelain 2> /dev/null | cut -c 1-2)
  set -l ahead (_git_ahead); echo -n $ahead                                    #show # of commits ahead/behind
  if [ (echo -sn $git_status\n | egrep -c "[ACDMT][ MT]|[ACMT]D") -gt 0 ]      # staged
    echo -n (_col green b)'+'
  end
  if [ (echo -sn $git_status\n | egrep -c "[ ACMRT]D") -gt 0 ]                  # deleted
      echo -n (_col red b)'-'
  end
  if [ (echo -sn $git_status\n | egrep -c ".[MT]") -gt 0 ]                      # modified
      echo -n (_col yellow b)'*'
  end
  if [ (echo -sn $git_status\n | egrep -c "R.") -gt 0 ]                         # renamed
      echo -n (_col purple b)'>'
  end
  if [ (echo -sn $git_status\n | egrep -c "AA|DD|U.|.U") -gt 0 ]                # unmerged
      echo -n (_col brred b)'!'
  end
  if [ (echo -sn $git_status\n | egrep -c "\?\?") -gt 0 ]                       # untracked
      echo -n (_col brcyan b)'?'
  end
  if test (command git rev-parse --verify --quiet refs/stash >/dev/null)        # stashed
      echo -n (_col brred b)'$'
  end

  echo ''
end

function _git_branch -d "Display the current git state"
  set -l ref
  if command git rev-parse --is-inside-work-tree >/dev/null 2>&1
    set ref (command git symbolic-ref HEAD 2>/dev/null)
    if [ $status -gt 0 ]
      set -l branch (command git show-ref --head -s --abbrev |head -n1 2>/dev/null)
      set ref " $branch"
    end
    set -l branch (echo $ref | sed  "s-refs/heads/--")
    echo (_col magenta)"$branch"(_col_res)
  end
end

function _is_git_folder     -d "Check if current folder is a git folder"
  git status 1>/dev/null 2>/dev/null
end

function _git_ahead -d         'Print the ahead/behind state for the current branch'
  command git rev-list --left-right '@{upstream}...HEAD' 2> /dev/null | awk '/>/ {a += 1} /</ {b += 1} {if (a > 0 && b > 0) nextfile} END {if (a > 0 && b > 0) print "⇕"; else if (a > 0) print ""; else if (b > 0) print ""}' #↑↓⇕⬍↕
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

