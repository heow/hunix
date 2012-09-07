#!/bin/sh
git clone git://repo.or.cz/muse-el.git muse
git clone git://jblevins.org/git/markdown-mode.git
git clone http://github.com/technomancy/durendal.git
git clone https://github.com/technomancy/clojure-mode.git
git clone https://github.com/technomancy/slime.git
ln -s slime/contrib slime-contrib