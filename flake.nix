{
  # TODO Maybe setup cachix for this
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
      # "github:NixOS/nixpkgs/093268502280540a7f5bf1e2a6330a598ba3b7d0";
      # 2023-01-15
      # "github:NixOS/nixpkgs/befc83905c965adfd33e5cae49acb0351f6e0404";
      # 2023-02-09
      # "github:NixOS/nixpkgs/fab09085df1b60d6a0870c8a89ce26d5a4a708c2";
      # 2023-03-10
      # "github:dpaetzel/nixpkgs/1e2590679d0ed2cee2736e8b80373178d085d263";
      "github:dpaetzel/nixpkgs/dpaetzel/nixos-config";

    emanote.url = "github:srid/emanote";
    # This leads to a very long compile.
    emanote.inputs.nixpkgs.follows = "nixpkgs";

    neuron.url = "github:srid/neuron/master";
    # This seems to be broken?
    # neuron.inputs.nixpkgs.follows = "nixpkgs";

    # mach-nix.url = "github:DavHau/mach-nix/master";
    # mach-nix.inputs.nixpkgs.follows = "nixpkgs";

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
          allowBroken = true;
          chromium.pulseSupport = true;
          # permittedInsecurePackages = [
          #   # TODO I'm not sure yet which package requires this, we probably just
          #   # want to remove that then
          #   "spidermonkey-38.8.0"
          # ];
        };
        overlays = with overlays; [
          # https://github.com/NixOS/nixpkgs/issues/205014#issuecomment-1402380175
          (self: super: {
            khal = super.khal.overridePythonAttrs (_ : { doCheck = false; });
          })
          yapfToml
          (self: super: {
            nix-direnv = super.nix-direnv.override { enableFlakes = true; };
          })
          # (self: super: {
          #   steam = super.steam.override { extraPkgs = pkgs: with pkgs; [ super.openssl ]; };
          # })
        ];
      };

      # General purpose Python shell I use everyday (I have an alias that runs
      # `nix run github:dpaetzel/nixos-config#pythonShell -- --profile=p`).
      pythonEnv = let
        cmdstanpy = pkgs.python.pkgs.buildPythonPackage rec {
          pname = "cmdstanpy";
          version = "1.0.7";

          propagatedBuildInputs = with pkgs.python.pkgs; [ numpy pandas tqdm ujson ];

          patches =
            [ "${self}/0001-Remove-dynamic-cmdstan-version-selection.patch" ];

          postPatch = ''
            sed -i \
              "s|\(cmdstan = \)\.\.\.|\1\"${pkgs.cmdstan}/opt/cmdstan\"|" \
              cmdstanpy/utils/cmdstan.py
          '';

          doCheck = false;

          src = pkgs.python.pkgs.fetchPypi {
            inherit pname version;
            sha256 = "sha256-AyzbqfVKup4pLl/JgDcoNKFi5te4QfO7KKt3pCNe4N8=";
          };
        };

      in pkgs.python310.withPackages (ps:
        with ps; [
          # pkgs.cmdstan # Rather large.
          # cmdstanpy
          click
          deap
          graphviz
          ipython
          matplotlib
          numpy
          pandas
          requests
          scikit-learn
          scipy
          seaborn
          tabulate # For to_markdown of pandas DataFrames.
          toolz
          tqdm
          xlrd
        ]);
    in {
      nixosConfigurations.sokrates = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        specialArgs = { inherit pkgs system inputs pythonEnv; };
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

      nixosConfigurations.iso = nixpkgs.lib.nixosSystem {
        inherit system pkgs;
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ({ pkgs, ... }: {
            environment.systemPackages = [ pkgs.inxi pkgs.hwinfo ];
          })
        ];
      };

      # Expose the Python shell.
      apps.${system}.pythonShell = {
        type = "app";
        program = "${pythonEnv}/bin/ipython";
      };
    };
}
