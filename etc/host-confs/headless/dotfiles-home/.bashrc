umask 0002 #u=rwx g=rx o=

export WINDOW_MANAGER=sawfish

export PAGER=less
export BLOCKSIZE=1k

# dev stuff
export CVS_RSH=ssh
#export CVSROOT=/var/cvs
#export CVSROOT=":ext:heow@www.lispnyc.org:/export/lispnyc/robocup"
export CVSROOT=":pserver:heow@127.0.0.1:/usr/local/cvsroot"
#export CVSROOT=":pserver:heow@cvshome.intdata.com:/cvs_files/repos"

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib

#
# PATH
#
export PATH=${HOME}/.hunix/bin:/sbin:/usr/sbin:/opt/local/bin:/opt/local/sbin:/usr/local/bin:${PATH}

# java 
#export JBOSS_HOME=${HOME}/prj/jboss/jboss-3.0.0_tomcat-4.0.3
export JAVA_HOME=$HOME/.hunix/opt/java
export JAVA=$JAVA_HOME/bin/java
#export ANT_HOME=/usr/share/ant/

# java path
export PATH=${PATH}:${JAVA_HOME}/bin:${ANT_HOME}/bin



# clojure
export CLJ_ROOT=~/.hunix/opt/clj/
export CLJ_HOME=~/.hunix/opt/clj/clojure
export CLOJURE_HOME=${CLJ_HOME}/clojure/

# android
#export PATH="/home/heow/.hunix/bin:~/prj-personal/android-sdk-linux_x86-1.0_r2/tools/:$PATH"
#export MANPATH="/home/heow/.local/share/man:$MANPATH"

# ruby 
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# PHP
#export PATH=$PATH:/usr/local/zend/bin
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/zend/lib

export PATH=/home/heow/.hunix/opt/jdk1.6/jdk/bin/:$PATH
