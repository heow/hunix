#!/bin/sh

if [ -z "$2" ]; then
    echo "usage: gpgbak.sh [relative-dir-to-backup] [target-archive.tar.bz2.gpg]"
    exit 1
fi

tar -jc "${1}" | gpg --encrypt --recipient heow@alphageeksinc.com > "${2}"

echo "To decrypt: gpg --decrypt foo.tar.bz2.gpg | tar -jxv"

exit 0