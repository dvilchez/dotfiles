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
	rlwrap \
	htop \
	man \
	mosh \
	neovim \
	tmux \
	unzip \
	wget \
	zsh \
	libssl-dev \
	zlib1g-dev \
	libbz2-dev \
	libreadline-dev \
	libsqlite3-dev \
	llvm \
	libncurses5-dev \
	xz-utils \
	tk-dev \
	libxml2-dev \
	libxmlsec1-dev \
	libffi-dev \
	liblzma-dev \
	--no-install-recommends 

sudo rm -rf /var/lib/apt/lists/*

git config --global user.email "dvilchez@xuaps.com"
git config --global user.name "dvilchez"

if [ ! -f "${HOME}/install_nvm.sh" ]; then
	echo " ==> Installing nvm"
	sudo apt-get update
	sudo apt-get install build-essential libssl-dev

	curl -sL https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh -o install_nvm.sh
	bash install_nvm.sh
	export NVM_DIR="/home/linux/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
	nvm install stable
fi

if [ ! -d "${HOME}/.pyenv" ]; then
	echo " ==> Installing pyenv"
	git clone https://github.com/pyenv/pyenv.git "${HOME}/.pyenv"
	git clone https://github.com/pyenv/pyenv-virtualenv.git "${HOME}/.pyenv/plugins/pyenv-virtualenv"
fi

if [ ! -d "${HOME}/.fzf" ]; then
	echo " ==> Installing fzf"
	git clone https://github.com/junegunn/fzf "${HOME}/.fzf"
	pushd "${HOME}/.fzf"
	git remote set-url origin git@github.com:junegunn/fzf.git 
	${HOME}/.fzf/install --bin --64 --no-bash --no-zsh --no-fish
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

if [ ! -d "${HOME}/dotfiles" ]; then
	echo "==> Setting up dotfiles"
	# the reason we dont't copy the files individually is, to easily push changes
	# if needed
	git clone --recurse-submodules https://github.com/dvilchez/dotfiles.git /home/linux/dotfiles

	cd "${HOME}/dotfiles"
	git remote set-url origin git@github.com:dvilchez/dotfiles.git
fi

if [ ! -f "${HOME}/.zshrc" ]; then
	# ln -sfn $(pwd)/vimrc "${HOME}/.vimrc"
	ln -sfn ${HOME}/dotfiles/.zshrc "${HOME}/.zshrc"
	ln -sfn ${HOME}/dotfiles/.oh-my-zsh "${HOME}/.oh-my-zsh"
	# ln -sfn $(pwd)/tmuxconf "${HOME}/.tmux.conf"
	# ln -sfn $(pwd)/tigrc "${HOME}/.tigrc"
	# ln -sfn $(pwd)/git-prompt.sh "${HOME}/.git-prompt.sh"
	# ln -sfn $(pwd)/gitconfig "${HOME}/.gitconfig"
	# ln -sfn $(pwd)/agignore "${HOME}/.agignore"
	# ln -sfn $(pwd)/sshconfig "${HOME}/.ssh/config"
	mkdir -p "$HOME/.zsh"
	git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
fi

echo "==> Setting shell to zsh..."
sudo sed -i 's/required/sufficient/g' /etc/pam.d/chsh
chsh -s /usr/bin/zsh
# echo "chsh -s /usr/bin/zsh"
echo ""
echo "==> Done!"
