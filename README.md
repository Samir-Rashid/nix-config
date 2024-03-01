# Samir's nix-config [![built with nix](https://img.shields.io/static/v1?logo=nixos&logoColor=white&label=&message=Built%20with%20Nix&color=41439a)](https://builtwithnix.org)
Nix configuration for MacBook 16,1. 2019 MacBook Pro 16 inch.

> [!TIP]
> If you just want to reference a minimal config for a MacBook 16,1, look at the [minimal config](/minimal-configuration.nix).
>
> If you want to meet more Nixers, check out [Nixcon NA](https://2024-na.nixcon.org/), the convention all about Nix in North America.

What's working:
- everything
  - display, audio, speakers, trackpad, keyboard, camera, mic, battery life, gpu, igpu, bluetooth, wifi, dual boot, touchbar, ...

What's not:
- some questionable sleep problems
  - Upgrading MacOS to Sonoma breaks Linux sleep across all distros. Apple has changed some firmware and fixes for this have not been merged upstream yet. Sleep used to work for me and I expect it to work again.
- some proprietary things are messed up and will never work
  - touch ID

> [!WARNING]  
> I seriously cannot recommend using NixOS. Any OS will work fine and there are better, useful things to spend your time on.
> A funny but apt warning I found in a [readme](https://github.com/javacafe01/nix-config/)
> 
>  <img src="https://camo.githubusercontent.com/c7aabe19981f9cf4ae58e0f7ac688869ed1e72a6564c080de320cc6a755e269f/68747470733a2f2f692e726564642e69742f697869367a6b756467737536312e706e67" alt="Learning curve of NixOS leads to death" width="50%" />
> 
> Some more serious posts of the pitfalls of using NixOS:
>
> Personally, I have experienced the bad UX debugging nix issues, the terrible NixOS documentation, and the fragmentation of nix standards making things very hard to understand. NixOS concepts are hard to grasp and you don't want to have to wonder about all these philosophical reasons why simple things are hard to do as you are searching through forum posts to solve your issue.
>
> https://github.com/lambdanil/nix-problems
>
> https://www.willghatch.net/blog/2020/06/27/nixos-the-good-the-bad-and-the-ugly/
> 
> While NixOS is a bit much, nix the package manager is a game changer. I can confidently recommend using Nix package manager + Unix derived OS. [This post](https://jvns.ca/blog/2023/02/28/some-notes-on-using-nix/) is a light read going over some basic info on what that would look like in practice.

### [Install instructions](https://wiki.t2linux.org/distributions/nixos/installation/)

I would recommend skimming below for potential pitfalls. The installation has become a lot simpler after I did my setup since all the t2 macbook hardware quirks got upstreamed into the nixos-hardware repo. The t2 nixos maintainers have graciously put basically all of the special patches listed in the wiki into the hardware config so you should not have to do anything special for things to work.

Useful resources
- Arch wiki
- NixOS wiki
- https://wiki.t2linux.org/

- https://www.arthurkoziel.com/installing-nixos-on-a-macbookpro/
- I would recommend following this along with the [Arch wiki](https://wiki.archlinux.org/title/Mac#Installation). The Arch wiki should stay up to date with any changes since this post. 
- Other links you may find useful to cross reference [1](https://superuser.com/questions/795879/how-to-configure-dual-boot-nixos-with-mac-os-x-on-an-uefi-macbook) [2](https://thoughtbot.com/blog/install-linux-on-a-macbook-air) [3](https://borretti.me/article/nixos-for-the-impatient)

Remaining tasks after you boot nixos will be to install the wifi drivers (instructions in t2 linux wiki)and to enable graphics switching (also in t2 wiki, note I had to reset nvram for it to work)

What I had to change from the post
- virtualbox flashing my boot usb didn't work. Make a shared folder with MacOS and then use Balena Etcher
- Be sure to use Konsole when editing files
- I would recommend making sure you see the USB in your boot menu before playing with partitions
- you may have to disable secure oot and allow booting from usb in recovery OS
- before changing partitions, disable filevault
- have to disable SIP before doing refind and then re-enable that and filevault afterwards

         
