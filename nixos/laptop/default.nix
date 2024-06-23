{
  lib,
  config,
  options,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.laptop;
in
{
  imports = [ ];

  options.laptop.enable = mkEnableOption "Enable laptop stuff";

  config = mkIf cfg.enable {
    services.libinput = {
      enable = true;
      touchpad = {
        scrollMethod = "twofinger";
        disableWhileTyping = true;
      };
    };

    # Proper backlight management.
    programs.light.enable = true;
    # Required to be able to use `light`.
    users.extraUsers.david.extraGroups = [ "video" ];

    services.logind = {
      lidSwitch = "suspend";
      lidSwitchDocked = "ignore";
      lidSwitchExternalPower = "ignore";
    };

    # Power management/saving for laptops.
    services.tlp.enable = true;
  };
}
