# Interactive shell configuration.

##############################################################################
# ZShell History Configuration
##############################################################################
export HISTFILE=~/.zsh_history   # Where to save history to disk
export HISTFILESIZE=1000000000
export HISTSIZE=1000000000       # How many lines of history to keep in memory
export SAVEHIST=1000000000       # Number of history entries to save to disk
export HISTTIMEFORMAT="[%F %T] "
export HIST_STAMPS="+%Y-%m-%d %H:%M:%S"
export HISTDUP=erase             # Erase duplicates in the history file

setopt APPEND_HISTORY            # Append history to the history file (no overwriting)
setopt SHARE_HISTORY             # Share history between all sessions.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt BANG_HIST                 # Treat the '!' character specially during expansion.

#setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
#setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
#setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
#setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
#setopt HIST_BEEP                 # Beep when accessing nonexistent history.

setopt AUTO_CD                   # Automatically cd to a path if specified as a command.

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

##############################################################################
# Input key bindings.
##############################################################################
#set bell-style none
#set match-hidden-files off
bindkey '\e[A' history-search-backward
bindkey '\e[B' history-search-forward
bindkey '\e[C' forward-char
bindkey '\e[D' backward-char
bindkey '\e[3;5~' backward-kill-word
bindkey '^?' backward-kill-word
bindkey '\e(' kill-word
bindkey '\e[1;5D' backward-word
bindkey '\e[1;5C' forward-word

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
  brew
  colorize
  dirpersist
  docker
  fast-syntax-highlighting
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
  virtualenv
  virtualenvwrapper
)

source /usr/local/opt/powerlevel10k/powerlevel10k.zsh-theme
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

source $ZSH/oh-my-zsh.sh

# Load rbenv ruby version selector
# https://github.com/rbenv/rbenv#homebrew-on-macos
#eval "$(rbenv init -)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

