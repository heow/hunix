#!/bin/sh
export username=${1}
export mypath=`dirname ${0}`

# run screen detached in the background
${mypath}/screen -dmS tunnel-cvs

# create another "screen"
${mypath}/screen   -S tunnel-cvs -X screen
${mypath}/screen   -S tunnel-cvs -p 0 -X split
${mypath}/screen   -S tunnel-cvs -p 0 -X focus

# screen0: start up the tunnel and log in
${mypath}/screen   -S tunnel-cvs -p 0 -X eval 'stuff tmp/tunnel-source-cvs.sh\015'
sleep 2
${mypath}/screen   -S tunnel-cvs -p 0 -X eval 'stuff yes\015'
sleep 1
${mypath}/screen   -S tunnel-cvs -p 0 -X eval 'stuff access\015'
${mypath}/screen   -S tunnel-cvs -p 0 -X next

# screen1: do a cvs checkout and misc stuff
${mypath}/screen   -S tunnel-cvs -p 1 -X eval 'stuff "tmp/install-heownix-remote1.sh"\015'

${mypath}/screen   -S tunnel-cvs -r

#${mypath}/screen   -S tunnel-cvs -X quit
