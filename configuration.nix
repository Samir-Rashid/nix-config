# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).


# TODO: post multiple channels flake/notflake guide
# TODO: home manager

# Commands
# to garbage collect $ nix-store --gc
# nix-env --delete-generations old
# To update nix channels sudo nixos-rebuild switch --upgrade (only update channels `nix-channel --update`)
# home-manager https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz
# nixos https://channels.nixos.org/nixos-23.11
# nixos-hardware https://github.com/NixOS/nixos-hardware/archive/master.tar.gz
# List generations: nix profile history --profile /nix/var/nix/profiles/system
# Delete generations: sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 14d.`
# https://specific.solutions.limited/blog/recovering-diskspace-in-nixos
# deduplicate nix-store pkgs nix-store --optimise
# nix shell github:DavHau/mach-nix
# to debug shutdown: journalctl -p 3 -b -1

# clear space with docker:
# docker system df
# docker builder prune

# TODO: nondeterminisms
# - background image
# - power button gnome setting, dark mode, automatic suspend, battery %, gnome extensions

# TODO: add dotfiles
# 	external monitor brightness
# add secrets https://xeiaso.net/blog/nixos-encrypted-secrets-2021-01-20/

# TODO: https://gitlab.com/magnolia1234/bypass-paywalls-firefox-clean#installation

# TODO: Fix touchbar issues https://wiki.t2linux.org/guides/postinstall/#setting-up-the-touch-bar

# TODO: reinstall and make reproducible wifi firmware in config, change fs

# TODO: remove networkmanager notifications (breaks touchid)
#sudo sh -c 'echo "# Disable for now T2 chip internal usb ethernet
#blacklist cdc_ncm
#blacklist cdc_mbim" >> /etc/modprobe.d/blacklist.conf'

# TODO: alias xclip to `xclip -selection clipboard`
# vim config: set clipboard=unnamedplus
# TODO: make home manager firefox and vscode extensions reproducible. 
#           nix.enableLanguageServer = "true" in vscode to make nix lsp work
# TODO: https://github.com/nix-community/nix-direnv

# different methods of storing secrets https://lgug2z.com/articles/handling-secrets-in-nixos-an-overview/

