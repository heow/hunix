
### Highlights of Heow's Unix ###

This is the collections of scripts and things that I've hacked together throughout my career to make life easier in a Unix-like environment.

You know you're doing things right when your scripts keep getting imported into software as features, I expect you'll find something here you like.

* find-known-hosts.sh - searches for known hosts on the local network by known MAC address.  If found, hosts are added or updated in ~/.ssh/config, making them accessible by ssh.  This is great if you bring more than one machine to a local network and need to get them talking quickly.
* secure-backup-remote.sh - find, encrypt, compress and back up directory tree over the network.  Supports file exclusions, uses GPG for encryption and SSH for transport.  Files are future proof.

```
curl -O https://raw.githubusercontent.com/heow/hunix/master/bin/get-hunix.sh
chmod +x get-hunix.sh
./get-hunix.sh
```

...and many more.
