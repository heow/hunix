#!/bin/bash

pathadd() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="${PATH:+"$PATH:"}$1"
    fi
}

add_gitignore () {
    grep -qxF $1 ${BIN}.gitignore || echo "$1" >> ${BIN}.gitignore
}

cd $HOME
if [ -d "${HOME}/.hunix" ] ; then
  echo "hunix is already installed"
  exit 1
fi

echo ""
echo -n "Are you Heow? (y/n) "
read YN

# am I heow?
if [ "$YN" == "y" ]; then
    git clone git@github.com:heow/hunix.git .hunix
else
    git clone https://github.com/heow/hunix.git .hunix
fi

# create and link to .local
mkdir -p ${HOME}/.local/opt 2>/dev/null
mkdir -p ${HOME}/.local/log 2>/dev/null
ln -s ${HOME}/.hunix/* ${HOME}/.local/

pathadd ${HOME}/.local/bin
export $PATH

# ensure giant rsa keys
if [ ! -f "$HOME/.ssh/id_rsa.pub" ]; then
    echo "generating big rsa key"
    ssh-keygen -t rsa -b 4096 -f $HOME/.ssh/id_rsa -q -N ""
fi

# yadm
if [ ! which yadm > /dev/null 2>&1 ] ; then
    echo "installing yadm..."
    sudo apt-get install yadm
fi

echo "cloning yadm"
yadm clone git@gitlab.com:heow/yadm.git

echo ""
echo -n "Decrypt YADM secrets? (y/n) "
read YN

if [ "$YN" == "y" ]; then
    yadm decrypt
fi

BIN=${HOME}/.local/bin/

if [ ! -d "${HOME}/.hunix" ] ; then
    echo "installing homebrew"
    pushd ${HOME}
    git clone https://github.com/Homebrew/brew .linuxbrew
    eval "$(.linuxbrew/bin/brew shellenv)"
    brew update --force --quiet
    chmod -R go-w "$(brew --prefix)/share/zsh"
    popd
else
    # ensure env
    eval "$(.linuxbrew/bin/brew shellenv)"
fi

echo "rclone (50MB)"
brew install rclone
cp -L .linuxbrew/bin/rclone ${BIN}/
add_gitignore rclone

echo "logseq (100MB)"
wget https://github.com/logseq/logseq/releases/download/0.4.4/logseq-linux-x64-0.4.4.AppImage
mv logseq-linux-x64-0.4.4.AppImage ${BIN}/logseq
chmod +x ${BIN}/logseq
add_gitignore logseq

echo "babashka (77MB)"
pushd /tmp
curl -sLO https://raw.githubusercontent.com/babashka/babashka/master/install
/bin/bash ./install --dir ${BIN} --static
rm ./install
rm ${BIN}/bb.old 2>/dev/null
add_gitignore bb
popd

echo "ngrok (33MB)"
pushd /tmp
wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
unzip ngrok-stable-linux-amd64.zip
mv ngrok ${BIN}/ngrok
rm ngrok-stable-linux-amd64.zip
add_gitignore ngrok
popd


exit

echo ""
echo "Linking hostfiles to $HOME directory, which system?"
echo "(type in the name or 'all')"
ls -1 ./etc/host-confs
read SYSTYPE
if [ "$SYSTYPE" == "all" ]; then
  SYSTYPE=`ls -1 ./etc/host-confs`
fi

for SYS in $SYSTYPE; do
  cd $HOME/.hunix/etc/host-confs >> /dev/null 2>&1
  cd ./$SYS/dotfiles-home
  echo ""
  echo "$SYS files and directories:"
  ls -pd .*  | grep -v "\./"
  echo -n "copy or link the above files to $HOME? (cp/ln) "
  read CPLN
  if [ "$CPLN" == "ln" ]; then
    echo "linking..."
    ~/.hunix/bin/ln2home.sh
  else
    echo "copying..."
    ~/.hunix/bin/cp2home.sh
  fi
done
