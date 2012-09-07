#!/usr/bin/env python

import sys
import os
import stat
import re

listKillable = ["~$", "^#", "#$",       # emacs
                "\.o$", "a\.out",       # obj files
                "\.core$",              # core
                "^core$",                 # more core
                "\.bak$",
                "\.out$",
                "semantic.cache",
                "\.saves$"
                ]
listEx = []

def isFileOrDir (pathName):
    try:
        mode = os.stat(pathName)[stat.ST_MODE]
        if stat.S_ISDIR(mode):
            return "d"
        if stat.S_ISREG(mode):
            return "f"
    except OSError:
        return None
    return None

def killable(fileName):
    for ex in listEx:
        if ex.search(fileName) != None:
            if isFileOrDir(fileName) == 'd':
                return 0
            else:
                return 1
    return 0
    
if __name__ == "__main__":
    
    # init the regex
    for expression in listKillable:
        listEx.append(re.compile(expression))
    
    # get a list of dirs to operate on
    if len(sys.argv[1:]) == 0:
        listDirs = ["."]
    else:
        listDirs = sys.argv[1:]

    # examine every file in each dir
    for dirName in listDirs:
        try:
            listFiles = os.listdir (dirName)
        except os.error:
            print "Error reading directory: ", dirName
            continue
        for fileName in listFiles:
            if killable(fileName) == 1:
                print "Deleting " + fileName,
                try:
                    os.remove(fileName)
                    print "ok"
                except os.error:
                    print "ERROR!"    
