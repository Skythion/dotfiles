#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"

# bash : ajout de la source
ln -sf "$DIR/.bashrc_perso" "$HOME/.bashrc_perso"
grep -q 'bashrc_perso' "$HOME/.bashrc" 2>/dev/null || \
	echo '[ -f ~/.bashrc_perso ] && source ~/.bashrc_perso' >> "$HOME/.bashrc"

# vimrc amix
[ -d "$HOME/.vim_runtime" ] || git clone --depth=1 https://github.com/amix/vimrc.git "$HOME/.vim_runtime"
sh "$HOME/.vim_runtime/install_awesome_vimrc.sh"

# reglage perso
ln -sf "$DIR/my_configs.vim" "$HOME/.vim_runtime/my_configs.vim"

echo "Dotfiles installes."
