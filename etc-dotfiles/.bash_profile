# path, env and umask are set in .bashrc
source $HOME/.bashrc

# run keychain
if [ -f /usr/bin/keychain ]; then keychain --quiet ; fi

if [ "$USER" = "root" ]; then
    mesg n
fi

#
# UI mods
#

# settings
set -o emacs					# emacs mode!
#set -o ignoreeof				# no ^D to lo

# use advanced settings
if [ -n "$BASH_VERSINFO" ]; then
	shopt -s cdable_vars			# cd to env var
	shopt -s cdspell			    # fix cd spelling
	shopt -s checkwinsize			# dynamically change LINE and WIDTH
	shopt -s hostcomplete			# complete @yaho
	shopt -s interactive_comments   # ignore # for non-interacive shells
fi

#export CDPATH=~/src:~/				# automagically cd to
export FIGNORE=".o:~:.class:.gdoc:.git"  # dont expand for tab compeltion

# bash history
export HISTCONTROL=ignoreboth       # hist ignore dups and leading spaces
export HISTCSIZE=5000               # 10x normal

# editor
export ALTERNATE_EDITOR=emacs 
export EDITOR=emacs
export VISUAL=emacs
export FCEDIT=$EDITOR
export PAGER=less

# set up prompt and keyboard
# modifiers
#   0; none		1; bold		4; underscore
#	5; blink	7; reverse	8; concealed
# colors (30 foreground, 40 background)
# 	;30 black	;31 red		;32 green	;33 yellow	
# 	;34 blue	;35 pink	;36 lt blue	;37 white
# commands
# 	\d date		\H hostname \h hn short	\n CRLF
#	\u user		\w dir		\W PWD		\# command number
#	\! hist num \@ time 12	\t HHMMSS	\T HHMMSS 12

parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

#export PS1='\n\h \! \033[0;32m\w\n$ \033[m'
#export PS1='\n\h \! \033[0;32m \w\n$ '
#export PS2='\! \033[1;34mmore\033[1;30m $ \033[m'
#export PS1='\[\e]1;My Desk\a\e]2;${PWD}\a\e[0;32m\][\u@\h \w]\n\#\$ \[\e[m\]'
#export PS1='\[\e]1;\a\e]2;${PWD}\a\u@\h \e[0;32m\w\n\$ \[\e[m\]'
#export PS1='\n\u@\h:\e[0;32m\w\n\$ \[\e[m\]'
#export PS1='\n\u@\H\e[0;30m:\e[0;32m\w\n\$ \[\e[m\]'

if [ -f /usr/bin/git ] ; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(parse_git_branch)\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
fi
   

cd() {
    if [ -n "$1" ]; then
    	case "$1" in
        ...)       builtin cd "../..";;
        ....)      builtin cd "../../..";;
        .....)     builtin cd "../../../..";;        
        ......)    builtin cd "../../../../..";;
        .......)   builtin cd "../../../../../..";;
        ........)  builtin cd "../../../../../../..";;
        .........) builtin cd "../../../../../../../..";;
        ..........)builtin cd "../../../../../../../../..";;        *) builtin cd "$1"
        esac
    else 
    	builtin cd
    fi
    ls
}

if [ "1" = $(($RANDOM%2+1)) ]; then
	echo
	huniversal-time
else
    if which fortune > /dev/null ; then
        echo
        fortune
    fi
fi
