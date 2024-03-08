# This is a minimal non-flake configuration.nix for a t2 MacBook (Intel CPU) running NixOS.
# NOTE: This file does not compile on it's own. It is a collection of patches for reference
# of the things you should add to your config.
# Made by Alina

# Add these channels to your system.
# channels:
# nixos https://nixos.org/channels/nixos-23.11
# nixos-hardware https://github.com/NixOS/nixos-hardware/archive/master.tar.gz
# optionally:
# home-manager https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz

{ config, lib, pkgs, ... }:

{
  imports = [
    <nixos-hardware/apple>
    <nixos-hardware/apple/t2>
    <nixos-hardware/common/cpu/intel>
    <nixos-hardware/common/pc/laptop/ssd>
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];
  # t2linux specific Nix cache
  nix.settings = {
    trusted-substituters = [
      "https://t2linux.cachix.org"
    ];
    trusted-public-keys = [
      "t2linux.cachix.org-1:P733c5Gt1qTcxsm+Bae0renWnT8OLs0u9+yfaK2Bejw="
    ];
  };


    # iGPU
  hardware.apple-t2.enableAppleSetOsLoader = true;

  # Apple Wireless brcm firmware
  hardware.firmware = [
    (pkgs.stdenvNoCC.mkDerivation {
      name = "brcm-firmware";
      buildCommand = ''
        dir="$out/lib/firmware"
        mkdir -p "$dir"
        cp -r ${./firmware}/* "$dir"
      '';
    })
  ];

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;

  # OpenGL & packages for intel integrated graphics
  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = with pkgs; [
    vaapiIntel
    libvdpau-va-gl
    intel-media-driver
    intel-ocl
  ];
  boot.initrd.kernelModules = [ "applespi" "spi_pxa2xx_platform" "intel_lpss_pci" "applesmc" ];

  # Enable sound.
  sound.enable = true;

  # Audio works better with PipeWire
  hardware.pulseaudio.enable = lib.mkForce false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  # also I use auto-cpufreq for frequency scaling to tame the fans, with default settings
  # if you intend to use gnome you will have to disable this to get auto-cpufreq to work
  # disable GNOME power profiles interfering with auto-cpufreq
  services.power-profiles-daemon.enable = false;

}
