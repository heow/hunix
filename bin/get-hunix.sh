#!/bin/bash

yadm
  * secrets
  * API keys
  * dot-files
  * sensitive info
  * gitlab, provate repo
.ssh
rclone.conf
host configs

hunix
* public utilities
move to .local
github


if [ -d "$HOME/.hunix" ] || [ -L "$HOME/.hunix" ]; then
  echo "hunix is already installed"
  exit 1
fi

cd $HOME
mkdir -p .local/opt 2>/dev/null
ln -s ./local .hunix

if [ ! which yadm > /dev/null 2>&1 ] ; then
    echo "installing yadm..."
    sudo apt-get install yadm
fi

# ensure big rsa keys
if [ ! -d "$HOME/.ssh/id_rsa.pub" ]; then
else
    echo "generating big rsa key"
    ssh-keygen -t rsa -b 4096 -f $HOME/.ssh/id_rsa -q -N ""
fi

yadm clone git@gitlab.com:heow/yadm.git
#git clone git@gitlab.com:heow/yadm.git

exit

echo ""
echo -n "Are you Heow? (y/n) "
read YN

# am I heow?
if [ "$YN" == "y" ]; then
    git clone git@github.com:heow/hunix-bin.git bin
    git clone git@github.com:heow/hunix-bin.git lib
#  git clone git@github.com:heow/hunix-etc.git etc
else
    git clone git://github.com/heow/hunix-bin.git bin
    git clone git://github.com/heow/hunix-bin.git lib
#  git clone git://github.com/heow/hunix-etc.git etc
fi

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
