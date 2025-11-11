# Check if the tmux session named 'dev' already exists
if tmux has-session -t git 2>/dev/null; then
  echo "Session 'git' already exists. Attaching..."
  tmux attach-session -t git
  exit 0
fi


# Start a new tmux session named 'git' with a new window named 'development'
tmux new-session -d -s git -n development

# Debug: Print the initial state
echo "Session and window created."

tmux send-keys -t git:development 'api && pyact' C-m
# tmux set-option -t dev:development remain-on-exit on

# Debug: Print after running dockrab
echo "web command sent."

# Split the window horizontally and run runserv in the new pane
tmux split-window -h -t git:development
tmux send-keys -t git:development.1 'web' C-m
# tmux set-option -t git:development.1 remain-on-exit on

# Debug: Print after running runserv
echo "api && pyact command sent."

# Set a hook to kill the session when the last window is closed
tmux set-hook -g session-closed "tmux kill-session -t git"

# Attach to the tmux session
tmux attach-session -t git