# nix-config

Nix configuration for MacBook 16,1. 2019 MacBook Pro 16 inch.

What's working:
everything
...


Useful resources
Arch wiki
NixOS wiki
https://wiki.t2linux.org/

https://www.arthurkoziel.com/installing-nixos-on-a-macbookpro/
I would recommend following this along with the [Arch wiki](https://wiki.archlinux.org/title/Mac#Installation). The Arch wiki should stay up to date with any changes since this post. 
Other links you may find useful to cross reference [1](https://superuser.com/questions/795879/how-to-configure-dual-boot-nixos-with-mac-os-x-on-an-uefi-macbook) [2](https://thoughtbot.com/blog/install-linux-on-a-macbook-air) [3](https://borretti.me/article/nixos-for-the-impatient)

Remaining tasks after you boot nixos will be to install the wifi drivers (instructions in t2 linux wiki)and to enable graphics switching (also in t2 wiki, note I had to reset nvram for it to work)

What I had to change from the post
- virtualbox flashing my boot usb didn't work. Make a shared folder with MacOS and then use Balena Etcher
- Be sure to use Konsole when editing files
- I would recommend making sure you see the USB in your boot menu before playing with partitions
- you may have to disable secure oot and allow booting from usb in recovery OS
- before changing partioins, disable filevault
- have to disable SIP before doing refind and then re-enable that and filevault afterwards

- I hope the t2 people's changes get upstreamed soon. That will make all of this a breeze. Especially with the asahi people constantly impiroving drivers.
         
         
