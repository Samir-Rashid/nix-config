{ config, pkgs, ...}:
let
  baseconfig = { allowUnfree = true; };
  unstable = import <nixos-unstable> { config = baseconfig; };
  # bruh = import <nixpkgs-old> { config = baseconfig; };
in {
  environment.systemPackages = with pkgs; [
    #unstable.google-chrome
    unstable.signal-desktop
    # bruh.segger-jlink
  ];
}
