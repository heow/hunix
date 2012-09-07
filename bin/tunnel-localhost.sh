#!/bin/sh
ssh-add

#export USRHOST="heow@lispnyc.org"
export USRHOST="hgoodman@208.72.159.219" 

#
# agi email
#

# forward smtp, run on user ports
#restart-sh.sh 3 "ssh -C -N -L 10025:smtp.gmail.com:25 ${USRHOST}" &

restart-sh.sh 3 "ssh -C -N -L 10587:smtp.gmail.com:587 ${USRHOST}" &

#restart-sh.sh 3 "ssh -C -N -L 10465:smtp.gmail.com:465 ${USRHOST}" &

# gmail pop
restart-sh.sh 3 "ssh -C -N -L 10995:pop.gmail.com:995 ${USRHOST}" &

# gmail imap
restart-sh.sh 3 "ssh -C -N -L 10993:imap.gmail.com:993 ${USRHOST}" &

# forward pop3
#restart-sh.sh 3 "ssh -C -N -L 10110:alphageeksinc.com:110 ${USRHOST}" &

#
# ...and more services
#

# socks5 proxy
restart-sh.sh 3 "ssh -C -N -D 1080 ${USRHOST}" &

# tor proxy
restart-sh.sh 3 "ssh -C -N -L 9050:localhost:9050 ${USRHOST}" &

# aim IM
restart-sh.sh 3 "ssh -C -N -L 5190:login.oscar.aol.com:5190 ${USRHOST}" &

# yahoo IM
restart-sh.sh 3 "ssh -C -N -L 5050:scs.msg.yahoo.com:5050 ${USRHOST}" &

# msn IM
restart-sh.sh 3 "ssh -C -N -L 1863:messenger.hotmail.com:1863 ${USRHOST}" &

# irc
restart-sh.sh 3 "ssh -C -N -L 6667:irc.freenode.net:6667 ${USRHOST}" &
