# path, env and umask are set in .bashrc
source $HOME/.bashrc

# run keychain
if [ -f /usr/bin/keychain ]; then keychain --quiet ; fi

# misc ui stuff
if [ -f $HOME/.bash_profile-ui ] ; then . $HOME/.bash_profile-ui ; fi

### added by llxt for setting $DISPLAY, xauth, and the current directory
if [ -f $HOME/.llxt_setup ] ; then . $HOME/.llxt_setup ; fi

if [ "$USER" = "root" ]; then
    mesg n
fi

