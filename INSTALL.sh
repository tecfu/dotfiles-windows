#!/bin/bash

# Get the directory of the script
REPO_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Installing dotfiles from $REPO_DIR..."

backup_and_link() {
    local src="$1"
    local dest="$2"
    
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        echo "Backing up existing $dest to ${dest}.bak"
        mv "$dest" "${dest}.bak"
    fi
    
    echo "Linking $src to $dest"
    # Ensure source path is absolute
    ln -sf "$src" "$dest"
}

# 1. Install .bashrc
backup_and_link "$REPO_DIR/.bashrc" "$HOME/.bashrc"

# 2. Install .inputrc
backup_and_link "$REPO_DIR/.inputrc" "$HOME/.inputrc"

# 3. Install oh-my-bash
if [ ! -d "$HOME/.oh-my-bash" ]; then
    echo "Installing oh-my-bash..."
    git clone https://github.com/ohmybash/oh-my-bash.git "$HOME/.oh-my-bash"
else
    echo "oh-my-bash is already installed at $HOME/.oh-my-bash"
fi

# 4. Install alacritty configs
# alacritty.toml goes in $HOME for WSL / Git Bash (Linux)
backup_and_link "$REPO_DIR/alacritty.toml" "$HOME/.alacritty.toml"
# alacritty.ps.toml goes in ~/.config/alacritty/ for Windows PowerShell
ALACRITTY_PS_CONFIG_DIR="$HOME/.config/alacritty"
if [ ! -d "$ALACRITTY_PS_CONFIG_DIR" ]; then
    echo "Creating directory $ALACRITTY_PS_CONFIG_DIR"
    mkdir -p "$ALACRITTY_PS_CONFIG_DIR"
fi
backup_and_link "$REPO_DIR/alacritty.ps.toml" "$ALACRITTY_PS_CONFIG_DIR/alacritty.ps.toml"

echo ""
echo "Configuration files installed successfully!"
echo ""
echo "For AutoHotkey scripts (*.ahk), please see README.md for startup instructions."