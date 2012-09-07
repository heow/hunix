#!/bin/sh

echo "post-installating setup..."

export username=${1}

cd ~/bin/dotfiles-home/
./ln2home.sh --squash
cd ~/

# copy svn to our bin to make oureselves self-propigating
mv -u ~/tmp/svn-static ~/bin

# clean up
rm -rf ~/tmp
