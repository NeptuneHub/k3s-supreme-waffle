# Introduction
This contains some useful command for who don't use Ubuntu but a Debian. This command was tested on Debain 12

# Add you user to sudoers group

Edit the config filw with vim
```
 vim /etc/sudoers
```
and after this line
```
# Allow members of group sudo to execute any command
%sudo   ALL=(ALL:ALL) ALL
```

add this by edit youruser with you actual user:
```
youruser    ALL=(ALL) NOPASSWD:ALL
```

You can also remove NOPASSWD: if you want that it ask the password every time
```
guido   ALL=(ALL) ALL
```

# Enable mouse cut&paste in vim terminal

# References
* **sudoers** - https://unix.stackexchange.com/questions/292562/adding-a-sudoer-in-debian
