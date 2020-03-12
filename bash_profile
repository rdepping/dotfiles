#!/bin/bash

########################################################################
# Bash Interactive Shell Setup
########################################################################

# Load paths and environment variables
source ~/dotfiles/vars
source ~/dotfiles/functions
source ~/dotfiles/paths
source ~/dotfiles/aliases
source ~/dotfiles/activities
source ~/dotfiles/colors

# Load bash options.
source ~/dotfiles/bash_options

#PROMPT_COMMAND='history -a'

# Load Matthew's Git bash prompt
#source ~/dotfiles/bash_prompt

# Load my Git bash prompt
source ~/dotfiles/bash_prompt_current

# Set up Autojump.
if [ -f /usr/share/autojump/autojump.sh ]; then
    source /usr/share/autojump/autojump.sh
fi
if isMac; then
    [[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]] && . $(brew --prefix)/etc/profile.d/autojump.sh
fi

# jfrog artifactory creds sourced from conf file
if [ -f ~/.jfrog/jfrog-cli.conf ]; then
    export ARTIFACTORY_EMAIL=`jq -r '.artifactory[0].user' ~/.jfrog/jfrog-cli.conf`
    export ARTIFACTORY_AUTH=`jq -r '.artifactory[0].password' ~/.jfrog/jfrog-cli.conf`
    export ARTIFACTORY_API_KEY=$ARTIFACTORY_AUTH
    export ARTIFACTORY_PSW=$ARTIFACTORY_AUTH
    export ARTIFACTORY_USR=$ARTIFACTORY_EMAIL
fi

#if [ -f ~/.aws/credentials ]; then
#    export AWS_ACCESS_KEY_ID=$(printValue default aws_access_key_id < ~/.aws/credentials)
#    export AWS_SECRET_ACCESS_KEY=$(printValue default aws_secret_access_key < ~/.aws/credentials)
#    export AWS_SESSION_TOKEN=$(printValue default aws_session_token < ~/.aws/credentials)
#    export AWS_REGION=${AWS_DEFAULT_REGION}
#fi

pmb_env_file=~/cpt/polaris-message-bus/.env
if [ -f "$pmb_env_file" ]; then
    mv -f ${pmb_env_file} ${pmb_env_file}.old
    echo AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} >> ${pmb_env_file}
    echo AWS_DEFAULT_REGION=${AWS_REGION} >> ${pmb_env_file}
    echo AWS_SESSION_TOKEN=${AWS_SESSION_TOKEN} >> ${pmb_env_file}
    echo AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} >> ${pmb_env_file}
    echo AWS_REGION=${AWS_REGION} >> ${pmb_env_file}
    echo BRANCH=feature/SOME_BANCH_NAME >> ${pmb_env_file}
    echo ENV=DEV >> ${pmb_env_file}
    echo ARTIFACTORY_EMAIL=${ARTIFACTORY_EMAIL} >> ${pmb_env_file}
    echo ARTIFACTORY_API_KEY=${ARTIFACTORY_API_KEY} >> ${pmb_env_file}
fi

# Set up autoenv
#source ~/.autoenv/activate.sh

#if [ -z "$SSH_CLIENT" -o ! -z "$SSH_TTY" ]; then
#    bind 'set match-hidden-files off'
#    #bind 'set show-all-if-ambiguous on'
#    bind '"\e[3;5~":backward-kill-word'
#    bind '"\C-?":backward-kill-word'
#    bind '"\e[1;5D":backward-word'
#    bind '"\e[1;5C":forward-word'
#fi

#if [ ! -z "$DISPLAY" ]; then
	#export LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lz=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:';
	#xmodmap -e 'clear lock'
	#xmodmap -e "remove Lock = Caps_Lock"
	#xmodmap -e "keycode 24 = q Q at at at at"
#fi

checkproxy

# Load mingit aliases.
source ~/dotfiles/git/mingit/.bashrc

# Set up virtualenvwrapper.
if [ -f /usr/share/virtualenvwrapper/virtualenvwrapper.sh ]; then
    source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
elif [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
    source /usr/local/bin/virtualenvwrapper.sh
elif [ -f /usr/bin/virtualenvwrapper.sh ]; then
    source /usr/bin/virtualenvwrapper.sh
else
     echo "WARNING: Can't find virtualenvwrapper.sh"
fi

# Set up Bash completion.
if [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
    source ~/dotfiles/go-bash-completion/go-bash-completion.bash
elif [ -f /usr/local/etc/bash_completion ]; then
    source /usr/local/etc/bash_completion
    source /usr/local/etc/bash_completion.d/git-completion.bash
    source ~/dotfiles/go-bash-completion/go-bash-completion.bash
fi

# Set up aws cli completion
if [ -f ~/.local/bin/aws_completer ]; then
    complete -C '~/.local/bin/aws_completer' aws
fi

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

#OktaAWSCLI
if [[ -f "$HOME/.okta/bash_functions" ]]; then
    . "$HOME/.okta/bash_functions"
fi
if [[ -d "$HOME/.okta/bin" && ":$PATH:" != *":$HOME/.okta/bin:"* ]]; then
    PATH="$HOME/.okta/bin:$PATH"
fi
