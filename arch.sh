#!/bin/bash
set -euo pipefail

# ==================================================
# SCRIPT DI FORZATURA TERMINALE ARCH
# Autore: anto426
# Modalità: FORZATA (override totale)
# ==================================================

FORCE_BACKUP=true   # true = backup config utente, false = cancella senza backup

# Colori
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
WHITE="\e[0m"

echo -e "${RED}
==================================================
  ATTENZIONE: MODALITÀ FORZATA ATTIVA
  Tutte le configurazioni utente verranno sovrascritte
  Autore: anto426
==================================================
${WHITE}"

sleep 2
cd ~

# ==================================================
# AGGIORNAMENTO SISTEMA
# ==================================================
sudo pacman -Syu --noconfirm

# ==================================================
# FORZATURA LOCALE ITALIANA
# ==================================================
sudo sed -i 's/^#it_IT.UTF-8 UTF-8/it_IT.UTF-8 UTF-8/' /etc/locale.gen
sudo locale-gen
sudo localectl set-locale LANG=it_IT.UTF-8

# ==================================================
# PACCHETTI BASE (FORZATI)
# ==================================================
sudo pacman -S --noconfirm --needed \
    base-devel git curl wget unzip \
    python python-pip nodejs npm ruby go \
    neovim tmux stow zsh \
    btop fastfetch cmatrix cowsay \
    ripgrep fd bat eza fzf zoxide \
    gdb strace ltrace binwalk checksec \
    openssh netcat rustup

# ==================================================
# INSTALLAZIONE YAY (FORZATA)
# ==================================================
if ! command -v yay &>/dev/null; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    rm -rf /tmp/yay
fi

# ==================================================
# PACCHETTI AUR
# ==================================================
yay -S --noconfirm --needed \
    cbonsai pipes.sh oh-my-posh pwninit

# ==================================================
# SBLOCCO PIP GLOBALE (FORZATO)
# ==================================================
sudo rm -f /usr/lib/python*/EXTERNALLY-MANAGED || true

# ==================================================
# INSTALLAZIONE PWNDBG
# ==================================================
rm -rf ~/pwndbg
git clone https://github.com/pwndbg/pwndbg ~/pwndbg
cd ~/pwndbg
./setup.sh
cd ~
rm -rf ~/pwndbg

sudo gem install one_gadget || true

# ==================================================
# INSTALLAZIONE WAIFU-COLORSCRIPT (FORZATA HTTPS)
# ==================================================
rustup default stable

rm -rf /tmp/waifu
git clone https://github.com/Akzestia/waifu-colorscripts.git /tmp/waifu
cd /tmp/waifu
cargo build --release
sudo cp target/release/waifu-colorscripts /usr/bin/
sudo chmod +x /usr/bin/waifu-colorscripts
cd ~
rm -rf /tmp/waifu

# ==================================================
# RESET CONFIGURAZIONI UTENTE
# ==================================================
if $FORCE_BACKUP; then
    BACKUP_DIR=~/config_backup_$(date +%s)
    mkdir -p "$BACKUP_DIR"
    mv ~/.bashrc ~/.zshrc ~/.config "$BACKUP_DIR" 2>/dev/null || true
else
    rm -rf ~/.bashrc ~/.zshrc ~/.config
fi

# ==================================================
# DOTFILES (FORZATI)
# ==================================================
rm -rf ~/dotfiles
git clone https://github.com/ViegPhunt/Dotfiles.git ~/dotfiles
git clone https://github.com/tmux-plugins/tpm ~/dotfiles/.tmux/plugins/tpm

cd ~/dotfiles
stow -t ~ . || true
cd ~

# ==================================================
# FORZATURA ZSH COME SHELL
# ==================================================
ZSH_PATH="$(command -v zsh)"
grep -qxF "$ZSH_PATH" /etc/shells || echo "$ZSH_PATH" | sudo tee -a /etc/shells
sudo chsh -s "$ZSH_PATH" "$USER"

# ==================================================
# ZSHRC FORZATO
# ==================================================
cat > ~/.zshrc << 'EOF'
# Configurazione forzata - anto426
export PATH="/usr/bin:$HOME/.cargo/bin:$PATH"

fastfetch
waifu-colorscripts --random
EOF

# ==================================================
# FINE
# ==================================================
echo -e "${GREEN}
==================================================
  INSTALLAZIONE COMPLETATA
  Effettua LOGOUT / LOGIN
  Autore: anto426
==================================================
${WHITE}"
