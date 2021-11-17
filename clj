#!/bin/sh

# the new clojure wrapper supplants 90% of this

# are we in leiningen?
if [ -f project.clj ]; then
    lein repl
    exit
fi

# current dir to CP
clojure -cp ${CLASSPATH}:${PWD} "$@"
