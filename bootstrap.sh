#!/bin/bash

set -eu

export DEBIAN_FRONTEND=noninteractive

UPGRADE_PACKAGES=${1:-none}

if [ "${UPGRADE_PACKAGES}" != "none" ]; then
	echo "==> Updating and upgrading packages ..."

	sudo apt-get update
	sudo apt-get upgrade -y
fi

sudo apt-get install -qq \
	build-essential \
	curl \
	git \
	htop \
	man \
	mosh \
	python \
	python3 \
	python3-flake8 \
	python3-pip \
	python3-setuptools \
	python3-venv \
	python3-wheel \
	neovim \
	tmux \
	unzip \
	wget \
	zsh \
	—no-install-recommends \

	rm -rf /var/lib/apt/lists/*

git config —global user.email "dvilchez@xuaps.com"
git config —global user.name "dvilchez"

if [ ! -d "${HOME}/.fzf" ]; then
	echo " ==> Installing fzf"
	git clone https://github.com/junegunn/fzf "${HOME}/.fzf"
	pushd "${HOME}/.fzf"
	git remote set-url origin git@github.com:junegunn/fzf.git 
	${HOME}/.fzf/install —bin —64 —no-bash —no-zsh —no-fish
	popd
fi

if [ ! -d "${HOME}/.zsh" ]; then
	echo " ==> Installing zsh plugins"
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${HOME}/.zsh/zsh-syntax-highlighting"
	git clone https://github.com/zsh-users/zsh-autosuggestions "${HOME}/.zsh/zsh-autosuggestions"
fi

if [ ! -d "${HOME}/.tmux/plugins" ]; then
	echo " ==> Installing tmux plugins"
	git clone https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
	git clone https://github.com/tmux-plugins/tmux-open.git "${HOME}/.tmux/plugins/tmux-open"
	git clone https://github.com/tmux-plugins/tmux-yank.git "${HOME}/.tmux/plugins/tmux-yank"
	git clone https://github.com/tmux-plugins/tmux-prefix-highlight.git "${HOME}/.tmux/plugins/tmux-prefix-highlight"
fi

echo "==> Setting shell to zsh..."
chsh -s /usr/bin/zsh

if [ ! -d "${HOME}/dotfiles" ]; then
	echo "==> Setting up dotfiles"
	# the reason we dont't copy the files individually is, to easily push changes
	# if needed
	git clone —recursive https://github.com/dvilchez/dotfiles.git /home/linux/dotfiles

	cd "${HOME}/dotfiles"
	git remote set-url origin git@github.com:dvilchez/dotfiles.git

	# ln -sfn $(pwd)/vimrc "${HOME}/.vimrc"
	ln -sfn $(pwd)/zshrc "${HOME}/.zshrc"
	ln -sfn $(pwd)/.oh-my-zsh "${HOME}/.oh-my-zsh"
	# ln -sfn $(pwd)/tmuxconf "${HOME}/.tmux.conf"
	# ln -sfn $(pwd)/tigrc "${HOME}/.tigrc"
	# ln -sfn $(pwd)/git-prompt.sh "${HOME}/.git-prompt.sh"
	# ln -sfn $(pwd)/gitconfig "${HOME}/.gitconfig"
	# ln -sfn $(pwd)/agignore "${HOME}/.agignore"
	# ln -sfn $(pwd)/sshconfig "${HOME}/.ssh/config"
fi

echo ""
echo "==> Done!"
