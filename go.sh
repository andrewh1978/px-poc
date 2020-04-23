#!/usr/bin/bash
trap '' 2
export KUBECONFIG=/kubeconfig
export LANG=en_US.UTF-8
tmux new-session -d -x $COLUMNS -y $LINES
tmux split-window -d -l 20 "k9s --headless --kubeconfig /kubeconfig -A"
tmux split-window -d -p 100 /menu.sh
tmux kill-pane -t 0
tmux attach
