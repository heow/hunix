#!/bin/bash

if [ -d "$HOME/.hunix" ]; then
  echo "hunix is already installed"
  exit
fi

echo ""
echo -n "Are you Heow? (y/n) "
read YN

cd $HOME
mkdir -p .hunix/opt
cd .hunix

# am I heow?
if [ "$YN" == "y" ]; then
  git clone git@github.com:heow/hunix-bin.git bin
  git clone git@github.com:heow/hunix-etc.git etc
else
  git clone git://github.com/heow/hunix-bin.git bin
  git clone git://github.com/heow/hunix-etc.git etc
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
