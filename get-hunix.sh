#!/bin/bash 

#
#  .local/
#    |-- bin
#    |-- etc
#    |-- lib
#    |-- log
#    `-- opt
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

# clone read-only
git clone https://github.com/heow/hunix.git ${HOME}/.local/bin

exit 0

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
