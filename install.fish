#!/usr/bin/env fish

# Install packages
sudo pacman -S wget curl gcc make cmake nano nvim fish
cd ~/

# Clone caelestia
git clone https://github.com/caelestia-dots/caelestia.git ~/.local/share/caelestia
cd ~/

# Run installation
~/.local/share/caelestia/install.fish
cd ~/

# Install yay
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ~/

# Copy LinuxBuild
sudo mkdir -p /etc/xdg/quickshell/caelestia/
sudo cp -r ~/Documents/LinuxBuild/CaelestiaCode/* /etc/xdg/quickshell/caelestia/
cd ~/

# Copy wallpapers
mkdir -p ~/Pictures/
cp -r ~/Documents/LinuxBuild/Wallpapers ~/Pictures/
cd ~/

# Configure fish
mkdir -p ~/.config/fish
cp ~/Documents/LinuxBuild/ConfigsMiscs/config.fish ~/.config/fish/config.fish
cd ~/

# Configure foot
mkdir -p ~/.config/foot
rm -rf ~/.config/foot/*
cp ~/Documents/LinuxBuild/ConfigsMiscs/foot-nvim.ini ~/Documents/LinuxBuild/ConfigsMiscs/foot.ini ~/.config/foot/
cd ~/

# Configure hyprland
mkdir -p ~/.config/hypr
rm -rf ~/.config/hypr/*
cp -r ~/Documents/LinuxBuild/HyprlandConfig/* ~/.config/hypr/
cd ~/

# Configure shell
mkdir -p ~/.config/caelestia
cp ~/Documents/LinuxBuild/ConfigsMiscs/shell.json ~/.config/caelestia/shell.json
cd ~/

# Install custom packages
cd ~/Documents/LinuxBuild/ConfigsMiscs
xargs -a Packages.txt sudo pacman -S --needed --noconfirm
cd ~/

# Configure Foot and Fish
mkdir -p ~/.config/fish
cp ~/.config/fish/functions/fish_greeting.fish ~/.config/fish/functions/fish_greeting.fish
cd ~/
mkdir -p ~/.config/fastfetch
cp ~/Documents/LinuxBuild/ConfigsMiscs/config.jsonc ~/.config/fastfetch/config.jsonc
cd ~/

# Setup razer-fix
sudo cp ~/Documents/LinuxBuild/SystemdScripts/Bin/razer-fix.sh /usr/local/bin/razer-fix.sh
sudo chmod +x /usr/local/bin/razer-fix.sh
sudo cp ~/Documents/LinuxBuild/SystemdScripts/Systemd/razer-fix.service /etc/systemd/system/razer-fix.service
sudo systemctl daemon-reload
sudo systemctl start razer-fix.service
cd ~/

# Check network
systemctl list-units --type=service | grep -E 'NetworkManager|netctl|dhcpcd|iwd|systemd-networkd'
cd ~/

# Creating Additional Folders
mkdir ~/Downloads
mkdir ~/Videos
mkdir ~/Music

# Enable ly service
sudo systemctl enable --now ly@tty1
cd ~/