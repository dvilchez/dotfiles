#!/bin/bash

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
echo >> /Users/dvilchez/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/dvilchez/.zprofilea
eval "$(/opt/homebrew/bin/brew shellenv)"
brew install rlwrap
if [ ! -d "${HOME}/.nvm" ]; then
	echo " ==> Installing nvm"

	curl -sL https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh -o install_nvm.sh
	bash install_nvm.sh
	export NVM_DIR="${HOME}/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
	nvm install stable
    rm install_nvm.sh
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
	brew install zsh
	ln -sfn ${HOME}/dotfiles/.oh-my-zsh "${HOME}/.oh-my-zsh"
	ln -sfn ${HOME}/dotfiles/.zshrc "${HOME}/.zshrc"
	mkdir -p "$HOME/.zsh"
	echo " ==> Installing zsh plugins"
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${HOME}/.zsh/zsh-syntax-highlighting"
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	git clone https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
fi

if [ ! -d "${HOME}/.tmux/plugins" ]; then
	echo " ==> Installing tmux plugins"
	git clone https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
	git clone https://github.com/tmux-plugins/tmux-open.git "${HOME}/.tmux/plugins/tmux-open"
	git clone https://github.com/tmux-plugins/tmux-yank.git "${HOME}/.tmux/plugins/tmux-yank"
	git clone https://github.com/tmux-plugins/tmux-prefix-highlight.git "${HOME}/.tmux/plugins/tmux-prefix-highlight"
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
    brew install nvim
    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
fi

echo "==> Setting shell to zsh..."
chsh -s $(which zsh)
echo "==> Done!"
