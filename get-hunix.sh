#!/bin/bash 

#
#  .hunix/
#    |-- bin
#    `-- lib
#  .local/
#    |-- bin -> ~/.hunix/bin
#    |-- etc
#    |   `-- archive
#    |-- lib -> ~/.hunix/lib
#    |-- log
#    `-- opt
#

pathadd() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="${PATH:+"$PATH:"}$1"
    fi
}

BIN=${HOME}/.local/bin/

add_gitignore () {
    grep -qxF $1 ${BIN}.gitignore || echo "$1" >> ${BIN}.gitignore
}

cd ${HOME}
if [ -d "${HOME}/.hunix" ] ; then
    echo "hunix is already installed"
    echo "  nuke and pave with get-hunix.sh nuke"
    if [[ "nuke" == "$1" ]]; then
        echo "nukeing hunix install..."
        rm -rf .hunix .yadm .config/yadm .local/bin .local/lib .local/etc /tmp/tmp_unzip* .emacs-site-lisp .bash_aliases .bash_profile .emacs .tmux.conf
    fi
  exit 1
fi

# base dependencies
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

# ensure giant rsa keys
if [ ! -f "${HOME}/.ssh/id_rsa.pub" ]; then
    echo "generating big rsa key"
    mkdir ${HOME}/.ssh 2>/dev/null
    ssh-keygen -t rsa -b 4096 -f ${HOME}/.ssh/id_rsa -q -N ""
    chmod 700 ${HOME}/.ssh
    chmod 600 ${HOME}/.ssh/*
fi

echo ""
echo -n "Are you Heow? (y/n) "
read ISHUBERT

# am I heow?
if [ "$ISHUBERT" == "y" ]; then
    echo 'foo' | base64 --decode > ${HOME}/.ssh/github-access-2021
    chmod 600 ${HOME}/.ssh/github-access-2021
    GIT_SSH_COMMAND="ssh -i ${HOME}/.ssh/github-access-2021" git clone git@github.com:heow/hunix.git .hunix
else
    git clone https://github.com/heow/hunix.git .hunix
fi

# create and link to .local
mkdir -p ${HOME}/.local/opt 2>/dev/null
mkdir -p ${HOME}/.local/log 2>/dev/null
ln -s ${HOME}/.hunix/bin ${HOME}/.local/
ln -s ${HOME}/.hunix/lib ${HOME}/.local/

touch ${BIN}/.gitignore

# add self to bin/.gitignore, it's only for automation
add_gitignore .gitignore


pathadd ${HOME}/.local/bin
export PATH

if [ "$ISHUBERT" == "y" ]; then

    echo 'foo' | base64 --decode > ${HOME}/.ssh/yadm-access-2021
    chmod 600 ${HOME}/.ssh/yadm-access-2021

    # yadm
    if  which yadm > /dev/null 2>&1 ; then
        echo "yadm ok"
    else
        echo "installing yadm..."
        sudo apt-get install yadm
    fi

    echo "make backward compatible with old yadm"
    mkdir -p ${HOME}/.config/yadm
    ln -s ${HOME}/.config/yadm ${HOME}/.yadm 

    echo "cloning yadm..."
    GIT_SSH_COMMAND="ssh -i ${HOME}/.ssh/yadm-access-2021" yadm  clone git@gitlab.com:heow/yadm.git

    # add overlayed yadm files from ~/.local/bin to .gitignore
    add_gitignore msg
    add_gitignore sync-with-cloud.sh

    echo -n "Decrypt YADM secrets? (y/n) "
    read YN

    if [ "$YN" == "y" ]; then
        # dependency
        if which gpg > /dev/null 2>&1 ; then
            echo "gpg ok"
        else
            sudo apt-get install gpg
        fi
        yadm decrypt
    fi
fi

echo ""
echo -n "Install large x86 binaries? (y/n) "
read YN

if [ "$YN" == "y" ]; then
    echo "installing..."
else
    exit
fi

if  which rclone > /dev/null 2>&1 ; then
    echo "rclone ok"
else
    echo "installing rclone..."
    OS="$(uname)"
    case $OS in
      Linux)
        OS='linux'
        ;;
      FreeBSD)
        OS='freebsd'
        ;;
      NetBSD)
        OS='netbsd'
        ;;
      OpenBSD)
        OS='openbsd'
        ;;  
      Darwin)
        OS='osx'
        ;;
      SunOS)
        OS='solaris'
        echo 'OS not supported'
        exit 2
        ;;
      *)
        echo 'OS not supported'
        exit 2
        ;;
    esac
    OS_type="$(uname -m)"
    case "$OS_type" in
      x86_64|amd64)
        OS_type='amd64'
        ;;
      i?86|x86)
        OS_type='386'
        ;;
      aarch64|arm64)
        OS_type='arm64'
        ;;
      arm*)
        OS_type='arm'
        ;;
      *)
        echo 'OS type not supported'
        exit 2
        ;;
    esac
    download_link="https://downloads.rclone.org/rclone-current-${OS}-${OS_type}.zip"
    rclone_zip="rclone-current-${OS}-${OS_type}.zip"
    curl -OfsS "$download_link"
    unzip_dir="/tmp/tmp_unzip_dir_for_rclone"
    mkdir "$unzip_dir"
    unzip -a "$rclone_zip" -d "$unzip_dir"
    pushd $unzip_dir/*
    mv rclone ~/.local/bin/
    popd
    add_gitignore rclone
fi

echo "logseq (100MB)"
curl https://github.com/logseq/logseq/releases/download/0.4.4/logseq-linux-x64-0.4.4.AppImage --output ${BIN}/logseq
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
curl https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip -o ngrok.zip
unzip ngrok.zip
mv ngrok ${BIN}/ngrok
rm ngrok-stable-linux-amd64.zip
add_gitignore ngrok
popd

exit

#
# pre-yadm logic
#
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
