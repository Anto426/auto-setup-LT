#!/bin/bash
set -euo pipefail

# Variables
#----------------------------
GREEN="\e[32m"
WHITE="\e[0m"
YELLOW="\e[33m"
BLUE="\e[34m"
#----------------------------

# Welcome message
echo -e "
                    ${GREEN}\e[1mWELCOME!${GREEN}
    Now we will customize Arch-based Terminal
             Created by \e[1;4mPhunt_Vieg_
${WHITE}"

cd ~

# Updating the system
echo -e "${GREEN}\n---------------------------------------------------------------------\n${YELLOW}[1/10]${GREEN} ==> Updating system packages\n---------------------------------------------------------------------\n${WHITE}"
sudo pacman -Syu --noconfirm


# Setting locale
echo -e "${GREEN}\n---------------------------------------------------------------------\n${YELLOW}[2/10]${GREEN} ==> Setting locale\n---------------------------------------------------------------------\n${WHITE}"
sudo sed -i '/^#en_US.UTF-8 UTF-8/s/^#//' /etc/locale.gen
sudo locale-gen
sudo localectl set-locale LANG=en_US.UTF-8


# Install base tools + yay
echo -e "${GREEN}\n---------------------------------------------------------------------\n${YELLOW}[3/10]${GREEN} ==> Installing base tools and yay\n---------------------------------------------------------------------\n${WHITE}"
sudo pacman -S --noconfirm --needed base-devel git rustup
rustup default stable

git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd ~
rm -rf yay


# Pacman packages
pacman_packages=(
    # System monitoring & visuals
    btop cmatrix cowsay fastfetch

    # Essential utilities
    make curl wget unzip dpkg ripgrep fd man openssh netcat
    fzf eza bat zoxide neovim tmux stow
    lazydocker lazygit

    # CTF / Reverse
    perl-image-exiftool gdb ascii ltrace strace checksec patchelf upx binwalk

    # Programming languages
    python python-pip nodejs npm ruby go

    # Shell
    zsh
)

# AUR packages
aur_packages=(
    cbonsai
    pipes.sh
    oh-my-posh
    pwninit
)


# Install pacman packages
echo -e "${GREEN}\n---------------------------------------------------------------------\n${YELLOW}[4/10]${GREEN} ==> Installing pacman packages\n---------------------------------------------------------------------\n${WHITE}"
sudo pacman -S --noconfirm "${pacman_packages[@]}"


# Install AUR packages
echo -e "${GREEN}\n---------------------------------------------------------------------\n${YELLOW}[5/10]${GREEN} ==> Installing AUR packages\n---------------------------------------------------------------------\n${WHITE}"
yay -S --noconfirm "${aur_packages[@]}"


# Allow global pip installs (CTF setup)
echo -e "${GREEN}\n---------------------------------------------------------------------\n${YELLOW}[6/10]${GREEN} ==> Enabling global pip installs\n---------------------------------------------------------------------\n${WHITE}"
sudo rm -f "$(python - <<EOF
import sys
print(f'/usr/lib/python{sys.version_info.major}.{sys.version_info.minor}/EXTERNALLY-MANAGED')
EOF
)"


# Install pwndbg & one_gadget
echo -e "${GREEN}\n---------------------------------------------------------------------\n${YELLOW}[7/10]${GREEN} ==> Installing pwndbg and one_gadget\n---------------------------------------------------------------------\n${WHITE}"
git clone --depth=1 https://github.com/pwndbg/pwndbg
cd pwndbg
./setup.sh
cd ~
rm -rf pwndbg

sudo gem install one_gadget


# Install waifu-colorscripts (Rust)
echo -e "${GREEN}\n---------------------------------------------------------------------\n${YELLOW}[8/10]${GREEN} ==> Installing waifu-colorscripts\n---------------------------------------------------------------------\n${WHITE}"
git clone https://github.com/Akzestia/waifu-colorscript.git
cd waifu-colorscript
cargo install --path .
sudo cp ~/.cargo/bin/waifu-colorscript /usr/bin/
cd ~
rm -rf waifu-colorscript


# Dotfiles
echo -e "${GREEN}\n---------------------------------------------------------------------\n${YELLOW}[9/10]${GREEN} ==> Installing dotfiles\n---------------------------------------------------------------------\n${WHITE}"
git clone --depth=1 https://github.com/ViegPhunt/Dotfiles.git ~/dotfiles
git clone --depth=1 https://github.com/tmux-plugins/tpm ~/dotfiles/.tmux/plugins/tpm

cd ~/dotfiles
./.config/viegphunt/backup_config.sh
stow -t ~ .
cd ~


# Change shell
echo -e "${GREEN}\n---------------------------------------------------------------------\n${YELLOW}[10/10]${GREEN} ==> Changing default shell to zsh\n---------------------------------------------------------------------\n${WHITE}"
ZSH_PATH="$(command -v zsh)"
grep -qxF "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells
chsh -s "$ZSH_PATH"


echo -e "\n${GREEN}
 **************************************************
 *                    \e[1;4mDone\e[0m${GREEN}!!!                     *
 *       Please relogin to apply new config.      *
 **************************************************
${WHITE}"
