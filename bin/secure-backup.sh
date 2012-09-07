#!/bin/bash

function usage {
cat<<EOF
usage: secure-backup-remote.sh [-tdN] /absolute-dir usr@gpgkey-example.com
       usr@targethost-example.com:foo.DATE.tar.gpg

Optional arguments:
  -d Sets a delay of N days based on the previous successful exeuction and
     INCREMENTALLY backs up the files.
  -t Test mode.  Searches for files, excluding files from $HOME/.arc-excludes

The string DATE will be replaced with today's date
To decrypt: gpg --decrypt foo.DATE.tar.gpg | tar -xv
EOF
  exit 1
}

DELAY=0
DELAYCMD=""
while getopts ":htd:?" options; do
  case $options in
    d ) DELAY=$OPTARG
        DELAYCMD="( -ctime -${DELAY} -o -mtime -${DELAY} )"
        shift $(($OPTIND - 1)) ;; # 2 args
    h )  usage;;
    \? ) usage;;
    t )  TEST=t 
         shift $(($OPTIND - 1));; # 1 arg
    * )  usage;;
  esac
done

if [ -z "$3" ]; then
    usage
fi

if [ ! -f $HOME/.arc-excludes ]; then
cat<<EOF
Error, \$HOME/.arc-excludes file missing!

The syntax of the file is one regex per line as such:

/.svn/
/.ssh/
/CVS/
/.Trash/
EOF
  exit 1
fi

ABSOLUTEDIR=$1
RELATIVEDIR=`basename ${ABSOLUTEDIR}`
GPGKEY=$2
TARGETUSRHOST=`echo $3 | cut -d ":" -f 1`
TARGETHOST=`echo $TARGETUSRHOST | cut -d "@" -f 2`
TARGETFILE=`echo $3 | cut -d ":" -f 2`

# date replacement
NOW=`date +"%Y-%m-%d"`
TARGETFILE=${TARGETFILE/DATE/${NOW}}

# modification date, in epoch
NOWEXE=`date +"%s"`
PREVEXE=`stat -c %Y $HOME/.arc-includes|cut -f 1 -d " "`
DAYSAGO=`echo "(${NOWEXE}-${PREVEXE})/86400"|bc`

#echo "0              $0"
#echo "1              $1"
#echo "2              $2"
#echo "3              $3"
#echo "ABSOLUTEDIR    $ABSOLUTEDIR"
#echo "RELATIVEDIR    $RELATIVEDIR"
#echo "GPGKEY         $GPGKEY"
#echo "TARGETHOST     $TARGETHOST"
#echo "TARGETUSRHOST  $TARGETUSRHOST"
#echo "TARGETFILE     $TARGETFILE"
#echo "NOWEXE         $NOWEXE"
#echo "PREVEXE        $PREVEXE"
#echo "DAYSAGO        $DAYSAGO"
#echo "DELAY          $DELAY"
#echo "DELAYCMD       $DELAYCMD"
#exit

if [ "${DELAY}" -gt "0" ]; then
  if [ "${DAYSAGO}" -gt "${DELAY}" ]; then
    echo "Last run ${DAYSAGO} days ago. Delay of ${DELAY} days exceed."
  else
    echo "Last run ${DAYSAGO} days ago. Delay of ${DELAY} days NOT exceed."
    echo "exiting"
    exit 0
  fi
fi

# go to directory above
pushd ${ABSOLUTEDIR}/.. > /dev/null
if [ "0" -ne "$?" ]; then 
  echo "absolute directory ${ABSOLUTEDIR} not found"; 
  exit 1
fi

echo "finding files..."
find ./$RELATIVEDIR -mount -xdev -type f ${DELAYCMD} -print | grep -v --file ~/.arc-excludes > ~/.arc-includes

# test mode?
if [ -n "${TEST}" ]; then
  total=0
  while read line; do 
      count=`du --apparent-size --block-size=1K "${line}" | cut -f 1`
      total=$(($total+$count))
  done < ~/.arc-includes
  #less ~/.arc-includes
  emacs ~/.arc-includes
  totalmb=$($total/1024)
  echo "unencrypted size: ${totalmb}M"
  echo -n "continue with backup?"
  read yn
  if [ "$yn" == "n" ]; then
      popd > /dev/null
      exit 1
  fi
fi
echo "found `wc -l ~/.arc-includes` files"

# secure backup
tar --files-from ~/.arc-includes -pc | gpg --encrypt --recipient ${GPGKEY} | dd of=${TARGETFILE}

echo "done".
echo "to decrypt: gpg --decrypt `basename ${TARGETFILE}` | tar -xv"
popd > /dev/null
