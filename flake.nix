{
  description = "dpaetzel's NixOS configuration";

  # From: https://github.com/srid/nixos-config/blob/master/flake.nix
  # “To update nixpkgs (and thus NixOS), pick the nixos-unstable rev from
  # https://status.nixos.org/ This ensures that we always use the official nix
  # cache.”
  # inputs.nixpkgs.url = "github:NixOS/nixpkgs/5aaed40d22f0d9376330b6fa413223435ad6fee5";
  inputs = {
    # TODO add deploy
    # deploy.url = "github:serokell/deploy-rs";
    mach-nix.url = "github:DavHau/mach-nix/master";
    neuron.url = "github:srid/neuron/master";
    emanote.url = "github:srid/emanote/master";
    nixpkgs.url =
      # "github:NixOS/nixpkgs/6d8215281b2f87a5af9ed7425a26ac575da0438f";
      # 2022-04-05
      # "github:NixOS/nixpkgs/bc4b9eef3ce3d5a90d8693e8367c9cbfc9fc1e13";
      # 2022-06-22
      "github:NixOS/nixpkgs/0d68d7c857fe301d49cdcd56130e0beea4ecd5aa";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    overlays.url = "github:dpaetzel/overlays/master";

    # TODO Maybe use these
    # home-manager.url = "github:nix-community/home-manager";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # emacs-overlay.url = "github:nix-community/emacs-overlay";
    # nix-doom-emacs.url = "github:vlaci/nix-doom-emacs";
  };

  outputs = inputs@{ self, nixpkgs, nixos-hardware, overlays, ... }:

    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        # Add nixpkgs overlays and config here. They apply to system and
        # home-manager builds.
        config = {
          android_sdk.accept_license = true;
          oraclejdk.accept_license = true;
          allowUnfree = true;
          chromium.pulseSupport = true;
          # permittedInsecurePackages = [
          #   # TODO I'm not sure yet which package requires this, we probably just
          #   # want to remove that then
          #   "spidermonkey-38.8.0"
          # ];
        };
        overlays = with overlays; [
          # khal
          yapfToml
          (self: super: { nix-direnv = super.nix-direnv.override { enableFlakes = true; }; })
        ];
      };
    in {
      nixosConfigurations.sokrates = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        specialArgs = { inherit pkgs system inputs; };
        modules = [
          # Not quite my t470 but close enough.
          nixos-hardware.nixosModules.lenovo-thinkpad-t470s
          ./sokrates/configuration.nix
          ./sokrates/packages.nix

          ./sokrates/cachix.nix
          ./common.nix
          ./desktop.nix
          ./theme.nix
          ./workstation.nix
        ];
      };
    };
}
