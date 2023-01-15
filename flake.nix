{
  description = "dpaetzel's NixOS configuration";

  # From: https://github.com/srid/nixos-config/blob/master/flake.nix
  # “To update nixpkgs (and thus NixOS), pick the nixos-unstable rev from
  # https://status.nixos.org/ This ensures that we always use the official nix
  # cache.”
  # inputs.nixpkgs.url = "github:NixOS/nixpkgs/5aaed40d22f0d9376330b6fa413223435ad6fee5";
  inputs = {
    nixpkgs.url =
      # "github:NixOS/nixpkgs/6d8215281b2f87a5af9ed7425a26ac575da0438f";
      # 2022-04-05
      # "github:NixOS/nixpkgs/bc4b9eef3ce3d5a90d8693e8367c9cbfc9fc1e13";
      # 2022-06-22
      # "github:NixOS/nixpkgs/0d68d7c857fe301d49cdcd56130e0beea4ecd5aa";
      # 2022-11-10
      "github:NixOS/nixpkgs/093268502280540a7f5bf1e2a6330a598ba3b7d0";
      # 2022-12-29
      # e182da8622a354d44c39b3d7a542dc12cd7baa5f

    emanote.url = "github:srid/emanote/master";
    # This leads to a very long compile.
    # emanote.inputs.nixpkgs.follows = "nixpkgs";

    neuron.url = "github:srid/neuron/master";
    # This seems to be broken?
    # neuron.inputs.nixpkgs.follows = "nixpkgs";

    mach-nix.url = "github:DavHau/mach-nix/master";
    mach-nix.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";

    overlays.url = "github:dpaetzel/overlays/master";
    overlays.inputs.nixpkgs.follows = "nixpkgs";

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
          (self: super: {
            nix-direnv = super.nix-direnv.override { enableFlakes = true; };
          })
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

      # General purpose Python shell I use everyday (I have an alias that runs
      # `nix run github:dpaetzel/nixos-config#pythonShell -- --profile=p`).
      apps.${system}.pythonShell = let
        python = pkgs.python310.withPackages (ps: with ps; [
          deap
          graphviz
          ipython
          matplotlib
          numpy
          pandas
          scikit-learn
          scipy
          seaborn
          toolz
          tqdm
        ]);
      in {
        type = "app";
        program = "${python}/bin/ipython";
      };
    };
}
