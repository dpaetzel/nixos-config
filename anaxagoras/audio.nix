{ pkgs, lib, inputs, config, ... }:

{
  # https://github.com/musnix/musnix#base-options
  musnix = {
    enable = true;
    kernel.realtime = true;

    # I don't think I want an ALSA sequencer.
    alsaSeq.enable = false;

    # Musnix is weird, this only seems to work as of 2024-06 because I exposed
    # the overlays via a Flake output.
    #
    # Also, there was once(?) a problem with NVidia (probably because the driver
    # is too *new* if I read this correctly?). Seems to be this issue
    # https://github.com/musnix/musnix/issues/127 . I solved this by choosing
    # the `_latest` kernel on 2023-10-30 but I don't know why that works or
    # whether it is still relevant.
    kernel.packages = pkgs.linuxPackages_6_9_rt;


    # 00:1b.0 Audio device: Intel Corporation 9 Series Chipset Family HD Audio Controller
    # 01:00.1 Audio device: NVIDIA Corporation GK104 HDMI Audio Controller (rev a1)
    soundcardPciId = "00:1b.0";
    # TODO Maybe use rtirq options https://github.com/musnix/musnix#base-options
    # https://nixos.wiki/wiki/JACK
    # “magic to me” — To me as well.
    # rtirq = {
    #   # highList = "snd_hrtimer";
    #   resetAll = 1;
    #   prioLow = 0;
    #   enable = true;
    #   nameList = "rtc0 snd";
    # };
  };

  environment.systemPackages = with pkgs; [
      jack-example-tools
      alsa-scarlett-gui
  ];
}


# TODO (2023-10-30) Work through
# https://wiki.linuxaudio.org/wiki/system_configuration#rtirq, esp. the script
# checking my config seems nice.
#
# https://wiki.linuxaudio.org/wiki/system_configuration#rtirq
#Screensavers
# When doing audio work screensavers tend to get in the way. So you might want to consider uninstalling them. You will find then that X is still trying to blank your screen after a while. To completely disable this you could add the following lines to your .profile file:
# xset -dpms
# xset s off
# setterm -powersave off -blank 0
