{ config, pkgs, ...}:
let
  baseconfig = { allowUnfree = true; };
  unstable = import <nixos-unstable> { config = baseconfig; };
  bruh = import <nixpkgs-2305> { config = baseconfig; };
in {
  environment.systemPackages = with pkgs; [
    #unstable.google-chrome
    unstable.signal-desktop
    bruh.segger-jlink
  ];
}
