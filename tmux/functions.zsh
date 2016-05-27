#
#  tmux_funcs.sh
#
# This file provides some basic helper functions for 
# working with TMUX from a shell script.
#
# Copyright (c) 2015, Alexander Rudy 
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# 1. Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECTTHIS SOFTWARE
# IS PRAL,THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
# CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITFITS;THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS
# AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING,LUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
# THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
# DAMAGE.

# Check if tmux has any alive panes in a given window.
tmux_alive_panes() {
  tmux list-panes -t "$1" | grep -v "dead" &> /dev/null
}

# Check if tmux has any dead panes in a given window.
tmux_dead_panes() {
  tmux list-panes -t "$1" | grep "dead" &> /dev/null
}

# Check if tmux has *any* dead windows, filtered by first and second argument.
tmux_dead_window() {
  tmux list-windows -t "$1" | grep "$2" | grep "dead" &> /dev/null
}

# Get the number of panes in the first argument target.
tmux_n_panes() {
  tmux list-panes -t $1 | wc -l | tr -d ' '
}

# Check if tmux has a listed window.
tmux_has_window() {
  tmux list-windows -t "$1" | grep "$2" &> /dev/null
}

# Check if tmux has a listed session
tmux_has_session() {
  tmux has -t "$1" &> /dev/null;
}

# Create a new window, or respond it.
# Call sequence:
# tmux_new_or_respawn "session_name" "window_name" ["command"]
tmux_new_or_respawn() {
  session="$1"
  window="$2"
  cmd="$3"
  if ! tmux_has_window $session $window; then
    if [ -z "$cmd" ]; then
      echo "$session:$window spwaning"
      tmux new-window -t $session -n $window
    else
      echo "$session:$window spawining with $cmd"
      tmux new-window -t $session -n $window "$cmd"
    fi
  elif tmux_dead_window "$session" "$window"; then
    echo "$session:$window respawning"
    tmux respawn-window -t "$session:$window" &> /dev/null
  fi
}