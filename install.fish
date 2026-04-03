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
sudo cp -r ~/Documents/LinuxBuild/* /etc/xdg/quickshell/caelestia/
cd ~/

# Install custom packages
cd ~/Documents/LinuxBuild/ConfigsMiscs
xargs -a Packages.txt sudo pacman -S --needed --noconfirm
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