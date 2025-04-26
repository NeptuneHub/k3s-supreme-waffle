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

Edit the configuration file or create one if needed:
```
vim /etc/vim/vimrc.local 
```

and add this:
```
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim = 1
if has('mouse')
  set mouse=r
endif
```

# References
* **sudoers** - https://unix.stackexchange.com/questions/292562/adding-a-sudoer-in-debian
* **Cut&paste in vim** - https://www.cyberciti.biz/faq/enable-vim-mouse-copy-paste-in-ubuntu-debian-linux-unix/
