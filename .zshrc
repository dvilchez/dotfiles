# Path to your oh-my-zsh installation.
export ZSH=${HOME}/.oh-my-zsh
export HELIX_RUNTIME=/home/user-name/src/helix/runtime

#export ANDROID_SDK_ROOT=/Users/dvilchez/Library/Android/sdk
#export ANDROID_HOME=/usr/local/opt/android-sdk

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME=""

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
plugins=(tmux git nvm docker pip python postgres zsh-autosuggestions)

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

source $ZSH/oh-my-zsh.sh

# pure theme
fpath+=("$HOME/.zsh/pure")
autoload -U promptinit; promptinit
prompt pure

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
DEFAULT_USER=`whoami`
#
# node
NODE_DISABLE_COLORS=1

#helpers
function saf(){
    local file
    file=$(tree -i -f | fzf --query="$1" --select-1 --exit-0)
    [ -n "$file" ] && ${EDITOR:-nvim} "$file"
}

function sif(){
    local file
    file=$(grep --line-buffered --color=never -r -v "^[[:space:]]*$" * | fzf --query="$1" --select-1 --exit-0 | cut -d ':' -f 1)
    [ -n "$file" ] && ${EDITOR:-nvim} "$file"
}

# alias
alias node="env NODE_NO_READLINE=1 rlwrap node"
alias node_repl="node -e \"require('repl').start({ignoreUndefined: true})\""
alias nviml="nvim -c ':sp|vsp|wincmd w|wincmd w|resize 10|te'"
alias vim='nvim'

# nvm
export NVM_SYMLINK_CURRENT=true
export NVM_DIR="${HOME}/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

export REVIEW_BASE=master
export PATH="${HOME}/.bin:${HOME}/.local/bin/:$PATH"
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
export PATH="/usr/local/opt/openjdk@11/bin:$PATH"
export PATH="$HOME/.docker/bin:$PATH"
source ~/.env

# pnpm
export PNPM_HOME="/Users/dvilchez/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
export PATH="/opt/homebrew/opt/sqlite/bin:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH=/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin:"${PATH}"

