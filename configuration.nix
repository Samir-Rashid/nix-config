# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

# Commands
# to garbage collect $ nix-store --gc
# To update nix channels sudo nixos-rebuild switch --upgrade
# List generations: nix profile history --profile /nix/var/nix/profiles/system
# Delete generations: sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 14d.`
# https://specific.solutions.limited/blog/recovering-diskspace-in-nixos
# deduplicate nix-store pkgs nix-store --optimise
# nix shell github:DavHau/mach-nix
# to debug shutdown: journalctl -p 3 -b -1

# TODO: add dotfiles
# 	external monitor brightness
# add secrets https://xeiaso.net/blog/nixos-encrypted-secrets-2021-01-20/
# add busybox, cope, toybox - breaks booting
# failed to install asahi-linux's speaker dsp https://wiki.t2linux.org/guides/audio-config/
# 						https://github.com/lemmyg/t2-apple-audio-dsp/tree/speakers_161
# debug sleep, hibernate

# TODO: audio config things in .nix

# TODO: https://gitlab.com/magnolia1234/bypass-paywalls-firefox-clean#installation

# Fix touchbar issues https://wiki.t2linux.org/guides/postinstall/#setting-up-the-touch-bar
# Add auto install for mic and speaker dsp
#    I installed currently just by doing the 2 install scripts, but that is not portable

# TODO: reinstall and make reproducible wifi firmware in config, change fs

# TODO: remove networkmanager notifications (breaks touchid)
#sudo sh -c 'echo "# Disable for now T2 chip internal usb ethernet
#blacklist cdc_ncm
#blacklist cdc_mbim" >> /etc/modprobe.d/blacklist.conf'

# TODO: alias xclip to `xclip -selection clipboard`

