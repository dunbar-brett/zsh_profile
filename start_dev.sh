# start_dev.sh

# Required Apps
    # tmux must be installed -- brew install tmux

# Required Commands in profile or rc file
    # alias api="cd ~/ah/PatientPortalAPI"                          # change this to whatever you API directory is
    # alias pyact="source .venv/bin/activate"                       # change this to whichever python env folder you have
    # alias dockrab="docker compose up db rabbitmq"
    # alias workerReg="poetry run python -m worker user-register"
    # alias web="cd ~/ah/PatientPortalWeb"                          # change this to whatever you API directory is

# Recommended alias commands
    # alias rundev="~/ah/start_dev.sh"                              # change this to wherever your start_dev script lives 
    # alias killtmux="tmux kill-server"
    # alias listtmux="tmux ls"

# Steps to implement
    # 1. Save script as start_dev.sh somewhere in your workspace, outside of a repo
    # 2. run this command to make this script executable: chmod +x start_dev.sh
    # 3. Run the Script: Execute the script by running: ./start_dev.sh
    # 3a. I suggest making this a alias as well.


# Check if the tmux session named 'dev' already exists
if tmux has-session -t dev 2>/dev/null; then
  echo "Session 'dev' already exists. Attaching..."
  tmux attach-session -t dev
  exit 0
fi

# Start a new tmux session named 'dev' with a new window named 'development'
tmux new-session -d -s dev -n development

tmux split-window -v -t dev:development
tmux split-window -h -t dev:development.0
tmux split-window -h -t dev:development.2

tmux send-keys -t dev:development.2 'api && pyact && dockrab' C-m
tmux send-keys -t dev:development.0 'api && pyact && cd app/ && make run' C-m
tmux send-keys -t dev:development.3 'sleep 3 && api && pyact && cd app/ && workerReg' C-m
tmux send-keys -t dev:development.1 'web && yarn dev' C-m

# Set a hook to kill the session when the last window is closed
tmux set-hook -g session-closed "tmux kill-session -t dev"

# Attach to the tmux session
tmux attach-session -t dev