#!/bin/sh
export username=${1}

echo "Be patient, checking out home tree from Subversion..."
cmd="co svn+ssh://source.lispfu.com/var/local/repos/${username}/home/bin;"
if ! eval "svn ${cmd}"; then
    echo "svn not installed locally, trying static..."
    if ! eval "~/tmp/svn-static ${cmd}"; then
#        echo "svn failed, trying a direct copy..."
#        if ! eval "scp -r ${username}@home.lispfu.com:~/bin ~/"; then
            echo "svn failed!"
            exit 1
#        fi
    fi
fi
exit 0
