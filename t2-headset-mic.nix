# https://github.com/lemmyg/t2-apple-audio-dsp/blob/mic/install.sh

{ config, pkgs, ... }:
let
  json = pkgs.formats.json {};
  pw_mic_config = {

  };
in
{
  environment.etc."pipewire/pipewire.conf.d/10-t2_mic.conf" = {
      source = json.generate "10-t2_mic.conf" pw_mic_config;
  };
#   systemd.user.services."pipewire-source-rnnoise" = {
#     environment = { LADSPA_PATH = "${pkgs.rnnoise-plugin}/lib/ladspa"; };
#     description = "Noise canceling source for pipewire";
#     wantedBy = ["pipewire.service"];
#     script = "${pkgs.pipewire}/bin/pipewire -c source-rnnoise.conf";
#     enable = true;
#     path = with pkgs; [pipewire rnnoise-plugin];
#   };
}
