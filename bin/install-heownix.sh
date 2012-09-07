#!/bin/sh
if test -z ${2}; then
    echo "usage: "`basename ${0}`" username hostname"
    exit
fi
export username=${1}
export hostname=${2}

echo "exchanging ssh key..."
cp-ssh-key.sh ${hostname} dsa

echo "moving over required binaries..."
ssh ${username}@${hostname} mkdir ${HOME}/tmp

# cvs isims
#scp    `which screen`                   ${username}@${hostname}:~/tmp
#scp    `which cvs`                      ${username}@${hostname}:~/tmp
#scp    ~/bin/tunnel-source-cvs.sh       ${username}@${hostname}:~/tmp
#scp    ~/bin/install-heownix-remote0.sh ${username}@${hostname}:~/tmp
#scp    ~/bin/install-heownix-remote1.sh ${username}@${hostname}:~/tmp
#scp    ~/.cvspass                       ${username}@${hostname}:~/

# svn isims
#scp    `which svn`                      ${username}@${hostname}:~/tmp
scp    ~/bin/svn-static                 ${username}@${hostname}:~/tmp
scp    ~/bin/install-heownix-remote3.sh ${username}@${hostname}:~/tmp
scp    ~/bin/install-heownix-remote4.sh ${username}@${hostname}:~/tmp

echo "working remotely..."
if ! eval "ssh -t ${username}@${hostname} ${HOME}/tmp/install-heownix-remote3.sh ${username}"; then
    echo "remote operations failed, self-propigating..."
    for file in `find ~/bin -type d | grep -v \.svn`; do
        sfile="~/bin/${file##*bin\/}"
        echo "ssh -t ${username}@${hostname} mkdir -p ${sfile}"
        ssh -t ${username}@${hostname} mkdir -p ${sfile}
    done
    for file in `find ~/bin -type f | grep -v \.svn`; do
        sfile="~/bin/${file##*bin\/}"
        echo "scp ${sfile} ${username}@${hostname}:${sfile}"
        eval "scp ${sfile} ${username}@${hostname}:${sfile}"
    done
fi

echo "post-install setup..."
eval "ssh -t ${username}@${hostname} ${HOME}/tmp/install-heownix-remote4.sh ${username}"

echo "done.  Logging in..."
ssh ${username}@${hostname}
