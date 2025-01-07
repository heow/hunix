#!/bin/bash 

#
#  .local/
#    |-- bin
#  .bash_profile     -> ~/.local/bin/etc-dotfiles/.bash_profile
#  .bash_aliases     -> ~/.local/bin/etc-dotfiles/.bash_aliases
#  .emacs            -> ~/.local/bin/etc-dotfiles/.emacs
#  .emacs-site-lisp  -> ~/.local/bin/etc-dotfiles/.emacs-site-lisp
#  .tmux.conf        -> ~/.local/bin/etc-dotfiles/.tmux-conf
#

pathadd() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="${PATH:+"$PATH:"}$1"
    fi
}

BIN=${HOME}/.local/bin/
mkdir -p ${HOME}/.local/bin 2>/dev/null

add_gitignore () {
    grep -qxF $1 ${BIN}.gitignore || echo "$1" >> ${BIN}.gitignore
}

cd ${HOME}
if [ -f "${HOME}/.local/bin/.gitignore" ] ; then
    echo "hunix is already installed, exiting."
    exit 1
fi

# dependencies
if  which curl > /dev/null 2>&1 ; then
    echo "curl ok"
else
    echo "installing curl..."
    sudo apt-get install curl
fi

if  which git > /dev/null 2>&1 ; then
    echo "git ok"
else
    echo "installing git..."
    sudo apt-get install git
fi

# clone from repo read-only into ~/.local/bin
git clone https://github.com/heow/hunix.git ${HOME}/.local/bin

# symlink the dotfiles to home
ln2home.sh ~/.local/bin/etc-dotfiles/

pathadd ${HOME}/.local/bin
export PATH
