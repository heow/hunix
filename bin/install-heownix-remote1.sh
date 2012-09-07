#!/bin/sh

# split the screens
cd ~/
tmp/screen   -S tunnel-cvs -X split
tmp/screen   -S tunnel-cvs -X focus
tmp/screen   -S tunnel-cvs -X next

# screen1: do a cvs checkout and misc stuff
echo "Be patient, checking out home tree from CVS..."
export CVSROOT=:pserver:${username}@127.0.0.1:/usr/local/cvsroot
while [ ! `tmp/cvs co home/${username}/bin` ]; do
    echo "Please log in below"
    sleep 1
done

mv home/${username}/bin ~/
rm -rf ~/home

cd bin/dotfiles-home/
./ln2home.sh --squash
cd ~/

# kill ourselves
tmp/screen -S tunnel-cvs -X quit
rm -rf ~/tmp