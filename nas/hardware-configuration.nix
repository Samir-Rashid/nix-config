# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  ### Internal drive is managed by disko ###
  #  fileSystems."/" =
  #    { device = "/dev/disk/by-uuid/46b46ae9-32cf-4941-809b-f6781e4d1560";
  #      fsType = "btrfs";
  #      options = [ "subvol=root" ];
  #    };
  #
  #  fileSystems."/home" =
  #    { device = "/dev/disk/by-uuid/46b46ae9-32cf-4941-809b-f6781e4d1560";
  #      fsType = "btrfs";
  #      options = [ "subvol=home" ];
  #    };
  #
  #  fileSystems."/nix" =
  #    { device = "/dev/disk/by-uuid/46b46ae9-32cf-4941-809b-f6781e4d1560";
  #      fsType = "btrfs";
  #      options = [ "subvol=nix" ];
  #    };
  #
  #  fileSystems."/boot" =
  #    { device = "/dev/disk/by-uuid/478C-83BD";
  #      fsType = "vfat";
  #    };

  # external drive
  fileSystems."/mnt/sda1" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp2s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
