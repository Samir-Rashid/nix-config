# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

# TODO: add dotfiles
# 	external monitor brightness
# add busybox, cope, toybox
{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      "${builtins.fetchGit { url = "https://github.com/kekrby/nixos-hardware.git"; }}/apple/t2"
<home-manager/nixos> # TODO: switch to flake + home manager
    ];

# system.autoUpgrade.channel = "https://nixos.org/channels/nixos-21.05/";
  hardware.facetimehd.enable = lib.mkDefault
    (config.nixpkgs.config.allowUnfree or false);

  #services.mbpfan.enable = lib.mkDefault true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  #boot.initrd.kernelModules = [ "applespi" "spi_pxa2xx_platform" "intel_lpss_pci" "applesmc" ];
  boot = {
    # kernelPackages = pkgs.linuxPackages_4_3;
    kernelParams = [
    # https://help.ubuntu.com/community/AppleKeyboard
    # https://wiki.archlinux.org/index.php/Apple_Keyboard
    "hid_apple.fnmode=1"
    "hid_apple.iso_layout=0"
    "hid_apple.swap_opt_cmd=1"
  ];
  };
 boot.tmp.cleanOnBoot = true;
         nixpkgs.config.segger-jlink.acceptLicense = true;

services.udev.packages = [
      (pkgs.writeTextFile {
        name = "99-ftdi.rules";
        text = ''
		ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6015", MODE="0666"
        '';
        destination = "/etc/udev/rules.d/99-ftdi.rules";
      })
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
  services.power-profiles-daemon.enable = false; # gnome enables this, which makes tlp incompatible
  services.tlp.enable = true;
  powerManagement.powertop.enable = true;

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  nixpkgs.config.allowUnfree = true;
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.hostName = "nixos";

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
  };

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
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  security.polkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  hardware.bluetooth.enable = true;
	services.usbmuxd.enable = true;
  
services.openvpn.servers = {
    homeVPN    = { config = '' config /home/samir/homeVPN.conf ''; }; # systemctl start openvpn-homeVPN.service
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
#  users.mutableUsers = false; # Make sure the only way to add users/groups is to change this file
  users.users.samir = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      firefox
      thunderbird
      ungoogled-chromium
      tree
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # toybox, busybox
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
	iwd
	openvpn
	gnu-efi
	ntfs3g
	exfat
  gnumake
  ffmpeg
  nmap
  pciutils
  # usb
  usbutils
  usbrip
  usbtop
  usbview
  libusb

busybox
  acpi
  psensor
  delta
    git
    gh
    glxinfo
#    nrf-command-line-tools
#nrfconnect
    curl
    neovim
#    segger-jlink
    htop
    discord
    keepassxc
    signal-desktop
    cider # apple music
    vlc
    epiphany
    bitwarden
    obsidian
    mpv
    obs-studio
    blender
    kdenlive
    slack
    timeshift
	jellyfin-media-player
	synology-drive-client

	  # shell utilities
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
	  croc
	  gocryptfs

	  htop
	  gotop
	  btop

  texlive.combined.scheme-basic
    (vscode-with-extensions.override {
    vscodeExtensions = with vscode-extensions; [
      bbenoist.nix
      ms-python.python
      ms-azuretools.vscode-docker
      ms-vscode-remote.remote-ssh
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "remote-ssh-edit";
        publisher = "ms-vscode-remote";
        version = "0.47.2";
        sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
      }
    ];
  })
  ];


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

