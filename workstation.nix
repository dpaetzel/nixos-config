{ config, pkgs, ... }:

{
  virtualisation.docker.enable = true;
  virtualisation.virtualbox.host.enable = true;
}

