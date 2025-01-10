#!/bin/bash
[ -z "$1" ] && echo "ERROR filename required" && exit
FILE=`realpath $1`
HOST=`hostname`
echo "from Emacs, M-x eval-defun"
echo "  (find-file \"/ssh:$USER@$HOST:$FILE\")"