#  programs = {
#    ssh.startAgent = true;
#    command-not-found.enable = true;
#    adb.enable = true;
#    gnupg.agent.enable = true;
#  };
#
{ config, lib, pkgs, inputs, pkgs-old, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    #./unstable.nix
    "${
      builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git";
      			  rev = "e158702cb8e39dc484c594a8bd733ca623f3309c"; # use this to pin to older kernels
			  # vmlinux File size limit exceeded
			  # ulimit -f 2097152
			# hash
			}
    }/apple/t2"

    #<nixos-hardware/apple> # TODO: this needs to get added for flake
    #<nixos-hardware/common/cpu/intel>
    #<nixos-hardware/common/pc/laptop/ssd>
  ];

  nix = {
    #nixPath = [ "/etc/nix/path" ];
    package = pkgs.nixFlakes;
    extraOptions = "experimental-features = nix-command flakes";
  };

  # t2linux specific
  nix.settings = {
    trusted-substituters = [
      "https://t2linux.cachix.org"
    ];
    trusted-public-keys = [
      "t2linux.cachix.org-1:P733c5Gt1qTcxsm+Bae0renWnT8OLs0u9+yfaK2Bejw="
    ];
  };
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
  nix.channel.enable = false;

  # Map flake inputs to the registry, any flake can go here (only nixpkgs for example)
  # nix.registry =
  #   (lib.mapAttrs (_: flake: {inherit flake;}))
  #   ((lib.filterAttrs (_: lib.isType "flake")) inputs);
  # nix.nixPath = ["/etc/nix/path"]; # This won't work
  # nix.settings.nix-path = ["/etc/nix/path"]; # This will fix the missing NIX_PATH
  #environment.etc."channels/nixpkgs".source = pkgs-old.outPath;
  # environment.etc."channels/home-manager".source = home-manager.outPath;
  # nix.nixPath = [
  #   "nixpkgs=/etc/channels/nixpkgs"
  #  # "home-manager=/etc/channels/home-manager"
  # ];

  # These DO not work!!!!
  #somethingTemporary = builtins.trace "input is inputs inputs" inputs;
  #somethingTemporary2 = builtins.trace (builtins.attrNames inputs) inputs;
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.nixPath = [ "/etc/nix/path" "nixpkgs=/etc/nix/path/nixpkgs" ];
  #environment.etc."nix/path/nixpkgs".source = pkgs; #pkgs.path; #inputs.nixpkgs;
  systemd.tmpfiles.rules = [
    "L+ /etc/nix/path/nixpkgs     - - - - ${inputs.nixpkgs}"
  ];
  # https://github.com/NobbZ/nixos-config/blob/main/nixos/modules/flake.nix

  # https://discourse.nixos.org/t/do-flakes-also-set-the-system-channel/19798/2
  # https://discourse.nixos.org/t/problems-after-switching-to-flake-system/24093/8

  hardware.facetimehd.enable =
    lib.mkDefault (config.nixpkgs.config.allowUnfree or false);

  # fan control
  services.mbpfan.enable = lib.mkDefault true;
  services.mbpfan.verbose = true;
  services.mbpfan.aggressive = true;


  # Use the systemd-boot EFI boot loader.
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  #boot.initrd.kernelModules = [ "applespi" "spi_pxa2xx_platform" "intel_lpss_pci" "applesmc" ]; # This breaks things, specifically applesmc

  boot = {
    # using the t2 custom kernel
    # kernelPackages = pkgs.linuxPackages_latest;

    kernelParams = [
      # https://help.ubuntu.com/community/AppleKeyboard
      # https://wiki.archlinux.org/index.php/Apple_Keyboard
      "hid_apple.fnmode=1"
      "hid_apple.iso_layout=0"
      "hid_apple.swap_opt_cmd=1"

      # "apple-gmux.force_igd=y"
    ];
  };

  # disable sleep on lid close
  services.logind = {
    lidSwitch = "lock";
    lidSwitchDocked = "lock";
    lidSwitchExternalPower = "lock";
  };

  boot.tmp.cleanOnBoot = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # You have to set these if you don't have channels
  # idk what this does
  # nix.registry = {
  #   nixpkgs.to = {
  #     type = "path";
  #     path = pkgs.path;
  #   };
  # };
  # nix.nixPath = [ "nixpkgs=nixpkgs.outPath" ]; # this does not work tot fix nix-shell

  # automatically activate nix-shells
  programs.direnv.enable = true;

  nixpkgs.config.segger-jlink.acceptLicense = true;
  # nixpkgs-old.config.segger-jlink.acceptLicense = true;

  # enable udev rules from packages
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "99-ftdi.rules";
      text = ''
        ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6015", MODE="0666"
      '';
      destination = "/etc/udev/rules.d/99-ftdi.rules";
    })
    pkgs-old.segger-jlink

    #gnome.gnome-settings-daemon
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

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  nixpkgs.config.allowUnfree = true;
  networking.networkmanager.enable =
    true; # Easiest to use and most distros use this by default.
  networking.hostName = "nixos";

  # /etc/hosts
  networking.extraHosts = ''
    #0.0.0.0 www.reddit.com
    #0.0.0.0 reddit.com
    #0.0.0.0 youtube.com
    #0.0.0.0 www.youtube.com
  '';
  # can also add stevenblack list from github
  # extrahostsfromsteve = pkgs.fetchurl { url = "https://raw.githubusercontent.com/StevenBlack/hosts/v2.3.7/hosts"; sha256 = "sha256-C39FsyMQ3PJEwcfPsYSF7SZQZGA79m6o70vmwyFMPLM="; }
  # networking.extraHosts = '' ${builtins.readFile extrahostsfromsteve} '';

  virtualisation.docker.enable = true;
  #home.username = "samir";
  #home.homeDirectory = "/home/samir";
  #home.stateVersion = "23.05";
  #programs.home-manager.enable = true;

  # have ld paths to be able to run normal Linux programs
  # programs.nix-ld.enable = true;
  # programs.nix-ld.libraries = with pkgs; [
  #   # Add any missing dynamic libraries for unpackaged 
  #   # programs here, NOT in environment.systemPackages
  # ];

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
  hardware.apple-t2.enableAppleSetOsLoader = true; # for iGPU, sets up firmware
  # OpenGL & packages for intel integrated graphics
  # TODO: check this out on new >=6.5 kernel
  # hardware.opengl.enable = true;
  # hardware.opengl.extraPackages = with pkgs; [
  #   vaapiIntel
  #   libvdpau-va-gl
  #   intel-media-driver
  #   intel-ocl
  # ];

  # https://nixos.wiki/wiki/OpenVPN
  # services.openvpn.servers = {
  #   homeVPN = {
  #     config = "config /home/samir/homeVPN.conf ";
  #   }; # systemctl start openvpn-homeVPN.service
  # };
  services.tailscale.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  # these are overwritten by gnome
  # services.xserver.libinput.touchpad.accelSpeed = "2.0";
  # services.xserver.libinput.touchpad.accelProfile = "adaptive"; # or "flat" for no acceleration

  # Define a user account. Don't forget to set a password with ‘passwd’.
  #  users.mutableUsers = false; # Make sure the only way to add users/groups is to change this file
  users.users.samir = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      firefox
      thunderbird
      ungoogled-chromium
      google-chrome
      tree
    ];
  };

  programs = {
    nix-index-database.comma.enable = true;
    kdeconnect.enable = true;
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      ohMyZsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = [
          #"sudo"
          #"terraform"
          #"systemadmin"
          #"vi-mode"
          "git"
        ];
      };
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  environment.systemPackages = with pkgs; [
    vim
    wget
    scc # cloc # source code line counter
    iwd
    # openvpn
    gnu-efi
    ntfs3g
    exfat
    gnumake
    remake
    nmap
    pciutils
    s-tui
    eza
    tailscale # VPN

    xcolor # color picker
    # gnome extensions
    gnomeExtensions.pop-shell
    gnomeExtensions.desktop-cube
    gnomeExtensions.system-monitor-2
    gnomeExtensions.burn-my-windows
    gnomeExtensions.grand-theft-focus
    gnomeExtensions.fullscreen-avoider
    gnomeExtensions.blur-my-shell
    gnomeExtensions.dash-to-panel
    gnomeExtensions.appindicator # systray icons
    gnomeExtensions.gsconnect

    mypaint # MS Paint
    sioyek # pdf viewer
    # diffpdf # diff pdfs

    acpi
    psensor
    delta # better diff
    # losslesscut-bin
    git
    gh # github cli

    # nix language
    nixfmt
    nixpkgs-fmt
    nil # nix lsp
    rnix-lsp

    # wine emulator
    # (wine.override { wineBuild = "wine64"; })
    # bottles

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
    # hollywood
    apostrophe
    i3 # twm

    ladspaPlugins
    neovim
    pkgs-old.segger-jlink # moved to unstable
    pkgs-old.nrf-command-line-tools # moved to unstable

    # inputs.nixpkgs-old.legacyPackages.x86_64-linux.segger-jlink # moved to unstable
    # inputs.nixpkgs-old.legacyPackages.x86_64-linux.nrf-command-line-tools
    htop

    # communication
    discord
    # element-desktop
    signal-desktop
    slack

    # password manager
    keepassxc
    bitwarden

    cider # apple music
    vlc
    # handbrake
    mc # tui file browser
    # epiphany
    obsidian
    mpv
    xournal
    #obs-studio
    #blender
    #kdenlive
    #timeshift
    jellyfin-media-player
    #synology-drive-client

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

    # search tools
    fzf
    ripgrep
    fd

    lfs

    # audio
    ffmpeg
    yt-dlp
    spotify
    croc # send/receive files
    gocryptfs
    libreoffice-still

    # terminal emulator
    cool-retro-term

    # `top` alternatives
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

    # Gstreamer
    # Video/Audio data composition framework tools like "gst-inspect", "gst-launch" ...
    gst_all_1.gstreamer
    # Common plugins like "filesrc" to combine within e.g. gst-launch
    gst_all_1.gst-plugins-base
    # Specialized plugins separated by quality
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    # Plugins to reuse ffmpeg to play almost every video format
    gst_all_1.gst-libav
    # Support the Video Audio (Hardware) Acceleration API
    gst_all_1.gst-vaapi

    # Text editing stuff
    # texlive.combined.scheme-basic # not using tex

    #typst
    # vscode-extensions.nvarner.typst-lsp
    # typst-fmt
    # typst-lsp

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
  ];


  # https://nixos.wiki/wiki/Discord
  nixpkgs.overlays =
    let
      myOverlay = self: super: {
        discord =
          super.discord.override {
            # withVencord = true; }; #withOpenASAR = true;
            nss = super.nss_latest;
            withOpenASAR = true;
            #withVencord = true; # TODO: broken
          };

      };
    in
    [ myOverlay ];
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

  programs.neovim.vimAlias = true;
  programs.neovim.viAlias = true;

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
  # Pin channels to flake registry entries
  # lib.mapAttrs'
  # (name: value: {
  #   name = "nix/path/${name}";
  #   value.source = value.flake;
  # })
  # config.nix.registry;


  programs.command-not-found.enable = false;
  #
  #  home-manager.users.samir = { pkgs, ... }: {
  #    home.stateVersion = "23.05";
  #    home.packages = with pkgs; [
  #      htop
  #    ];
  #
  #  };

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
  # system.copySystemConfiguration = true; # this is impure

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  # for an unattended server
  # system.autoUpgrade.enable = true;
  # system.autoUpgrade.allowReboot = true;
}

