#!/usr/bin/env bash
set -euo pipefail

# BASE="${1:-$PWD}"
BASE="${HOME}/work/src/github.com/bloggle-app"

# Start clean if you want; ignore error if win 0 doesn't exist
tmux kill-window -t 0 2>/dev/null || true

# Load helper
source ~/.config/terminal/tmux/helpers.sh

# name,                left,          right-top,                     right-bottom,       workdir
make_3pane "blymapi"   "nvim ."       "docker compose up"            "npm run dev"       "$BASE/writer-api"
make_3pane "blymweb"   "nvim ."       "npm run dev"                  ""                  "$BASE/writer-web-app"
make_3pane "blymai"    "nvim ."       "docker compose up --build"    ""                  "$BASE/blym-ai"
make_3pane "bloggle"   "nvim ."       ""                             ""                  "$BASE/bloggle-v1"

tmux select-window -t blymapi


