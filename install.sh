#!/usr/bin/env bash
set -e 
echo "Installing Neovim config..."

mkdir -p ~/.config 

git clone https://github.com/AlexVila0204/nvim_config.git

echo "Done. open nvim and let lazy do the rest :D"

