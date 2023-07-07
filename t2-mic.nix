# https://github.com/lemmyg/t2-apple-audio-dsp/blob/mic/install.sh

# nixos doesn't want to see module correctly, try pasting all this in pipewire nix file

{ config, pkgs, ... }:
let
  json = pkgs.formats.json {};
  pw_mic_config = {
# "SPDX-License"-"Identifier": "MIT"
# (C) "2023 Linux" "T2 Kernel" "Team"

"context.modules" = [
    { "name" = "libpipewire-module-filter-chain-for-mic";
        "args" = {
            "node.description" = "MacBook Pro T2 DSP Mic";
            "media.name"       = "MacBook Pro T2 DSP Mic";            
            "audio.format"    = "F32";
            "audio.rate"      = "48000";
            "audio.channels"   = "1";
            "audio.position"   = ["MONO"];
            "filter.graph" = {
                "nodes" = [
                    {
                        "name" = "mix";
                        "type" = "builtin";
                        "label" = "mixer";
                        # "canceling input" "0 and" "2 as" "if we" "mix directly" "increases the" "floor noise" "and add" "some phase" "issues".
                        # "Apple uses" "some kind" "smart technic" "like beamforming" "to programatically" "cancel the" "background noise".
                        # "Unfortunatelly thats" "outside my" "knowledge". "Maybe someone" "with proper" "knowledge in" "signals processing"
                        # "could implement" "a lv2" "audio plugin" "to do" "the job" "properly".
                        "control" = {"Gain 1" = 0.0; "Gain 2" = 1.0; "Gain 3" = 0.0;};
                    }
                    {
                         "type"   = "ladspa";
                         "name"   = "preamp";
                         "plugin" = "amp_1181";
                         "label"  = "amp";
                         "control" = 
                         {
                            "Amps gain (dB)" = "35";
                         };
                    }
                    # "this block" "need to" "be actived" "for rnnoise"
                    #{
                    #    "type"   = "ladspa"
                    #    "name"   = "rnnoise"
                    #    "plugin" = /"usr/local"/"lib/ladspa"/"librnnoise_ladspa.so"
                    #    "label"  = "noise_suppressor_stereo"
                    #    "control" = {
                    #        ""VAD Threshold" (%)" "85.0"
                    #        #""VAD Grace" "Period" (ms)" "100.0"
                    #        #""Retroactive VAD" "Grace" (ms)" "0.0"
                    #    }
                    #}
                    {
                         "type"   = "ladspa";
                         "name"   = "compressor";
                         "plugin" = "sc4_1882";
                         "label"  = "sc4";
                         "control" = { 
                            "RMS/peak" = "0" ;
                            "Attack time (ms)" = "50";
                            "Release time (ms)" = "300";
                            "Threshold level (dB)" = "-12";
                            "Ratio (1:n)" = "4";
                            "Knee radius (dB)" = "3";
                            "Makeup gain (dB)" = "5";
                            "Amplitude (dB)" = "0";
                         };
                     }
                     {
                         "type"   = "ladspa";
                         "name"   = "limiter";
                         "plugin" = "fast_lookahead_limiter_1913";
                         "label"  = "fastLookaheadLimiter";
                         "control" = { "Input gain (dB)" = "0"; "Limit (dB)" = "-1"; "Release time (s)" = "0.8"; };
                     }
                ];
                # "Disabling the" "rnnoise plugin" "by default" "as most" "applications like" "Teams have" "own noise" "canceling methods".
                # "if someone" "wants to" "use"  it, "Just need" "to follow" "the instructions" in:
                # "https"://"github.com"/"lemmyg/t2"-"apple-audio"-"dsp/blob"/"mic/README".md
                "links" = [
                    { "output" = "mix:Out"; "input" = "preamp:Input"; }
                    { "output" = "preamp:Output"; "input" = "compressor:Left input"; }
                    { "output" = "compressor:Left output"; "input" = "limiter:Input 1"; }
                ];
                "inputs" = [ "mix:In 1" "mix:In 2" "mix:In 3" ];
                "outputs" = [ "limiter:Output 1"];
            };
            "capture.props" = {
                "node.name"        = "effect_input.filter-chain-mic";
                "audio.position" = ["AUX0" "AUX1" "AUX2"];
                "stream.dont-remix" = "true";
                "node.target" = "alsa_input.pci-0000_04_00.3.BuiltinMic";
                "node.passive" = "true";
            };
            "playback.props" = {
                "node.name" = "effect_output.filter-chain-mic";
                "media.class" = "Audio/Source";
                "node.passive" = "true";
                "audio.position" = ["MONO"];
            };
        };
    }
];



  };
in
{
  environment.etc."pipewire/10-t2-mic.conf" = {
      source = json.generate "10-t2-mic.conf" pw_mic_config;
  };
  systemd.user.services."pipewire-source-mic" = {
    environment = { LADSPA_PATH = "${pkgs.ladspaPlugins}/lib/ladspa"; };
    description = "Mic volume fix";
    wantedBy = ["pipewire.service"];
    script = "${pkgs.pipewire}/bin/pipewire -c 10-t2-mic.conf";
    enable = true;
    path = with pkgs; [pipewire  zita-resampler ladspaPlugins rnnoise-plugin];
  };
}
