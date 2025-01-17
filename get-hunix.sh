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
mkdir -p ${BIN} 2>/dev/null
pathadd ${BIN}
export PATH

add_gitignore () {
    grep -qxF $1 ${BIN}.gitignore || echo "$1" >> ${BIN}.gitignore
}

cd ${HOME}

# dependencies
if  which git > /dev/null 2>&1 ; then
    echo "git ok"
else
    echo "git required"
    exit 1
fi

# clone from repo read-only into ~/.local/bin
if [ -f "${BIN}/.gitignore" ] ; then
    echo "hunix is already installed, updating..."
    cd ${BIN}
    git pull
else
    if [ -z "$1" ]; then
        echo "getting read-only from github..."
        git clone https://github.com/heow/hunix.git ${HOME}/.local/bin
    else
        echo "getting read-write from github..."
        git clone git@github.com:heow/hunix.git ${HOME}/.local/bin
    fi
fi

# symlink the dotfiles to home
~/.local/bin/ln2home.sh ~/.local/bin/etc-dotfiles/
