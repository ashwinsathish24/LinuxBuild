#!/usr/bin/env fish
# 1. Install required packages
sudo pacman -S wget curl gcc make cmake nano nvim

git clone https://github.com/caelestia-dots/caelestia.git ~/.local/share/caelestia
~/.local/share/caelestia/install.fish

sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ~

git clone https://github.com/ashwinsathish24/LinuxBuild.git ~/Documents/LinuxBuild/
sudo mkdir -p /etc/xdg/quickshell/caelestia/
sudo cp -r ~/Documents/LinuxBuild/* /etc/xdg/quickshell/caelestia/

cd /home/ashwins/Documents/LinuxBuild/ConfigsMiscs
xargs -a Packages.txt sudo pacman -S --needed --noconfirm

sudo cp /home/ashwins/Documents/LinuxBuild/SystemdScripts/Bin/razer-fix.sh /usr/local/bin/razer-fix.sh
sudo chmod +x /usr/local/bin/razer-fix.sh
sudo cp /home/ashwins/Documents/LinuxBuild/SystemdScripts/Systemd/razer-fix.service /etc/systemd/system/razer-fix.service

sudo systemctl daemon-reload
sudo systemctl start razer-fix.service

systemctl list-units --type=service | grep -E 'NetworkManager|netctl|dhcpcd|iwd|systemd-networkd'
