#!/bin/sh
SHELLSCONFIGDIR=~/dotfiles
DOTFILESDIR=~/dotfiles
DOTFILES=".autoenv .bash_logout .bash_profile .bashrc .Brewfile .colordiffrc .colorgccrc .conf .gemrc .git_identities .gitconfig .gitignore .inputrc .netrc .profile .pythonrc .rvmrc .shellactivities .shellaliases .shellpaths .shellvars .tmux .tmux.conf .vimrc .vim .xxdiffrc .zlogout .zprofile .zshenv .zshrc"
DROPDIRS="bin .pip"
MOVE=true
SAVEDIR=~/.old

function symlinkifne {
    target=~/$1
    echo "Working on: $target"
	export dotless=`echo $1 | sed s/^\.//`
	if [ -e $target ]; then
		echo "  WARNING: $target already exists!"
		if [ "$MOVE" = "true" ]; then
			echo "  Moving $target to $SAVEDIR/"
			mv $target $SAVEDIR/
			dotless=$(echo $1 | sed s/.//)
			echo "  Symlinking $DOTFILESDIR/$dotless to $1"
			ln -s $DOTFILESDIR/$dotless $target
		else
			echo "  Skipping $1."  
		fi
	else
		echo "  Symlinking $DOTFILESDIR/$dotless to $1"
		ln -s $DOTFILESDIR/$dotless $1
	fi
}

echo "This script must be run from the dotfiles directory"
echo "Setting up..."

pushd ~

if [ "$MOVE" = "true" -a -d $SAVEDIR ]; then
	echo "$SAVEDIR already exists! Please clean up and try again."
	echo "This is usesd to save old versions of your configuration files."
	exit 1
fi

mkdir $SAVEDIR

if [ ! -d dotfiles ]; then 
	echo "The dotfiles dir does not exist in your home directory!"
	echo "You need to do:"
	echo "# cd ~"
	echo "# git clone --recurse-submodules https://github.com/jimlawton/dotfiles"
	echo "# cd dotfiles"
	echo "# ./_setupdotfiles.sh"
	exit 1
fi

for dotfile in $DOTFILES; do
	symlinkifne $dotfile
done

for dropdir in $DROPDIRS; do
    if [ ! -e ~/$dropdir ]; then
        ln -s ~/Dropbox/unixhome/$dropdir ~/
    fi
done

popd

echo "Done!"
