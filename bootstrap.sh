#!/bin/bash

set -e

export DEBIAN_FRONTEND=noninteractive

UPGRADE_PACKAGES=${1:-none}

if [ "${UPGRADE_PACKAGES}" != "none" ]; then
	echo "==> Updating and upgrading packages ..."

	sudo apt-get update
	sudo apt-get upgrade -y
fi

if command -v apt-get 1>/dev/null 2>&1; then
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
fi

if [ ! -d "${HOME}/.nvm" ]; then
	echo " ==> Installing nvm"

	curl -sL https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh -o install_nvm.sh
	bash install_nvm.sh
	export NVM_DIR="${HOME}/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
	nvm install stable
    rm install_nvm.sh
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

if [ ! -f "${HOME}/.zshrc" ]; then
	ln -sfn ${HOME}/dotfiles/.oh-my-zsh "${HOME}/.oh-my-zsh"
	ln -sfn ${HOME}/dotfiles/.zshrc "${HOME}/.zshrc"
	mkdir -p "$HOME/.zsh"
	echo " ==> Installing zsh plugins"
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${HOME}/.zsh/zsh-syntax-highlighting"
	git clone https://github.com/zsh-users/zsh-autosuggestions "${HOME}/.zsh/zsh-autosuggestions"
	git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
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
	git clone --recurse-submodules https://github.com/dvilchez/dotfiles.git ${HOME}/dotfiles

	cd "${HOME}/dotfiles"
	git remote set-url origin git@github.com:dvilchez/dotfiles.git
fi

if [ ! -f "${HOME}/.gitconfig" ]; then
    ln -sfn ${HOME}/dotfiles/.gitconfig "${HOME}/.gitconfig"
fi

if [ ! -f "${HOME}/.gitignore_global" ]; then
    ln -sfn ${HOME}/dotfiles/.gitignore_global "${HOME}/.gitignore_global"
fi

if [ ! -f "${HOME}/.gitmessage" ]; then
    ln -sfn ${HOME}/dotfiles/.gitmessage "${HOME}/.gitmessage"
fi

if [ ! -f "${HOME}/.config" ]; then
    ln -sfn ${HOME}/dotfiles/.config/nvim "${HOME}/.config/"
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
fi

echo "==> Setting shell to zsh..."
sudo sed -i 's/required/sufficient/g' /etc/pam.d/chsh
chsh -s /usr/bin/zsh
# echo "chsh -s /usr/bin/zsh"
echo ""
echo "==> Done!"
