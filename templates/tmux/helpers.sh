#!/usr/bin/env bash
# helpers.sh
# Source this from other scripts or call it directly with a here-doc.

# make_3pane WINDOW_NAME LEFT_CMD RIGHT_TOP_CMD RIGHT_BOTTOM_CMD [WORKDIR]
make_3pane() {
  local name="$1" left_cmd="$2" rt_cmd="$3" rb_cmd="$4"
  # Expand ~ safely:
  local dir="${5/#\~/$HOME}"

  tmux new-window -n "$name" -c "$dir" "$left_cmd"
  tmux split-window -h -p 50 -c "$dir" "$rt_cmd"
  tmux split-window -v -p 50 -c "$dir" "$rb_cmd"

  # Put focus back on the left big pane
  tmux select-pane -t 0
}