#  programs = {
#    ssh.startAgent = true;
#    command-not-found.enable = true;
#    adb.enable = true;
#    gnupg.agent.enable = true;
#  };
#
#  documentation = {
#    man.enable = true;
#  };
{ config, lib, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    #./pipewire.nix
    #./t2-mic.nix
    ./unstable.nix
    "${
      builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }
    }/apple/t2"
    # "${builtins.fetchGit { url = "https://github.com/kekrby/nixos-hardware.git"; }}/apple/t2"

    <home-manager/nixos> # TODO: switch to flake + home manager
  ];

  /* # wifi stuff
     hardware.firmware = [
       (pkgs.stdenvNoCC.mkDerivation {
         name = "brcm-firmware";

         buildCommand = ''
           dir="$out/lib/firmware"
           mkdir -p "$dir"
           cp -r ${./files/firmware}/* "$dir"
         '';
       })
     ];
  */

  # system.autoUpgrade.channel = "https://nixos.org/channels/nixos-21.05/";
  hardware.facetimehd.enable =
    lib.mkDefault (config.nixpkgs.config.allowUnfree or false);

  #services.mbpfan.enable = lib.mkDefault true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  #boot.initrd.kernelModules = [ "applespi" "spi_pxa2xx_platform" "intel_lpss_pci" "applesmc" ];
  boot = {
    # using the t2 custom kernel
    # kernelPackages = pkgs.linuxPackages_latest; #pkgs.linuxPackages_4_3; # TODO: check this

    kernelParams = [
      # https://help.ubuntu.com/community/AppleKeyboard
      # https://wiki.archlinux.org/index.php/Apple_Keyboard
      "hid_apple.fnmode=1"
      "hid_apple.iso_layout=0"
      "hid_apple.swap_opt_cmd=1"
    ];
  };
  boot.tmp.cleanOnBoot = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nixpkgs.config.segger-jlink.acceptLicense = true;

  # enable udev rules from packages
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "99-ftdi.rules";
      text = ''
        ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6015", MODE="0666"
      '';
      destination = "/etc/udev/rules.d/99-ftdi.rules";
    })
    pkgs.segger-jlink
  ];

  #services.udev = {
  #	extraRules = ''
  #		ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6015", MODE="0666"
  #		ATTRS{idVendor}=="2341", ATTRS{idProduct}=="005a", MODE="0666"
  #'';
  #};
  # https://nixos.wiki/wiki/Laptop
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "schedutil";
  services.thermald.enable = true;
  services.power-profiles-daemon.enable =
    false; # gnome enables this, which makes tlp incompatible
  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
      governor = "powersave";
      turbo = "never";
    };
    charger = {
      governor = "powersave";
      # governor = "performance";
      # turbo = "auto";
      turbo = "never";
    };
  };

  services.tlp.enable = true;
  powerManagement.powertop.enable = true;
  # try system76 power?

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  nixpkgs.config.allowUnfree = true;
  networking.networkmanager.enable =
    true; # Easiest to use and most distros use this by default.
  networking.hostName = "nixos";

  # /etc/hosts
  networking.extraHosts = ''
    0.0.0.0 reddit.com
    0.0.0.0 youtube.com
  '';
  # can also add stevenblack list from github
  # extrahostsfromsteve = pkgs.fetchurl { url = "https://raw.githubusercontent.com/StevenBlack/hosts/v2.3.7/hosts"; sha256 = "sha256-C39FsyMQ3PJEwcfPsYSF7SZQZGA79m6o70vmwyFMPLM="; }
  # networking.extraHosts = '' ${builtins.readFile extrahostsfromsteve} '';

  virtualisation.docker.enable = true;
  #home.username = "samir";
  #home.homeDirectory = "/home/samir";
  #home.stateVersion = "23.05";
  #programs.home-manager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    # keyMap = "us";
    useXkbConfig = true; # use xkbOptions in tty.
    # packages = [ terminus_font ];
  };
  # console font (readable at boot)
  # i18n.consoleFont = "ter-i32b";

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  #services.xserver.displayManager.defaultSession = "xfce";
  #services.xserver.desktopManager.xfce.enable = true;

  # The wifi broadcom driver 
  networking.enableB43Firmware = true;

  # Configure keymap in X11
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  # hardware.pulseaudio.enable = false;
  hardware.pulseaudio.enable = pkgs.lib.mkForce false;
  security.rtkit.enable = true;
  security.polkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;
    wireplumber.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  hardware.bluetooth.enable = true;
  services.usbmuxd.enable = true;
  hardware.apple-t2.enableAppleSetOsLoader =
    true; # not sure if this is needed. it was working fine

  # https://nixos.wiki/wiki/OpenVPN
  services.openvpn.servers = {
    homeVPN = {
      config = "config /home/samir/homeVPN.conf ";
    }; # systemctl start openvpn-homeVPN.service
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  # these are overwritten by gnome
  # services.xserver.libinput.touchpad.accelSpeed = "2.0";
  # services.xserver.libinput.touchpad.accelProfile = "adaptive"; # or "flat" for no acceleration

  # Define a user account. Don't forget to set a password with ‘passwd’.
  #  users.mutableUsers = false; # Make sure the only way to add users/groups is to change this file
  users.users.samir = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      firefox
      thunderbird
      ungoogled-chromium
      google-chrome
      tree
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    scc # cloc
    iwd
    openvpn
    gnu-efi
    ntfs3g
    exfat
    gnumake
    ffmpeg
    nmap
    pciutils
    s-tui

    # gnome extensions
    gnomeExtensions.pop-shell
    gnomeExtensions.desktop-cube
    gnomeExtensions.system-monitor
    gnomeExtensions.burn-my-windows
    gnomeExtensions.grand-theft-focus
    gnomeExtensions.fullscreen-avoider
    gnomeExtensions.blur-my-shell
    gnomeExtensions.dash-to-panel
    gnomeExtensions.appindicator

    mypaint
    # usb
    # usbutils
    # usbrip
    # usbtop
    # usbview
    # libusb

    acpi
    psensor
    delta
    losslesscut-bin
    git
    gh
    nixfmt

    (wine.override { wineBuild = "wine64"; })
    bottles

    glxinfo
    radeontop
    gnome.gnome-sound-recorder
    radeon-profile
    #    nrf-command-line-tools
    #nrfconnect
    curl
    #libbass
    yt-dlp
    trashy
    scrot
    okular
    hollywood
    apostrophe
    i3 # twm

    ladspaPlugins
    neovim
    segger-jlink
    htop
    discord
    keepassxc
    signal-desktop
    cider # apple music
    vlc
    mc # tui file browser
    epiphany
    bitwarden
    obsidian
    mpv
    xournal
    obs-studio
    blender
    kdenlive
    slack
    timeshift
    jellyfin-media-player
    synology-drive-client

    # shell utilities
    xclip
    lsd
    zoxide
    starship
    zsh-completions
    nix-zsh-completions
    coreutils-full
    tealdeer
    act # local gh actions
    stow
    zip
    unzip
    gnutar
    bat
    jq
    tree
    tmux
    fzf
    ripgrep
    fd
    lfs
    ffmpeg
    yt-dlp
    spotify
    croc
    gocryptfs
    libreoffice-still
    cool-retro-term

    htop
    gotop
    btop

    # trying to get audio dsp to work
    #carla # gui thing
    #lsp-plugins
    rnnoise-plugin
    #distrho
    #ir.lv2
    #ardour
    #easyeffects
    calf
    #jack2
    swh_lv2
    lv2
    lilv

    pipewire
    #pipewire-audio-client-libraries 
    #libpipewire-0.3-modules 
    #libspa-0.2-bluetooth 
    #libspa-0.2-jack 
    #libspa-0.2-modules 
    #pipewire-pulse 
    #pipewire-bin 
    #pipewire-tests
    wireplumber
    lsp-plugins
    ladspaPlugins

    texlive.combined.scheme-basic
    vscode-fhs
    # TODO: switch to using these vscode extensions https://github.com/nix-community/nix-vscode-extensions
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions;
        [
          bbenoist.nix
          ms-python.python
          ms-azuretools.vscode-docker
          ms-vscode-remote.remote-ssh
          ms-vscode.cmake-tools
          ms-vscode.cpptools
          twxs.cmake
          eamodio.gitlens
          ms-toolsai.jupyter
          ms-python.python
          ms-vscode.makefile-tools
          rust-lang.rust-analyzer
          davidanson.vscode-markdownlint

          # ms-vscode-remote.remote-containers
          vscode-icons-team.vscode-icons

          formulahendry.auto-rename-tag
          # GitHub.vscode-pull-request-github
          redhat.vscode-yaml
          wholroyd.jinja
          # TabNine.tabnine-vscode
          vscodevim.vim

          # aaron-bond.better-comments
          # wayou.vscode-todo-highlight
          # Gruntfuggly.todo-tree
          # ms-vscode.live-server

          /* dracula-theme.theme-dracula
             # vscodevim.vim
             yzhang.markdown-all-in-one
             # WakaTime.vscode-wakatime
             denoland.vscode-deno
             esbenp.prettier-vscode
             eamodio.gitlens
             file-icons.file-icons
             dracula-theme.theme-dracula
             jnoortheen.nix-ide
             svelte.svelte-vscode
             golang.go
             github.copilot
             ms-python.python
             ms-toolsai.jupyter
             antfu.icons-carbon
             matklad.rust-analyzer
             file-icons.file-icons
             dbaeumer.vscode-eslint
             bradlc.vscode-tailwindcss
             kamikillerto.vscode-colorize
             ms-vscode-remote.remote-ssh
             mechatroner.rainbow-csv
             donjayamanne.githistory
             davidanson.vscode-markdownlint
             bbenoist.nix
             github.copilot
          */

        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
          name = "remote-ssh-edit";
          publisher = "ms-vscode-remote";
          version = "0.47.2";
          sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
        }];
    })

    nix-index
    comma # run `nix-index` to generate package index
    #(let
    #  comma = (import (pkgs.fetchFromGitHub {
    #    owner = "nix-community";
    #    repo = "comma";
    #    rev = "v1.2.0";
    #    sha256 = "0000000000000000000000000000000000000000000000000000";
    #  })).default;
    #in [ comma ];)
    #    comma = (import (pkgs.fetchFromGitHub {
    #    owner = "nix-community";
    #    repo = "comma";
    #    rev = "v1.2.0";
    #    sha256 = "0000000000000000000000000000000000000000000000000000";
    #  })).default;

  ];

  # https://nixos.wiki/wiki/Discord
  nixpkgs.overlays = let
    myOverlay = self: super: {
      discord =
        super.discord.override { # withVencord = true; }; #withOpenASAR = true;
          nss = super.nss_latest;
          withOpenASAR = true;
          #withVencord = true; # TODO: broken
        };

    };
  in [ myOverlay ];
  # TODO: add krisp workaround to config
  # https://github.com/NixOS/nixpkgs/issues/195512

  environment.localBinInPath = true;
  environment.variables = {
    DSSI_PATH =
      "$HOME/.dssi:$HOME/.nix-profile/lib/dssi:/run/current-system/sw/lib/dssi";
    LADSPA_PATH =
      "$HOME/.ladspa:$HOME/.nix-profile/lib/ladspa:/run/current-system/sw/lib/ladspa";
    LV2_PATH =
      "$HOME/.lv2:$HOME/.nix-profile/lib/lv2:/run/current-system/sw/lib/lv2";
    LXVST_PATH =
      "$HOME/.lxvst:$HOME/.nix-profile/lib/lxvst:/run/current-system/sw/lib/lxvst";
    VST_PATH =
      "$HOME/.vst:$HOME/.nix-profile/lib/vst:/run/current-system/sw/lib/vst";
  };

  #  environment.variables =
  #    (with lib;
  #    listToAttrs (
  #      map
  #        (
  #          type: nameValuePair "${toUpper type}_PATH"
  #            ([ "$HOME/.${type}" "$HOME/.nix-profile/lib/${type}" "/run/current-system/sw/lib/${type}" ])
  #        )
  #        [ "dssi" "ladspa" "lv2" "lxvst" "vst" "vst3" ]
  #    ));

  #programs.nix-index.enable = true; # for comma

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  environment.etc = {
    # Creates /etc/nanorc
    "/modprobe.d/apple-gmux.conf" = {
      text = ''
        # Enable the iGPU by default if present
        options apple-gmux force_igd=y
      '';

      # The UNIX file mode bits
      mode = "0440";
    };
  };

  programs.command-not-found.enable = false;
  # for home-manager, use programs.bash.initExtra instead
  #programs.bash.interactiveShellInit = ''
  #  source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
  #'';

  #systemd.services.btattach-bcm2e7c = lib.mkIf config.hardware.bluetooth.enable {
  #  before = [ "bluetooth.target" ];

  #  # Hacky, as it's a different device,  but this always comes after ttyS0
  #  after = [ "sys-devices-platform-serial8250-tty-ttyS1.device" ];
  #  path = [ pkgs.bash pkgs.kmod pkgs.bluez ];

  #  serviceConfig.Type = "simple";
  #  serviceConfig.ExecStart = "${./btfix.sh}";

  #  wantedBy = [ "multi-user.target" ];
  #};

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}

