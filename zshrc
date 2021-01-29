# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

##############################################################################
# oh-my-zsh setup
##############################################################################

# Path to your oh-my-zsh configuration.
export ZSH=$HOME/dotfiles/oh-my-zsh

# Set name of the theme to load.
# Look in $ZSH/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.

#export ZSH_THEME="gozilla"
#export ZSH_THEME="fino"
#export ZSH_THEME="takashiyoshida"
#export ZSH_THEME="random"
#export ZSH_THEME="jnrowe"
#export ZSH_THEME="agnoster"

# powerlevel10k has to be set separately. See:
# https://github.com/romkatv/powerlevel10k/blob/master/README.md#cannot-make-powerlevel10k-work-with-my-plugin-manager
#export ZSH_THEME="powerline10k"

# Set to this to use case-sensitive completion
export CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# export DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# export DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# export DISABLE_AUTO_TITLE="true"

# Which plugins would you like to load? (plugins can be found in ~/.dotfiles/oh-my-zsh/plugins/*)
plugins=(
  aws
  battery
  # brew
  colorize
  dirpersist
  docker
  git
  gitignore
  golang
  iterm2
  osx
  pip
  pipenv
  # pyenv
  pylint
  python
  ripgrep
  ssh-agent
  sublime
  sublime-merge
  sudo
  terraform
  textmate
  # virtualenv
  # virtualenvwrapper
)

source /usr/local/opt/powerlevel10k/powerlevel10k.zsh-theme

source $ZSH/oh-my-zsh.sh

# Load rbenv ruby version selector
# https://github.com/rbenv/rbenv#homebrew-on-macos
#eval "$(rbenv init -)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
