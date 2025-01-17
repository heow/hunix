
### Highlights of Heow's Unix ###

This is the collections of scripts and things that I've hacked together throughout my career to make life easier in a Unix-like environment.

You know you're doing things right when your scripts keep getting imported into software as features, I expect you'll find something here you like.

* secure-backup-remote.sh - find, encrypt, compress and back up directory tree over the network.  Supports file exclusions, uses GPG for encryption and SSH for transport.  Files are future proof.

...and many more.

### Getting Started

```
bash <(curl -s https://raw.githubusercontent.com/heow/hunix/master/get-hunix.sh)
```

Use hunix-bin/get-hunix.sh to bootstrap the system:

    wget https://raw.github.com/heow/hunix-bin/master/get-hunix.sh
    /bin/bash ./get-hunix.sh

Creates the following directory tree:

    .local/bin
    .bash_profile     -> ~/.local/bin/etc-dotfiles/.bash_profile
    .bash_aliases     -> ~/.local/bin/etc-dotfiles/.bash_aliases
    .emacs            -> ~/.local/bin/etc-dotfiles/.emacs
    .emacs-site-lisp  -> ~/.local/bin/etc-dotfiles/.emacs-site-lisp
    .tmux.conf        -> ~/.local/bin/etc-dotfiles/.tmux-conf
