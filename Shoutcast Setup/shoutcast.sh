#!/bin/sh

# Shoutcast Server Automation Script part 1
# Automates setup after initial server creation

# Update MOTD
echo "Finish setup at $(ip route get 8.8.8.8 | awk '{ print $NF; exit }'):8000" > /etc/motd

# Update and upgrade system
sudo apt update
sudo apt upgrade

# Download Shoutcast
echo "Downloading Shoutcast DNAS..."
wget https://download.nullsoft.com/shoutcast/tools/sc_serv2_linux_x64-latest.tar.gz

# Create Shoutcast directory
sudo mkdir ~/shoutcast_server
# Extract shoutcast files
tar -xzf sc_serv2_linux_x64-latest.tar.gz -C ~/shoutcast_server
cd ~/shoutcast_server

# Install and configure firewall
sudo apt install ufw
sudo ufw allow 8000 && sudo ufw allow 8001 && sudo ufw allow 8002 && sudo ufw allow 22

# Install tmux
echo "Installing tmux..."
sudo apt install tmux -y
# Create new tmux session
# Split tmux panes horizontally
tmux new-session -d -s shoutcast
tmux send-keys -t shoutcast.0 "tmux split-window -h" ENTER
tmux send-keys -t shoutcast.0 "cd ~/shoutcast_server" ENTER
tmux send-keys -t shoutcast.0 "echo 'Starting Shoutcast setup. This requires manual configuration in your browser.'" ENTER
# Start shoutcast setup script in pane 0
tmux send-keys -t shoutcast.0 "sudo bash setup.sh" ENTER
tmux send-keys -t shoutcast.1 "cd ~/" ENTER
tmux send-keys -t shoutcast.1 "cd ~/" ENTER
tmux send-keys -t shoutcast.1 "bash shoutcast2.sh" ENTER
tmux send-keys -t shoutcast.1 "cd ~/" ENTER
# Attach to pane 1
tmux a -t shoutcast